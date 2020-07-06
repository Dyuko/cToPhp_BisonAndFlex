 %{
	#include "header.h"
	//Definir todos los tokens como tipo char*
	#ifndef YYSTYPE
    	# define YYSTYPE char*
	#endif
	#define TRUE 1
	#define FALSE 0
    extern int yylex();
    extern int yyparse();
	extern FILE *yyin;		// Puntero al archivo de entrada 
	extern FILE *yyout;		// Puntero al archivo de salida
	extern int yylineno;	// Número de línea actual en el archivo de entrada
	extern char* yytext;
    void yyerror(const char* s);
	void debug_mode(int indice);

	// Declaro e inicializo explícitamente 
	struct bandera_estado bandera_estado = {FALSE, FALSE, FALSE, FALSE, FALSE, FALSE};	

	//Symbol Table
	symrec *sym_table = (symrec * )0;
	symrec *s;
	symrec *symtable_set_type;
%}
%token	IDENTIFIER I_CONSTANT F_CONSTANT STRING_LITERAL FUNC_NAME SIZEOF
%token	PTR_OP INC_OP DEC_OP LEFT_OP RIGHT_OP LE_OP GE_OP EQ_OP NE_OP
%token	AND_OP OR_OP MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN ADD_ASSIGN
%token	SUB_ASSIGN LEFT_ASSIGN RIGHT_ASSIGN AND_ASSIGN
%token	XOR_ASSIGN OR_ASSIGN
%token	TYPEDEF_NAME ENUMERATION_CONSTANT
%token	TYPEDEF EXTERN STATIC AUTO REGISTER INLINE
%token	CONST RESTRICT VOLATILE
%token	BOOL CHAR SHORT INT LONG SIGNED UNSIGNED FLOAT DOUBLE VOID
%token	COMPLEX IMAGINARY 
%token	STRUCT UNION ENUM ELLIPSIS
%token	CASE DEFAULT IF ELSE SWITCH WHILE DO FOR GOTO CONTINUE BREAK RETURN
%token	ALIGNAS ALIGNOF ATOMIC GENERIC NORETURN STATIC_ASSERT THREAD_LOCAL
%start translation_unit
%%
primary_expression
	: IDENTIFIER{
		 			if (bandera_estado.funcion_declarada == TRUE)	//Si es una función imprimo "function"
					{ 
						fprintf(yyout, "function %s", $1); 
						bandera_estado.funcion_declarada = FALSE;
					} 
					else
					{ 
						fprintf(yyout, "$%s", $1);
					} 
					debug_mode(1);
				} 
	| constant
	| string
	| '('	{ 
				fprintf(yyout, "("); 
			}
	expression_cierre 
	| generic_selection
	;

expression_cierre
	: expression ')'	{ 
							fprintf(yyout, ")"); 
							debug_mode(2);
						}
	//Detección de error
	| expression error	{
							printf("Símbolo ')' faltante [expression_cierre]\n");
							yyerrok;
							yyclearin;
						}
	;

constant
	: I_CONSTANT	{
						//Al imprimir una constante debo verificar si esta no es la dimensión de un array, si lo es debo ignorarla
						if (bandera_estado.ignorar_dimension_vector == TRUE)
							bandera_estado.ignorar_dimension_vector = FALSE; //dejo de ignorar
						else
							fprintf(yyout, "%s", $1);
						debug_mode(3);
					}		
	| F_CONSTANT 	{
						if (bandera_estado.ignorar_dimension_vector == TRUE)
							bandera_estado.ignorar_dimension_vector = FALSE; //dejo de ignorar
						else
							fprintf(yyout, "%s", $1);
						debug_mode(4);
					}	
	| ENUMERATION_CONSTANT 
					{
						if (bandera_estado.ignorar_dimension_vector == TRUE)
							bandera_estado.ignorar_dimension_vector = FALSE; //dejo de ignorar
						else
							fprintf(yyout, "%s", $1);
						debug_mode(5);
					}	
	;

enumeration_constant		/* before it has been defined as such */
	: IDENTIFIER
	;

string
	: STRING_LITERAL {fprintf(yyout, "%s", $1); debug_mode(6);}
	| FUNC_NAME {fprintf(yyout, "%s", $1); debug_mode(7);}
	;

