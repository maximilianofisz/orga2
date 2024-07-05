#include "contar_espacios.h"
#include <stdio.h>

uint32_t longitud_de_string(char* string) {
uint32_t contador=0; // contador de longitud del string
if(string == NULL) {
    return contador;
}
// queremos calcular el size del string
// *string nos dice el valor del puntero (o sea que valor vale a lo que apunta)
    while(*string != '\0') // backslash cero nos dice que termina el string 
    {
        contador++;
        string++; // apunta al siguiente
    }

    return contador;

}

uint32_t contar_espacios(char* string) {
    uint32_t contadorEspacios=0; // contador de longitud del string
    if(string == NULL) {
    return contadorEspacios;
}
    // queremos calcular el size del string
    // *string nos dice el valor del puntero (o sea que valor vale a lo que apunta)
    while(*string != '\0') // backslash cero nos dice que termina el string 
    {
        if(*string == ' ') {
            contadorEspacios++;
        }
        string++; // apunta al siguiente
    }

    return contadorEspacios;
}

