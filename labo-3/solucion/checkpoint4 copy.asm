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
	ret

; char* strClone(char* a)
strClone:
	push rbp ; alineado a 16
	mov rbp,rsp

	mov rsi, 0 ; iterador Y offset ja
	
	clone_len:
	mov byte r8, [rdi + rsi] ; guardo la letra actual aca
	cmp byte r8, 0x00 ; comparar si en una direccion esta el terminador
	je clone_salida

	sub rsp, 1 ; apunto a una nueva direccion vacia la pila
	mov [rsp], r8 ; meto la letra en la nueva direc
	add rsi, 1 ; aumento el iterador
	jmp clone_len

	; agrego espacio para el terminador
	sub rsp,1 
	mov [rsp], 0

	clone_salida:
	; guardo en rax la posicion del primer char copiado
	mov r9, rbp
	inc r9
	mov rax, r9
	pop rbp
	ret

; void strDelete(char* a)
strDelete:
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
	cmp byte [rdi + rsi], 0x00 ; comparar si en una direccion esta el terminador
	je salida

	add rsi, 1 
	jmp restart

	salida:
	mov rax, rsi
	pop rbp
	ret


