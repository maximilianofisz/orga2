global temperature_asm

section .data

; mascaras

mascaraPonerAlpha: times 4 dd 0xFF000000  
mascaraSacarAlpha: times 4 dd 0x00FFFFFF 


mascara1:   times 16 db 0x01 
mascara3: times 4 dd 0x03
mascara255: times 16 db 0xFF

; vamos a usar estas mascaras para comparar Y para restar/sumar
; cuando comparemos, el extremo inferior no nos importa hacerle greater a un cierto valor + 1 porque son =< 
; pero nos queda comodo para el extremo superior comparar con el valor - 1 y despues hacerle XOR para saber si el
; original era menor
; cuando queramos el valor posta para sumar o restas le hacemos INC
; aparte
; le sumamos 128 a todos los que NO sean 128 porque PCMPGTB usa signed, se nos rompe todo sino en 8 bits,
; sumamos aca y a las temps, con eso no deberiamos tener problema de wrap around

mascara32:  times 16 db (0x1F + 0x80) 
mascara96:  times 16 db (0x5F + 0x80) 
mascara128: times 16 db 0x80 
mascara160: times 16 db (0x9F + 0x80)
mascara224: times 16 db (0xDF + 0x80)

mascaraFullF: times 4 dd 0xFFFFFFFF  


mascaraSelecRojo: times 4 dd 0x00FF0000
mascaraSelecVerde: times 4 dd 0x0000FF00
mascaraSelecAzul: times 4 dd 0x000000FF
; y alpha los dos primeros

mascaraT: times 2 dd 0x00000000, 0x01010101 

section .text

