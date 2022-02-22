#include <stdio.h>
#include <string.h>
#include "Lexer.h"

int tokenHandler(char *token_str)
{
    printf("%s", token_str);
    return 0;
}

int main()
{
    char *query_str = "QUERY query1: ```abcdef```";
    lexer(query_str, tokenHandler);
    printf("\n");

    return 0;
}