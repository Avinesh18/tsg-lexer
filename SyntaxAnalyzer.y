%{
    #include <stdio.h>

    int yylex();
    int yyerror(char *);
%}

%token QUERY
%token SWITCH
%token DEFAULT
%token EQUALS
%token BOOLEAN_AND
%token BOOLEAN_OR
%token COLON
%token SEMICOLON
%token OPEN_PAREN
%token CLOSED_PAREN
%token IDENT
%token NUMBER
%token QUERY_STRING

%%
start: QUERY_DECL        {}
     | QUERY_EXEC        {}
     | SWITCH_STMT       {}
     ;

QUERY_DECL: QUERY IDENT COLON { printf("%s", $1); }
          ;

QUERY_EXEC: ;

SWITCH_STMT: ;

%%