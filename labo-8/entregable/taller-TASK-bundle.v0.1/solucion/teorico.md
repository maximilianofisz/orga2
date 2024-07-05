# Teoricos

1. Si queremos definir un sistema que utilice sólo dos tareas, ¿Qué nuevas estructuras, cantidad de nuevas entradas en las estructuras ya definidas, y registros tenemos que configurar?¿Qué formato tienen? ¿Dónde se encuentran almacenadas?
    - Cada tarea debe tener un TSS que almacene su estado cuando no está en ejerución. Esto incluye EIP, ESP, CR3, etc.
        - Almacena una foto de la ejecución de la tarea con su contexto..
    - Necesitamos definir dos tareas especiales: idle y busy.
        - Idle es la tarea que se ejecuta cuando no hay tareas pendientes.
        - Busy es la tarea que se ejecuta cuando hay tareas pendientes.
    - Cada TSS va a tener un GDT, que contiene lo de siempre y los atributos del TSS, incluyendo el bit de tarea ocupada busy, DPL, etc.
- Formatos:
    - La GDT contiene los descriptores de los TSS de cada tarea.
# 
2. ¿A qué llamamos cambio de contexto?¿Cuándo se produce?¿Qué efecto tiene sobre los registros del procesador?
- Expliquen en sus palabras que almacena el registro TR y cómo obtiene la información necesaria para ejecutar una tarea después de un cambio de contexto.
    - Un cambio de contexto es un proceso que permite al CPU alternar entre varias tareas.
    - El cambio de contexto se puede producir en diferentes formas, como:
        - Interrupciones: interrupcion de reloj, interrupción de hardware, etc.
        - Llamadas al sistema: syscalls de todo tipo.
        - Prioridades: cuando se ejecuta una tarea con una prioridad mayor que la actual.
    - Los efectos durante un cambio de contexto son varios: la CPU se guarda la foto en la TSS de la que está siendo interrumpida, y se carga la foto de la tarea que se está ejecutando.
    - Almacena el selector de segmento que apunta a la entrada de la GDT correspondiente al TSS de la tarea en ejecución.
    - Cuando se produce un cambio de contexto la información se obtiene al reanudar la ejecución de la tarea utilizando el estado de la TSS de la tarea en ejecución.
#
3. Al momento de realizar un cambio de contexto el procesador va almacenar el estado actual de acuerdo al selector indicado en el registro TR y ha de restaurar aquel almacenado en la TSS cuyo selector se asigna en el jmp far. 
- ¿Qué consideraciones deberíamos tener para poder realizar el primer cambio de contexto?
    - es necesario que la GDT esté configurada correctamente, es decir que tenga todos los descriptores de segmento necesarios, junto con los selectores de los TSS de las tareas que se ejecutarán.
    - el TR tiene que estar inicializado con el selector de la TSS de la tarea que sde la tarea inicial.
    - la el ISR tiene que poder permitir cambios de contexto establecidos por el sistema operativo. [Preguntar, abarcar más]
    - la tarea idle tiene que ser accesible a través de su propio selector en la GDT, admitiendo que el S.O realice un cambio de contexto cuando sea necesario.
- ¿Y cuáles cuando no tenemos tareas que ejecutar o se encuentran todas suspendidas?
    - lo mismo de idle TSS.idle => actualizada.

4. ¿Qué hace el scheduler de un Sistema Operativo? ¿A qué nos referimos con que usa una política?
    - El scheduler es el componente encargado de gestionar el tiempo de ejecución de las tareas, y de asignar a cada una de ellas un tiempo de ejecución.
    - La política de prioridad es la que determina cuál de las tareas se ejecutará primero.
        - Planificación round-robin: cada tarea se ejecutará en el momento en que se le asigna el próximo tiempo de ejecución.
        - Planificación de prioridad: cada tarea se ejecutará en el momento en que se le asigna el próximo tiempo de ejecución, y se le asignará el tiempo de ejecución en función de la prioridad de la tarea.

5. En un sistema de una única CPU, ¿cómo se hace para que los programas parezcan ejecutarse en simultáneo?
    - Es muy rapido, nosotros como seres humanos no nos percatamos, y parece que el sistema operativo nos permite ejecutar varias tareas en simultáneo, pero en realidad va haciendo una a una y no en simultáneo.