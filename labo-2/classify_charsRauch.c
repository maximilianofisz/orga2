#include "classify_chars.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void classify_chars(classifier_t *array, uint64_t size_of_array)
{
    for (int idx = 0; idx < size_of_array; idx++)
    {
        array[idx].vowels_and_consonants = malloc(2 * sizeof(char *));
        array[idx].vowels_and_consonants[0] = calloc(64, 1);
        array[idx].vowels_and_consonants[1] = calloc(64, 1);

        int indice_vocales = 0;
        int indice_consonantes = 0;
        int i = 0;
        while (array[idx].string[i] != '\0')
        {
            if (array[idx].string[i] == 'a' || array[idx].string[i] == 'e' || array[idx].string[i] == 'i' || array[idx].string[i] == 'o' || array[idx].string[i] == 'u')
            {
                array[idx].vowels_and_consonants[0][indice_vocales] = array[idx].string[i];
                indice_vocales++;
            }
            else
            {
                array[idx].vowels_and_consonants[1][indice_consonantes] = array[idx].string[i];
                indice_consonantes++;
            }
            i++;
        }
    }
}
