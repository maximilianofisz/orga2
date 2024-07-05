#include "task_lib.h"

#define WIDTH TASK_VIEWPORT_WIDTH
#define HEIGHT TASK_VIEWPORT_HEIGHT

#define SHARED_SCORE_BASE_VADDR (PAGE_ON_DEMAND_BASE_VADDR + 0xF00)
#define CANT_PONGS 3


void task(void) {
	screen pantalla;
	// ¿Una tarea debe terminar en nuestro sistema?
	while (true)
	{
	// Completar:
	// - Pueden definir funciones auxiliares para imprimir en pantalla
	// - Pueden usar `task_print`, `task_print_dec`, etc.
		uint8_t boardId = ENVIRONMENT->task_id; // mi propio id, no lo quiero chequear, asumo que todo el resto son pongs 
		uint8_t iteradorTareas;
		for(iteradorTareas = 0; iteradorTareas < MAX_TASKS - 1; iteradorTareas++){ // asumo que las tareas son pongs excepto la ultima que es el score, como reconozco que tareas son las otras?
			
			if(iteradorTareas == boardId) {
				continue; // evito mi propia tarea
			}

			uint8_t renglon = 5 + iteradorTareas * 2;

			uint32_t* current_task_record = (uint32_t*) SHARED_SCORE_BASE_VADDR + ((uint32_t) iteradorTareas * sizeof(uint32_t)*2);
			uint32_t score1 = current_task_record[0];
			uint32_t score2 = current_task_record[1];

			task_print(pantalla, "Pong", 1, renglon, C_FG_WHITE);
			task_print_dec(pantalla, iteradorTareas, 1, 6, renglon, C_FG_WHITE);
			task_print(pantalla, "-", 9, renglon, C_FG_WHITE);
			task_print(pantalla, "P1:", 11, renglon, C_FG_WHITE);
			task_print_dec(pantalla, score1, 2, 15, renglon, C_FG_WHITE);
			task_print(pantalla, "-", 18, renglon, C_FG_WHITE);
			task_print(pantalla, "P2:", 20, renglon, C_FG_WHITE);
			task_print_dec(pantalla, score2, 2, 24, renglon, C_FG_WHITE);
		}

	
		syscall_draw(pantalla);
	}
}
