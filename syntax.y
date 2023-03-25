%{
    #include<stdio.h>
    #include"node.h"
    #include"lex.yy.c"
    extern int synError;
    pNode root;
    #define YYERROR_VERBOSE 1

%}


/* Token Type */
%union{
    pNode node; 
}

// tokens

%token <node> INT
%token <node> FLOAT
%token <node> ID
%token <node> TYPE
%token <node> COMMA
%token <node> DOT
%token <node> SEMI
%token <node> RELOP
%token <node> ASSIGNOP
%token <node> PLUS MINUS STAR DIV
%token <node> AND OR NOT 
%token <node> LP RP LB RB LC RC
%token <node> IF
%token <node> ELSE
%token <node> WHILE
%token <node> STRUCT
%token <node> RETURN

// non-terminals

%type <node> Program ExtDefList ExtDef ExtDecList   //  High-level Definitions
%type <node> Specifier StructSpecifier OptTag Tag   //  Specifiers
%type <node> VarDec FunDec VarList ParamDec         //  Declarators
%type <node> CompSt StmtList Stmt                   //  Statements
%type <node> DefList Def Dec DecList                //  Local Definitions
%type <node> Exp Args                               //  Expressions

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
%nonassoc ELSEH

%%
// High-level Definitions
Program:            ExtDefList                              { $$ = newNode(@$.first_line, SYNTAX, "Program", 1, $1); root = $$; }
    ; 
ExtDefList:         ExtDef ExtDefList                       { $$ = newNode(@$.first_line, SYNTAX, "ExtDefList", 2, $1, $2); }
    |                                                       { $$ = NULL; } 
    ; 
ExtDef:             Specifier ExtDecList SEMI               { $$ = newNode(@$.first_line, SYNTAX, "ExtDef", 3, $1, $2, $3); }
    |               Specifier SEMI                          { $$ = newNode(@$.first_line, SYNTAX, "ExtDef", 2, $1, $2); }
    |               Specifier FunDec CompSt                 { $$ = newNode(@$.first_line, SYNTAX, "ExtDef", 3, $1, $2, $3); }
    |               error SEMI                              { synError = TRUE; }
    ; 
ExtDecList:         VarDec                                  { $$ = newNode(@$.first_line, SYNTAX, "ExtDecList", 1, $1); }
    |               VarDec COMMA ExtDecList                 { $$ = newNode(@$.first_line, SYNTAX, "ExtDecList", 3, $1, $2, $3); }
    ; 

// Specifiers
Specifier:          TYPE                                    { $$ = newNode(@$.first_line, SYNTAX, "Specifier", 1, $1); }
    |               StructSpecifier                         { $$ = newNode(@$.first_line, SYNTAX, "Specifier", 1, $1); }
    ; 
StructSpecifier:    STRUCT OptTag LC DefList RC             { $$ = newNode(@$.first_line, SYNTAX, "StructSpecifier", 5, $1, $2, $3, $4, $5); }
    |               STRUCT Tag                              { $$ = newNode(@$.first_line, SYNTAX, "StructSpecifier", 2, $1, $2); }
    ; 
OptTag:             ID                                      { $$ = newNode(@$.first_line, SYNTAX, "OptTag", 1, $1); }
    |                                                       { $$ = NULL; }
    ; 
Tag:                ID                                      { $$ = newNode(@$.first_line, SYNTAX, "Tag", 1, $1); }
    ; 

// Declarators
VarDec:             ID                                      { $$ = newNode(@$.first_line, SYNTAX, "VarDec", 1, $1); }
    |               VarDec LB INT RB                        { $$ = newNode(@$.first_line, SYNTAX, "VarDec", 4, $1, $2, $3, $4); }
    |               error RB                                { synError = TRUE; }
    ; 
FunDec:             ID LP VarList RP                        { $$ = newNode(@$.first_line, SYNTAX, "FunDec", 4, $1, $2, $3, $4); }
    |               ID LP RP                                { $$ = newNode(@$.first_line, SYNTAX, "FunDec", 3, $1, $2, $3); }
    |               error RP                                { synError = TRUE; }
    ; 
VarList:            ParamDec COMMA VarList                  { $$ = newNode(@$.first_line, SYNTAX, "VarList", 3, $1, $2, $3); }
    |               ParamDec                                { $$ = newNode(@$.first_line, SYNTAX, "VarList", 1, $1); }
    ; 
ParamDec:           Specifier VarDec                        { $$ = newNode(@$.first_line, SYNTAX, "ParamDec", 2, $1, $2); }
    ; 
// Statements
CompSt:             LC DefList StmtList RC                  { $$ = newNode(@$.first_line, SYNTAX, "CompSt", 4, $1, $2, $3, $4); }
    |               error RC                                { synError = TRUE; }
    ; 
StmtList:           Stmt StmtList                           { $$ = newNode(@$.first_line, SYNTAX, "StmtList", 2, $1, $2); }
    |                                                       { $$ = NULL; }
    ; 
