

;########### ESTOS SON LOS OFFSETS Y TAMAÑO DE LOS STRUCTS
; Completar:
NODO_LENGTH	EQU	28
LONGITUD_OFFSET	EQU	24

PACKED_NODO_LENGTH	EQU	21
PACKED_LONGITUD_OFFSET	EQU	17

;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;########### LISTA DE FUNCIONES EXPORTADAS
global cantidad_total_de_elementos
global cantidad_total_de_elementos_packed

;########### DEFINICION DE FUNCIONES
;extern uint32_t cantidad_total_de_elementos(lista_t* lista);
;registros: lista[rdi]
cantidad_total_de_elementos:
	push rbp
	mov rbp, rsp

	mov rdi, [rdi] ; aca tengo a mi primer nodo en rdi
	mov rax, [rdi + LONGITUD_OFFSET] ; nuestro contador. Por que funciona esto????????????

	restart:
	mov rsi, [rdi]
	cmp rsi, 0
	je salida
	mov rdi, [rdi]
	add rax, [rdi + LONGITUD_OFFSET]
	jmp restart

	salida:

	pop rbp
	ret

;extern uint32_t cantidad_total_de_elementos_packed(packed_lista_t* lista);
;registros: lista[rdi]
cantidad_total_de_elementos_packed:
	push rbp
	mov rbp, rsp

	mov rdi, [rdi] ; aca tengo a mi primer nodo en rdi
	mov eax, [rdi + PACKED_LONGITUD_OFFSET] ; nuestro contador. Por que funciona esto????????????

	prestart:
	mov rsi, [rdi]
	cmp rsi, 0
	je psalida
	mov rdi, [rdi]
	add eax, [rdi + PACKED_LONGITUD_OFFSET]
	jmp prestart

	psalida:
	pop rbp
	ret

