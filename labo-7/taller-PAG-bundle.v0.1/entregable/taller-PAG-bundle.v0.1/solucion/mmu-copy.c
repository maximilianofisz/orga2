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
  paddr_t ret = next_free_kernel_page;
  next_free_kernel_page += PAGE_SIZE;
  return ret;
}

/**
 * mmu_next_free_user_page devuelve la dirección de la próxima página de usuario disponible
 * @return devuelve la dirección de memoria de comienzo de la próxima página libre de usuario
 */
paddr_t mmu_next_free_user_page(void) {
  paddr_t ret = next_free_user_page;
  next_free_user_page += PAGE_SIZE;
  return ret;
}

/**
 * mmu_init_kernel_dir inicializa las estructuras de paginación vinculadas al kernel y
 * realiza el identity mapping
 * @return devuelve la dirección de memoria de la página donde se encuentra el directorio
 * de páginas usado por el kernel
 */
paddr_t mmu_init_kernel_dir(void) {

  // recordar que cada dirección virtual de 32 bits se divide en 3 partes: PD, PT y offset

  // Inicializamos el directorio de páginas con identity mapping
  for (uint32_t i = 0; i < 1024; i++)
  {
    // kernel page directory attributes (P, R/W)
    // operacion OR bit a bit para setear los atributos de la entrada del directorio de paginas
    kpd[i].attrs = MMU_P | MMU_W; // Atributos validos, lectura/escritura.
    kpd[i].pt = MMU_ENTRY_PADDR((uint32_t)&kpt[i]) >> 12; // direccion fisica de la tabla de paginas shifteo 12 bits a la derecha para quedarme con los 20 bits menos significativos
  }

  // Ahora también inicializamos las tablas de paginas
  for (uint32_t i = 0; i < 1024; i++)
  {
    // kernel page table attributes (P, R/W)
    kpt[i].attrs = MMU_P | MMU_W; // Atributos validos, lectura/escritura.
    kpt[i].page = i; // identity mapping
  }
  
  return (paddr_t)kpd; // devolvemos la direccion fisica del directorio de paginas
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
  // recordar que cada dirección virtual de 32 bits se divide en 3 partes: PD, PT y offset

  // Obtenemos el índice del directorio de páginas y de la tabla de páginas
  uint32_t pd_index = VIRT_PAGE_DIR(virt);
  uint32_t pt_index = VIRT_PAGE_TABLE(virt);

  // Obtenemos la dirección física del directorio de páginas
  pd_entry_t* pd = (pd_entry_t*)CR3_TO_PAGE_DIR(cr3); // nos quedamos con los 20 bits más significativos para obtener la dirección física del directorio de páginas

  // Comprobar si la PDE está presente
  if (!(pd[pd_index].attrs & MMU_P)) {
    // Si no está presente, asignamos nueva tabla de páginas
    paddr_t new_pt = mmu_next_free_kernel_page();
    // inicializar la nueva tabla de páginas con ceros
    zero_page(new_pt);
    // Actualizar PDE con la nueva tabla de páginas
    pd[pd_index].attrs = MMU_P | MMU_W | MMU_U ; // present, read/write, user/supervisor
    pd[pd_index].pt = MMU_ENTRY_PADDR(new_pt) >> 12; // shift para tener los 20 bits menos significativos

}
  // Obtenemos la dirección física de la tabla de páginas
  pt_entry_t* pt = (pt_entry_t*)MMU_ENTRY_PADDR(pd[pd_index].pt << 12);

  // configuramos la entrada de la tabla de páginas
  pt[pt_index].attrs = attrs | MMU_P ; // me aseguro que el bit de presencia esté en 1
  pt[pt_index].page = phy >> 12; // Dirección fisica de la pagina

}

/**
 * mmu_unmap_page elimina la entrada vinculada a la dirección virt en la tabla de páginas correspondiente
 * @param virt la dirección virtual que se ha de desvincular
 * @return la dirección física de la página desvinculada
 */
paddr_t mmu_unmap_page(uint32_t cr3, vaddr_t virt) {
// bit present en 0, flush tlb
  
  // Obtenemos el índice del directorio de páginas y de la tabla de páginas
  uint32_t pd_index = VIRT_PAGE_DIR(virt);
  uint32_t pt_index = VIRT_PAGE_TABLE(virt);
  // Obtenemos la dirección física del directorio de páginas
  pd_entry_t* pd = (pd_entry_t*)CR3_TO_PAGE_DIR(cr3); // nos quedamos con los 20 bits más significativos para obtener la dirección física del directorio de páginas
  // Comprobar si la PDE está presente
  if (!(pd[pd_index].attrs & MMU_P)) {
    return 0;
  }

  // Obtenemos la dirección física de la tabla de páginas
  pt_entry_t* pt = (pt_entry_t*)MMU_ENTRY_PADDR(pd[pd_index].pt << 12);

  // Comprobar si la PTE está presente
  if (!(pt[pt_index].attrs & MMU_P)) {
    return 0;
  }

  // obtener la dirección física de la página
  paddr_t phy = pt[pt_index].page << 12;

  // Seleccionar la entrada como no presente
  pt[pt_index].attrs &= ~MMU_P;

  // flush tlb
  tlbflush();

  return phy;
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
}

 /**
 * mmu_init_task_dir inicializa las estructuras de paginación vinculadas a una tarea cuyo código se encuentra en la dirección phy_start
 * @pararm phy_start es la dirección donde comienzan las dos páginas de código de la tarea asociada a esta llamada
 * @return el contenido que se ha de cargar en un registro CR3 para la tarea asociada a esta llamada
 */
paddr_t mmu_init_task_dir(paddr_t phy_start) {
}

// COMPLETAR: devuelve true si se atendió el page fault y puede continuar la ejecución 
// y false si no se pudo atender
bool page_fault_handler(vaddr_t virt) {
  print("Atendiendo page fault...", 0, 0, C_FG_WHITE | C_BG_BLACK);
  // Chequeemos si el acceso fue dentro del area on-demand
  // En caso de que si, mapear la pagina
}
