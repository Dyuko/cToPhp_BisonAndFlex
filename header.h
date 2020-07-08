#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define T_VARIABLE 0
#define T_FUNCTION 1
#define T_CONSTANT 2
/* Function type. */
typedef double (func_t) (double);

/* Data type for links in the chain of symbols. */
struct symrec
{
	char *name;			/* name of symbol */
	char *type;			/* type of symbol */
	int function;
	struct symrec *next;		/* link field */
};

typedef struct symrec symrec;

/* The symbol table: a chain of 'struct symrec'. */
extern symrec *sym_table;

/* 
* Una estructura que representa un conjunto de banderas de estados
* parche_imprimir_array: Bandera utilizada para corregir orden de impresión incorrecta al declarar un array con elementos
* funcion_declarada: Si se declara una función en c, en php debo imprimir function 
* ignorar_dimension_vector: En c se declara la dimensión del vector, en php lo ignoro
* ignorar_vector_multidimensional: Si se detecta un vector multidimensional en c, debo evitar imprimir array() array() en php
* variable_global_detectada: Si se ha detectado una variable global declarada en c
* cerrar_parentesis_array: Bandera utilizada para imprimir correctamente al declarar un array
* debug_mode: Utilizado para debuggear, habilita la impresión de identificadores en las reglas semánticas 
*/
struct bandera_estado
{
	int parche_imprimir_array;
	int funcion_declarada;
	int ignorar_dimension_vector;
	int ignorar_vector_multidimensional;
	int cerrar_parentesis_array;
	int debug_mode;
};

//Declaración de funciones
symrec * putsym(char *sym_name,	char* sym_type, int b_function);
symrec * getsym(char *sym_name_name);
void print_sym_table();
void comprobacion_de_tipo(char* operando_1, char* operando_2, char operacion);