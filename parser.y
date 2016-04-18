%{
  #include "common.h"
	#include <stdio.h>
  #include "symbol_table.h"
  int columns = 0;
  FILE *yyin;
%}

/* Definições */

%union
{
  char * strval;
}

%token T_CREATE
%token T_TABLE
%token T_STRING
%token T_INT
%token T_VARCHAR
%token T_FLOAT
%token D_STRING
%type <strval> D_STRING
%token D_INTEGER
%token D_FLOAT

%start Input

%% /* Regras */

Start_create_table:
  T_CREATE T_TABLE D_STRING '(' Create_column {insert_entity(entity_list_pointer, $3);}
;

Finish_create_table:
  ')' ';'
;

Type_specifier:
  T_INT
  | T_VARCHAR
  | T_FLOAT
;

Create_column:
  D_STRING Type_specifier Finish_create_table {}
  | D_STRING Type_specifier ',' Create_column {}
;

Input:
  
  | Input Start_create_table
;
  

%% /* Código C */

void yyerror(const char* errmsg)
{
  printf("\n*** Erro: %s, on line: \n", errmsg);
}
 
int yywrap(void) 
{ 
  return 1;
}

int main(int argc, char** argv)
{ 
  
  entity_list_pointer = (entity_instance*) malloc(sizeof(entity_instance));
  entity_list_pointer->next_entity = NULL;
  
  FILE *file = fopen("arquivo_entrada.sql", "r");

  if(!file) {
    printf("I can't open arquivo_entrada.sql\n");
    return -1;
  }

  yyin = file;

  yyparse();
  
  printf("\nNumero de colunas: %d\n", columns);
  print_entity_list(entity_list_pointer);

  return 0;
}

