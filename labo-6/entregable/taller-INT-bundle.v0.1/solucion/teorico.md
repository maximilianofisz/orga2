- Ejercicio 1a:
    - offset_15_0 y offset_31_16: Representan las partes bajas y altas del offset de la dirección de la rutina de servicio de interrupción (ISR). Estos offsets se combinan para formar una dirección de 32 bits que el cpu va a usar para acceder a la rutina de interrupción.
    - segment selector: Este campo almacena el selector de segmento que indica el segmento de memoria en donde reside la ISR. Para interrupciones que operan a nivel kernel (nivel cero), este selector va a ser el de un segmento de memoria de kernel configurado en la gdt.
    reserver y should be zero: Estos campos almacenan un valor reservado y deben ser ceros, se supone que están reservados para futuras versiones de la especificación de la interrupción.
    - type: Este campo almacena el tipo de interrupción. Define el tipo de entrada en la IDT.
    - Descriptor Privilege Level (DPL): Este campo almacena el nivel de privilegio minimo de acceso que se requiere para acceder a la rutina de interrupción. Para interrupciones que pueden ser invocadas desde código de usuario es 3, para las que solo se pueden invocar desde el kernel es 0.
    - Present: este campo se pone en 1 para indicar que la entrada está presente en la IDT y activa.
- los valores que puede tomar el campo offset son calculados a partir de la dirección de la función que maneja la interrupción. Usando las macros low_16_bits y high_16_bits. Se extraen los 16 bits de cada parte baja y alta de la dirección de la rutina de interrupción.
