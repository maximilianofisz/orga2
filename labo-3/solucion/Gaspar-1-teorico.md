# 1. Conceptos generales

a. a) ¿Qu´e entienden por convencion de llamada? ¿C´omo est´a definida en la ABI de System V para 64 y 32 bits?
    - Es el esquema que define como pasan los argumentos a la funciones, cómo se devuelve el valor de las funciones y como se utiliza el stack durante una llamada de función.
    - Para 64 bits:
        - El abi de system v establece que los primeros 6 args enteros o punteros de una función pasen a traves de ciertos registros RDI,RSI,RDX,RCX,R8,R9.
        - Y los flotantes a través de XMMO, ... , XMM7.
        - Y el resto van directo a memoria stack.
    - Para 32 bits, la ABI especifica que todos los args se pasan a través del stack.

b. b) ¿Qui´en toma la responsabilidad de asegurar que se cumple la convenci´on de llamada en C? ¿Qui´en toma la respon-
sabilidad de asegurar que se cumple la convenci´on de llamada en ASM?
    - En C la responsabilidad de adherirse a la convención de llamadas recae directamente en el compilador.
    - En cambio en ASM es directamente del programador.

c. c) ¿Qu´e es un stack frame? ¿A qu´e se le suele decir pr´ologo y ep´ılogo?
    - stack frame: Estructura de datos utilizada en el stack para almacenar información relevante a la llamada de función, incluyendo argumentos, local vars, env values, return address.
    - Prologo: secuencia de instrucciones al inicio de una función que prepara el stack frame. Utiliza el stack pointer `RSP` etc etc para mantener el orden.
    - Epliogo: secuencia de instrucciones al final de una función que limpia el stack frame restableciendo el SP y el BP.

d. d) ¿Cu´al es el mecanismo utilizado para almacenar variables temporales?
    - Stack, stack frame.

e. e) ¿A cu´antos bytes es necesario alinear la pila si utilizamos funciones de libc? ¿Si la pila est´a alienada a 16 bytes
al realizarse una llamada funci´on, cu´al va a ser su alineamiento al ejecutar la primera instrucci´on de la funci´on
llamada?
    - 16 bytes por la ABI.
    - Sí la pila está en 16 bytes su alineamiento es de la mitad pues al ejecutar la 1ra instrucción de la función, la función de reotrno pusheada en el stack desalinea la pila.
f. f)
    - Los programas ya compiladas que dependen de estas funciones van a fallar porque el código compilado espera otra interfaz.
    - Elaborar un poco más.