generic_selection
	: GENERIC '(' assignment_expression ',' generic_assoc_list ')'
	;

generic_assoc_list
	: generic_association
	| generic_assoc_list ',' generic_association
	;

generic_association
	: type_name ':' assignment_expression
	| DEFAULT ':' assignment_expression
	;

postfix_expression
	: primary_expression 
	| postfix_expression '['	{ 
									fprintf(yyout, "[ "); 
								}
	postfix_expression_corchete_cierre 
	| postfix_expression '(' { fprintf(yyout, "( "); } postfix_expression_parentesis_cierre
	| postfix_expression '.' IDENTIFIER
	| postfix_expression PTR_OP IDENTIFIER
	| postfix_expression INC_OP { fprintf(yyout, "++"); debug_mode(8);}
	| postfix_expression DEC_OP { fprintf(yyout, "--"); debug_mode(9);}
	| '(' type_name ')' '{' initializer_list '}'
	| '(' type_name ')' '{' initializer_list ',' '}'
	;

postfix_expression_corchete_cierre
	: expression ']'	{ 
							fprintf(yyout, " ]");
							debug_mode(10);
						}
	//Detección de error
	| expression error {
							printf("Símbolo ']' faltante [postfix_expression_corchete_cierre]\n");
							yyerrok;
							yyclearin;
						}
	;

postfix_expression_parentesis_cierre
	: ')'	{ 
				fprintf(yyout, " )"); 
				if(bandera_estado.debug_mode == TRUE)  
					fprintf(yyout, "*9*"); 
			}
	| argument_expression_list ')'	{ 
										fprintf(yyout, " )"); 
										debug_mode(11);
									}
	//Detección de error
	| argument_expression_list error	{
											printf("Símbolo ')' faltante [postfix_expression_parentesis_cierre]\n");
											yyerrok;
											yyclearin;
										}
	| error {
				printf("Símbolo ')' faltante [postfix_expression_parentesis_cierre]");
				yyerrok;
				yyclearin;
			}
	;

argument_expression_list
	: assignment_expression
	| argument_expression_list ',' { fprintf(yyout, ", "); } assignment_expression
	;

unary_expression
	: postfix_expression
	| INC_OP { fprintf(yyout, "++"); } unary_expression
	| DEC_OP { fprintf(yyout, "--"); } unary_expression
	| unary_operator cast_expression
	| SIZEOF unary_expression
	| SIZEOF '(' type_name ')'
	| ALIGNOF '(' type_name ')'
	;

unary_operator
	: '&' { fprintf(yyout, "&"); }
	| '*' { fprintf(yyout, "*"); }
	| '+' { fprintf(yyout, "+"); }
	| '-' { fprintf(yyout, "-"); }
	| '~' { fprintf(yyout, "~"); }
	| '!' { fprintf(yyout, "!"); }
	;

cast_expression
	: unary_expression
	| '(' type_name ')' cast_expression
	;

multiplicative_expression
	: cast_expression
	| multiplicative_expression '*' { fprintf(yyout, " * "); } cast_expression
	| multiplicative_expression '/' { fprintf(yyout, " / "); } cast_expression
	| multiplicative_expression '%' { fprintf(yyout, " %% "); } cast_expression
	//Detección de error
	| multiplicative_expression '*' error	{
												printf("Símbolo cast_expression faltante para operación '*' [multiplicative_expression]\n");
												yyerrok;
												yyclearin;
											}
	| multiplicative_expression '/' error	{
												printf("Símbolo cast_expression faltante para operación '/' [multiplicative_expression]\n");
												yyerrok;
												yyclearin;
											}
	| multiplicative_expression '%' error	{
												printf("Símbolo cast_expression faltante para operación '%' [multiplicative_expression]\n");
												yyerrok;
												yyclearin;
											}
	;

additive_expression
	: multiplicative_expression
	| additive_expression '+' { fprintf(yyout, " + "); } multiplicative_expression
	| additive_expression '-' { fprintf(yyout, " - "); } multiplicative_expression
	//Detección de error
	| additive_expression '+' error	{
										printf("Símbolo multiplicative_expression faltante para operación '+' [additive_expression]\n");
										yyerrok;
										yyclearin;
									}
	| additive_expression '-' error	{
										printf("Símbolo multiplicative_expression faltante para operación '-' [additive_expression]\n");
										yyerrok;
										yyclearin;
									}
	;

