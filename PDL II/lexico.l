%{
/* Analizador de l�xico */
#include <stdlib.h>
#include <stdio.h>

#ifndef __STDC__
#define __STDC__
#endif

%}

letra [a-zA-Z]
digito [0-9]
alphanum [a-zA-Z_0-9]
todos .

%x comentario

%%

"(" return PIZ;
")" return PDE;
"+" return SUM;
"-" return RES;
"*" return MUL;
"/" return DIV;
"=" return ASI;


"<"{letra}{alphanum}*".h>" return CAB1;
\"{letra}{alphanum}*".h"\" return CAB2;

"\[" return CORI;
"\]" return CORD;
":" return PUNTOS;
"\{" return LLIZ;
"\}" return LLDE;
";" return PYC;
"," return COMA;
"&&" return AND;
"||" return OR;
">=" return MAYORIQ;
"<=" return MENORIQ;
">" return MAYORQ;
"<" return MENORQ;
"!=" return DIST;
"==" return II;
"!" return NEGEXP;

"case" return CASE;
{digito}+ return NUM;
"break" return BREAK;
"int"	return INT;
"float" return FLOAT;
"char" return CHAR;
"set" return SET;

"bool" return BOOL;
"true" return TRUE;
"false" return FALSE;
"string" return STRING;
"'"{letra}"'" return CARACTER;

"<--" return ADDC;
"-->" return MINC;
"~" return COMPC;




"typedef" return TYPEDEF;
{digito}+"."{digito}* return REAL;
\""%"[dfcso]\" return OP_INOUT;
\"([^"\n]|\\\")*\" return TEXTO_OUT;
"empty" return EMPTY;
"length" return LENGTH;
"void" return VOID;
"switch" return SWITCH;
"while" return WHILE;
"#include" return INCLUDE;
"#define" return DEFINE;
"if" return IF;
"scanf" return IN;
"printf" return OUT;
"default" return DEFAULT;
"else" return ELSE;
"create" return CREATE;
"insert" return INSERT;
"main" return MAIN;
"extract" return EXTRACT;
"delete" return DELETE;
"minus" return MINUS;
"union" return UNION;
"intersection" return INTERSECTION;
"neg" return NEG; 

" "+ ;
\n linea_actual++;
\t ;
"/*" { BEGIN(comentario); }
<comentario>[^*\n]* 
<comentario>"*"+[^*/\n]*
<comentario>\n {++linea_actual;}
<comentario>"*"+"/" {BEGIN(INITIAL);}

{letra}{alphanum}* return ID;

. yyerror("Error en la l�nea: ");

%%