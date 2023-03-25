#ifndef NODE_H
#define NODE_H


#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "type.h"

#define TRUE 1
#define FALSE 0

typedef struct node {
    int lineNo;  
    NodeType type;  
    char* name;     
    char* val;      
    struct node* child;  
    struct node* next;   
} Node;

typedef Node* pNode;

pNode syntaxNode(int lineNo, NodeType type, char* syntaxName, int argc,
                            ...) ;

pNode tokenNode(int lineNo, NodeType type, char* tokenName,
                                 char* tokenText);

void delNode(pNode node) ;

void printTreeInfo(pNode curNode, int height) ;

#endif