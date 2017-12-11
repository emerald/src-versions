%{
/*
 * @(#)vmcpar.y	1.3  1/18/90
 */
#include <stdlib.h>
#include <stdio.h>
#include "defs.h"

extern FILE *actions, *otherstuff;
extern int linenumber;
int theline;
%} 
%token  OEOF 0 /* "end of file" */
%token	KSTATE
%token	KINTERRUPTS
%token	KINSTRUCTIONS
%token <string> ID /* "identifier" */
%token <string> NUMBER /* "number" */
%token <string> CODE /* "{ ... }" */
%token <string> STRING /* "string" */
%start machine
%union yylval {
    struct identifier_entry	*id;
    char			*string;
} 
%%
machine :
		odefinitions ostate ointerrupts oinstructions
	;
odefinitions:
		
	|	CODE
		{ installDefinition($1); }
	;
ostate:
		KSTATE states
	|
	;
states:
		
	|	states ID STRING STRING
		{ installState($2, $3, $4); }
	;
ointerrupts:
		KINTERRUPTS interrupts
	|	
	;
interrupts:
		
	|	interrupts ID CODE
		{ installInterrupt($2, $3); }
	;
oinstructions:
		KINSTRUCTIONS instructions
	|	
	;
instructions:
	|	instructions { theline = linenumber; } ID STRING CODE
		{ installInstruction($3, $4, $5, theline); }
	;
%%
