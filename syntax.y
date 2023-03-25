%{
    #include<stdio.h>
    #include"node.h"
    #define YYSTYPE pNode
    #include"lex.yy.c"

    extern int synError;
    pNode root;
    #define YYERROR_VERBOSE 1
    

%}


// tokens

%token  INT
%token  FLOAT
%token  ID
%token  TYPE
%token  COMMA
%token  DOT
%token  SEMI
%token  RELOP
%token  ASSIGNOP
%token  PLUS MINUS STAR DIV
%token  AND OR NOT 
%token  LP RP LB RB LC RC
%token  IF
%token  ELSE
%token  WHILE
%token  STRUCT
%token  RETURN

// non-terminals

//%type  Program ExtDefList ExtDef ExtDecList   //  High-level Definitions
//%type  Specifier StructSpecifier OptTag Tag   //  Specifiers
//%type  VarDec FunDec VarList ParamDec         //  Declarators
//%type  CompSt StmtList Stmt                   //  Statements
//%type  DefList Def Dec DecList                //  Local Definitions
//%type  Exp Args                               //  Expressions

// precedence and associativity

%right ASSIGNOP
%left OR
%left AND
%left RELOP
%left PLUS MINUS
%left STAR DIV
%right NOT
%left DOT
%left LB RB
%left LP RP
%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%
// High-level Definitions
Program:            ExtDefList                              { $$ = syntaxNode(@$.first_line, SYNTAX, "Program", 1, $1); root = $$; }
    ; 
ExtDefList:         ExtDef ExtDefList                       { $$ = syntaxNode(@$.first_line, SYNTAX, "ExtDefList", 2, $1, $2); }
    |                                                       { $$ = NULL; } 
    ; 
ExtDef:             Specifier ExtDecList SEMI               { $$ = syntaxNode(@$.first_line, SYNTAX, "ExtDef", 3, $1, $2, $3); }
    |               Specifier SEMI                          { $$ = syntaxNode(@$.first_line, SYNTAX, "ExtDef", 2, $1, $2); }
    |               Specifier FunDec CompSt                 { $$ = syntaxNode(@$.first_line, SYNTAX, "ExtDef", 3, $1, $2, $3); }
    |               error SEMI                              { synError = TRUE; }
    ; 
ExtDecList:         VarDec                                  { $$ = syntaxNode(@$.first_line, SYNTAX, "ExtDecList", 1, $1); }
    |               VarDec COMMA ExtDecList                 { $$ = syntaxNode(@$.first_line, SYNTAX, "ExtDecList", 3, $1, $2, $3); }
    ; 

// Specifiers
Specifier:          TYPE                                    { $$ = syntaxNode(@$.first_line, SYNTAX, "Specifier", 1, $1); }
    |               StructSpecifier                         { $$ = syntaxNode(@$.first_line, SYNTAX, "Specifier", 1, $1); }
    ; 
StructSpecifier:    STRUCT OptTag LC DefList RC             { $$ = syntaxNode(@$.first_line, SYNTAX, "StructSpecifier", 5, $1, $2, $3, $4, $5); }
    |               STRUCT Tag                              { $$ = syntaxNode(@$.first_line, SYNTAX, "StructSpecifier", 2, $1, $2); }
    ; 
OptTag:             ID                                      { $$ = syntaxNode(@$.first_line, SYNTAX, "OptTag", 1, $1); }
    |                                                       { $$ = NULL; }
    ; 
Tag:                ID                                      { $$ = syntaxNode(@$.first_line, SYNTAX, "Tag", 1, $1); }
    ; 

// Declarators
VarDec:             ID                                      { $$ = syntaxNode(@$.first_line, SYNTAX, "VarDec", 1, $1); }
    |               VarDec LB INT RB                        { $$ = syntaxNode(@$.first_line, SYNTAX, "VarDec", 4, $1, $2, $3, $4); }
    |               error RB                                { synError = TRUE; }
    ; 
FunDec:             ID LP VarList RP                        { $$ = syntaxNode(@$.first_line, SYNTAX, "FunDec", 4, $1, $2, $3, $4); }
    |               ID LP RP                                { $$ = syntaxNode(@$.first_line, SYNTAX, "FunDec", 3, $1, $2, $3); }
    |               error RP                                { synError = TRUE; }
    ; 
VarList:            ParamDec COMMA VarList                  { $$ = syntaxNode(@$.first_line, SYNTAX, "VarList", 3, $1, $2, $3); }
    |               ParamDec                                { $$ = syntaxNode(@$.first_line, SYNTAX, "VarList", 1, $1); }
    ; 
ParamDec:           Specifier VarDec                        { $$ = syntaxNode(@$.first_line, SYNTAX, "ParamDec", 2, $1, $2); }
    ; 
// Statements
CompSt:             LC DefList StmtList RC                  { $$ = syntaxNode(@$.first_line, SYNTAX, "CompSt", 4, $1, $2, $3, $4); }
    |               error RC                                { synError = TRUE; }
    ; 
StmtList:           Stmt StmtList                           { $$ = syntaxNode(@$.first_line, SYNTAX, "StmtList", 2, $1, $2); }
    |                                                       { $$ = NULL; }
    ; 
