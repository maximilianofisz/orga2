section .data
mascaraMataAlpha: times 2 dd 00000000_11111111_11111111_11111111b ; deja pasar los valores de rgb de un pixel y pone en 0 el alpha. 2 pixeles a la vez
;11111111
;00000000
; mascaras genericas para la funcion partida
;               <0         0    0>   ,      < 0          0    255>   ,   <0      255       255>  , <255      255      0>,    <255      0         0>,       null
mascaraBase: dq 00000000_00000000_00000000_00000000_00000000_11111111_00000000_11111111_11111111_11111111_11111111_00000000_11111111_00000000_00000000_00000000b



mascaraPoneT: db 0x80, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x80, 0x80
;                                                        32               96                 96                160              224                          null
mascaraResta1: dq 00000000_00000000_00000000_00000000_00100000_00000000_01100000_00000000_01100000_00000000_10100000_00000000_11100000_00000000_00000000_00000000b

;                                     4                  4                4                  4                 4               4
mascaraMult4: dq 00000000_00000000_00000011_00000000_00000011_00000000_00000011_00000000_00000011_00000000_00000011_00000000_00000011_00000000_00000000_00000000b







;               <0         0    128>   , < 0          0    255>   ,   <0      255       255>  , <255      255      0>,    <255      0         0>
;mascara1: dq 00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000b
mascara2: dd 11111111_00000000_00000000_11111111b
mascara3: dd 11111111_00000000_11111111_00000000b
mascara4: dd 11111111_11111111_00000000_00000000b
mascara5: dd 11111111_00000000_00000000_00000000b


section .text
global temperature_asm
;registros y pila: src[rdi], dst[rsi], width[rdx], height[rcx], src_row_size[r8], dst_row_size[r9]
;void temperature_asm(unsigned char *src,
;              unsigned char *dst,
;              int width,
;              int height,
;              int src_row_size,
;              int dst_row_size);

temperature_asm:
    push rbp
    mov rbp, rsp
    push r10
    push r11
    push r13
    push r14
    push r15

    movq xmm1, [mascaraMataAlpha] ; cargamos mascara una sola vez
    movd xmm4, [mascara1]
    movd xmm5, [mascara2]
    movd xmm6, [mascara3]
    movd xmm7, [mascara4]
    movd xmm8, [mascara5]


    mov eax, edx ; calculamos las iteraciones: (height * width) / 2
    mul ecx 

    mov ecx, 2
    div ecx
    mov rdx, rax 

    mov r10, rdx

    loop:
    cmp r10, 0
    je exit

    movq xmm0, [rdi] ; movemos dos pixeles del src a nuestro registro de trabajo

    pand xmm0, xmm1 ; aplicamos la mascara mata alpha, nos quedan nuestros dos pixeles pero con alpha en 00000000

    pmovzxbw xmm0, xmm0 ; extendemos a word, para poder hacer sumas horizontales Y, aparte, que no haya overflow

    phaddw xmm0, xmm0 ; doble suma horizontal, la suma de los componentes de los pixeles que ocupaban 64 bits post extend cada uno
                      ; ahora esta en los ultimos 32 bit del xmm0 (16 bit para cada uno)

    phaddw xmm0, xmm0

    pextrw r13, xmm0, 00000000b ; extraemos el valor de sum1 a r13 (la suma de los componentes del primer pixel)

    pextrw r14, xmm0, 00000001b ; extraemos el valor de sum2 a r14 (la suma de los componentes del segundo pixel)


    
    ; Dividiamos por 3 las sumas para tener t
    mov ecx, 3

    mov rax, r13
    xor rdx, rdx
    div ecx ; div por 3, nos queda t1 en rax
    mov r13, rax

    mov rax, r14
    xor rdx, rdx
    div ecx ; div por 3, nos queda t2 en rax
    mov r14, rax

    ; ahora tengo el t1 en r13 y el t2 en r14

    ;

 
    sig_pixeles: ; 
 
    add rdi, 8 ; adelante el src 2 pixeles
    dec r10 ; sig iteracion
    jmp loop

    exit:

    pop r15
    pop r14
    pop r13
    pop r11
    pop r10
    pop rbp
    ret
