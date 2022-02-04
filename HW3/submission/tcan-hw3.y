%{
#include <stdio.h>
#include <stdlib.h>
#include "tcan-hw3.h"

void yyerror (const char *s) {}

char * strAdder(char *, char *);

type_value * calculate(type_value *, type_value *, OPtypes);
type_value * type_checker(type_value *);

type_value * makeINTnode(int);
type_value * makeFLOnode(float);
type_value * makeSTRnode(char*);
type_value * space_opener();
void printer(type_value *);
%}

%union {
	int line;
	float value;
	char* str;
	type_value *typeVal;
}

%type <typeVal> expr 
%type <typeVal> operation
%token 
	<line> tADD 
	<line> tMUL
	<line> tSUB
        <line> tDIV

%token <value> tINT
%token <value> tFLOAT
%token <str> tSTRING

%token tPRINT tGET tSET tFUNCTION tRETURN tIDENT tEQUALITY tIF tGT tLT tGEQ tLEQ tINC tDEC

%start prog

%%

prog:		'[' stmtlst ']'
;

stmtlst:	stmtlst stmt |
;

stmt:		setStmt | if | print | unaryOperation | expr {printer($1);}| returnStmt
;

getExpr:	'[' tGET ',' tIDENT ',' '[' exprList ']' ']'
		| '[' tGET ',' tIDENT ',' '[' ']' ']'
		| '[' tGET ',' tIDENT ']'
;

setStmt:	'[' tSET ',' tIDENT ',' expr ']' {printer($6);}
;

if:		'[' tIF ',' condition ',' '[' stmtlst ']' ']'
		| '[' tIF ',' condition ',' '[' stmtlst ']' '[' stmtlst ']' ']'
;

print:		'[' tPRINT ',' '[' expr ']' ']' {printer($5);}
;

expr:		tINT 		{$$ = makeINTnode($1);} 
		| tFLOAT 	{$$ = makeFLOnode($1);}
		| tSTRING	{$$ = makeSTRnode($1);}
		| getExpr 	{$$ = space_opener();}
		| function 	{$$ = space_opener();}
		| operation 	{$$ = type_checker($1);}
		| condition	{$$ = space_opener();}
;

operation:	'[' tADD ',' expr ',' expr ']'  {$$ =  calculate($4, $6, ADD); $$ -> line = $2;}
		| '[' tSUB ',' expr ',' expr ']' {$$ =  calculate($4, $6, SUB); $$ -> line = $2;}
		| '[' tMUL ',' expr ',' expr ']' {$$ =  calculate($4, $6, MUL); $$ -> line = $2;}
		| '[' tDIV ',' expr ',' expr ']' {$$ =  calculate($4, $6, DIV); $$ -> line = $2;}
;	

unaryOperation: '[' tINC ',' tIDENT ']'
		| '[' tDEC ',' tIDENT ']'
;


function:	 '[' tFUNCTION ',' '[' parametersList ']' ',' '[' stmtlst ']' ']'
		| '[' tFUNCTION ',' '[' ']' ',' '[' stmtlst ']' ']'
;

condition:	'[' tEQUALITY ',' expr ',' expr ']' {printer($4); printer($6);}
		| '[' tGT ',' expr ',' expr ']' {printer($4); printer($6);}
		| '[' tLT ',' expr ',' expr ']' {printer($4); printer($6);}
		| '[' tGEQ ',' expr ',' expr ']' {printer($4); printer($6);}
		| '[' tLEQ ',' expr ',' expr ']' {printer($4); printer($6);}
;

returnStmt:	'[' tRETURN ',' expr ']' {printer($4);}
		| '[' tRETURN ']'
;

parametersList: parametersList ',' tIDENT | tIDENT
;

exprList:	exprList ',' expr {printer($3);}| expr {printer($1);} 
;

%%
int lineNO;

char * subStr(char * string) {
	int len = strlen(string);
	char * newstr = (char *) malloc(sizeof(char*) * len - 1);
	strncpy(newstr, &string[1], len - 2);
    	newstr[len - 2] = '\0';
	return newstr;
}

char * strAdder(char * str1, char * str2) {
	char * str3 = (char *) malloc(1 +sizeof(char*) * (strlen(str1)+ strlen(str2)));
	strcpy(str3, str1);
     	strcat(str3, str2);
	return (str3);
}

void printer (type_value * node) {
	int mismatch = node -> mismatch;
	int line = node -> line;
	if(node -> type == integer) {
		printf("Result of expression on %d is (%d)\n", line, (int)node -> val); 
	}
	else if(node -> type == flo) {
		printf("Result of expression on %d is (%f)\n", line, node -> val);
	}
	else if(node -> type == str) {
		printf("Result of expression on %d is (%s)\n", line, node -> str);
	}
	else if (mismatch == 1){
		printf("Type mismatch on %d\n", line);
	}
}

type_value * makeINTnode(int i) {
	type_value * temp = (type_value *)malloc (sizeof(type_value));
	temp -> type = integer;
	temp -> val = i;
	temp -> str = "";
	temp -> isConstant = 1;
	return (temp);	
}

