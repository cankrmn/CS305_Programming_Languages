%{
#include <stdio.h>

void yyerror(const char *msg)
{
}
%}

%token tSTRING tGET tSET tFUNCTION tPRINT tIF tRETURN
%token tINC tDEC tGT tEQUALITY tLT tLEQ tGEQ tIDENT tNUM
%start program
%%
program: '[' sentence ']';

sentence:	word sentence | ;
word:		set | if | print | inc | dec | condition | get | function | operation | rtrn | ;

statement: set | if | print | inc | dec | rtrn | get | ;

set:	'[' tSET ',' tIDENT ',' expr ']';

if:	  '[' tIF ',' condition ',' '[' then_else ']' ']' 
	| '[' tIF ',' condition ',' '[' then_else ']' '[' then_else ']' ']' ;  
then_else: 	  then_else statement | ;
		
print:	  '[' tPRINT ',' '[' expr ']' ']' ;

inc:	'[' tINC ',' tIDENT ']';
dec:	'[' tDEC ',' tIDENT ']';

inequality: tGT | tLT | tEQUALITY| tLEQ | tGEQ;
condition: '[' inequality ',' expr ',' expr ']';

expr: tNUM | tSTRING | get | function | operation | condition;

get: 	  '[' tGET ',' tIDENT ']' 
	| '[' tGET ',' tIDENT ',' '[' func_param ']' ']'
	| '[' tGET ',' tIDENT ',' '[' ']' ']' ;


func_param: 	tIDENT | tNUM | func_param ',' tIDENT | func_param ',' tNUM ;
statement_list:	statement_list statement | ;	
function:	  '[' tFUNCTION ',' '[' func_param ']' ',' '[' statement_list ']' ']'
		| '[' tFUNCTION ',' '[' ']' ',' '[' statement_list ']' ']'
		| '[' tFUNCTION ',' '[' func_param ']' ',' '[' ']' ']'
		| '[' tFUNCTION ',' '[' ']' ',' '[' ']' ']' ;

operator: '"' '+' '"' | '"' '-' '"' | '"' '*' '"' | '"' '/' '"' ;
operation: '[' operator ',' expr ',' expr ']' ;

rtrn: '[' tRETURN ']' | '[' tRETURN ',' expr ']';

%%
int main()
{
	if(yyparse())
	{
		printf("ERROR\n");
		return 1;
	}
	else
	{
		printf("OK\n");
		return 0;
	}
}
