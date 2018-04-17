#include <stdio.h>
#include "calculator_interpreter_partial.h"
#include "y.tab.h"

int interpret(nodeType *p) {
    if (!p) return 0;
    switch (p->type) {
        case typeConstant:
            return p->constant.value;
        case typeIdentifier:
            return symbol_table[p->identifier.identifier_index];
        case typeOperator:
            switch (p->operator_.operator_id) {
                //CSI3120
                case WHILE:
                    while(interpret(p->operator_.poperands[0]))
                        interpret(p->operator_.poperands[1]);
                    return 0;
                case IF:
                    if( interpret(p->operator_.poperands[0]))
                        interpret(p->operator_.poperands[1]);
                    else if( ! interpret(p->operator_.poperands[0]))
                        interpret(p->operator_.poperands[2]);
                    return 0;
                //CSI3120
                case PRT:
                    printf("Calculator output: %d\n", interpret(p->operator_.poperands[0]));
                    return 0;
                case ';':
                    interpret(p->operator_.poperands[0]);
                    return interpret(p->operator_.poperands[1]);
                case '=':
                    return symbol_table[p->operator_.poperands[0]->identifier.identifier_index] = interpret(
                            p->operator_.poperands[1]);
                case '+':
			
                    return interpret(p->operator_.poperands[0]) + interpret(p->operator_.poperands[1]);
                //CSI3120
                case '-':
			
                    return interpret(p->operator_.poperands[0]) - interpret(p->operator_.poperands[1]);
                case '*':
			
                    return interpret(p->operator_.poperands[0]) * interpret(p->operator_.poperands[1]);
                case '/':
			
                    return interpret(p->operator_.poperands[0]) / interpret(p->operator_.poperands[1]);
                case '%':
			
                    return interpret(p->operator_.poperands[0]) % interpret(p->operator_.poperands[1]);
                case UMINUS:
                    return 0 - interpret(p->operator_.poperands[0]);
        
                case '<':
                    return interpret(p->operator_.poperands[0]) < interpret(p->operator_.poperands[1]);
                case '>':
                    return interpret(p->operator_.poperands[0]) > interpret(p->operator_.poperands[1]);
                case GE:
                    return interpret(p->operator_.poperands[0]) >= interpret(p->operator_.poperands[1]);
                case LE:
                    return interpret(p->operator_.poperands[0]) <= interpret(p->operator_.poperands[1]);
                case NE:
                    return interpret(p->operator_.poperands[0]) != interpret(p->operator_.poperands[1]);
                case EQ:
                    return interpret(p->operator_.poperands[0]) == interpret(p->operator_.poperands[1]);
                //CSI3120
		

            }
    }
    return 0;
}
