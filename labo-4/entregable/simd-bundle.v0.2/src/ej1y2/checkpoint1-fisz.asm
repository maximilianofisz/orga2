
section .text

global dot_product_asm

; uint32_t dot_product_asm(uint16_t *p, uint16_t *q, uint32_t length);
; implementacion simd de producto punto
; registros y pila: x1[rdi], x2[rsi], x3[rdx], x4[rcx], x5[r8], x6[r9]
dot_product_asm:
	push rbp
	mov rbp, rsp

	mov ecx, 0; temp
	mov eax, 0; rta

	restart:
	cmp rdx, 0 ; En rdx tengo el contador y puedo procesar de a max 4 numeros, reducimos de a 4 cada iteracion hasta terminar
	je salida

	MOVQ xmm0, [rdi]; paso los primeros 4 numeros del vector A a xmm0 (4 numeros de 16bit = quadword)
	MOVQ xmm1, [rsi]; paso los primeros 4 numeros del vector B a xmm1

	PMOVZXWD xmm0, xmm0; Extiendo a 32 bit cada numero de 16 bit, para tener lugar cuando los multiplique (sin signo hice)
	PMOVZXWD xmm1, xmm1; same

	PMULLD xmm0, xmm1; multiplico cada double word (32 bit) entre si y guardo el low (aca esta lo mas importante, no?)

	PHADDD xmm0, xmm0; compactocompactocompactocompacto
	PHADDD xmm0, xmm0; pase de un xmm de 128 bits a la suma de los 4 paquetes en el lowest register del xmm

	movd ecx, xmm0; pase el lowest 32 a algun lado
	add eax, ecx; lo sumo a la rta
	sub rdx, 4 ; ya procese 4 numeros, lo descarto de la length
	add rdi, 8 ; quiero apuntarle a los proximos 4 numeros, 4 * 2bytes
	add rsi, 8
	jmp restart

	salida:
	pop rbp
	ret
