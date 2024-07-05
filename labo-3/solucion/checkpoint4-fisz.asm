extern malloc
extern free
extern fprintf

section .data

section .text

global strCmp
global strClone
global strDelete
global strPrint
global strLen

; ** String **

; int32_t strCmp(char* a, char* b)
strCmp:
	push rbp ; alineado a 16
	mov rbp,rsp

	mov r14, rdi ;a
	mov r15, rsi ;b
	mov rsi, 0 ; iterador a

	cmp_loop:
	; movzx mueve y limpia el resto del registro con 0
	movzx r8, byte [r14 + rsi]
    movzx r9, byte [r15 + rsi]

	; final de a
	cmp r8, 0x00
	je cmp_check_final_b

	;final de b
	cmp r9, 0x00
	je cmp_check_final_a

	;letra es igual
	cmp r8, r9 
	je cmp_letra_igual

	;letra es menor
	jl cmp_a_menor

	;letra es mayor
	jmp cmp_a_mayor

	cmp_letra_igual:
	inc rsi
	jmp cmp_loop

	cmp_check_final_b:
	cmp r9, 0x00
	je cmp_iguales
	jmp cmp_a_menor

	cmp_check_final_a:
	cmp r8, 0x00
	je cmp_iguales
	jmp cmp_a_mayor

	cmp_iguales:
	mov rax, 0
	jmp cmp_exit

	cmp_a_menor:
	mov rax, 1
	jmp cmp_exit

	cmp_a_mayor:
	mov rax, -1
	jmp cmp_exit

	cmp_exit:
	pop rbp
	ret

; char* strClone(char* a)
strClone:
	push rbp ; alineado a 16
	mov rbp,rsp

	mov r12, rdi ; guardamos el input
	mov rsi, 0 ; contador y offset
	
	clone_loop_length:
	cmp byte [r12 + rsi], 0x00 ; comparar si en una direccion esta el terminador
	je clone_malloc_call

	add rsi, 1 
	jmp clone_loop_length

	clone_malloc_call:
	inc rsi ; lugar para el terminador
	mov rdi, rsi ; preparamos la longitud para malloc
	mov r15, rsi ; guardamos la longitud en algo no volatil
	call malloc

	mov r14, r15 ; guardamos la longitud
	mov r13, rax ; guardamos el dest de malloc
	mov rsi, 0 ; reiniciamos el contador

	clone_assign:
	cmp r14, rsi ; si el iterador y longitud son iguales nos vamos
	je clone_salida

	mov r15b, [r12 + rsi] ; guardamos la primer letra en algun lado
	mov [r13 + rsi], r15b ; la ponemos en el espacio donde nos dejo malloc

	inc rsi
	jmp clone_assign


	clone_salida:
	mov rax, r13
	pop rbp
	ret

; void strDelete(char* a)
strDelete:
	push rbp ; alineado a 16
	mov rbp,rsp

	call free

	pop rbp
	ret

; void strPrint(char* a, FILE* pFile)
strPrint:
	ret

; uint32_t strLen(char* a)
strLen:
	push rbp ; alineado a 16
	mov rbp,rsp

	mov rsi, 0 ; contador Y offset ja!
	
	restart:
	cmp byte [rdi + rsi], 0 ; comparar si en una direccion esta el terminador
	je salida

	add rsi, 1 
	jmp restart

	salida:
	mov rax, rsi
	pop rbp
	ret