shift_expression
	: additive_expression
	| shift_expression LEFT_OP { fprintf(yyout, " << "); } additive_expression
	| shift_expression RIGHT_OP { fprintf(yyout, " >> "); } additive_expression
	;

relational_expression
	: shift_expression
	| relational_expression '<' { fprintf(yyout, " < "); } shift_expression
	| relational_expression '>' { fprintf(yyout, " > "); } shift_expression
	| relational_expression LE_OP { fprintf(yyout, " <= "); } shift_expression
	| relational_expression GE_OP { fprintf(yyout, " >= "); } shift_expression
	//Detección de error
	| relational_expression '<' error {printf("Símbolo shift_expression faltante para operación '<' [relational_expression]\n");}
	| relational_expression '>' error {printf("Símbolo shift_expression faltante para operación '>' [relational_expression]\n");}
	| relational_expression LE_OP error {printf("Símbolo shift_expression faltante para operación 'LE_OP' [relational_expression]\n");}
	| relational_expression GE_OP error {printf("Símbolo shift_expression faltante para operación 'GE_OP' [relational_expression]\n");}
	;

equality_expression
	: relational_expression
	| equality_expression EQ_OP { fprintf(yyout, " == "); } relational_expression
	| equality_expression NE_OP { fprintf(yyout, " != "); } relational_expression
	//Detección de errores
	| equality_expression NE_OP error {printf("Símbolo relational_expression faltante para operación 'NE_OP' [equality_expression]\n");}
	| equality_expression EQ_OP error {printf("Símbolo relational_expression faltante para operación 'EQ_OP' [equality_expression]\n");}
	;

and_expression
	: equality_expression
	| and_expression '&' { fprintf(yyout, " & "); } equality_expression
	;

exclusive_or_expression
	: and_expression
	| exclusive_or_expression '^' { fprintf(yyout, " ^ "); } and_expression
	;

inclusive_or_expression
	: exclusive_or_expression
	| inclusive_or_expression '|' { fprintf(yyout, " | "); } exclusive_or_expression
	;

logical_and_expression
	: inclusive_or_expression
	| logical_and_expression AND_OP { fprintf(yyout, " && "); } inclusive_or_expression
	//Detección de error
	| logical_and_expression AND_OP error {printf("Error operador AND_OP\n");}
	;

logical_or_expression
	: logical_and_expression
	| logical_or_expression OR_OP { fprintf(yyout, " || "); } logical_and_expression
	//Detección de error
	| logical_or_expression OR_OP error {printf("Error operador OR_OP\n");}
	;

conditional_expression
	: logical_or_expression
	| logical_or_expression '?' { fprintf(yyout, " ? "); } expression ':' { fprintf(yyout, " : "); } conditional_expression
	;

assignment_expression
	: conditional_expression
	| unary_expression assignment_operator assignment_expression
	//Detección de error
	| unary_expression assignment_operator error {printf("Error operador assignment_operator\n");} 
	;

assignment_operator
	: '=' { fprintf(yyout, " = "); }
	| MUL_ASSIGN { fprintf(yyout, " *= "); }
	| DIV_ASSIGN { fprintf(yyout, " /= "); }
	| MOD_ASSIGN { fprintf(yyout, " %%= "); }
	| ADD_ASSIGN { fprintf(yyout, " += "); }
	| SUB_ASSIGN { fprintf(yyout, " -= "); }
	| LEFT_ASSIGN { fprintf(yyout, " <<= "); }
	| RIGHT_ASSIGN { fprintf(yyout, " >>= "); }
	| AND_ASSIGN { fprintf(yyout, " &= "); }
	| XOR_ASSIGN { fprintf(yyout, " ^= "); }
	| OR_ASSIGN { fprintf(yyout, " |= "); }
	;

expression
	: assignment_expression
	| expression ',' { fprintf(yyout, ", "); debug_mode(12);} assignment_expression
	| expression ',' error { printf("Error de expresión de asignación\n");  }
	;

