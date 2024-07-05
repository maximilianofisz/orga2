/* ** por compatibilidad se omiten tildes **
================================================================================
 TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================

  Definicion de funciones del manejador de memoria
*/

#include "mmu.h"
#include "i386.h"

#include "kassert.h"

static pd_entry_t* kpd = (pd_entry_t*)KERNEL_PAGE_DIR;
static pt_entry_t* kpt = (pt_entry_t*)KERNEL_PAGE_TABLE_0;

static const uint32_t identity_mapping_end = 0x003FFFFF;
static const uint32_t user_memory_pool_end = 0x02FFFFFF;

static paddr_t next_free_kernel_page = 0x100000;
static paddr_t next_free_user_page = 0x400000;

/**
 * kmemset asigna el valor c a un rango de memoria interpretado
 * como un rango de bytes de largo n que comienza en s
 * @param s es el puntero al comienzo del rango de memoria
 * @param c es el valor a asignar en cada byte de s[0..n-1]
 * @param n es el tamaño en bytes a asignar
 * @return devuelve el puntero al rango modificado (alias de s)
*/
static inline void* kmemset(void* s, int c, size_t n) {
  uint8_t* dst = (uint8_t*)s;
  for (size_t i = 0; i < n; i++) {
    dst[i] = c;
  }
  return dst;
}

/**
 * zero_page limpia el contenido de una página que comienza en addr
 * @param addr es la dirección del comienzo de la página a limpiar
*/
static inline void zero_page(paddr_t addr) {
  kmemset((void*)addr, 0x00, PAGE_SIZE);
}


void mmu_init(void) {}


/**
 * mmu_next_free_kernel_page devuelve la dirección física de la próxima página de kernel disponible. 
 * Las páginas se obtienen en forma incremental, siendo la primera: next_free_kernel_page
 * @return devuelve la dirección de memoria de comienzo de la próxima página libre de kernel
 */
paddr_t mmu_next_free_kernel_page(void) {
  paddr_t temp = next_free_kernel_page;
  next_free_kernel_page = next_free_kernel_page + PAGE_SIZE;
  return temp;
}

/**
 * mmu_next_free_user_page devuelve la dirección de la próxima página de usuarix disponible
 * @return devuelve la dirección de memoria de comienzo de la próxima página libre de usuarix
 */
paddr_t mmu_next_free_user_page(void) {
  paddr_t temp = next_free_user_page;
  next_free_user_page = next_free_user_page + PAGE_SIZE;
  return temp;
}

/**
 * mmu_init_kernel_dir inicializa las estructuras de paginación vinculadas al kernel y
 * realiza el identity mapping
 * @return devuelve la dirección de memoria de la página donde se encuentra el directorio
 * de páginas usado por el kernel
 */
paddr_t mmu_init_kernel_dir(void) {
  // vamos a poner en la posicion de arranque del directorio (0x25000) la primer entrada
  pd_entry_t pageDirectoryEntry; // El valor de la primer entry de PD (attrs = 3, addrs = 20 bits del directorio)
  kpd[0].pt = VIRT_PAGE_TABLE(KERNEL_PAGE_TABLE_0);
  kpd[0].attrs = MMU_P | MMU_W;
  
  pt_entry_t pageTableEntry;
  uint32_t ptIterator;
  for(ptIterator = 0; ptIterator < 1024; ptIterator++) { // iteramos para crear una page table llena
    kpt[ptIterator].page = ptIterator;
    kpt[ptIterator].attrs = MMU_P | MMU_W;
  }

  return (paddr_t)KERNEL_PAGE_DIR;
}

/**
 * mmu_map_page agrega las entradas necesarias a las estructuras de paginación de modo de que
 * la dirección virtual virt se traduzca en la dirección física phy con los atributos definidos en attrs
 * @param cr3 el contenido que se ha de cargar en un registro CR3 al realizar la traducción
 * @param virt la dirección virtual que se ha de traducir en phy
 * @param phy la dirección física que debe ser accedida (dirección de destino)
 * @param attrs los atributos a asignar en la entrada de la tabla de páginas
 */
void mmu_map_page(uint32_t cr3, vaddr_t virt, paddr_t phy, uint32_t attrs) {
  pd_entry_t* pd = (pd_entry_t*)CR3_TO_PAGE_DIR(cr3); // nos quedamos con los 20 bits mas significativos de cr3
  uint32_t pdIndex = VIRT_PAGE_DIR(virt); // nos quedamos con los 10 bits mas significativos de virt
  
  if((pd[pdIndex].attrs & MMU_P) == NULL) {
    pt_entry_t* ptNueva = (pt_entry_t*)mmu_next_free_kernel_page();
    zero_page(ptNueva);
    pd[pdIndex].attrs = MMU_P | MMU_U | MMU_W;
    pd[pdIndex].pt = (uint32_t)ptNueva >> 12;
  }

  pt_entry_t* pt = (pt_entry_t*)MMU_ENTRY_PADDR(pd[pdIndex].pt); // mmu_entry_paddr se queda con los 20 bits mas significativos, la base
  uint32_t ptIndex = VIRT_PAGE_TABLE(virt); // nos quedamos con los 10 bits del medio de virt

  pt[ptIndex].attrs = attrs | MMU_P;
  pt[ptIndex].page = phy >> 12;

  tlbflush();
}



