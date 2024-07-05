extern sumar_c
extern restar_c
;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;########### LISTA DE FUNCIONES EXPORTADAS

global alternate_sum_4
global alternate_sum_4_simplified
global alternate_sum_8
global product_2_f
global product_9_f
global alternate_sum_4_using_c

;########### DEFINICION DE FUNCIONES
; uint32_t alternate_sum_4(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; registros: x1[?], x2[?], x3[?], x4[?]
alternate_sum_4:
	;prologo
	; No se necesitan prologo ni epligo porque no voy a usar la pila ni registros que van a ser restaurados
    mov eax, edi        ; Mueve el valor de x1 a eax
    sub eax, esi        ; Resta el valor de x2 de eax (eax ahora tiene x1-x2)
    add eax, edx        ; Suma el valor de x3 eax (eax ahora tiene x1-x2+x3)
    sub eax, ecx        ; Resta el valor de x4 de eax (eax ahora tiene x1-x2+x3-x4)
    ret                 ; Retorna el resultado (en eax)
	;recordar que si la pila estaba alineada a 16 al hacer la llamada
	;con el push de RIP como efecto del CALL queda alineada a 8

	;epilogo
	; COMPLETAR
	ret

; uint32_t alternate_sum_4_using_c(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; registros: x1[rdi], x2[rsi], x3[rdx], x4[rcx]
alternate_sum_4_using_c:
	;prologo
	push rbp ; alineado a 16
	mov rbp,rsp

	; COMPLETAR
	sub rsp, 16 ; voy a reservar 16 bytes para posibles cambios en los registros.
	mov [rbp - 8], rdx ; guardo x3
	mov [rbp - 16], rcx ; guardo x4

	call restar_c
	; x1-x2 usando rdi y rsi respectivamente
	mov rdi, rax ; muevo el resultado de la resta a rdi para ser el pr imer argumento en la suma
	mov rsi, [rbp-8]; recupero x3 del stack
	call sumar_c ; rax + x3

	mov rdi, rax ; mueve el resultado anterior de la suma a rdi para ser el primer argumento en restar_c
	mov rsi, [rbp - 16] ; recupero x4
	call restar_c

	add rsp, 16 ; libero
	;epilogo
	pop rbp
	ret





; uint32_t alternate_sum_4_simplified(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; registros: x1[?], x2[?], x3[?], x4[?]
alternate_sum_4_simplified:
    mov eax, edi        ; Mueve el valor de x1 a eax
    sub eax, esi        ; Resta el valor de x2 de eax (eax ahora tiene x1-x2)
    add eax, edx        ; Suma el valor de x3 eax (eax ahora tiene x1-x2+x3)
    sub eax, ecx        ; Resta el valor de x4 de eax (eax ahora tiene x1-x2+x3-x4)
    ret                 ; Retorna el resultado (en eax)
	ret


; uint32_t alternate_sum_8(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4, uint32_t x5, uint32_t x6, uint32_t x7, uint32_t x8);
; registros y pila: x1[?], x2[?], x3[?], x4[?], x5[?], x6[?], x7[?], x8[?]
alternate_sum_8:
	;prologo
	push rbp
	mov rbp, rsp
	; los primeros 6 argumentos van directo a los registros desde rdi , ... , r9
	; los 7 y 8 caen a stack
	sub rdi, rsi ; x1 - x2
	add rdi, rdx ; + x3
	sub rdi, rcx ; - x4
	add rdi, r8 ; + x5
	sub rdi, r9 ; - x6

	; sumar x7:
	mov rax, [rbp + 16] ; cargar x7 en rax
	add rdi, rax

	; restar x8:
	mov rax, [rbp + 24] ; cargo x8
	sub rdi, rax ; resto x8

	mov rax, rdi ; muevoel resultado final para devolverlo

	
	;epilogo
	mov rsp, rbp ; vuelve el rsp
	pop rbp
	ret


; SUGERENCIA: investigar uso de instrucciones para convertir enteros a floats y viceversa
;void product_2_f(uint32_t * destination, uint32_t x1, float f1);
;registros: destination[?], x1[?], f1[?]
; hay que convertir el entero a float se puede hacer con CVTSI2SS o CVTSI2SD
product_2_f:

	; primero mis argumentos en los registros serían:
	; rdi = puntero destination
	; rsi = entero x1
	; xmm0 = flotante f1
	;prologo
	push rbp
	mov rbp, rsp
		;convertimos los flotantes de cada registro xmm en doubles
	; https://wiki.cheatengine.org/index.php?title=Assembler:Commands:CVTSI2SS
	cvtsi2ss xmm1, rsi
	; multioplica flotante en xmm0 (f1) por xmm1
	; https://docs.oracle.com/cd/E26502_01/html/E28388/eojde.html
	mulss xmm0, xmm1 ; multiplica los flotantes
	; lo convierte a entero (los test me lo piden entero)
	cvttss2si rax, xmm0

    mov [rdi], eax


	;epilogo
	mov rsp, rbp
	pop rbp
	ret


;extern void product_9_f(uint32_t * destination
;, uint32_t x1, float f1, uint32_t x2, float f2, uint32_t x3, float f3, uint32_t x4, float f4
;, uint32_t x5, float f5, uint32_t x6, float f6, uint32_t x7, float f7, uint32_t x8, float f8
;, uint32_t x9, float f9);
;registros y pila: destination[rdi], x1[?], f1[?], x2[?], f2[?], x3[?], f3[?], x4[?], f4[?]
;	, x5[?], f5[?], x6[?], f6[?], x7[?], f7[?], x8[?], f8[?],
;	, x9[?], f9[?]
product_9_f:
	;prologo
	push rbp
	mov rbp, rsp

	;convertimos los flotantes de cada registro xmm en doubles
	; COMPLETAR

	;multiplicamos los doubles en xmm0 <- xmm0 * xmm1, xmmo * xmm2 , ...
	; COMPLETAR

	; convertimos los enteros en doubles y los multiplicamos por xmm0.
	; COMPLETAR

	; epilogo
	pop rbp
	ret