constant_expression
	: conditional_expression	/* with constraints */
	;

declaration
	: declaration_specifiers ';'	{
										fprintf(yyout, ";\n"); 
										debug_mode(13);
									}
	| declaration_specifiers init_declarator_list ';'	
				{
					fprintf(yyout, "$%s", $2);	//Es para declaraciones tipo int global;
					if(bandera_estado.parche_imprimir_array == TRUE)
					{
						fprintf(yyout, "=array( ");
						bandera_estado.parche_imprimir_array = FALSE; 
					}
					if(bandera_estado.ignorar_vector_multidimensional == TRUE
					&& bandera_estado.cerrar_parentesis_array == TRUE)
					{
						fprintf(yyout, " );\n");
						bandera_estado.ignorar_vector_multidimensional = FALSE;
						bandera_estado.cerrar_parentesis_array = FALSE;
					}
					else
						fprintf(yyout, ";\n");
					debug_mode(14);
					//Symbol Table
					for(symtable_set_type=sym_table; symtable_set_type!=(symrec *)0; symtable_set_type=(symrec *)symtable_set_type->next){
								if(symtable_set_type->type == NULL){
									symtable_set_type->type=$1;
								}
							}
				}														
	| static_assert_declaration
	//Detección de error
	| declaration_specifiers init_declarator_list error { printf("Error con ; faltante \n");  }
	| declaration_specifiers error { printf("Error en declaración\n");  }
	;

declaration_specifiers
	: storage_class_specifier declaration_specifiers
	| storage_class_specifier
	| type_specifier declaration_specifiers
	| type_specifier
	| type_qualifier declaration_specifiers
	| type_qualifier
	| function_specifier declaration_specifiers
	| function_specifier
	| alignment_specifier declaration_specifiers
	| alignment_specifier
	;

init_declarator_list
	: init_declarator	{
							$$=$1;	//Atributo sintetizado
						}
	| init_declarator_list ',' { fprintf(yyout, ";\n"); debug_mode(15);} init_declarator
	;

init_declarator
	: declarator	{
						s = getsym($1);
						if (s==(symrec *)0)
						{
							s = putsym($1, NULL, 0);
						}
						else
						{
							printf("Variable ya declarada!\n");
							yyerrok;	
						}
					}

	init_declarator_resto
	;

init_declarator_resto
	: '='	{
				if(bandera_estado.cerrar_parentesis_array == TRUE) 
					fprintf(yyout, "=");
				debug_mode(16);
			} 
	initializer
	|
	//Detección de error 
	| error initializer {printf("Error en inicialización de variable\n");}
	| '=' error {printf("Error en inicialización de variable\n");}
	;

storage_class_specifier
	: TYPEDEF	/* identifiers must be flagged as TYPEDEF_NAME */
	| EXTERN
	| STATIC
	| THREAD_LOCAL
	| AUTO
	| REGISTER
	;

type_specifier
	: VOID
	| CHAR
	| SHORT
	| INT
	| LONG
	| FLOAT
	| DOUBLE
	| SIGNED
	| UNSIGNED
	| BOOL
	| COMPLEX
	| IMAGINARY	  	/* non-mandated extension */
	| atomic_type_specifier
	| struct_or_union_specifier
	| enum_specifier
	| TYPEDEF_NAME		/* after it has been defined as such */
	;

struct_or_union_specifier
	: struct_or_union '{' struct_declaration_list '}'
	| struct_or_union IDENTIFIER '{' struct_declaration_list '}'
	| struct_or_union IDENTIFIER
	//Detección de error
	| struct_or_union '{' struct_declaration_list error {printf("Símbolo faltante \"}\"\n");}
	| struct_or_union IDENTIFIER '{' struct_declaration_list error {printf("Símbolo faltante \"}\"\n");}
	;

struct_or_union
	: STRUCT
	| UNION
	;

struct_declaration_list
	: struct_declaration
	| struct_declaration_list struct_declaration
	;

struct_declaration
	: specifier_qualifier_list ';'	/* for anonymous struct/union */
	| specifier_qualifier_list struct_declarator_list ';'
	| static_assert_declaration
	//Detección de error
	| specifier_qualifier_list struct_declarator_list error  {printf("Símbolo faltante ;\n");}
	;

