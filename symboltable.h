#include <stdio.h>
#include <stdlib.h>
#include <string.h>
/* Function type. */
typedef double (func_t) (double);

/* Data type for links in the chain of symbols. */
struct symrec
{
	char *name;			/* name of symbol */
	char *type;			/* type of symbol */
	double value;				/* value of a VAR */
	int function;
	struct symrec *next;		/* link field */
};

typedef struct symrec symrec;

/* The symbol table: a chain of 'struct symrec'. */
extern symrec *sym_table;

symrec * putsym(char *sym_name,	char* sym_type, int b_function);
symrec * getsym(char *sym_name_name);
void print_sym_table();