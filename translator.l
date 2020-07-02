O   [0-7]
D   [0-9]
NZ  [1-9]
L   [a-zA-Z_]
A   [a-zA-Z_0-9]
H   [a-fA-F0-9]
HP  (0[xX])
E   ([Ee][+-]?{D}+)
P   ([Pp][+-]?{D}+)
FS  (f|F|l|L)
IS  (((u|U)(l|L|ll|LL)?)|((l|L|ll|LL)(u|U)?))
CP  (u|U|L)
SP  (u8|u|U|L)
ES  (\\(['"\?\\abfnrtv]|[0-7]{1,3}|x[a-fA-F0-9]+))
WS  [ \t\v\n\f]
%option yylineno
%{
#include <stdio.h>
#ifndef YYSTYPE
    # define YYSTYPE char*
#endif
#include "translator.tab.h"
extern void yyerror(const char *);  /* prints grammar violation message */
extern int sym_type(const char *);  /* returns type from symbol table */
#define sym_type(identifier) IDENTIFIER /* with no symbol table, fake it */
static void comment(void);
static int check_type(void);
%}

%%
^{WS}*#include{WS}*(<([^"'<>]+)>|\"([^"'<>]+)\")    {/*Ignorar directivas #include*/}
"/*"                                                { comment(); }
"//".*                                              { /* consume //-comment */ }

"auto"					                            { yylval=strdup(yytext); return(AUTO); }
"break"					                            { yylval=strdup(yytext); return(BREAK); }
"case"					                            { yylval=strdup(yytext); return(CASE); }
"char"					                            { yylval=strdup(yytext); return(CHAR); }
"const"					                            { yylval=strdup(yytext); return(CONST); }
"continue"				                            { yylval=strdup(yytext); return(CONTINUE); }
"default"				                            { yylval=strdup(yytext); return(DEFAULT); }
"do"					                            { yylval=strdup(yytext); return(DO); }
"double"				                            { yylval=strdup(yytext); return(DOUBLE); }
"else"					                            { yylval=strdup(yytext); return(ELSE); }
"enum"					                            { yylval=strdup(yytext); return(ENUM); }
"extern"				                            { yylval=strdup(yytext); return(EXTERN); }
"float"					                            { yylval=strdup(yytext); return(FLOAT); }
"for"					                            { yylval=strdup(yytext); return(FOR); }
"goto"					                            { yylval=strdup(yytext); return(GOTO); }
"if"					                            { yylval=strdup(yytext); return(IF); }
"inline"				                            { yylval=strdup(yytext); return(INLINE); }
"int"					                            { yylval=strdup(yytext); return(INT); }
"long"					                            { yylval=strdup(yytext); return(LONG); }
"register"				                            { yylval=strdup(yytext); return(REGISTER); }
"restrict"				                            { yylval=strdup(yytext); return(RESTRICT); }
"return"				                            { yylval=strdup(yytext); return(RETURN); }
"short"					                            { yylval=strdup(yytext); return(SHORT); }
"signed"				                            { yylval=strdup(yytext); return(SIGNED); }
"sizeof"			                            	{ yylval=strdup(yytext); return(SIZEOF); }
"static"				                            { yylval=strdup(yytext); return(STATIC); }
"struct"				                            { yylval=strdup(yytext); return(STRUCT); }
"switch"				                            { yylval=strdup(yytext); return(SWITCH); }
"typedef"				                            { yylval=strdup(yytext); return(TYPEDEF); }
"union"					                            { yylval=strdup(yytext); return(UNION); }
"unsigned"				                            { yylval=strdup(yytext); return(UNSIGNED); }
"void"					                            { yylval=strdup(yytext); return(VOID); }
"volatile"				                            { yylval=strdup(yytext); return(VOLATILE); }
"while"					                            { yylval=strdup(yytext); return(WHILE); }
"_Alignas"                                          { yylval=strdup(yytext); return ALIGNAS; }
"_Alignof"                                          { yylval=strdup(yytext); return ALIGNOF; }
"_Atomic"                                           { yylval=strdup(yytext); return ATOMIC; }
"_Bool"                                             { yylval=strdup(yytext); return BOOL; }
"_Complex"                                          { yylval=strdup(yytext); return COMPLEX; }
"_Generic"                                          { yylval=strdup(yytext); return GENERIC; }
"_Imaginary"                                        { yylval=strdup(yytext); return IMAGINARY; }
"_Noreturn"                                         { yylval=strdup(yytext); return NORETURN; }
"_Static_assert"                                    { yylval=strdup(yytext); return STATIC_ASSERT; }
"_Thread_local"                                     { yylval=strdup(yytext); return THREAD_LOCAL; }
"__func__"                                          { yylval=strdup(yytext); return FUNC_NAME; }

{L}{A}*					                            { yylval=strdup(yytext); return check_type(); }

{HP}{H}+{IS}?				                        { yylval=strdup(yytext); return I_CONSTANT; }
{NZ}{D}*{IS}?				                        { yylval=strdup(yytext); return I_CONSTANT; }
"0"{O}*{IS}?				                        { yylval=strdup(yytext); return I_CONSTANT; }
{CP}?"'"([^'\\\n]|{ES})+"'"	                        { yylval=strdup(yytext); return I_CONSTANT; }

{D}+{E}{FS}?				                        { yylval=strdup(yytext); return F_CONSTANT; }
{D}*"."{D}+{E}?{FS}?		                        { yylval=strdup(yytext); return F_CONSTANT; }
{D}+"."{E}?{FS}?			                        { yylval=strdup(yytext); return F_CONSTANT; }
{HP}{H}+{P}{FS}?			                        { yylval=strdup(yytext); return F_CONSTANT; }
{HP}{H}*"."{H}+{P}{FS}?		                        { yylval=strdup(yytext); return F_CONSTANT; }
{HP}{H}+"."{P}{FS}?			                        { yylval=strdup(yytext); return F_CONSTANT; }

({SP}?\"([^"\\\n]|{ES})*\"{WS}*)+	                { yylval=strdup(yytext); return STRING_LITERAL; }

"..."					                            { yylval=strdup(yytext); return ELLIPSIS; }
">>="					                            { yylval=strdup(yytext); return RIGHT_ASSIGN; }
"<<="					                            { yylval=strdup(yytext); return LEFT_ASSIGN; }
"+="					                            { yylval=strdup(yytext); return ADD_ASSIGN; }
"-="					                            { yylval=strdup(yytext); return SUB_ASSIGN; }
"*="					                            { yylval=strdup(yytext); return MUL_ASSIGN; }
"/="					                            { yylval=strdup(yytext); return DIV_ASSIGN; }
"%="					                            { yylval=strdup(yytext); return MOD_ASSIGN; }
"&="					                            { yylval=strdup(yytext); return AND_ASSIGN; }
"^="					                            { yylval=strdup(yytext); return XOR_ASSIGN; }
"|="					                            { yylval=strdup(yytext); return OR_ASSIGN; }
">>"					                            { yylval=strdup(yytext); return RIGHT_OP; }
"<<"					                            { yylval=strdup(yytext); return LEFT_OP; }
"++"					                            { yylval=strdup(yytext); return INC_OP; }
"--"					                            { yylval=strdup(yytext); return DEC_OP; }
"->"					                            { yylval=strdup(yytext); return PTR_OP; }
"&&"					                            { yylval=strdup(yytext); return AND_OP; }
"||"					                            { yylval=strdup(yytext); return OR_OP; }
"<="					                            { yylval=strdup(yytext); return LE_OP; }
">="					                            { yylval=strdup(yytext); return GE_OP; }
"=="					                            { yylval=strdup(yytext); return EQ_OP; }
"!="					                            { yylval=strdup(yytext); return NE_OP; }
";"					                                { yylval=strdup(yytext); return ';'; }
("{"|"<%")				                            { yylval=strdup(yytext); return '{'; }
("}"|"%>")				                            { yylval=strdup(yytext); return '}'; }
","					                                { yylval=strdup(yytext); return ','; }
":"					                                { yylval=strdup(yytext); return ':'; }
"="					                                { yylval=strdup(yytext); return '='; }
"("					                                { yylval=strdup(yytext); return '('; }
")"					                                { yylval=strdup(yytext); return ')'; }
("["|"<:")				                            { yylval=strdup(yytext); return '['; }
("]"|":>")				                            { yylval=strdup(yytext); return ']'; }
"."					                                { yylval=strdup(yytext); return '.'; }
"&"					                                { yylval=strdup(yytext); return '&'; }
"!"					                                { yylval=strdup(yytext); return '!'; }
"~"					                                { yylval=strdup(yytext); return '~'; }
"-"					                                { yylval=strdup(yytext); return '-'; }
"+"					                                { yylval=strdup(yytext); return '+'; }
"*"					                                { yylval=strdup(yytext); return '*'; }
"/"					                                { yylval=strdup(yytext); return '/'; }
"%"					                                { yylval=strdup(yytext); return '%'; }
"<"					                                { yylval=strdup(yytext); return '<'; }
">"					                                { yylval=strdup(yytext); return '>'; }
"^"					                                { yylval=strdup(yytext); return '^'; }
"|"					                                { yylval=strdup(yytext); return '|'; }
"?"					                                { yylval=strdup(yytext); return '?'; }

{WS}+					                            { /* whitespace separates tokens */ }
.					                                { /* discard bad characters */ }

%%

int yywrap(void)        /* called at end of input */
{
    return 1;           /* terminate now */
}

static void comment(void)
{
    int c;

    while ((c = input()) != 0)
        if (c == '*')
        {
            while ((c = input()) == '*')
                ;

            if (c == '/')
                return;

            if (c == 0)
                break;
        }
    yyerror("unterminated comment");
}

static int check_type(void)
{
    switch (sym_type(yytext))
    {
    case TYPEDEF_NAME:                /* previously defined */
        return TYPEDEF_NAME;
    case ENUMERATION_CONSTANT:        /* previously defined */
        return ENUMERATION_CONSTANT;
    default:                          /* includes undefined */
        return IDENTIFIER;
    }
}