specifier_qualifier_list
	: type_specifier specifier_qualifier_list
	| type_specifier
	| type_qualifier specifier_qualifier_list
	| type_qualifier
	;

struct_declarator_list
	: struct_declarator
	| struct_declarator_list ',' struct_declarator
	;

struct_declarator
	: ':' constant_expression
	| declarator ':' constant_expression
	| declarator
	;

enum_specifier
	: ENUM '{' enumerator_list '}'
	| ENUM '{' enumerator_list ',' '}'
	| ENUM IDENTIFIER '{' enumerator_list '}'
	| ENUM IDENTIFIER '{' enumerator_list ',' '}'
	| ENUM IDENTIFIER
	;

enumerator_list
	: enumerator
	| enumerator_list ',' enumerator
	;

enumerator	/* identifiers must be flagged as ENUMERATION_CONSTANT */
	: enumeration_constant '=' constant_expression
	| enumeration_constant
	;

atomic_type_specifier
	: ATOMIC '(' type_name ')'
	;

type_qualifier
	: CONST { fprintf(yyout, "const "); }
	| RESTRICT { fprintf(yyout, "restrict "); } 
	| VOLATILE { fprintf(yyout, "volatile "); }
	| ATOMIC { fprintf(yyout, "atomic "); }
	;

function_specifier
	: INLINE
	| NORETURN
	;

alignment_specifier
	: ALIGNAS '(' type_name ')'
	| ALIGNAS '(' constant_expression ')'
	;

declarator
	: pointer direct_declarator
	| direct_declarator	{
							$$ = $1;	//Atributo sintetizado necesario
						}
	;

direct_declarator
	: IDENTIFIER	{ 
						$$ = $1;	//Atributo sintetizado necesario
						debug_mode(17);
					}

	| '(' declarator ')'
	| direct_declarator '[' { if (bandera_estado.ignorar_vector_multidimensional == FALSE) fprintf(yyout, "=array( "); bandera_estado.ignorar_vector_multidimensional = TRUE; }
	 ']' { bandera_estado.cerrar_parentesis_array =TRUE; debug_mode(18);}
	| direct_declarator '[' '*' ']'
	| direct_declarator '[' STATIC type_qualifier_list assignment_expression ']'
	| direct_declarator '[' STATIC assignment_expression ']'
	| direct_declarator '[' type_qualifier_list '*' ']'
	| direct_declarator '[' type_qualifier_list STATIC assignment_expression ']'
	| direct_declarator '[' type_qualifier_list assignment_expression ']'
	| direct_declarator '[' type_qualifier_list ']'
	| direct_declarator '[' { 
								bandera_estado.ignorar_dimension_vector = TRUE; 
								if (bandera_estado.ignorar_vector_multidimensional == FALSE) 
									bandera_estado.parche_imprimir_array = TRUE; 
								bandera_estado.ignorar_vector_multidimensional = TRUE; 
							}
	assignment_expression ']' 	{ 
									bandera_estado.cerrar_parentesis_array = TRUE; 
									debug_mode(19);
								}
	| direct_declarator '(' { fprintf(yyout, "( "); } parameter_type_list ')' { fprintf(yyout, " )"); debug_mode(20);}
	| direct_declarator '(' ')' {
									fprintf(yyout, "function %s ()", $1);
									if(bandera_estado.debug_mode == TRUE) { fprintf(yyout, "*22*"); }
								}
	| direct_declarator '(' { fprintf(yyout, "( "); } identifier_list ')' { fprintf(yyout, " )"); debug_mode(21);}
	//Detección de error
	| direct_declarator '[' error {printf("Símbolo faltante \"]\"\n");}
	| direct_declarator '(' error {printf("Símbolo faltante \")\"\n");}
	;

pointer
	: '*' type_qualifier_list pointer
	| '*' type_qualifier_list
	| '*' pointer
	| '*'
	;

type_qualifier_list
	: type_qualifier
	| type_qualifier_list type_qualifier
	;


parameter_type_list
	: parameter_list ',' ELLIPSIS
	| parameter_list
	;

