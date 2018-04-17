typedef enum { typeConstant, typeIdentifier, typeOperator } nodeTEnum; // a node is of type constant, identifier, or operator

/* constants hold only values, e.g. 1, 2, 3 ... */
typedef struct {
    int value;
} constantNodeType;

//CSI3120
extern int symbol_table[1000]; // this is a reference to the symbol table specified on the yacc (.y) file

/* the symbol table is implemented by a simple array of ints (our calculator supports integer only)
 * so the identifiers nodes contain a index to the symbol table
 */
typedef struct {
    int identifier_index;
} identifierNodeType;

/* operators have id, number of operands, and a pointer to operands that is expanded during parsing
 * the number of operands depends on the expression and operator, e.g.
 *      a= b - c // '-' operator with two operands that may be solved at runtime;
 *      a= -b    // '-' operator with one operand
 */
typedef struct {
    int operator_id;
    int number_of_operands;
    struct nodeTypeTag *poperands[1];   /* operands expanded during parsing */
} operatorNodeType;

typedef struct nodeTypeTag {
    nodeTEnum type; //type

    union { //this union is allocated depending on the type, constants, identifiers, operators
        constantNodeType constant;
        identifierNodeType identifier;
        operatorNodeType operator_;
    };
} nodeType;
