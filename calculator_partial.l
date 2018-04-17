%{
#include <stdlib.h>
#include<string.h>
#include "calculator_interpreter_partial.h"
#include "y.tab.h"

void yyerror(char *);
int hash(char *input); //CSI3120

%}

%%


[ \t\n]+    ; /* whitespaces don't matter */

"print"     return PRT;

">="    return GE;
"<="    return LE;
"=="    return EQ;
"!="    return NE;
"while" return WHILE;
"if"    return IF;
"else"  return ELSE;



[=+*;/(){}.%-]       { return *yytext; } //CSI3120

	/*CSI3120*/	
[a-zA-Z][a-zA-Z0-9]*       {//printf("user defined variable: %s\n", yytext);
			yylval.symbol_index = hash(yytext);
			//printf("position: %d\n", hash(yytext));
			return VARIABLE; }

0           { yylval.input_Value = atoi(yytext); return INTEGER; }

[1-9][0-9]* { yylval.input_Value = atoi(yytext); return INTEGER; }

.           yyerror("Character not in the alphabet");
%%

int yywrap(void) {
    return 1;
}

/* hash the user variable, return a hashed integer value 
int hash(char *input){
	unsigned long hash = 5381;
    int c;

    while (c = *input++)
        hash = (((hash << 5) + hash) + c)%100000;
    return hash;
}
*/
//CSI3120
int hash (char *input)
{
    unsigned int hash = 0;
    for (int i = 0 ; input[i] != '\0' ; i++)
    {
        hash = (31*hash + input[i])%1000;
    }
    
    return hash;
}