parameter_list
	: parameter_declaration
	| parameter_list ',' { fprintf(yyout, ", "); } parameter_declaration
	;

parameter_declaration
	: declaration_specifiers declarator
									{
										//Symbol Table
										s=getsym($2);
										if(s==(symrec *) 0)
										{
											s=putsym($2, $1, 0);
										}
										else
										{
											printf("Variable ya declarada!\n");
											yyerrok;
										}
									}	
	| declaration_specifiers abstract_declarator
	| declaration_specifiers
	| declaration_specifiers error declarator {printf("Error en declaración de parámetros\n");}
	;

identifier_list
	: IDENTIFIER
	| identifier_list ',' IDENTIFIER
	| identifier_list error',' IDENTIFIER {printf("Error en lista de identificadores\n");}
	;

type_name
	: specifier_qualifier_list abstract_declarator
	| specifier_qualifier_list
	;

abstract_declarator
	: pointer direct_abstract_declarator
	| pointer
	| direct_abstract_declarator
	;

direct_abstract_declarator
	: '(' abstract_declarator ')'
	| '[' ']'
	| '[' '*' ']'
	| '[' STATIC type_qualifier_list assignment_expression ']'
	| '[' STATIC assignment_expression ']'
	| '[' type_qualifier_list STATIC assignment_expression ']'
	| '[' type_qualifier_list assignment_expression ']'
	| '[' type_qualifier_list ']'
	| '[' assignment_expression ']'
	| direct_abstract_declarator '[' ']'
	| direct_abstract_declarator '[' '*' ']'
	| direct_abstract_declarator '[' STATIC type_qualifier_list assignment_expression ']'
	| direct_abstract_declarator '[' STATIC assignment_expression ']'
	| direct_abstract_declarator '[' type_qualifier_list assignment_expression ']'
	| direct_abstract_declarator '[' type_qualifier_list STATIC assignment_expression ']'
	| direct_abstract_declarator '[' type_qualifier_list ']'
	| direct_abstract_declarator '[' assignment_expression ']'
	| '(' ')'
	| '(' parameter_type_list ')'
	| direct_abstract_declarator '(' ')'
	| direct_abstract_declarator '(' parameter_type_list ')'
	;

initializer
	: '{' initializer_list '}'
	| '{' initializer_list ',' '}'
	| assignment_expression
	//Detección de error
	| '{' initializer_list ',' error {printf("Símbolo faltante }\n");}
	| '{' initializer_list error {printf("Símbolo faltante }\n");}
	;

initializer_list
	: designation initializer
	| initializer
	| initializer_list ',' { fprintf(yyout, " ,"); } initializer_list_resto
	;

initializer_list_resto
	: designation initializer
	| initializer
	;

designation
	: designator_list '='
	;

designator_list
	: designator
	| designator_list designator
	;

designator
	: '[' constant_expression ']'
	| '.' IDENTIFIER
	;

static_assert_declaration
	: STATIC_ASSERT '(' constant_expression ',' STRING_LITERAL ')' ';'
	;

statement
	: labeled_statement
	| compound_statement
	| expression_statement
	| selection_statement
	| iteration_statement
	| jump_statement
	;

labeled_statement
	: IDENTIFIER { fprintf(yyout, $1); } ':' { fprintf(yyout, ": "); } statement {debug_mode(22);}
	| CASE { fprintf(yyout, "case "); } constant_expression ':' { fprintf(yyout, ": "); } statement {debug_mode(23);}
	| DEFAULT { fprintf(yyout, "default "); } ':' { fprintf(yyout, ": "); } statement {debug_mode(24);}
	;

compound_statement
	: '{' { fprintf(yyout, "{\n"); } compound_statement_cierre
	//Detección de error
	;

compound_statement_cierre
	: '}' { fprintf(yyout, " }\n"); debug_mode(25);}
	|  block_item_list '}' { fprintf(yyout, "}\n"); debug_mode(26);}
	//Detección de error
	| error {printf("Símbolo faltante }\n");}
	| block_item_list error {printf("Símbolo faltante }\n");}
	;

block_item_list
	: block_item
	| block_item_list block_item
	;

block_item
	: declaration
	| statement
	;

