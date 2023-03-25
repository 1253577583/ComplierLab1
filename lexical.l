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
ID [_a-zA-Z][_a-zA-Z0-9]*
/* Integer */
int_suffix [uU]([lL]|ll|LL)?
int_suffix_opt {int_suffix}?
int_dec ([1-9]+[0-9]*|0){int_suffix_opt}
int_hex 0[xX][0-9a-fA-F]+{int_suffix_opt}
int_oct 0[01234567]+{int_suffix_opt}
INT {int_dec}|{int_hex}|{int_oct}
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
enter [\n\r]

%%
{whitespace}+ {;}
{enter} { yycolumn = 1; }

{TYPE} { yylval = tokenNode(yylineno, TOKEN_TYPE, "TYPE", yytext); return TYPE; }
{STRUCT} { yylval = tokenNode(yylineno, OTHER, "STRUCT", yytext); return STRUCT; }
{IF} { yylval = tokenNode(yylineno, OTHER, "IF", yytext); return IF; }
{ELSE} { yylval = tokenNode(yylineno, OTHER, "ELSE", yytext); return ELSE; }
{WHILE} { yylval = tokenNode(yylineno, OTHER, "WHILE", yytext); return WHILE; }
{RETURN} { yylval = tokenNode(yylineno, OTHER, "RETURN", yytext); return RETURN; }

{LP} { yylval = tokenNode(yylineno, OTHER, "LP", yytext); return LP; }
{RP} { yylval = tokenNode(yylineno, OTHER, "RP", yytext); return RP; }
{LB} { yylval = tokenNode(yylineno, OTHER, "LB", yytext); return LB; }
{RB} { yylval = tokenNode(yylineno, OTHER, "RB", yytext); return RB; }
{LC} { yylval = tokenNode(yylineno, OTHER, "LC", yytext); return LC; }
{RC} { yylval = tokenNode(yylineno, OTHER, "RC", yytext); return RC; }
{SEMI} { yylval = tokenNode(yylineno, OTHER, "SEMI", yytext); return SEMI; }

{ID} { yylval = tokenNode(yylineno, TOKEN_ID, "ID", yytext); return ID;}
{INT} { yylval = tokenNode(yylineno, TOKEN_INT, "INT", yytext); return INT;}
{FLOAT} { yylval = tokenNode(yylineno, TOKEN_FLOAT, "FLOAT", yytext); return FLOAT;}

{DOT} { yylval = tokenNode(yylineno, OTHER, "DOT", yytext); return DOT; }
{COMMA} { yylval = tokenNode(yylineno, OTHER, "COMMA", yytext); return COMMA; }
{ASSIGNOP} { yylval = tokenNode(yylineno, OTHER, "ASSIGNOP", yytext); return ASSIGNOP; }
{AND} { yylval = tokenNode(yylineno, OTHER, "AND", yytext); return AND; }
{OR} { yylval = tokenNode(yylineno, OTHER, "OR", yytext); return OR; }
{NOT} { yylval = tokenNode(yylineno, OTHER, "NOT", yytext); return NOT; }
{PLUS} { yylval = tokenNode(yylineno, OTHER, "PLUS", yytext); return PLUS; }
{MINUS} { yylval = tokenNode(yylineno, OTHER, "MINUS", yytext); return MINUS; }
{STAR} { yylval = tokenNode(yylineno, OTHER, "STAR", yytext); return STAR; }
{DIV} { yylval = tokenNode(yylineno, OTHER, "DIV", yytext); return DIV; }
{RELOP} { yylval = tokenNode(yylineno, OTHER, "RELOP", yytext); return RELOP; }



%%