/**
 * mmu_unmap_page elimina la entrada vinculada a la dirección virt en la tabla de páginas correspondiente
 * @param virt la dirección virtual que se ha de desvincular
 * @return la dirección física de la página desvinculada
 */
paddr_t mmu_unmap_page(uint32_t cr3, vaddr_t virt) {
  pd_entry_t* pd = (pd_entry_t*)CR3_TO_PAGE_DIR(cr3); // nos quedamos con los 20 bits mas significativos de cr3
  uint32_t pdIndex = VIRT_PAGE_DIR(virt); // nos quedamos con los 10 bits mas significativos de virt


  pt_entry_t* pt = (pt_entry_t*)MMU_ENTRY_PADDR(pd[pdIndex].pt); // mmu_entry_paddr se queda con los 20 bits mas significativos, la base
  uint32_t ptIndex = VIRT_PAGE_TABLE(virt); // nos quedamos con los 10 bits del medio de virt

  pt[ptIndex].attrs = 0;

  tlbflush();

  return MMU_ENTRY_PADDR(pt[ptIndex].page);
}

#define DST_VIRT_PAGE 0xA00000
#define SRC_VIRT_PAGE 0xB00000

/**
 * copy_page copia el contenido de la página física localizada en la dirección src_addr a la página física ubicada en dst_addr
 * @param dst_addr la dirección a cuya página queremos copiar el contenido
 * @param src_addr la dirección de la página cuyo contenido queremos copiar
 *
 * Esta función mapea ambas páginas a las direcciones SRC_VIRT_PAGE y DST_VIRT_PAGE, respectivamente, realiza
 * la copia y luego desmapea las páginas. Usar la función rcr3 definida en i386.h para obtener el cr3 actual
 */
void copy_page(paddr_t dst_addr, paddr_t src_addr) {
  uint32_t cr3 = rcr3();

  mmu_map_page(cr3, SRC_VIRT_PAGE, src_addr, MMU_P | MMU_W);
  mmu_map_page(cr3, DST_VIRT_PAGE, dst_addr, MMU_P | MMU_W);

  uint32_t* src = SRC_VIRT_PAGE;
  uint32_t* dst = DST_VIRT_PAGE;

  uint32_t copyIterator;
  for(copyIterator = 0; copyIterator < 1024; copyIterator++) { 
    dst[copyIterator] = src[copyIterator];
  }

  mmu_unmap_page(cr3, SRC_VIRT_PAGE);
  mmu_unmap_page(cr3, DST_VIRT_PAGE);
  
}


 /**
 * mmu_init_task_dir inicializa las estructuras de paginación vinculadas a una tarea cuyo código se encuentra en la dirección phy_start
 * @pararm phy_start es la dirección donde comienzan las dos páginas de código de la tarea asociada a esta llamada
 * @return el contenido que se ha de cargar en un registro CR3 para la tarea asociada a esta llamada
 */
paddr_t mmu_init_task_dir(paddr_t phy_start) {

  pd_entry_t* taskPD = (pd_entry_t*)mmu_next_free_kernel_page(); // direccion del nuevo directorio para la tarea
  pd_entry_t* kernelPD = (pd_entry_t*)KERNEL_PAGE_DIR;

  taskPD[0] = kernelPD[0];

  mmu_map_page(taskPD, TASK_CODE_VIRTUAL, phy_start, MMU_P | MMU_U); //mappeamos la pagina 1 del codigo
  mmu_map_page(taskPD, TASK_CODE_VIRTUAL + PAGE_SIZE, phy_start + PAGE_SIZE, MMU_P | MMU_U); // mappeamos la pagina 2 del codigo

  paddr_t freeStackPage = mmu_next_free_user_page(); // direccion del nuevo stack para la tarea
  mmu_map_page(taskPD, TASK_CODE_VIRTUAL + (2 * PAGE_SIZE), freeStackPage, MMU_P | MMU_W | MMU_U); // mappeo  el stack (le saco la ultima pagina para que no colisione con shared??)

  mmu_map_page(taskPD, TASK_SHARED_PAGE, SHARED, MMU_P | MMU_U); // mappeo a la memoria compartida

  return taskPD;
}

// COMPLETAR: devuelve true si se atendió el page fault y puede continuar la ejecución 
// y false si no se pudo atender
bool page_fault_handler(vaddr_t virt) {
  print("Atendiendo page fault...", 0, 0, C_FG_WHITE | C_BG_BLACK);
  // Chequeemos si el acceso fue dentro del area on-demand
  // En caso de que si, mapear la pagina
  if(virt >= ON_DEMAND_MEM_START_VIRTUAL & virt <= ON_DEMAND_MEM_END_VIRTUAL) {
    uint32_t cr3 = rcr3();
    mmu_map_page(cr3, virt, ON_DEMAND_MEM_START_PHYSICAL, MMU_P | MMU_W | MMU_U);
    return true;
  }

  return false;
}