expression_statement
	: ';' { fprintf(yyout, ";\n"); }
	| expression ';' { fprintf(yyout, ";\n"); }
	//Detección de error
	| expression error {printf("Símbolo faltante ; \n");}
	;

selection_statement
	: IF '(' { fprintf(yyout, "if ( "); } expression statement if_resto
	| SWITCH '(' { fprintf(yyout, "switch ( "); } switch_resto
	;

if_resto
	: ')' { fprintf(yyout, " )"); } ELSE { fprintf(yyout, "else"); } statement
	| ')' { fprintf(yyout, " )"); }
	| error	{printf("En el if, Símbolo faltante \")\"\n");}
	;

switch_resto
	: expression ')' { fprintf(yyout, " )"); } statement
	| expression error {printf("En el switch. Símbolo faltante \")\"\n");}
	;

iteration_statement
	: WHILE '(' expression ')' statement
	| DO statement WHILE '(' expression ')' ';'
	| FOR { fprintf(yyout, "for"); } '(' { fprintf(yyout, "( "); } for_resto
	;

for_resto
	: expression_statement expression_statement ')' { fprintf(yyout, " )"); } statement
	| expression_statement expression_statement expression ')' { fprintf(yyout, " )"); } statement
	| declaration expression_statement ')' { fprintf(yyout, " )"); } statement
	| declaration expression_statement expression ')' { fprintf(yyout, " )"); } statement
	//Detección de error
	| error  {printf("Error cerca del for\n");}
	;

jump_statement
	: GOTO IDENTIFIER ';'
	| CONTINUE ';'				{fprintf(yyout,"continue;\n");}
	| BREAK ';'					{fprintf(yyout,"break;\n");}
	| RETURN {fprintf(yyout,"return ");} return_resto
	;

return_resto
	: ';'				{fprintf(yyout,"return;\n");}
	| expression ';'	{fprintf(yyout,";\n");}
	| error 			{printf("Error en return\n");}
	| expression error	{printf("Cerca del return. Símbolo ; faltante\n");}
	;

translation_unit	
	: external_declaration
	| translation_unit external_declaration
	;
//declaración externa
external_declaration	
	//declaración de función
	: function_definition {bandera_estado.funcion_declarada = TRUE;if(bandera_estado.debug_mode == TRUE) { fprintf(yyout, "*29*"); }}
	//declaración global
	| declaration
	;
//Declaración de una función
function_definition
	: declaration_specifiers declarator declaration_list compound_statement {debug_mode(27);}
	| declaration_specifiers declarator compound_statement 	{ 
																debug_mode(28);
																
																//Symbol Table
																s=getsym($2);
																if(s==(symrec *)0)
																{
																	s=putsym($2,$1,1);
																}
																else
																{
																	printf("Funcion ya declarada!");
																	yyerrok;
																}
															}
	;

declaration_list
	: declaration
	| declaration_list declaration
	;

%%
int main(int argc,char **argv)
{
	if(argc != 3)	//La cantidad de parámetros debe ser tre
		printf("Parámetros incorrectos.");

	char* archivo_c = argv[1];		//Path al archivo c 
	char* archivo_php = argv[2];	//Path al archivo php

	if ((yyin = fopen(archivo_c, "r")) == NULL)	//Establecer archivo c como archivo de entrada
	{
		printf("Error al abrir el archivo de lectura %s", archivo_c);
		return 1;
	}
	if ((yyout = fopen(archivo_php, "w")) == NULL)	//Establecer archivo php como archivo de salida
	{
		printf("Error al abrir el archivo de escritura %s", archivo_c);
		return 1;
	}
	fprintf(yyout, "<?php\n");
	yyparse();
	fprintf(yyout, "main()\n");
	fprintf(yyout, "?>\n");
	print_sym_table();
	fclose(yyin);		//Cerrar archivo de entrada
	fclose(yyout);		//Cerrar archivo de salida
}

void yyerror(const char *s)
{
	printf("*** %s en la linea: %d    %s\n", s, yylineno,yytext);
}

/*Imprime un índice en las reglas semánticas para facilitar el debugueo */
void debug_mode(int indice)
{
	if(bandera_estado.debug_mode == TRUE)
		fprintf(yyout, "*%d*", indice);
}