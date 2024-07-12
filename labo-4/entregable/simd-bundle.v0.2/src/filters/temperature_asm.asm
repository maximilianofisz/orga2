global temperature_asm

section .data

; mascaras

mascaraPonerAlpha: times 4 dd 0xFF000000  
mascaraSacarAlpha: times 4 dd 0x00FFFFFF 


mascara1:   times 16 db 1 
mascara3: times 4 dd 0x3
mascara255: times 16 db 0xFF 
mascara32:  times 16 db (0x1F + 0x80) 
mascara96:  times 16 db (0x5F + 0x80) 
mascara128: times 16 db 0x80 
mascara160: times 16 db (0x9F + 0x80)
mascara224: times 16 db (0xDF + 0x80)

mascaraFullF: times 4 dd 0xFFFFFFFF  


mascaraSelecRojo: times 4 dd 0x00FF0000
mascaraSelecVerde: times 4 dd 0x0000FF00
mascaraSelecAzul: times 4 dd 0x000000FF

mascaraT: times 2 dd 0x00000000, 0x01010101 

section .text

temperature_asm:
    push rbp
	mov rbp, rsp 
    
    ; cargamos todo lo que podamos de antemano
    
    movdqu xmm11, [mascara3]
    movdqu xmm8, [mascaraT]
    movdqu xmm9, [mascaraFullF]
    movdqu xmm10, [mascaraSacarAlpha]

    movdqu xmm12, [mascara32]
    movdqu xmm13, [mascara96]
    movdqu xmm14, [mascara160]
    movdqu xmm15, [mascara224]



    cvtdq2ps xmm11, xmm11 ; a float

    xor r9, r9 ; usamos de puntero para ambas imagenes

    imul rcx, rdx ; cantidad de iteraciones restantes
    

    loop:

        cmp rcx, 0 
        je exit

        movq xmm0, [rdi + r9] ; cargamos 2 pixeles (quad)

        
        pand xmm0, xmm10 ; sacamos el alpa


        pmovzxbw xmm1, xmm0 ; extendemos a words


        phaddw xmm1, xmm1 ; Hacemmos las sumas horizontales para sacar el t
        phaddw xmm1, xmm1

        
        pmovzxwd xmm1, xmm1 ; extendemos a double word 


        cvtdq2ps xmm1, xmm1 ; a float para divir
        divps xmm1, xmm11 ; 

        cvttps2dq xmm1, xmm1  ; a entero de vuelta

        packssdw xmm1, xmm1  ; de 32 a 8 bits
        packuswb xmm1, xmm1  

        pshufb xmm1, xmm8 ; acomodamos los ts como t0t0t0t0 y t1t1t1t1

        pxor xmm7, xmm7 ; vamos a ir sumando en un registro cualquier valor que cumpla un caso, despues lo pegamos en destino    


        ; caso 1
        movdqu xmm3, xmm1

        ; x4
        paddb xmm3, xmm3
        paddb xmm3, xmm3 

        ; + 128
        movdqu xmm5, [mascara128]
        paddb xmm3, xmm5 ; 

        ; compare 
        movdqu xmm2, [mascara128]
        paddb xmm2, xmm1
        pcmpgtb xmm2, xmm12   
        pxor xmm2, xmm9 ; porque comparo con greater

        ; filtramos que valores cumplen con el caso
        pand xmm3, xmm2
        movdqu xmm5, [mascaraSelecAzul] 
        pand xmm3, xmm5 

        ; agregamos al resultado
        paddb xmm7, xmm3



        ; caso 2
        movdqu xmm3, xmm1

        ; t - 32
        movdqu xmm5, [mascara32]
        movdqu xmm6, [mascara1]
        paddb xmm5, xmm6
        psubb xmm3, xmm5

        ; x4
        paddb xmm3, xmm3
        paddb xmm3, xmm3 

        ; compare >= a 32
        movdqu xmm2, [mascara128]
        paddb xmm2, xmm1
        pcmpgtb xmm2, xmm12 

        ; compare < a 96
        movdqu xmm4, [mascara128]
        paddb xmm4, xmm1
        pcmpgtb xmm4, xmm13 
        pxor xmm4, xmm9 ; 

        ; combinamos ambas condiciones
        pand xmm2, xmm4
        pand xmm3, xmm2

        ; borramos todo menos lo que esta en el vrde
        movdqu xmm5, [mascaraSelecVerde]
        pand xmm3, xmm5

        ; ponemos 255 en azul
        movdqu xmm5, [mascaraSelecAzul]
        ; ignorar el 255 si no corresponde
        pand xmm5, xmm2
        paddb xmm3, xmm5 
        
        ; suma suma suma
        paddb xmm7, xmm3


        ; caso 3
        movdqu xmm3, xmm1

        ; t - 96
        movdqu xmm5, [mascara96]
        movdqu xmm6, [mascara1]
        paddb xmm5, xmm6
        psubb xmm3, xmm5

        ; 4x
        paddb xmm3, xmm3
        paddb xmm3, xmm3

        ; compare >= 96
        movdqu xmm2, [mascara128]
        paddb xmm2, xmm1
        pcmpgtb xmm2, xmm13

        ; compare < 160
        movdqu xmm4, [mascara128]
        paddb xmm4, xmm1
        pcmpgtb xmm4, xmm14
        pxor xmm4, xmm9 

        pand xmm2, xmm4 

        ; aca necesitamos ya armar una base mas compleja
        pxor xmm4, xmm4
        movdqu xmm4, [mascara255]
        
        ; el 255 del azul
        movdqu xmm5, [mascaraSelecAzul] 

        ; restamos el calculo anterior
        psubb xmm4, xmm3 

        ; lo dejamos en la componente que corresponde
        pand xmm4, xmm5   
        
        ; movemos el calculo anterior a rojo que tambien necesita
        movdqu xmm5, [mascaraSelecRojo]
        pand xmm3, xmm5 

        ; juntamos 
        paddb xmm4, xmm3 ;

        ; agregamos 255 en verde
        movdqu xmm5, [mascaraSelecVerde]
        paddb xmm4, xmm5 

        ; filtramos si el caso aplica
        pand xmm4, xmm2


        paddb xmm7, xmm4 ;suma


        ; caso 4
        movdqu xmm3, xmm1

        ; t - 160
        movdqu xmm5, [mascara160]
        movdqu xmm6, [mascara1]
        paddb xmm5, xmm6
        psubb xmm3, xmm5

   
        paddb xmm3, xmm3
        paddb xmm3, xmm3 

        ; comapre >= 160
        movdqu xmm2, [mascara128]
        paddb xmm2, xmm1
        pcmpgtb xmm2, xmm14 

        ; compare < 224
        movdqu xmm4, [mascara128]
        paddb xmm4, xmm1
        pcmpgtb xmm4, xmm15 
        pxor xmm4, xmm9 

        pand xmm2, xmm4 ; juntar condiciones


        pxor xmm4, xmm4
        movdqu xmm4, [mascara255]
        
        ; otra con 255 en la segunda
        movdqu xmm5, [mascaraSelecVerde]

        ; le restamos el resultado
        psubb xmm4, xmm3 

        ; dejamos solo esa componente
        pand xmm4, xmm5   

        ; ponemos a manopla el 255 del rojo
        movdqu xmm5, [mascaraSelecRojo]
        paddb xmm4, xmm5 

        ; ignorar sino cumple el caso y sumar
        pand xmm4, xmm2
        paddb xmm7, xmm4


        ; caso 5
        movdqu xmm3, xmm1

        ; t - 224
        movdqu xmm5, [mascara224]
        movdqu xmm6, [mascara1]
        paddb xmm5, xmm6
        psubb xmm3, xmm5

        paddb xmm3, xmm3
        paddb xmm3, xmm3 

        ; compare >= 224
        movdqu xmm2, [mascara128]
        paddb xmm2, xmm1
        pcmpgtb xmm2, xmm15

        ; base
        pxor xmm4, xmm4
        movdqu xmm4, [mascara255]
        
        ; vamos a poner cosas solo en la primer componente, arrancamos con 255
        movdqu xmm5, [mascaraSelecRojo] 

        ; sub el resultado anterior
        psubb xmm4, xmm3

        ;dejarlo solo en el rojo
        pand xmm4, xmm5   

        ; ignorar si no es el caso
        pand xmm4, xmm2 

        ; result
        paddb xmm7, xmm4
                

        ; volvemos a poner el alpha
            
        movdqu xmm6, [mascaraPonerAlpha]
        paddb xmm7, xmm6

        ; guardar en destino con el puntero
        movq [rsi + r9], xmm7 

        add r9, 8 ; siguientes 2 pixeles y restart
        sub rcx, 2   
        jmp loop    
        
    
    exit:
        pop rbp
        ret