temperature_asm:
    push rbp
	mov rbp, rsp 
    
    ; cargamos todo lo que podamos de antemano
    
    movdqu xmm6, [mascara3]
    movdqu xmm5, [mascaraT]
    movdqu xmm4, [mascaraFullF]
    movdqu xmm3, [mascaraSacarAlpha]

    movdqu xmm10, [mascara32]
    movdqu xmm9, [mascara96]
    movdqu xmm8, [mascara160]
    movdqu xmm7, [mascara224]


    cvtdq2ps xmm6, xmm6 ; a float

    xor r9, r9 ; usamos de puntero para ambas imagenes

    imul rcx, rdx ; cantidad de iteraciones restantes
    

    loop:

        cmp rcx, 0 
        je exit

        movq xmm12, [rdi + r9] ; cargamos 2 pixeles (quad)

        
        pand xmm12, xmm3 ; sacamos el alpha
        pmovzxbw xmm13, xmm12 ; extendemos a words

        phaddw xmm13, xmm13 ; Hacemmos las sumas horizontales para sacar el t
        phaddw xmm13, xmm13

        pmovzxwd xmm13, xmm13 ; extendemos a double word 


        cvtdq2ps xmm13, xmm13 ; a float para divir
        divps xmm13, xmm6 ; /3

        cvttps2dq xmm13, xmm13  ; a entero de vuelta

        packssdw xmm13, xmm13  ; de 32 a 8 bits
        packuswb xmm13, xmm13  

        pshufb xmm13, xmm5 ; acomodamos los ts como t0t0t0t0 y t1t1t1t1

        pxor xmm11, xmm11 ; vamos a ir sumando en un registro cualquier valor que cumpla un caso, despues lo pegamos en destino    


        ; caso 1
        movdqu xmm15, xmm13

        ; x4
        paddb xmm15, xmm15
        paddb xmm15, xmm15 

        ; + 128
        movdqu xmm2, [mascara128]
        paddb xmm15, xmm2 

        ; compare 
        movdqu xmm14, [mascara128]
        paddb xmm14, xmm13 ; le sumo los 128 por el pcmpgtb
        pcmpgtb xmm14, xmm10   
        pxor xmm14, xmm4 ; porque comparo con greater

        ; filtramos que valores cumplen con el caso
        pand xmm15, xmm14
        movdqu xmm2, [mascaraSelecAzul] 
        pand xmm15, xmm2 

        ; agregamos al resultado
        paddb xmm11, xmm15



        ; caso 2
        movdqu xmm15, xmm13

        ; t - 32
        movdqu xmm2, [mascara32]
        movdqu xmm1, [mascara1] ; para estos casos donde no queremos comparar sino sumar le hacemos INC a todo el registro
        paddb xmm2, xmm1
        psubb xmm15, xmm2

        ; x4
        paddb xmm15, xmm15
        paddb xmm15, xmm15 

        ; compare >= a 32
        movdqu xmm14, [mascara128]
        paddb xmm14, xmm13 ; le sumo los 128 por el pcmpgtb
        pcmpgtb xmm14, xmm10 

        ; compare < a 96
        movdqu xmm0, [mascara128]
        paddb xmm0, xmm13 ; le sumo los 128 por el pcmpgtb
        pcmpgtb xmm0, xmm9 
        pxor xmm0, xmm4 ; 

        ; combinamos ambas condiciones
        pand xmm14, xmm0

        ; limpiamos todo menos lo que calculamos antes y cumple el caso
        pand xmm15, xmm14

        ; borramos todo menos lo que esta en el verde
        movdqu xmm2, [mascaraSelecVerde]
        pand xmm15, xmm2

        ; ponemos 255 en azul
        movdqu xmm2, [mascaraSelecAzul]
        ; ignorar el 255 si no corresponde
        pand xmm2, xmm14
        paddb xmm15, xmm2 
        
        ; suma suma suma
        paddb xmm11, xmm15


        ; caso 3
        movdqu xmm15, xmm13

        ; t - 96
        movdqu xmm2, [mascara96]
        movdqu xmm1, [mascara1]
        paddb xmm2, xmm1
        psubb xmm15, xmm2

        ; 4x
        paddb xmm15, xmm15
        paddb xmm15, xmm15

        ; compare >= 96
        movdqu xmm14, [mascara128]
        paddb xmm14, xmm13
        pcmpgtb xmm14, xmm9

        ; compare < 160
        movdqu xmm0, [mascara128]
        paddb xmm0, xmm13
        pcmpgtb xmm0, xmm8
        pxor xmm0, xmm4 

        pand xmm14, xmm0 

        ; aca necesitamos ya armar una base mas compleja
        pxor xmm0, xmm0
        movdqu xmm0, [mascara255]
        
        ; el 255 del azul
        movdqu xmm2, [mascaraSelecAzul] 

        ; restamos el calculo anterior
        psubb xmm0, xmm15 

        ; lo dejamos en la componente que corresponde
        pand xmm0, xmm2   
        
        ; movemos el calculo anterior a rojo que tambien necesita
        movdqu xmm2, [mascaraSelecRojo]
        pand xmm15, xmm2 

        ; juntamos 
        paddb xmm0, xmm15 ;

        ; agregamos 255 en verde
        movdqu xmm2, [mascaraSelecVerde]
        paddb xmm0, xmm2 

        ; filtramos si el caso aplica
        pand xmm0, xmm14


        paddb xmm11, xmm0 ;suma


        ; caso 4
        movdqu xmm15, xmm13

        ; t - 160
        movdqu xmm2, [mascara160]
        movdqu xmm1, [mascara1]
        paddb xmm2, xmm1
        psubb xmm15, xmm2

   
        paddb xmm15, xmm15
        paddb xmm15, xmm15 

        ; comapre >= 160
        movdqu xmm14, [mascara128]
        paddb xmm14, xmm13
        pcmpgtb xmm14, xmm8 

        ; compare < 224
        movdqu xmm0, [mascara128]
        paddb xmm0, xmm13
        pcmpgtb xmm0, xmm7 
        pxor xmm0, xmm4 

        pand xmm14, xmm0 ; juntar condiciones


        pxor xmm0, xmm0
        movdqu xmm0, [mascara255]
        
        ; otra con 255 en la segunda
        movdqu xmm2, [mascaraSelecVerde]

        ; le restamos el resultado
        psubb xmm0, xmm15 

        ; dejamos solo esa componente
        pand xmm0, xmm2   

        ; ponemos a manopla el 255 del rojo
        movdqu xmm2, [mascaraSelecRojo]
        paddb xmm0, xmm2 

        ; ignorar sino cumple el caso y sumar
        pand xmm0, xmm14
        paddb xmm11, xmm0


        ; caso 5
        movdqu xmm15, xmm13

        ; t - 224
        movdqu xmm2, [mascara224]
        movdqu xmm1, [mascara1]
        paddb xmm2, xmm1
        psubb xmm15, xmm2

        paddb xmm15, xmm15
        paddb xmm15, xmm15 

        ; compare >= 224
        movdqu xmm14, [mascara128]
        paddb xmm14, xmm13
        pcmpgtb xmm14, xmm7

        ; base
        pxor xmm0, xmm0
        movdqu xmm0, [mascara255]
        
        ; vamos a poner cosas solo en la primer componente, arrancamos con 255
        movdqu xmm2, [mascaraSelecRojo] 

        ; sub el resultado anterior
        psubb xmm0, xmm15

        ;dejarlo solo en el rojo
        pand xmm0, xmm2   

        ; ignorar si no es el caso
        pand xmm0, xmm14 

        ; result
        paddb xmm11, xmm0
                

        ; volvemos a poner el alpha
        movdqu xmm1, [mascaraPonerAlpha]
        paddb xmm11, xmm1

        ; guardar en destino con el puntero
        movq [rsi + r9], xmm11 

        add r9, 8 ; siguientes 2 pixeles y restart
        sub rcx, 2   
        jmp loop    
        
    
    exit:
        pop rbp
        ret
