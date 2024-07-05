1. Explorando el manual Intel Volumen 3: System Programming. Sección 2.2 Modes of Operation. ¿A qué nos referimos con modo real y con modo protegido en un procesador Intel? ¿Qué particularidades tiene cada modo?
    - Modo real: es el modo de compatibilidad con el 8086, direcciona hasta 1MB de memoria, usa segmentación y no tiene protección.
    - Modo protegido: Permite direccionar hasta 4GB, tiene protección de memoria, multitarea, paginacin y cambia el direccionamiento.

2. Comenten en su equipo, ¿Por qué debemos hacer el pasaje de modo real a modo protegido? ¿No podríamos simplemente tener un sistema operativo en modo real? ¿Qué desventajas tendría?
    - Pasamos a modo protegido para tener un entorno con una memoria especial que esté protegida para garantizar el minimo funcionamiento del sistema operativo, se necesitan niveles de privilegio, y paginación. Además que en modo real estaría muy limitado por el direccionamiento. (esta es la mayor desventaja).

3. Busquen el manual volumen 3 de Intel en la sección 3.4.5 Segment Descriptors. ¿Qué es la GDT? ¿Cómo es el formato de un descriptor de segmento, bit a bit? Expliquen para qué sirven los campos Limit, Base, G, P, DPL, S. También puede referirse a la teórica slide 30
    - La GDT (Global Descriptor Table) contiene descriptores de segmentos que definen áreas de la memoria con ciertos permisos y caracteristicas. El formato de un descriptor tiene:
        - Limit: Tamaño del segmento.
        - Base: Dirección de inicio.
        - G: granularidad (limite en bytes o páginas de 4KB).
        - P: Presencia en memoria.
        - DPL: nivel de privilegio.
        - S: tipo de segmento (código/datos)
4. La tabla de la sección 3.4.5.1 Code- and Data-Segment Descriptor Types del volumen 3 del manual del Intel nos permite completar el Type, los bits 11, 10, 9, 8. ¿Qué combinación de bits tendríamos que usar si queremos especificar un segmento para ejecución y lectura de código?
    - Para un segmento de código ejecutable y lectura seríe type 1010 (code, conforming, readable, accessed)
5. en excel
6. En el archivo gdt.h observen las estructuras: struct gdt_descriptor_t y el struct gdt_entry_t. ¿Qué creen que contiene la variable extern gdt_entry_t gdt[]; y extern gdt_descriptor_t GDT_DESC;
```C
extern gdt_entry_t gdt[]; // esta variable contiene la tabla de descriptores de la GDT 
extern gdt_descriptor_t GDT_DESC; // y esta otra variable contiene el descriptor de la GDT 
```
7. Buscar en el Volumen 3 del manual de Intel, sección 3.4.2 Segment Selectors el formato de los selectores de segmento. Observar en el archivo defines.h las constantes con los valores de distintos selectores de segmento posibles. También puede referirse a la teórica slide 28. Manejo de memoria. Completen los defines faltantes en defines.h y entiendan la utilidad de las macros allí definidas. USAR LAS MACROS para
definir los campos de los entries de la gdt. En lo posible, no hardcodeen los números directamente en los campos.