Stmt:               Exp SEMI                                { $$ = newNode(@$.first_line, SYNTAX, "Stmt", 2, $1, $2); }
    |               CompSt                                  { $$ = newNode(@$.first_line, SYNTAX, "Stmt", 1, $1); }
    |               RETURN Exp SEMI                         { $$ = newNode(@$.first_line, SYNTAX, "Stmt", 3, $1, $2, $3); }    
    |               IF LP Exp RP Stmt %prec LOWER_THAN_ELSE { $$ = newNode(@$.first_line, SYNTAX, "Stmt", 5, $1, $2, $3, $4, $5); }
    |               IF LP Exp RP Stmt ELSE Stmt             { $$ = newNode(@$.first_line, SYNTAX, "Stmt", 7, $1, $2, $3, $4, $5, $6, $7); }
    |               WHILE LP Exp RP Stmt                    { $$ = newNode(@$.first_line, SYNTAX, "Stmt", 5, $1, $2, $3, $4, $5); }
    |               error SEMI                              { synError = TRUE; }
    ; 
// Local Definitions
DefList:            Def DefList                             { $$ = newNode(@$.first_line, SYNTAX, "DefList", 2, $1, $2); }
    |                                                       { $$ = NULL; }
    ;     
Def:                Specifier DecList SEMI                  { $$ = newNode(@$.first_line, SYNTAX, "Def", 3, $1, $2, $3); }
    ; 
DecList:            Dec                                     { $$ = newNode(@$.first_line, SYNTAX, "DecList", 1, $1); }
    |               Dec COMMA DecList                       { $$ = newNode(@$.first_line, SYNTAX, "DecList", 3, $1, $2, $3); }
    ; 
Dec:                VarDec                                  { $$ = newNode(@$.first_line, SYNTAX, "Dec", 1, $1); }
    |               VarDec ASSIGNOP Exp                     { $$ = newNode(@$.first_line, SYNTAX, "Dec", 3, $1, $2, $3); }
    ; 
//7.1.7 Expressions
Exp:                Exp ASSIGNOP Exp                        { $$ = newNode(@$.first_line, SYNTAX, "Exp", 3, $1, $2, $3); }
    |               Exp AND Exp                             { $$ = newNode(@$.first_line, SYNTAX, "Exp", 3, $1, $2, $3); }
    |               Exp OR Exp                              { $$ = newNode(@$.first_line, SYNTAX, "Exp", 3, $1, $2, $3); }
    |               Exp RELOP Exp                           { $$ = newNode(@$.first_line, SYNTAX, "Exp", 3, $1, $2, $3); }
    |               Exp PLUS Exp                            { $$ = newNode(@$.first_line, SYNTAX, "Exp", 3, $1, $2, $3); }
    |               Exp MINUS Exp                           { $$ = newNode(@$.first_line, SYNTAX, "Exp", 3, $1, $2, $3); }
    |               Exp STAR Exp                            { $$ = newNode(@$.first_line, SYNTAX, "Exp", 3, $1, $2, $3); }
    |               Exp DIV Exp                             { $$ = newNode(@$.first_line, SYNTAX, "Exp", 3, $1, $2, $3); }
    |               LP Exp RP                               { $$ = newNode(@$.first_line, SYNTAX, "Exp", 3, $1, $2, $3); }
    |               MINUS Exp                               { $$ = newNode(@$.first_line, SYNTAX, "Exp", 2, $1, $2); }
    |               NOT Exp                                 { $$ = newNode(@$.first_line, SYNTAX, "Exp", 2, $1, $2); }
    |               ID LP Args RP                           { $$ = newNode(@$.first_line, SYNTAX, "Exp", 4, $1, $2, $3, $4); }
    |               ID LP RP                                { $$ = newNode(@$.first_line, SYNTAX, "Exp", 3, $1, $2, $3); }
    |               Exp LB Exp RB                           { $$ = newNode(@$.first_line, SYNTAX, "Exp", 4, $1, $2, $3, $4); }
    |               Exp DOT ID                              { $$ = newNode(@$.first_line, SYNTAX, "Exp", 3, $1, $2, $3); }
    |               ID                                      { $$ = newNode(@$.first_line, SYNTAX, "Exp", 1, $1); }
    |               INT                                     { $$ = newNode(@$.first_line, SYNTAX, "Exp", 1, $1); }
    |               FLOAT                                   { $$ = newNode(@$.first_line, SYNTAX, "Exp", 1, $1); }
    ; 
Args :              Exp COMMA Args                          { $$ = newNode(@$.first_line, SYNTAX, "Args", 3, $1, $2, $3); }
    |               Exp                                     { $$ = newNode(@$.first_line, SYNTAX, "Args", 1, $1); }
    ; 
%%

yyerror(char* msg){
    fprintf(stderr, "Error type B at line %d: %s.\n", yylineno, msg);
}