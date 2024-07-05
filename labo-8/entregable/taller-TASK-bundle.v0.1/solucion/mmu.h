/* ** por compatibilidad se omiten tildes **
================================================================================
 TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================

  Declaracion de funciones del manejador de memoria
*/

#ifndef __MMU_H__
#define __MMU_H__

#include "types.h"

typedef struct pd_entry_t {
  uint32_t attrs : 12;
  uint32_t pt : 20;
} __attribute__((packed)) pd_entry_t;

typedef struct pt_entry_t {
  uint32_t attrs : 12;
  uint32_t page : 20;
} __attribute__((packed)) pt_entry_t;

void mmu_init(void);

paddr_t mmu_next_free_kernel_page(void);

paddr_t mmu_next_free_user_page(void);

void mmu_map_page(uint32_t cr3, vaddr_t virt, paddr_t phy, uint32_t attrs);

paddr_t mmu_unmap_page(uint32_t cr3, vaddr_t virt);

paddr_t mmu_init_kernel_dir(void);

paddr_t mmu_init_task_dir(paddr_t phy_start);

bool page_fault_handler(vaddr_t virt);


// Índice del directorio de páginas (PDE)
// Acá lo que hacemos es shiftear y poner una máscara para quedarnos con los bits que nos interesan

#define VIRT_PAGE_DIR(x) (((x) >> 22) & 0x3FF) // shifteamos 22 bits a la derecha y nos quedamos con los 10 bits mas significativos (0x3FF = 1111111111 en binario)

// Índice de la tabla de páginas (PTE)
#define VIRT_PAGE_TABLE(x) (((x) >> 12) & 0x3FF) // shifteamos 12 bits a la derecha y nos quedamos con los 10 bits del medio (0x3FF = 1111111111 en binario)

// Offset dentro de la página
#define VIRT_PAGE_OFFSET(x) ((x) & 0xFFF) // nos quedamos con los 12 bits menos significativos con un AND (0xFFF = 111111111111 en binario)

// Dirección del directorio de páginas a partir de CR3
#define CR3_TO_PAGE_DIR(x) ((x) & 0xFFFFF000) // nos quedamos con los 20 bits más significativos con un AND (0xFFFFF000 = 11111111111111111111000000000000 en binario)

// Dirección física de una entrada en la tabla de páginas o directorio de páginas
#define MMU_ENTRY_PADDR(x) (x << 12)

#define PHY_TO_PAGE(x) (x / 4096) // dada una direccion fisica, nos devuelve el indice de la pagina fisica en la quedaria
#endif // __DEFINES_H__




#ifndef __MMU_H__
#endif //  __MMU_H__
