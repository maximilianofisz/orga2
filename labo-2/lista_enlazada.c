#include "lista_enlazada.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>


lista_t* nueva_lista(void) {
    lista_t* nuevaLista = malloc(sizeof(lista_t));
    nuevaLista->head = NULL;
    return nuevaLista;
}

uint32_t longitud(lista_t* lista) {

    if(lista == NULL) { //Si la lista no esta inicializada, devolvemos 0
        return 0;
    }

    if(lista->head == NULL) { // Si la lista no tiene primer elemento devolvemos 0
        return 0;
    }


    uint32_t contador = 0;
    nodo_t* nodoActual =  lista->head;

    while(nodoActual->next != NULL) {
        contador++;
        nodoActual = nodoActual->next;
    }

    return contador;

}

void agregar_al_final(lista_t* lista, uint32_t* arreglo, uint64_t longitud) {
    if(lista == NULL) { //Si la lista no esta inicializada, no hacemos nada
        return;
    }

    if(lista->head == NULL) { // Si la lista no tiene primer elemento, lo agregamos
        nodo_t* nuevoNodo = malloc(sizeof(nodo_t));
        nuevoNodo->longitud = longitud;
        nuevoNodo->arreglo = arreglo;
        nuevoNodo->next = NULL;
        lista->head = nuevoNodo;
        printf("Se agrega el primer nodo, la longitud es 1\n");
        
    }

    else { // Buscamos el ultimo nodo y le agregamos uno
        nodo_t* nodoActual =  lista->head;
        while(nodoActual->next != 0) {
            nodoActual = nodoActual->next;
        }
        nodo_t* nuevoNodo = malloc(sizeof(nodo_t));
        nuevoNodo->longitud = longitud;
        nuevoNodo->arreglo = arreglo;
        nuevoNodo->next = NULL;
        nodoActual->next = nuevoNodo;
    }
}

nodo_t* iesimo(lista_t* lista, uint32_t i) {
    if(lista == NULL) { //Si la lista no esta inicializada, devolvemos NULL
        return NULL;
    }

    uint32_t contador = 0;

    nodo_t* nodoActual =  lista->head;

    // Buscamos el iesimo elemento y lo devolvemos
    while(contador != i) {
        nodoActual = nodoActual->next;
        contador++;
    }

    return nodoActual;
}

uint64_t cantidad_total_de_elementos(lista_t* lista) {

    if(lista == NULL) { //Si la lista no esta inicializada, devolvemos 0
        return 0;
    }

    if(lista->head == NULL) { // Si la lista no tiene primer elemento devolvemos 0
        return 0;
    }

    // Buscamos el ultimo elemento y vamos contando
    nodo_t* nodoActual =  lista->head;
    uint32_t contador = nodoActual->longitud;
    while(nodoActual->next != 0) {
        nodoActual = nodoActual->next;
        contador = contador + nodoActual->longitud;
    }
    return contador;

}

void imprimir_lista(lista_t* lista) {
}

// Función auxiliar para lista_contiene_elemento
int array_contiene_elemento(uint32_t* array, uint64_t size_of_array, uint32_t elemento_a_buscar) {
    uint32_t contador = 0;
    while(size_of_array != contador) {
        if(elemento_a_buscar == *array) {
            return 1;
        }
        else {
            array++;
            contador++;
        }        
    }
    return 0;
}

int lista_contiene_elemento(lista_t* lista, uint32_t elemento_a_buscar) {

    if(lista == NULL) { //Si la lista no esta inicializada, devolvemos 0
        return 0;
    }

    if(lista->head == NULL) { // Si la lista no tiene primer nodo devolvemos 0
        return 0;
    }

    // Buscamos el ultimo elemento y vamos contando
    nodo_t* nodoActual =  lista->head;
    while(nodoActual != 0) {
        if(array_contiene_elemento(nodoActual->arreglo, nodoActual->longitud, elemento_a_buscar) == 1) {
            return 1;
        }
        else {
            nodoActual = nodoActual->next;
        }
    }
    return 0;
}


// Devuelve la memoria otorgada para construir la lista indicada por el primer argumento.
// Tener en cuenta que ademas, se debe liberar la memoria correspondiente a cada array de cada elemento de la lista.
void destruir_lista(lista_t* lista) {
    if(lista == NULL) { //Si la lista no esta inicializada, terminamos
        return;
    }

    if(lista->head == NULL) { // Si la lista no tiene primer elemento, la liberamos y terminamos
        free(lista);
        return;
    }

    // Buscamos el primer nodo, liberamos la lista y su primer arreglo
    nodo_t* nodoActual = lista->head;
    free(nodoActual->arreglo);
    free(lista);

    // Iteramos por los nodos, guardando el actual en algun lado para eliminarlo despues de saltar al siguiente
    while(nodoActual != NULL) {
        nodo_t* nodoAEliminar = nodoActual;
        nodoActual = nodoActual->next;
        free(nodoAEliminar);
    }
}


/* IDEA DE GASPAR SI ES QUE FUNCIONA SIN TODOS ESOS CONDICIONALES CHEQUEANDO.
PREGUNTAR SI ES NECESARIO.
void destruir_lista(lista_t* lista) {
nodo_t* nodoActual = lista->head;
while(nodoActual != NULL) {
    nodo_t* temp = nodoActual;
    nodoActual = nodoActual->next;
    free(temp);
}
free(lista);
}


/*
Ejercicio 2.2)
a) mi_lista es una variable de puntero creada dentro de una función que apunta a una lista.
    Si no mal recuerdo los punteros se guardan en el stack (a consultar).
    y a la lista que apunta se crea con el malloc dentro de nueva_lista() así que la lista en sí, se guarda en el heap.
b) mi_otra_lista, no usa malloc o sea que no tiene asignación dinámica dentro de una función va directo al stack.
c) mi_otra_lista.head: stack
d) mi_lista->head
    mi_lista es un puntero que apunta al heap, y como `head` sigue siendo parte del puntero, también va a estar ahí.


¿Y si a la lista mi_otra_lista la creamos fuera de cualquier función?
Estoy seguro, preguntar.
*/



