bison -d syntax.y
flex lexical.l
gcc main.c syntax.tab.c node.c -lfl -ly -o parser
