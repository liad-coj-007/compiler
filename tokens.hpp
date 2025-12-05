#ifndef TOKENS_HPP
#define TOKENS_HPP

enum tokentype {
    TOKEN_VOID = 1,
    TOKEN_INT,
    TOKEN_BYTE,
    TOKEN_BOOL,
    TOKEN_AND,
    TOKEN_OR,
    TOKEN_NOT,
    TOKEN_TRUE,
    TOKEN_FALSE,
    TOKEN_RETURN,
    TOKEN_IF,
    TOKEN_ELSE,
    TOKEN_WHILE,
    TOKEN_BREAK,
    TOKEN_CONTINUE,
    TOKEN_SC,
    TOKEN_COMMA,
    TOKEN_LPAREN,
    TOKEN_RPAREN,
    TOKEN_LBRACE,
    TOKEN_RBRACE,
    TOKEN_LBRACK,
    TOKEN_RBRACK,
    TOKEN_ASSIGN,

    // Relational operators
    TOKEN_GT,      // >
    TOKEN_LT,      // <
    TOKEN_GE,      // >=
    TOKEN_LE,      // <=
    TOKEN_EQ,      // ==
    TOKEN_NE,      // !=

    // Binary operators
    TOKEN_PLUS,    // +
    TOKEN_MINUS,   // -
    TOKEN_MUL,     // *
    TOKEN_DIV,     // /

    TOKEN_COMMENT,
    TOKEN_ID,
    TOKEN_NUM,
    TOKEN_NUM_B,
    TOKEN_STRING
};

extern int yylineno;
extern char *yytext;
extern int yyleng;

extern int yylex();

#endif //TOKENS_HPP