Stmt:               Exp SEMI                                { $$ = syntaxNode(@$.first_line, SYNTAX, "Stmt", 2, $1, $2); }
    |               CompSt                                  { $$ = syntaxNode(@$.first_line, SYNTAX, "Stmt", 1, $1); }
    |               RETURN Exp SEMI                         { $$ = syntaxNode(@$.first_line, SYNTAX, "Stmt", 3, $1, $2, $3); }    
    |               IF LP Exp RP Stmt %prec LOWER_THAN_ELSE { $$ = syntaxNode(@$.first_line, SYNTAX, "Stmt", 5, $1, $2, $3, $4, $5); }
    |               IF LP Exp RP Stmt ELSE Stmt             { $$ = syntaxNode(@$.first_line, SYNTAX, "Stmt", 7, $1, $2, $3, $4, $5, $6, $7); }
    |               WHILE LP Exp RP Stmt                    { $$ = syntaxNode(@$.first_line, SYNTAX, "Stmt", 5, $1, $2, $3, $4, $5); }
    |               error SEMI                              { synError = TRUE; }
    ; 
// Local Definitions
DefList:            Def DefList                             { $$ = syntaxNode(@$.first_line, SYNTAX, "DefList", 2, $1, $2); }
    |                                                       { $$ = NULL; }
    ;     
Def:                Specifier DecList SEMI                  { $$ = syntaxNode(@$.first_line, SYNTAX, "Def", 3, $1, $2, $3); }
    ; 
DecList:            Dec                                     { $$ = syntaxNode(@$.first_line, SYNTAX, "DecList", 1, $1); }
    |               Dec COMMA DecList                       { $$ = syntaxNode(@$.first_line, SYNTAX, "DecList", 3, $1, $2, $3); }
    ; 
Dec:                VarDec                                  { $$ = syntaxNode(@$.first_line, SYNTAX, "Dec", 1, $1); }
    |               VarDec ASSIGNOP Exp                     { $$ = syntaxNode(@$.first_line, SYNTAX, "Dec", 3, $1, $2, $3); }
    ; 
//7.1.7 Expressions
Exp:                Exp ASSIGNOP Exp                        { $$ = syntaxNode(@$.first_line, SYNTAX, "Exp", 3, $1, $2, $3); }
    |               Exp AND Exp                             { $$ = syntaxNode(@$.first_line, SYNTAX, "Exp", 3, $1, $2, $3); }
    |               Exp OR Exp                              { $$ = syntaxNode(@$.first_line, SYNTAX, "Exp", 3, $1, $2, $3); }
    |               Exp RELOP Exp                           { $$ = syntaxNode(@$.first_line, SYNTAX, "Exp", 3, $1, $2, $3); }
    |               Exp PLUS Exp                            { $$ = syntaxNode(@$.first_line, SYNTAX, "Exp", 3, $1, $2, $3); }
    |               Exp MINUS Exp                           { $$ = syntaxNode(@$.first_line, SYNTAX, "Exp", 3, $1, $2, $3); }
    |               Exp STAR Exp                            { $$ = syntaxNode(@$.first_line, SYNTAX, "Exp", 3, $1, $2, $3); }
    |               Exp DIV Exp                             { $$ = syntaxNode(@$.first_line, SYNTAX, "Exp", 3, $1, $2, $3); }
    |               LP Exp RP                               { $$ = syntaxNode(@$.first_line, SYNTAX, "Exp", 3, $1, $2, $3); }
    |               MINUS Exp                               { $$ = syntaxNode(@$.first_line, SYNTAX, "Exp", 2, $1, $2); }
    |               NOT Exp                                 { $$ = syntaxNode(@$.first_line, SYNTAX, "Exp", 2, $1, $2); }
    |               ID LP Args RP                           { $$ = syntaxNode(@$.first_line, SYNTAX, "Exp", 4, $1, $2, $3, $4); }
    |               ID LP RP                                { $$ = syntaxNode(@$.first_line, SYNTAX, "Exp", 3, $1, $2, $3); }
    |               Exp LB Exp RB                           { $$ = syntaxNode(@$.first_line, SYNTAX, "Exp", 4, $1, $2, $3, $4); }
    |               Exp DOT ID                              { $$ = syntaxNode(@$.first_line, SYNTAX, "Exp", 3, $1, $2, $3); }
    |               ID                                      { $$ = syntaxNode(@$.first_line, SYNTAX, "Exp", 1, $1); }
    |               INT                                     { $$ = syntaxNode(@$.first_line, SYNTAX, "Exp", 1, $1); }
    |               FLOAT                                   { $$ = syntaxNode(@$.first_line, SYNTAX, "Exp", 1, $1); }
    ; 
Args :              Exp COMMA Args                          { $$ = syntaxNode(@$.first_line, SYNTAX, "Args", 3, $1, $2, $3); }
    |               Exp                                     { $$ = syntaxNode(@$.first_line, SYNTAX, "Args", 1, $1); }
    ; 
%%

yyerror(char* msg){
    fprintf(stderr, "Error type B at line %d: %s.\n", yylineno, msg);
}