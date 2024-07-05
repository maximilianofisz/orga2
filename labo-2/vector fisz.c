#include "vector.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


vector_t* nuevo_vector(void) {
    vector_t* nuevoVector = malloc(sizeof(vector_t));
    nuevoVector->array = malloc(sizeof(uint32_t)*2);
    nuevoVector->capacity = 2;
    nuevoVector->size = 0;
    return nuevoVector;
}

uint64_t get_size(vector_t* vector) {
    return vector->size;
}

void push_back(vector_t* vector, uint32_t elemento) {
    // Caso no hay capacity
    if (vector->size == vector->capacity) {
        size_t nuevaCapacidad = vector->capacity * 2;
        vector->array = realloc(vector->array, sizeof(uint32_t) * nuevaCapacidad);
        vector->capacity = nuevaCapacidad;
    }
    // Voy hasta el primer elemento libre del array
    uint32_t* iterador = vector->array;
    for(int32_t i = 0; i < vector->size; i++) {
        iterador++;
    }

    // Asigno alli el elemento
    *iterador = elemento;
    vector->size++;
}

int son_iguales(vector_t* v1, vector_t* v2) {
    if(v1->size != v2->size) {
        return 0;
    }
    
    uint32_t* ptrArray1 = v1->array;
    uint32_t* ptrArray2 = v2->array;

    for(uint32_t i = 0; i < v1->size; i++) {
        if(*ptrArray1 != *ptrArray2) {
            return 0;
        }
        ptrArray1++;
        ptrArray2++;
    }

    return 1;

}

uint32_t iesimo(vector_t* vector, size_t index) {

    if(index > vector->size) {
        return 0;
    }
    
    uint32_t* ptrArray = vector->array;
    for(uint32_t i = 0; i < index; i++) {
        ptrArray++;
    }
    return *ptrArray;
}

// Util para debuggear
void imprimir_vector(vector_t* vector)
{
    uint32_t* ptrArray = vector->array;
    for(uint32_t i = 0; i < vector->size; i++) {
        printf("El vector tiene a  %d\n", *ptrArray);
        ptrArray++;
    }
}

void copiar_iesimo(vector_t* vector, size_t index, uint32_t* out)
{
    uint32_t* ptrArray = vector->array;
    for(uint32_t i = 0; i < index; i++) {
        ptrArray++;
    }
    *out = *ptrArray;
}


// Dado un array de vectores, devuelve un puntero a aquel con mayor longitud.
vector_t* vector_mas_grande(vector_t** array_de_vectores, size_t longitud_del_array) {
    if(array_de_vectores == NULL) {
        return NULL;
    }

    vector_t* vectorGanador = array_de_vectores[0];
    uint32_t longitudGanadora = vectorGanador->size;

    // Se puede usar esta notacion ** para arrays de arrays??? muy util pero no la termino de entender
    for(int32_t i = 0; i < longitud_del_array - 1; i++) {
        if(array_de_vectores[i]->size < array_de_vectores[i+1]->size) {
            longitudGanadora = array_de_vectores[i+1]->size;
            vectorGanador = array_de_vectores[i+1];
        }
    }

    return vectorGanador;

}