type_value * makeFLOnode(float i) {
        type_value * temp = (type_value *)malloc (sizeof(type_value));
        temp -> type = flo;
        temp -> val = i;
        temp -> str = "";
        temp -> isConstant = 1;
	return (temp);
}

type_value * makeSTRnode(char* n) {
        type_value * temp = (type_value *)malloc (sizeof(type_value));
        temp -> type = str;
        temp -> val = 0;
	temp -> str = subStr(n);
        temp -> isConstant = 1;
	return (temp);
}

type_value * space_opener() {
	type_value * temp = (type_value *)malloc (sizeof(type_value));
	temp -> type = nothing;
        temp -> val = 0;
        temp -> str = "";
        temp -> isConstant = 0;
	return (temp);
}


type_value * calculate(type_value * left, type_value * right, OPtypes operator) {
	int mismatch = 0;
	type_value * temp = (type_value *)malloc (sizeof(type_value));
	if(left -> isConstant == 1 && right -> isConstant == 1) {
	if(left -> type == nothing || right -> type == nothing) {
		temp -> type = nothing;
                temp -> val = 0;
                temp -> str = "";
	}
	else if(operator == ADD) {
		if(left -> type == right -> type) {
			temp -> type = left -> type;
			temp -> val = left -> val;
			temp -> val += right -> val;
			temp -> str = strAdder(left -> str, right -> str);
				
		}
		else if(left -> type == flo && right -> type == integer || left -> type == integer && right -> type == flo) {
			temp -> type = flo;
                        temp -> val = left -> val;
                        temp -> val += right -> val;
                        temp -> str = "";
		}
		else { //type mismatch!!
			mismatch = 1;
			temp -> type = nothing;
			temp -> val = 0;
                        temp -> str = "";
		}
	}
	else if(operator == SUB) {
		if(left -> type == right -> type && left -> type != str) {
			if(left -> type == flo) temp -> type = flo;
                        else temp -> type = integer;
                        temp -> val = left -> val;
                        temp -> val -= right -> val;
                        temp -> str = "";
		}
		else if(left -> type == flo && right -> type == integer || left -> type == integer && right -> type == flo) {
			temp -> type = flo;
                        temp -> val = left -> val;
                        temp -> val -= right -> val;
                        temp -> str = "";	
		}
		else { //type mismatch!!
                        mismatch = 1;
			temp -> type = nothing;
			temp -> val = 0;
			temp -> str = "";
		}
        }
	else if(operator == MUL) {

		if(left -> type == right -> type && left -> type != str) {
                        if(left -> type == flo) temp -> type = flo;
			else temp -> type = integer;
                        temp -> val = left -> val;
                        temp -> val *= right -> val;
                        temp -> str = "";
                }
                else if(left -> type == flo && right -> type == integer || left -> type == integer && right -> type == flo) {
                        temp -> type = flo;
                        temp -> val = left -> val;
                        temp -> val *= right -> val;
                        temp -> str = "";
		}
		else if(left -> type == integer && right -> type == str) {
			int i = 0;
			if(left -> type == integer) {
				i = left -> val;
				temp -> str = right -> str;
			}
			else {
				i = right -> val;
				temp -> str = left -> str;
			}
			temp -> type = str;
			temp -> val = 0;
			char * tempstr = temp -> str;
			for(;i > 1; i--) {
				temp -> str = strAdder(temp -> str, tempstr);	
			}
		}
		else { //type mismatch!!!
                        mismatch = 1;
			temp -> type = nothing;
                        temp -> val = 0;
                        temp -> str = "";
		}
        }
	else if(operator == DIV) {
		if(left -> type == right -> type && left -> type != str) {
                        if(left -> type == flo) temp -> type = flo;
                        else temp -> type = integer;
                        temp -> val = left -> val;
                        temp -> val /= right -> val;
                        temp -> str = "";
                }
                else if(left -> type == flo && right -> type == integer || left -> type == integer && right -> type == flo) {
                        temp -> type = flo;
                        temp -> val = left -> val;
                        temp -> val /= right -> val;
                        temp -> str = "";
                }
                else { //type mismatch!!
                        mismatch = 1;
                        temp -> type = nothing;
                        temp -> val = 0;
                        temp -> str = "";
                }
        }
	temp-> isConstant = 1;
	temp -> mismatch = mismatch;
	}
	else {
		temp -> mismatch = mismatch;
		temp -> type = nothing;
                temp -> val = 0;
                temp -> str = "";
		temp -> isConstant = 0;
	}
	return (temp);
}

type_value * type_checker(type_value * param) {
	type_value * temp = (type_value *)malloc (sizeof(type_value));
	if(param->type == integer || param->type == flo || param->type == str) {
		temp -> type = param -> type;
		temp -> val = param -> val;
		temp -> str = param -> str;
	}
	else {
		temp -> type = nothing;
		temp -> val = 0;
		temp -> str = "";
	}
	temp -> line = param -> line;
	temp -> mismatch = param -> mismatch;
	temp -> isConstant = 1;
	return (temp);
}

int main ()
{
if (yyparse()) {
// parse error
printf("ERROR\n");
return 1;
}
else {
// successful parsing
return 0;
}
}
