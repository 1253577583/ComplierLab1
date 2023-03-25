flex lexical.l
bison -d syntax.y
gcc main.c syntax.tab.c node.c -lfl -ly -o parser
