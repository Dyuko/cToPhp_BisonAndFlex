#include "header.h"
/*
* Función put para la tabla de símbolos
*/
symrec * putsym(char *sym_name,	char* sym_type, int b_function)
{
	symrec *ptr;
	ptr = (symrec *) malloc(sizeof(symrec));
	ptr->name = (char *) malloc(strlen(sym_name) + 1);
	strcpy(ptr->name, sym_name);
	ptr->type = sym_type;
	ptr->value = 0; //set value to 0
	ptr->function = b_function;
	ptr->next =(struct symrec *) sym_table;
	sym_table = ptr;
	return ptr;
}
/*
* Función get para la tabla de símbolos
*/
symrec * getsym(char *sym_name)
{
	symrec *ptr;
	for(ptr = sym_table; ptr != (symrec*)0; ptr = (symrec *)ptr->next)
		if(strcmp(ptr->name, sym_name) == 0)
		{
			//printf("simbolo: %s\n", ptr->name);
			return ptr;
		}
	return 0;
}
/*
* Imprimir la tabla de símbolos
*/
void print_sym_table()
{
	printf("\n\t\t\tTabla de símbolos\n");
	printf("Identificador\t\tTipo de valor\t\tTipo de símbolo\n");
    symrec *ptr;
    for (ptr = sym_table; ptr != (symrec *)0; ptr = (symrec *)ptr->next)
	{
        printf("%s\t\t\t%s", ptr->name, ptr->type);
		switch(ptr->function)
		{
			case T_FUNCTION: 
						printf("\t\t\tFunción\n");
						break;
			case T_VARIABLE: 
						printf("\t\t\tVariable\n");
						break;
			case T_CONSTANT: 
						printf("\t\t\tConstante\n");
						break;
		}
	}	
}