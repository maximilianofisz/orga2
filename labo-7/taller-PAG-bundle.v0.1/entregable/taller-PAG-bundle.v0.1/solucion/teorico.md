- a) ¿Cuántos niveles de privilegio podemos definir en las estructuras de paginación?
    - En la arquitectura x86 hay cuatro niveles de privs que son los anillos.
        - ring 0: nivel kernel
        - 1 y 2: priv intermedio.
        - 3: nivel usuario.
    - En paginacion se maneja usuario y kernel, uno para el S.O y otro para las apps del usuario.
- b) ¿Cómo se traduce una dirección lógica en una dirección fı́sica?
    - La traduccion de una direccion logica/virtual a una fisica se hace a traves de la paginacion que utiliza el registro de control CR3, dir de pags y tabla de pags (DP, TP)
- ¿Cómo participan la dirección lógica, el registro de control CR3, el directorio y la tabla de páginas?
    - direccion logica: tiene tres partes
        - indice de directorio de paginas PDI
        - indice de tablas de paginas PTI
        - offset dentro de la pagina
    - CR3: contiene la direccion fisica base del directorio de paginas del proceso actual.
    - Directorio de paginas: se acccede a una entrada especifica del directorio de paginas que apunta a una tabla de paginas
    - Tabla de paginas: Utilizandolo, se accede a una entrada especifico de la tabla de paginas que apunta a la direccion base de una pagina fisica.
    - el offset es la suma de la direccion base de la pagina fisica para obtener la fisica final. 
- Recomendación: describan el proceso en pseudocódigo

#### Pseudocodigo
```
function traducir_direccion_logica_a_fisica(direccion_logica):
    CR3 = obtener_CR3()  // Obtiene el valor del registro CR3
    PDI = extraer_PDI(direccion_logica)  // Extrae el índice del directorio de páginas
    PTI = extraer_PTI(direccion_logica)  // Extrae el índice de la tabla de páginas
    offset = extraer_offset(direccion_logica)  // Extrae el offset dentro de la página

    // Paso 1: Obtener la dirección de la tabla de páginas desde el directorio de páginas
    base_directorio_paginas = CR3
    entrada_directorio_paginas = leer_memoria(base_directorio_paginas + PDI * tamaño_de_EntradaDirectorioPaginas)
    
    if not entrada_directorio_paginas.presente:
        raise ExcepcionFalloDePagina("La entrada del directorio de páginas no está presente")

    base_tabla_paginas = entrada_directorio_paginas.direccion

    // Paso 2: Obtener la dirección de la página física desde la tabla de páginas
    entrada_tabla_paginas = leer_memoria(base_tabla_paginas + PTI * tamaño_de_EntradaTablaPaginas)

    if not entrada_tabla_paginas.presente:
        raise ExcepcionFalloDePagina("La entrada de la tabla de páginas no está presente")

    direccion_base_pagina = entrada_tabla_paginas.direccion

    // Paso 3: Calcular la dirección física
    direccion_fisica = direccion_base_pagina + offset

    return direccion_fisica

// Funciones auxiliares
function extraer_PDI(direccion_logica):
    return (direccion_logica >> 22) & 0x3FF  // Suponiendo una estructura de paginación de dos niveles

function extraer_PTI(direccion_logica):
    return (direccion_logica >> 12) & 0x3FF  // Suponiendo una estructura de paginación de dos niveles

function extraer_offset(direccion_logica):
    return direccion_logica & 0xFFF  // Asumiendo un tamaño de página de 4KB

function obtener_CR3():
    // Función que obtiene el valor del registro CR3 del procesador
    return valor_CR3

function leer_memoria(direccion):
    // Función que lee el contenido de memoria en la dirección especificada
    return memoria[direccion]
```

