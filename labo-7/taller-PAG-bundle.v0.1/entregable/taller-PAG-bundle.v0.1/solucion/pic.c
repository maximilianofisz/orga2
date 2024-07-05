/* ** por compatibilidad se omiten tildes **
================================================================================
 TALLER System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================

  Rutinas del controlador de interrupciones.
*/
#include "pic.h"

#define PIC1_PORT 0x20
#define PIC2_PORT 0xA0

static __inline __attribute__((always_inline)) void outb(uint32_t port,
                                                         uint8_t data) {
  __asm __volatile("outb %0,%w1" : : "a"(data), "d"(port));
}
void pic_finish1(void) { outb(PIC1_PORT, 0x20); }
void pic_finish2(void) {
  outb(PIC1_PORT, 0x20);
  outb(PIC2_PORT, 0x20);
}

// COMPLETAR: implementar pic_reset()
void pic_reset() {
    outb(PIC1_PORT, 0x11); // ICW1: Inicia la inicialización
    outb(PIC1_PORT + 1, 0x20); // ICW2: Comienzo de interrupciones IRQ0-7 mapeadas al vector 32
    outb(PIC1_PORT + 1, 0x04); // ICW3: PIC1 tiene un esclavo en IRQ2
    outb(PIC1_PORT + 1, 0x01); // ICW4: Modo 8086

    outb(PIC2_PORT, 0x11); // ICW1: Inicia la inicialización
    outb(PIC2_PORT + 1, 0x28); // ICW2: Comienzo de interrupciones IRQ8-15 mapeadas al vector 40
    outb(PIC2_PORT + 1, 0x02); // ICW3: PIC2 es esclavo, conectado a IRQ2 de PIC1
    outb(PIC2_PORT + 1, 0x01); // ICW4: Modo 8086
}


void pic_enable() {
  outb(PIC1_PORT + 1, 0x00);
  outb(PIC2_PORT + 1, 0x00);
}

void pic_disable() {
  outb(PIC1_PORT + 1, 0xFF);
  outb(PIC2_PORT + 1, 0xFF);
}

void pit_config() {
  uint16_t resetValue = 0x8000; // Un pulso del pit cada 65536/2 pulsos del cpu (doble del default)

  outb(0x40, resetValue&0xff); // low byte
  outb(0x40, resetValue&0xFF00>>8); // high byt
}



