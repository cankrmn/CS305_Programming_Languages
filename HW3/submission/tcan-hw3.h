#ifndef __TCANHW3_H
#define __TCANHW3_H

typedef enum { nothing, integer, flo, str } types;

typedef enum {ADD, SUB, DIV, MUL} OPtypes;

typedef struct type_value {
	int mismatch;
        int line;
	int isConstant;
	types type;
	float val;
        char* str;
}type_value;

#endif
