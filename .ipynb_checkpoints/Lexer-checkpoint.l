%{
	#include<string.h>
	#include <stdio.h>
	#include "Lexer.h"
	#include "SyntaxAnalyzer.tab.h"


	#define BUFFER_SIZE 512

	char buff1[BUFFER_SIZE];
	char *query = buff1;
	int query_len = 0;
	int query_capacity = BUFFER_SIZE;

	char buff2[BUFFER_SIZE];
	char *token_string = buff2;
	int token_string_len = 0;
	int token_string_capacity = BUFFER_SIZE;

	int isWhiteSpace(char);
	void trim(char *);
	void appendString(char *, char **, int *, int *);
	int (*handleToken)(char *);
%}

identifier [a-zA-Z_][a-zA-Z0-9_]*
number	   [+-]?[0-9]+([.][0-9]+)?([eE][0-9]+)?

%x query_string

%%
[ \t]*```					{  BEGIN query_string; query[0] = '\0'; query_len = 0; }
<query_string>[^`]*			{ appendString(yytext, &query, &query_len, &query_capacity); }
<query_string>```			{ handleToken(query); BEGIN 0; return QUERY_STRING; }
<query_string>``			{ appendString(yytext, &query, &query_len, &query_capacity); }
<query_string>`				{ appendString(yytext, &query, &query_len, &query_capacity); }
[ \t\n]*QUERY 				{ handleToken("QUERY"); return QUERY; }
[ \t\n]*SWITCH				{ handleToken("SWITCH"); return SWITCH; }
[ \t\n]*default				{ handleToken("DEFAULT"); return DEFAULT; }
[ \t]*{identifier}			{ trim(yytext); handleToken("IDENTIFIER"); return IDENT; }
[ \t]*{number}				{ trim(yytext); handleToken("NUMBER"); return NUMBER;  }
[ \t\n]*=					{ handleToken("EQUALS"); return EQUALS;}
[ \t\n]*&&					{ handleToken("BOOLEAN_AND"); return BOOLEAN_AND; }
[ \t\n]*\|\|				{ handleToken("BOOLEAN_OR"); return BOOLEAN_OR; }
[ \t]*:						{ handleToken("COLON"); return COLON; }
[ \t]*\{					{ handleToken("OPEN_PAREN"); return OPEN_PAREN; }
[ \t]*\}					{ handleToken("CLOSED_PAREN"); return CLOSED_PAREN; }
[ \t\n]*;					{ handleToken("END_CASE"); return SEMICOLON;}
.							{ printf("UNRECOGNIZED: %s %i\n", yytext, yytext[0]); }
%%


int isWhiteSpace(char ch)
{
	if(ch == 32 || ch == 9)
		return 1;
	return 0;
}

void trim(char *str)
{
	int begin = -1;
	while(isWhiteSpace(str[++begin]));

	int end = begin;
	int j = 0;
	while(str[end])
	{
		if(begin == 0)
			while(!isWhiteSpace(str[++end]) && str[end] != '\0');
		else
			while(!isWhiteSpace(str[end]) && str[end] != '\0') str[j++] = str[end++];

		int i = end;
		if(str[i] != '\0')
			while(isWhiteSpace(str[++i]));
		if(str[i] == '\0')
		{
			if(begin == 0)
				str[end] = '\0';
			else
				str[j] = '\0';
			return;
		}
		else
		{
			if(begin == 0)
				end = i;
			else
				while(end < i) str[j++] = str[end++];
		}
	}
	str[0] = '\0';
}

void strconcat(char *dest, char *src)
{
	--dest;
	while(*(++dest));
	while(*dest++ = *src++);
}

void appendString(char* str, char **buff, int *len, int *capacity)
{
	int str_len = strlen(str);

	if(*len + str_len > *capacity)
	{
		*capacity *= 2;
		*buff = realloc(*buff, *capacity);
	}

	strconcat(*buff + *len, str);
	*len += str_len;
}

int yywrap()
{
	return 1;
}

int yyerror(char *s)
{
	printf("ERROR: %s\n", s);
	return 1;
}

int print(char *a)
{
	return 0;
}

void lexer(char *str, int (*tokenHandler)(char *))
{
	yy_scan_string(str);
	if (!tokenHandler)
	{
		printf("Token Handler not specified\n");
		handleToken = print;
	}
	else
	{
		handleToken = tokenHandler;
	}
	// yyin = fopen("query.txt", "r");
	// yylex();
	yyparse();
}