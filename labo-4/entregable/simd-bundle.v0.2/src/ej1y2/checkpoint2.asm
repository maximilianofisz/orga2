section .rodata
mascaraValor: times 16 db 00001111b ; para convertir sets de 4 bits impares en 0000
mascaraIguales: db 0x00, 0x00, 0x00, 0x00, 0x04, 0x04, 0x04, 0x04, 0x08, 0x08, 0x08, 0x08, 0x0C, 0x0C, 0x0C, 0x0C ; pone 4 copias de etc etc
mascaraPrimerBit: times 4 dd 1; pone en 0 todos los bits de una dword excepto el primero, transformas quiza 1111111111 en 000000001 



section .text

global four_of_a_kind_asm

; uint32_t four_of_a_kind_asm(card_t *hands, uint32_t n);
;registros y pila: x1[rdi], x2[rsi], x3[rdx], x4[rcx], x5[r8], x6[r9]
; una carta = 1 byte, una mano = 4 bytes, el valor esta en el indice 0 (pares), el palo en el 1(impar)
four_of_a_kind_asm:
	push rbp
	mov rbp, rsp

	mov eax, 0; rta
	mov ecx, 0; rtatmp

	restart:
	cmp rsi, 0 ; En rsi tengo el contador y puedo procesar de a max 4 manos, reducimos de a 4 cada iteracion hasta terminar
	je salida


	movdqu xmm0, [rdi] ;muevo 4 manos a un xmm, queda lleno, aca va a estar los valores en 8 bits
	
	movdqu xmm7, [mascaraValor] ; cargo la mascara de valor, debug
	pand xmm0, xmm7 ; filtro los palos

	movdqu xmm1, xmm0 ; hago una copia para el shuffle y crear la mascara

	movdqu xmm8, [mascaraIguales] ; cargo la mascara de valores iguales, debug
	pshufb xmm1, xmm8 ; creo la mascara completa, con el patron de xmm8 y los valores de xmm1 (los originales de xmm0)

	pcmpeqd xmm0, xmm1 ; comparo cada mano contra la "mano ideal"

	; tengo los resultados en dword en xmm0 hasta aca

	movdqu xmm9, [mascaraPrimerBit] ; cargo la mascara de primer bit, debug
	pand xmm0, xmm9 ; le limpio todos los bits excepto el primero de cada dword para poder sumar sin tener overflow

	PHADDD xmm0, xmm0; compactocompactocompactocompacto
	PHADDD xmm0, xmm0; 

	movd ecx, xmm0; pase el lowest 32 a algun lado
	add eax, ecx; lo sumo a la rta

	add rdi, 16
	sub rsi, 4
	jmp restart


	salida:
	pop rbp
	ret

