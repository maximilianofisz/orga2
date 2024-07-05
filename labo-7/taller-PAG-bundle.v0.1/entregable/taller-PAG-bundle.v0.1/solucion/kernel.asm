; ** por compatibilidad se omiten tildes **
; ==============================================================================
; TALLER System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
; ==============================================================================

%include "print.mac"

global start


; COMPLETAR - Agreguen declaraciones extern según vayan necesitando
extern GDT_DESC
extern IDT_DESC
extern idt_init
extern pic_reset
extern pic_enable
extern pit_config
extern copy_page
extern mmu_init_task_dir
extern screen_draw_layout
extern mmu_init_kernel_dir


; COMPLETAR - Definan correctamente estas constantes cuando las necesiten
%define CS_RING_0_SEL 0x08  ; Esto son indices en la gdt, deben ser offsets no indices! (momento high level btw)
%define DS_RING_0_SEL 0x18  ; 

BITS 16
;; Saltear seccion de datos
jmp start

;;
;; Seccion de datos.
;; -------------------------------------------------------------------------- ;;
start_rm_msg db     'Iniciando kernel en Modo Real'
start_rm_len equ    $ - start_rm_msg

color_terminal db 00001010b

start_pm_msg db     'Iniciando kernel en Modo Protegido'
start_pm_len equ    $ - start_pm_msg

;;
;; Seccion de código.
;; -------------------------------------------------------------------------- ;;

;; Punto de entrada del kernel.
BITS 16
start:
    ; COMPLETAR - Deshabilitar interrupciones
    cli
    ; completo


    ; Cambiar modo de video a 80 X 50
    mov ax, 0003h
    int 10h ; set mode 03h
    xor bx, bx
    mov ax, 1112h
    int 10h ; load 8x8 font

    ; COMPLETAR - Imprimir mensaje de bienvenida - MODO REAL
    ; (revisar las funciones definidas en print.mac y los mensajes se encuentran en la
    ; sección de datos)

    print_text_rm start_rm_msg, start_rm_len, color_terminal, 0, 0
    ; completo

    ; COMPLETAR - Habilitar A20
    ; (revisar las funciones definidas en a20.asm)
    call A20_enable
    ; completo

    ; COMPLETAR - Cargar la GDT
    lgdt [GDT_DESC]
    ; load global descriptor table, se utiliza para cargar la dirección base y el limite de la GDT en el registro GDTR
    ; Indica una estructura de datos que contiene los descriptores de segmento de la memoria
    ; Se inicializa en gdt.c
    ; completo


    ; COMPLETAR - Setear el bit PE del registro CR0
    ; El estado del cr0 aca es = 00000010 (00000000000000000000000000010000). podemos tocar ese binario y cargarlo aca si necesitaramos tocar varias cosas, sino, inc basta
    mov eax, cr0
    inc eax
    mov cr0, eax
    ; completo
    ; comentario: el bit PE es el bit 0 del registro CR0, que indica si el procesador está en modo protegido o real. Si está en modo protegido, PE = 1, sino PE = 0
    ; por defecto el procesador arranca en modo real, por lo que PE = 0. Para pasar a modo protegido, se debe setear PE = 1


    ; COMPLETAR - Saltar a modo protegido (far jump)
    ; (recuerden que un far jmp se especifica como jmp CS_selector:address)
    ; Pueden usar la constante CS_RING_0_SEL definida en este archivo
    jmp CS_RING_0_SEL:modo_protegido


BITS 32
modo_protegido:
    ; COMPLETAR - A partir de aca, todo el codigo se va a ejectutar en modo protegido
    ; Establecer selectores de segmentos DS, ES, GS, FS y SS en el segmento de datos de nivel 0

    mov ax, DS_RING_0_SEL
    mov ds, ax ; DS = Data Segment
    mov es, ax ; ES = Extra Segment
    mov gs, ax ; GS = General Segment
    mov fs, ax ; FS = Extra Segment
    mov ss, ax ; SS = Stack Segment

    ; Pueden usar la constante DS_RING_0_SEL definida en este archivo

    ; COMPLETAR - Establecer el tope y la base de la pila
    mov esp, 0x25000
    mov ebp, esp


    ; COMPLETAR - Imprimir mensaje de bienvenida - MODO PROTEGIDO
    print_text_pm start_pm_msg, start_pm_len, color_terminal, 0, 0

    ; inicializar paginacion, page directory
    call mmu_init_kernel_dir

    mov eax, cr3
    or eax, 0x00025000
    mov cr3, eax
    
    ; COMPLETAR - Inicializar pantalla
    call screen_draw_layout
    
    ; activar el bit de paginacion en cr0
    mov eax, cr0
    or eax, 0x80000000 ; bit 31 activa la paginacion 
    mov cr0, eax

    ; Inicializacion de la idt y carga en idtr
    call idt_init
    lidt [IDT_DESC]



    ; Inicalizacion de pics e interrupciones
    call pic_reset
    call pic_enable

    ; configuracion de pit

    call pit_config
    
    ; arrancar interrupts
    sti

    ; test de syscalls
    nop

    int 0x58

    nop ; post int eax debe valer 58

    int 0x62

    nop ; post int eax debe valer 62

    ; test init task
    mov eax, cr3
    push eax ; guardamos el cr3 del kernel
    push 0x18000
    call mmu_init_task_dir
    
    mov cr3, eax ; cargamos el cr3 de la tarea que nos devolvio mmu_init_task_dir

    ; test escritura on demand 1
    mov eax, 88
    mov [0x7000000], eax

    ; test escritura on demand 2
    mov eax, 14
    mov [0x7000001], eax

    pop eax;pop del 18k
    pop eax ;pop del cr3 del kernel
    mov cr3, eax ; restablecer el cr3 viejo

    ; Ciclar infinitamente 
    mov eax, 0xFFFF
    mov ebx, 0xFFFF
    mov ecx, 0xFFFF
    mov edx, 0xFFFF
    jmp $

;; -------------------------------------------------------------------------- ;;

%include "a20.asm"
