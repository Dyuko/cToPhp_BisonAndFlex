 
%{
    #include <stdio.h>
    #include <stdlib.h>
	#include <string.h>
	#ifndef YYSTYPE
    	# define YYSTYPE char*
	#endif
	#define TRUE 1
	#define FALSE 0
    extern int yylex();
    extern int yyparse();
	extern FILE *yyin;
	extern FILE *yyout;
    void yyerror(const char* s);

	//Una estructura que representa un conjunto de banderas de estados
	struct bandera_estado
	{
		int funcion_declarada;
	};

	struct bandera_estado bandera_estado;

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
	: IDENTIFIER	{
						if(bandera_estado.funcion_declarada == TRUE)
						{
							fprintf(yyout, "%s", $1);
							bandera_estado.funcion_declarada = FALSE;
						}
						else
						{
							fprintf(yyout, "$%s", $1);
						}
					}
	| constant
	| string
	| '(' { fprintf(yyout, "( "); } expression ')' { fprintf(yyout, " )"); }
	| generic_selection
	;

constant
	: I_CONSTANT {fprintf(yyout, "%s", $1);}		/* includes character_constant */
	| F_CONSTANT {fprintf(yyout, "%s", $1);}
	| ENUMERATION_CONSTANT {fprintf(yyout, "%s", $1);}	/* after it has been defined as such */
	;

enumeration_constant		/* before it has been defined as such */
	: IDENTIFIER
	;

string
	: STRING_LITERAL {fprintf(yyout, "%s", $1);}
	| FUNC_NAME {fprintf(yyout, "%s", $1);}
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
	| postfix_expression '[' expression ']'
	| postfix_expression '(' ')'
	| postfix_expression '(' argument_expression_list ')'
	| postfix_expression '.' IDENTIFIER
	| postfix_expression PTR_OP IDENTIFIER
	| postfix_expression INC_OP
	| postfix_expression DEC_OP
	| '(' type_name ')' '{' initializer_list '}'
	| '(' type_name ')' '{' initializer_list ',' '}'
	;

argument_expression_list
	: assignment_expression
	| argument_expression_list ',' { fprintf(yyout, ", "); } assignment_expression
	;

unary_expression
	: postfix_expression
	| INC_OP { fprintf(yyout, $1); } unary_expression
	| DEC_OP { fprintf(yyout, $1); } unary_expression
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
	;

additive_expression
	: multiplicative_expression
	| additive_expression '+' { fprintf(yyout, " + "); } multiplicative_expression
	| additive_expression '-' { fprintf(yyout, " - "); } multiplicative_expression
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
	;

equality_expression
	: relational_expression
	| equality_expression EQ_OP { fprintf(yyout, " == "); } relational_expression
	| equality_expression NE_OP { fprintf(yyout, " != "); } relational_expression
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
	;

logical_or_expression
	: logical_and_expression
	| logical_or_expression OR_OP { fprintf(yyout, " || "); } logical_and_expression
	;

conditional_expression
	: logical_or_expression
	| logical_or_expression '?' { fprintf(yyout, " ? "); } expression ':' { fprintf(yyout, " : "); } conditional_expression
	;

assignment_expression
	: conditional_expression
	| unary_expression assignment_operator assignment_expression
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
	| expression ',' { fprintf(yyout, ", "); } assignment_expression
	;

constant_expression
	: conditional_expression	/* with constraints */
	;

declaration
	: declaration_specifiers ';' {fprintf(yyout, ";\n");}
	| declaration_specifiers init_declarator_list ';' {fprintf(yyout, ";\n");}
	| static_assert_declaration
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
	: init_declarator
	| init_declarator_list ',' { fprintf(yyout, ";\n"); } init_declarator
	;

init_declarator
	: declarator '=' {fprintf(yyout, "=");} initializer
	| declarator
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
	| direct_declarator
	;

direct_declarator
	: IDENTIFIER	{ 
						if(bandera_estado.funcion_declarada == TRUE)
						{
							fprintf(yyout, "function %s", $1);
							bandera_estado.funcion_declarada = FALSE;
						}
						else
						{
							fprintf(yyout, "$%s", $1);
						}
					}

	| '(' declarator ')'
	| direct_declarator '[' ']'
	| direct_declarator '[' '*' ']'
	| direct_declarator '[' STATIC type_qualifier_list assignment_expression ']'
	| direct_declarator '[' STATIC assignment_expression ']'
	| direct_declarator '[' type_qualifier_list '*' ']'
	| direct_declarator '[' type_qualifier_list STATIC assignment_expression ']'
	| direct_declarator '[' type_qualifier_list assignment_expression ']'
	| direct_declarator '[' type_qualifier_list ']'
	| direct_declarator '[' assignment_expression ']'
	| direct_declarator '(' { fprintf(yyout, "( "); } parameter_type_list ')' { fprintf(yyout, " )"); }
	| direct_declarator '(' { fprintf(yyout, "( "); }')' { fprintf(yyout, " )"); }
	| direct_declarator '(' { fprintf(yyout, "( "); } identifier_list ')' { fprintf(yyout, " )"); }
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
	| declaration_specifiers abstract_declarator
	| declaration_specifiers
	;

identifier_list
	: IDENTIFIER
	| identifier_list ',' IDENTIFIER
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
	: IDENTIFIER { fprintf(yyout, $1); } ':' { fprintf(yyout, ": "); } statement
	| CASE { fprintf(yyout, "case "); } constant_expression ':' { fprintf(yyout, ": "); } statement
	| DEFAULT { fprintf(yyout, "default "); } ':' { fprintf(yyout, ": "); } statement
	;

compound_statement
	: '{' { fprintf(yyout, "{ "); } '}' { fprintf(yyout, " }\n"); }
	| '{' { fprintf(yyout, "{\n"); } block_item_list '}' { fprintf(yyout, "}\n"); }
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
	;

selection_statement
	: IF { fprintf(yyout, "if"); } '(' { fprintf(yyout, "( "); } expression ')' { fprintf(yyout, " )"); } statement if_resto
	| SWITCH { fprintf(yyout, "switch"); } '(' { fprintf(yyout, "( "); } expression ')' { fprintf(yyout, " )"); } statement
	;

if_resto
	: ELSE { fprintf(yyout, "else"); } statement
	| 
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
	;

jump_statement
	: GOTO IDENTIFIER ';'
	| CONTINUE ';'				{fprintf(yyout,"continue;\n");}
	| BREAK ';'					{fprintf(yyout,"break;\n");}
	| RETURN ';'				{fprintf(yyout,"return;\n");}
	| RETURN {fprintf(yyout,"return ");} expression ';'	{fprintf(yyout,";\n");}
	;

translation_unit
	: external_declaration
	| translation_unit external_declaration
	;

external_declaration
	: function_definition
	| declaration
	;

function_definition
	: declaration_specifiers declarator declaration_list compound_statement
	| declaration_specifiers declarator compound_statement
	;

declaration_list
	: declaration
	| declaration_list declaration
	;

%%
int main(int argc,char **argv)
{
	if(argc != 3)	//La cantidad de parámetros debe ser tres
	{
		printf("Parámetros incorrectos.");
	}
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
	yyparse();
	
	fclose(yyin);		//Cerrar archivo de entrada
	fclose(yyout);	//Cerrar archivo de salida
}

void yyerror(const char *s)
{
	fflush(stdout);
	fprintf(stderr, "*** %s\n", s);
}