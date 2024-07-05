section .rodata
pxnegros: times 4 dd 11111111_00000000_00000000_00000000b 
pxblancos: times 4 dd 11111111_11111111_11111111_11111111b

section .text
global Pintar_asm

;void Pintar_asm(unsigned char *src,
;              unsigned char *dst,
;              int width,
;              int height,
;              int src_row_size,
;              int dst_row_size);

;registros y pila: src[rdi], dst[rsi], width[rdx], height[rcx], src_row_size[r8], dst_row_size[r9]

Pintar_asm:
	push rbp
	mov rbp, rsp
	push r12
	push r13

	movdqu xmm1, [pxnegros]
	movdqu xmm2, [pxblancos]

	mov r12, rdx ; R12 = ANCHO
	;-----pintar las dos primeras filas de pixeles de negro----- (hay que repetir esto al final)

	loop1:
	cmp r12, 0
	je salida1

	movdqu [rsi], xmm1 ; cargamos 2 pixeles
	add rsi, 16
	sub r12, 4
	jmp loop1
	
	salida1:
	
	; podria ser esto todo un unico loop? si
	mov r12, rdx ; R12 = ANCHO ; reestablecemos

	loop2:
	cmp r12, 0
	je salida2

	movdqu [rsi], xmm1
	add rsi, 16
	sub r12, 4
	jmp loop2
	
	salida2:
	;------------------------------------------------------------ ya esta apuntando al primer pixel de la 3ra fila

	;-----pintar los pixeles del medio de blanco----- 
	mov r13, rcx ; R13 = ALTURA
	sub r13, 4; le resto las dos filas de arriba y de abajo

	loop4:
	cmp r13, 0 ; si ya hice todas las filas de blanco me voy
	je salida4

	;-----pintar dos primeros pixeles de negro----- 

	movdqu [rsi], xmm1
	add rsi, 8

	; Aca iteramos los anchos para una misma altura (loop3)
	mov r12, rdx ; R12 = ANCHO
	sub r12, 4 ; ya le sacamos dos pixeles de atras y adelante !!!!!!

	loop3:
	cmp r12, 0
	je salida3

	movdqu [rsi], xmm2
	add rsi, 16
	sub r12, 4
	jmp loop3
	
	salida3:


	;-----pintar dos ultimos pixeles de negro----- 
	movdqu [rsi], xmm1 
	add rsi, 8 
	dec r13
	jmp loop4 ; aca terminamos los anchos de una altura, seguimos con la siguiente

	salida4:
	

	;------------------------------------------------------------ ya esta apuntando al primer pixel de la n-1 fila

	mov r12, rdx ; R12 = ANCHO
	;-----pintar las dos ultimas filas de pixeles de negro----- 

	loop5:
	cmp r12, 0
	je salida5

	movdqu [rsi], xmm1
	add rsi, 16
	sub r12, 4
	jmp loop5
	
	salida5:
	
	mov r12, rdx ; R12 = ANCHO ; reestablecemos

	loop6:
	cmp r12, 0
	je salida6

	movdqu [rsi], xmm1
	add rsi, 16
	sub r12, 4
	jmp loop6
	
	salida6:
	pop r13
	pop r12
	pop rbp
	ret
	


