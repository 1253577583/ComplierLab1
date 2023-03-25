%{
#include"node.h"
#include "syntax.tab.h"

extern unsigned lexError;

int yycolumn = 1;
#define YY_USER_ACTION \
    yylloc.first_line=yylloc.last_line=yylineno; \
    yylloc.first_column=yycolumn; \
    yylloc.last_column=yycolumn+yyleng-1; \
    yycolumn+=yyleng;
%}

/* Use yylineon */
%option yylineno

/* Identifier */
nondigit [_a-zA-Z]
ID {nondigit}{_a-zA-Z0-9}*
/* Integer */
int_suffix [uU]([lL]|ll|LL)?
int_suffix_opt {int_suffix}?
int_dec = ([1-9]+[0-9]*|0){int_suffix_opt}
int_hex = 0[xX][0-9a-fA-F]+{int_suffix_opt}
int_oct = 0[012345678]+{int_suffix_opt}
INT int_dec|int_hex|int_oct
/* Float */
digit [0-9]
frac ({digit}+\.)|({digit}*\.{digit}+)
exp [eE][+-]?{digit}+
exp_opt {exp}?
float_suffix [fFlL]
float_suffix_opt {float_suffix}?
FLOAT ({frac}{exp_opt}{float_suffix_opt})|({digit}+{exp}{float_suffix_opt})
/* Keywords */
TYPE int|float
STRUCT struct
IF if
ELSE else
WHILE while
RETURN return
/* Delimiters */
LP "("
RP ")"
LB "["
RB "]"
LC "{"
RC "}"
SEMI ";"
/* Operators */
DOT "."
COMMA ","
ASSIGNOP "="
RELOP 	>|<|>=|<=|==|!=
AND "&&"
OR "||"
NOT "!"
PLUS "+"
MINUS "-"
STAR "*"
DIV "/"
/* Misc */
whitespace [ \t]
return [\n\r]

%%
{whitespace}+ {;}
/* Reset yycolomn */
{return} { yycolumn = 1; }
{IF} { yylval.node = tokenNode(yylineno, OTHER, "IF", yytext); return IF; }
{ELSE} { yylval.node = tokenNode(yylineno, OTHER, "ELSE", yytext); return ELSE; }
{WHILE} { yylval.node = tokenNode(yylineno, OTHER, "WHILE", yytext); return WHILE; }
{TYPE} { yylval.node = tokenNode(yylineno, TYPE, "TYPE", yytext); return TYPE; }
{STRUCT} { yylval.node = tokenNode(yylineno, OTHER, "STRUCT", yytext); return STRUCT; }
{RETURN} { yylval.node = tokenNode(yylineno, OTHER, "RETURN", yytext); return RETURN; }
{RELOP} { yylval.node = tokenNode(yylineno, OTHER, "RELOP", yytext); return RELOP; }

{PLUS} { yylval.node = tokenNode(yylineno, OTHER, "PLUS", yytext); return PLUS; }
{MINUS} { yylval.node = tokenNode(yylineno, OTHER, "MINUS", yytext); return MINUS; }
{STAR} { yylval.node = tokenNode(yylineno, OTHER, "STAR", yytext); return STAR; }
{DIV} { yylval.node = tokenNode(yylineno, OTHER, "DIV", yytext); return DIV; }
{AND} { yylval.node = tokenNode(yylineno, OTHER, "AND", yytext); return AND; }
{OR} { yylval.node = tokenNode(yylineno, OTHER, "OR", yytext); return OR; }
{NOT} { yylval.node = tokenNode(yylineno, OTHER, "NOT", yytext); return NOT; }

{DOT} { yylval.node = tokenNode(yylineno, OTHER, "DOT", yytext); return DOT; }
{SEMI} { yylval.node = tokenNode(yylineno, OTHER, "SEMI", yytext); return SEMI; }
{COMMA} { yylval.node = tokenNode(yylineno, OTHER, "COMMA", yytext); return COMMA; }
{ASSIGNOP} { yylval.node = tokenNode(yylineno, OTHER, "ASSIGNOP", yytext); return ASSIGNOP; }

{LP} { yylval.node = tokenNode(yylineno, OTHER, "LP", yytext); return LP; }
{RP} { yylval.node = tokenNode(yylineno, OTHER, "RP", yytext); return RP; }
{LB} { yylval.node = tokenNode(yylineno, OTHER, "LB", yytext); return LB; }
{RB} { yylval.node = tokenNode(yylineno, OTHER, "RB", yytext); return RB; }
{LC} { yylval.node = tokenNode(yylineno, OTHER, "LC", yytext); return LC; }
{RC} { yylval.node = tokenNode(yylineno, OTHER, "RC", yytext); return RC; }

{ID} { yylval.node = tokenNode(yylineno, ID, "ID", yytext); return ID;}
{INT} { yylval.node = tokenNode(yylineno, INT, "INT", yytext); return INT;}
{FLOAT} { yylval.node = tokenNode(yylineno, FLOAT, "FLOAT", yytext); return FLOAT;}

{digit}+{ID} {lexError = TRUE; printf("Error type A at Line %d: Illegal ID \"%s\".\n", yylineno, yytext); }
"."{digit}+ { lexError = TRUE; printf("Error type A at Line %d: Illegal floating point number \"%s\".\n", yylineno, yytext); }
{digit}+"." { lexError = TRUE; printf("Error type A at Line %d: Illegal floating point number \"%s\".\n", yylineno, yytext); }
{digit}*"."{digit}+[eE] { lexError = TRUE; printf("Error type A at Line %d: Illegal floating point number \"%s\".\n", yylineno, yytext); }
{digit}+"."{digit}*[eE] { lexError = TRUE; printf("Error type A at Line %d: Illegal floating point number \"%s\".\n", yylineno, yytext); }
{digit}+[eE][+-]?{digit}* { lexError = TRUE; printf("Error type A at Line %d: Illegal floating point number \"%s\".\n", yylineno, yytext); }
"."[eE][+-]?{digit}+ { lexError = TRUE; printf("Error type A at Line %d: Illegal floating point number \"%s\".\n", yylineno, yytext); }
. { lexError = TRUE; printf("Error type A at Line %d: Mysterious character \'%s\'.\n", yylineno, yytext); }
%%