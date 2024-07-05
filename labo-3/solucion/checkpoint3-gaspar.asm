

;########### ESTOS SON LOS OFFSETS Y TAMAÑO DE LOS STRUCTS
; Completar:
NODO_LENGTH	EQU	32 ; Tamaño de la estructura nodo_t
LONGITUD_OFFSET	EQU	24 ; Offset del campo longitud en la estructura nodo_t

PACKED_NODO_LENGTH	EQU	21 ; Tamaño de la estructura packed_nodo_t
PACKED_LONGITUD_OFFSET	EQU	17 ; Offset del campo longitud en la estructura packed_nodo_t

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
	xor rax, rax ; limpia rax
	; prologo
	push rbp
	mov rbp, rsp ; guarda el puntero de pila
	mov rsi, [rdi] ; mueve el puntero a la lista a rsi
loop:
	cmp rsi , 0 ; si lista == NULL
	je fin ; si es null termina
	add rax, [rsi + LONGITUD_OFFSET] ; suma la longitud del nodo actual
	mov rsi, [rsi] ; mueve el puntero al siguiente nodo
	jmp loop ; salta al inicio del bucle
	fin:
	; epilogo	
	pop rbp
		ret


;extern uint32_t cantidad_total_de_elementos_packed(packed_lista_t* lista);
;registros: lista[?]
cantidad_total_de_elementos_packed:
	; me quedó pendiente
	ret

