%{
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h> /* va_list, va_start, va_arg, va_end */
#include "calculator_interpreter_partial.h"

nodeType *opera(int oper_id, int n_operands, ...);
nodeType *identifier(int i);
nodeType *constant(int value);
void freedom(nodeType *p);
int interpret(nodeType *p);
int yylex(void);

void yyerror(char *s);
int symbol_table[1000];//CSI3120

%}

%union { //Create a union to handle the integer input values, the index to the symble table for identifiers, or the
         // pointer for an operator node
    int input_Value;
    char symbol_index;
    nodeType *nodePointer;
};

%token <input_Value> INTEGER
%token <symbol_index> VARIABLE
%token PRT
%token WHILE IF  //CSI3120
%nonassoc ELSE     //CSI3120
%nonassoc IFX       //CSI3120

%left '+'
%left '-'  //CSI3120
%left '*'  //CSI3120
%left '/'  //CSI3120
%left '%'  //CSI3120
%right '=' //CSI3120
%nonassoc UMINUS //CSI3120
%left GE NE LE EQ '<' '>'   //CSI3120


%type <nodePointer> stmt expr term factor stmt_list //CSI3120

%%


program:
    function	{ exit(0); }
    ;

function:
        function stmt   { interpret($2); freedom($2); }
        | /* NULL */
        ;

stmt:
    ';'				                    { $$ = opera(';', 2, NULL, NULL); }
    | expr ';'			                { $$ = $1; }
    | PRT expr ';'		                { $$ = opera(PRT, 1, $2); }
    | VARIABLE '=' expr ';'	            { $$ = opera('=', 2, identifier($1), $3); }
    | WHILE '(' expr ')' stmt           { $$ = opera(WHILE, 2, $3, $5); } //CSI3120
   // | IF '(' expr ')' stmt %prec IFX    { $$ = opera(IF, 2, $3, $5); }//CSI3120
    | IF '(' expr ')' stmt ELSE stmt    { $$ = opera(IF, 3, $3, $5, $7); }//CSI3120
    | '{' stmt_list '}'                 { $$ = $2; }//CSI3120
    ;

stmt_list:
    stmt                                { $$ = $1; }//CSI3120
    |stmt_list stmt                     { $$ = opera(';', 2, $1, $2); }//CSI3120
    ;

expr:
     expr '+' term                      { $$ = opera('+', 2, $1, $3); }//CSI3120
    | expr '-' term	                    { $$ = opera('-', 2, $1, $3); } //CSI3120
    | term		                        { $$ = $1; }                          //CSI3120
    | expr '<' expr                     { $$ = opera('<', 2, $1, $3); }//CSI3120
    | expr '>' expr                     { $$ = opera('>', 2, $1, $3); }//CSI3120
    | expr GE expr                      { $$ = opera(GE, 2, $1, $3); }//CSI3120
    | expr LE expr                      { $$ = opera(LE, 2, $1, $3); }//CSI3120
    | expr NE expr                      { $$ = opera(NE, 2, $1, $3); }//CSI3120
    | expr EQ expr                      { $$ = opera(EQ, 2, $1, $3); }//CSI3120
    ;

term: 
    term '*' factor                     { $$ = opera('*', 2, $1, $3); }  //CSI3120
    | term '/' factor                   { if($3==0)
					yyerror("Divide zero");
				else	
					$$ = opera('/', 2, $1, $3); }  //CSI3120
    | term '%' factor                   { $$ = opera('%', 2, $1, $3); }  //CSI3120
    | factor		                    { $$ = $1; }  			//CSI3120
    ;

factor:
    INTEGER		                        { $$ = constant($1); }	     //CSI3120
    |VARIABLE                           { $$ = identifier($1); }		//CSI3120
    |'(' expr ')' 	                    { $$ = $2; }			//CSI3120
    | '-' factor %prec UMINUS           { $$ = opera(UMINUS, 1, $2); } //CSI3120
    ;
    

%%

nodeType *constant(int value) {
    nodeType *p;
    if ((p = malloc(sizeof(nodeType))) == NULL) yyerror("Could not allocate node for constant");

    //set node properties
    p->type = typeConstant;
    p->constant.value = value;

    return p;
}

nodeType *identifier(int i) {
    nodeType *p;

    /* allocate node */
    if ((p = malloc(sizeof(nodeType))) == NULL) yyerror("Could not allocate node for identifier");

    p->type = typeIdentifier;
    p->identifier.identifier_index = i;
    

    return p;
}

nodeType *opera(int oper_id, int n_operands, ...) {
    va_list ap;
    nodeType *p;
    int i;

    /* allocate node, extending operands array */
    if ((p = malloc(sizeof(nodeType) + (n_operands - 1) * sizeof(nodeType *))) == NULL)
        yyerror("Could not allocate node for operator and its operands!");

    p->type = typeOperator;
    p->operator_.operator_id = oper_id;
    p->operator_.number_of_operands = n_operands;
    va_start(ap, n_operands);
    for (i = 0; i < n_operands; i++) p->operator_.poperands[i] = va_arg(ap, nodeType*);
    va_end(ap);
    return p;
}

void freedom(nodeType *p) {
    if (!p) return;
    int i;
    if (p->type == typeOperator)
        for (i = 0; i < p->operator_.number_of_operands; i++) freedom(p->operator_.poperands[i]);
    free(p);
}

void yyerror(char *s) { fprintf(stdout, "CSI3120 calc: %s\n", s);}

int main(void) { yyparse(); return 0; }
