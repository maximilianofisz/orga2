#include "classify_chars.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/*
¿Por qué al declarar un string en C no hace falta especificar su tamaño de antemano?
    - un string es un array de caracteres que termina en el caracter nulo '\0'.
    - Cuando declaras un string y lo arrancas con un string, el compilador calcula el tamañó del arreglo para incluir todos los chars del string mas el caracter nulo.
    - Esto hace que el compilador gestione el tamaño del array sin que el programador tenga que escribirlo explicitamente.

Supongamos que ahora nos interesa implementar una funcion para retornar ambas listas de vocales y consonantes.
El lenguaje C no nos provee ninguna forma sintactica de retornar mas de un dato de una funcion.
Explorar distintas formas que se podrıa resolver este problema (al menos dos formas distintas, y que funcionen).
    - Podemos usar punteros como argumentos de la función.
    - La función modificaría los valores en estas direcciones de memoria, permitiendo que los cambios se reflejen en las variables originales.
    - Podemos armar una estructura que contenga los valores que quiero retornar y usarla como el tipo de retorno de la función.

    typedef struct {
        char vocales[];
        char consonantes[];
    } ResultadoVyC;

    ResultadoVyC obtenerVyC(char *input){
        resultadoVyC res;
        // etc..
        return res;
    }


*/

// Opcion 1: que nos pasen punteros y nosotros se los apuntamos a las vocales y consonantes
void recuperarPtrs(classifier_t classy, char* vocales, char* consonantes) {
    vocales = classy.vowels_and_consonants[0];
    consonantes = classy.vowels_and_consonants[1];
}

// Opcion 2: que nos pasen solo el classy y les devolvemos un struct
typedef struct ptrsToLetters_s {
    char* vowels;
    char* consonants;
} ptrsToLetters_t;

ptrsToLetters_t* recuperarUnStruct(classifier_t classy) {
    // Hay que liberar este struct en algun momento!!!
    ptrsToLetters_t* result = malloc(sizeof(ptrsToLetters_t));
    result->vowels = classy.vowels_and_consonants[0];
    result->consonants = classy.vowels_and_consonants[1];
    return result;
}

void classify_chars_in_string(char* string, char** vowels_and_cons) {
    char* letraActual = string;
    // Recorremos una palabra hasta su caracter de terminacion
    while(*letraActual != '\0') {
        // Tenemos que recorrer todo el ""array"" de vocales O consonantes para poder agregar otra mas al final
        char* iteradorVyC;

        // Caso la letra es vocal
        if(is_vowel(letraActual) == 1) {
            iteradorVyC = vowels_and_cons[0];

            // Buscamos la ultima letra sin terminador
            while(*iteradorVyC != '\0') {
                iteradorVyC++;
            }

            // Agregamos donde esta el terminador nuestra letra y ponemos el term en la sig
            *iteradorVyC = *letraActual;
            iteradorVyC++;
            *iteradorVyC = '\0';
        }
        // Caso la letra es consonante
        else {
            iteradorVyC = vowels_and_cons[1];

            // Buscamos la ultima letra sin terminador
            while(*iteradorVyC != '\0') {
                iteradorVyC++;
            }

            // Agregamos donde esta el terminador nuestra letra y ponemos el term en la sig
            *iteradorVyC = *letraActual;
            iteradorVyC++;
            *iteradorVyC = '\0';
        }
        letraActual++;
    }
}


void classify_chars(classifier_t* array, uint64_t size_of_array) {

    for(uint32_t i = 0; i < size_of_array; i++) {
        char* vowelPtr = calloc(1, 64 * sizeof(char));
        char* cnstPtr = calloc(1, 64 * sizeof(char));

        char** vyc = malloc(2 * sizeof(char*));

        array->vowels_and_consonants = vyc;
        array->vowels_and_consonants[0] = vowelPtr;
        array->vowels_and_consonants[1] = cnstPtr;

        // Voy a arrancar con el caracter de terminacion en la primera posicion y despues lo voy empujando
        *array->vowels_and_consonants[0] = '\0';
        *array->vowels_and_consonants[1] = '\0';

        classify_chars_in_string(array->string, array->vowels_and_consonants);

        array++;
    }
}

// Para hacer mas lindo el check
int is_vowel(char* letterPtr) {
    char letter = *letterPtr;
    if(letter == 97 || letter == 101 || letter == 105 || letter == 111 || letter == 117) {
        return 1;

    }
    else {
        return 0;
    }
}