- c) ¿Cuál es el efecto de los siguientes atributos en las entradas de la tabla de página?
- Dirty: indica si la pagina ha sido escrita, se establece cuando se realiza una escritura en la pagina.
- A (accessed): indica si la pagina ha sido leida o escrita, se establece cuando se accede a la pagina.
- PCD: page cache disable, si esta habilitado se desactiva la cache para esta pagina.
- PWT: page write through define el comportamiento de escritura en cache. Si esta habilitado, la cache tiliza el metodo de escritura directa.
- U/S user supervisor: determina el nivel de priv para acceder a la pagina, si esta establecido la pagina puede ser accedida como kernel y como usuario, si no solo por el kernel.
- R/W read write: define los permisos de lectura escritura, si esta habilitado permite la escritura en la pagina, y si no solo la lectura
- P (present): indica si la pagina esta presente en la memoria fisica, si no esta presente se va a producir una excepcion al intentar acceder.

- d) ¿Qué sucede si los atributos U/S y R/W del directorio y de la tabla de páginas difieren? ¿Cuáles terminan siendo los atributos de una página determinada en ese caso?
- si los atributos U/S y R/W del dir de pags y de la tabla de pags difieren, el sistema aplica una combinacion de estos atributos para determinar los permisos de la pagina.
- La Combined Page Directory and Page Table Protection se aplica asi:
	- Permiso de usuario: La página es accesible en modo usuario solo si ambos, el directorio y la tabla de páginas, tienen el bit U/S establecido.
	- Permiso de escritura: La página es escribible solo si ambos, el directorio y la tabla de páginas, tienen el bit R/W establecido.
	- Permiso de lectura: Si cualquiera de los bits de U/S o R/W en el directorio o la tabla de páginas no está establecido, los accesos estarán restringidos de acuerdo con el bit más restrictivo presente en cualquier nivel.
- e) Suponiendo que el código de la tarea ocupa dos páginas y utilizaremos una página para la pila de la tarea.
- ¿Cuántas páginas hace falta pedir a la unidad de manejo de memoria para el directorio, tablas de páginas y la memoria de una tarea?
	- para saber cuantas paginas se necesitan consideramos:
	- DP, 1pag, 4KB
	- TP, cada tabla de pags tambien ocupa una pag. Se necesitan suficintes entradas en las tablas para mapear las paginas de codigo y la pila, normalmente se utiliaran al menos una pag de tabla de pags.
	- Codigo de la tarea: 2 pags 8KB
	- pila de la tarea: 1 pag 4KB
- total de paginas: 5 pags
- g) ¿Qué es el buffer auxiliar de traducción (Translation Lookaside Buffer o TLB) y por qué es necesario purgarlo (tlbflush) al introducir modificaciones a nuestras estructuras de paginación (directorio, tabla de páginas)? ¿Qué atributos posee cada traducción en la TLB? Al desalojar una entrada determinada de la TLB, ¿se ve afectada la homóloga en la tabla original para algún caso?
    -  Translation lookaside buffer: es una cache que almacena las traducciones recientes de direcciones virtuales, a fisicas. Ayuda a reducir el tiempo necesario de acceso a memoria.
    - tlbflush: Se purga cuando el TLB hace cambios en las estructuras de paginacion como el PD o TP, pues el tlb podria contener entradas antiguas que no reflejan las nuevas traducciones de direcciones.
    - Si no se purga el TLB el CPU podria utilizar una traduccion incorrecta llevando a errores de memory access.
    - Atributos TLB:
        - Direccion virtual: la direccion que se traduce.
        - La direccion fisica.
        - Bits de control: incluyen atributos como permisos de acceso R/W, U/S, PCD, PWT, etc.
    - Cuando se desaloja una entrada de la TLB, si se necesita acceer a esa direccion virtual de nuevo, el CPU realiza una busqueda en las TPs para reconstruir la entrada en la TLB. 
- el tamaño cubierto por una entrada del directorio de paginas es igual a 1024 entradas en la tabla de paginas x 4kb por pagina
- porque una PDE te lleva a una PT que tiene hasta 1024 paginas asociadas
