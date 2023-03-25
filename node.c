#include "node.h"

pNode tokenNode(int lineNo, NodeType type, char* tokenName,
                                 char* tokenText) {
    pNode tokenNode = (pNode)malloc(sizeof(Node));
    tokenNode->lineNo = lineNo;
    tokenNode->type = type;

    tokenNode->name = (char*)malloc(sizeof(char) * (strlen(tokenName) + 1));
    tokenNode->val = (char*)malloc(sizeof(char) * (strlen(tokenText) + 1));

    strncpy(tokenNode->name, tokenName, strlen(tokenName) + 1);
    strncpy(tokenNode->val, tokenText, strlen(tokenText) + 1);

    tokenNode->child = NULL;
    tokenNode->next = NULL;

    return tokenNode;
}

pNode syntaxNode(int lineNo, NodeType type, char* syntaxName, int argc,
                            ...) {
    pNode fatherNode = (pNode)malloc(sizeof(Node));
    fatherNode->lineNo = lineNo;
    fatherNode->type = type;

    fatherNode->name = (char*)malloc(sizeof(char) * (strlen(syntaxName) + 1)); 
    strncpy(fatherNode->name, syntaxName, strlen(syntaxName) + 1);

    va_list vaList;
    va_start(vaList, argc);
    pNode childNode = va_arg(vaList, pNode);
    fatherNode->child = childNode;
    for (int i = 1; i < argc; i++) {
        childNode->next = va_arg(vaList, pNode);
        if (childNode->next != NULL) {
            childNode = childNode->next;
        }
    }
    va_end(vaList);

    return fatherNode;
}

void delNode(pNode node) {
    if (node == NULL) return;
    while (node->child != NULL) {
        pNode temp = node->child;
        node->child = node->child->next;
        delNode(temp);
    }
    free(node->name);
    free(node->val);
    free(node);
    node->name = NULL;
    node->val = NULL;
    node = NULL;
}

void printTreeInfo(pNode curNode, int height) {
    if (curNode == NULL) {return;}

    for (int i = 0; i < height; i++) {
        printf("  ");
    }
    printf("%s", curNode->name);
    if (curNode->type == SYNTAX) {
        printf(" (%d)", curNode->lineNo);
    } else if (curNode->type == TOKEN_TYPE || curNode->type == TOKEN_ID ||
               curNode->type == TOKEN_INT) {
        printf(": %s", curNode->val);
    } else if (curNode->type == TOKEN_FLOAT) {
        printf(": %lf", atof(curNode->val));
    }
    printf("\n");
    printTreeInfo(curNode->child, height + 1);
    printTreeInfo(curNode->next, height);
}