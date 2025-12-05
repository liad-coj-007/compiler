%{
#define BUFFER_SIZE 1024
#include <stdio.h>
#include <stdlib.h>
#include "output.hpp"
#include "nodes.hpp"
#include "tokens.hpp"
#include "parser.tab.h"



char string_buffer[BUFFER_SIZE] = {0};         // buffer to hold string
int string_len = 0;                     // length of the string

int hexToInt(char c);                   // convert hex char to int
int processHex(int i);                  // converts hex from string buffer to int
int processEscapeSequence(int i);       // covert escape sequence from string buffer to char
void processString();                   // deal with escape sequences in strings
void printToken(enum tokentype token);  // print token function


/**
 * @brief empty the buffer of the string
*/
void empty_buffer(int size); 
/**
 * @brief send a lex error msg
*/
void errorLex();

tokentype AddTokenType( tokentype token);

%}

%option yylineno
%option noyywrap

LETTER      ([a-z]|[A-Z])
DIGIT       [0-9]
NOT0DIGIT   [1-9]
CHAR   [\x20-\x21\x23-\x7E]

ID          {LETTER}({LETTER}|{DIGIT})*
NUM         (0|{NOT0DIGIT}{DIGIT}*)
NUM_B       {NUM}b

RELOP       (>=?|<=?|==|!=)
BINOP       (\+|\-|\*|\/)

BLACKSLASH   \\
QUOTE       \"
WHITE_SPACE [ \t\r\n ]

%x COMMENT_STATE
%x STRING_STATE
%x BLACKSLASH_STATE

%%
"void"  {return AddTokenType(TOKEN_VOID);}

"int"   {return AddTokenType(TOKEN_INT);}

"byte"  {return AddTokenType(TOKEN_BYTE);}

"bool"  {return AddTokenType(TOKEN_BOOL);}
"and" {return AddTokenType(TOKEN_AND);}

"or" {return AddTokenType(TOKEN_OR);}

"not" {return AddTokenType(TOKEN_NOT);}
"true"                      {return AddTokenType(TOKEN_TRUE);}
"false"                     {return AddTokenType(TOKEN_FALSE);}
"return"                    {return AddTokenType(TOKEN_RETURN);}
"if"                        {return AddTokenType(TOKEN_IF);}
"else"                      {return AddTokenType(TOKEN_ELSE);}
"while"                     {return AddTokenType(TOKEN_WHILE);}
"break"                     {return AddTokenType(TOKEN_BREAK);}
"continue"                  {return AddTokenType(TOKEN_CONTINUE);}

";"         {return AddTokenType(TOKEN_SC);}
","         { return AddTokenType(TOKEN_COMMA); }
"("         { return AddTokenType(TOKEN_LPAREN); }
")"         { return AddTokenType(TOKEN_RPAREN); }
"{"         { return AddTokenType(TOKEN_LBRACE); }
"}"         { return AddTokenType(TOKEN_RBRACE); }
"["         { return AddTokenType(TOKEN_LBRACK); }
"]"         { return AddTokenType(TOKEN_RBRACK); }
"="         { return AddTokenType(TOKEN_ASSIGN); }
">"         { return AddTokenType(TOKEN_GT); }
"<"         { return AddTokenType(TOKEN_LT); }
">="        { return AddTokenType(TOKEN_GE); }
"<="        { return AddTokenType(TOKEN_LE); }
"=="        { return AddTokenType(TOKEN_EQ); }
"!="        { return AddTokenType(TOKEN_NE); }

"+"         { return AddTokenType(TOKEN_PLUS); }
"-"         { return AddTokenType(TOKEN_MINUS); }
"*"         { return AddTokenType(TOKEN_MUL); }
"/"         { return AddTokenType(TOKEN_DIV); }

{ID}                        { printToken(TOKEN_ID);
                              yylval = std::make_shared<ast::Id>(yytext);
                              return TOKEN_ID;
                            }

{NUM}                       { printToken(TOKEN_NUM);
                              yylval = std::make_shared<ast::Num>(yytext);
                              return TOKEN_NUM;
                            }

{NUM_B}                     { printToken(TOKEN_NUM_B);
                              yylval = std::make_shared<ast::NumB>(yytext);
                              return TOKEN_NUM_B;
                            }

{WHITE_SPACE}               { /* skip */ }

"//"                        { BEGIN(COMMENT_STATE); }
<COMMENT_STATE>[^\n]*       { printToken(TOKEN_COMMENT); BEGIN(INITIAL); }

{QUOTE}                     { BEGIN(STRING_STATE); }

<STRING_STATE>{BLACKSLASH}  { string_buffer[string_len++] = yytext[0];
                              BEGIN(BLACKSLASH_STATE);
                            }

<STRING_STATE>{CHAR}        { string_buffer[string_len++] = yytext[0]; }

<STRING_STATE>{QUOTE}       {
                                processString();
                                printToken(TOKEN_STRING);
                                BEGIN(INITIAL);
                                return TOKEN_STRING;
                            }

<STRING_STATE>\n            { errorLex(); }

<BLACKSLASH_STATE>{CHAR}|{QUOTE}
                            { string_buffer[string_len++] = yytext[0];
                              BEGIN(STRING_STATE);
                            }

<BLACKSLASH_STATE>\n        { errorLex(); }

.                           { errorLex(); }


%%


int hexToInt(char c) {
    if (c >= '0' && c <= '9') return c - '0';
    if (c >= 'a' && c <= 'f') return c - 'a' + 10;
    if (c >= 'A' && c <= 'F') return c - 'A' + 10;
    return -1; // invalid hex digit
}

int processHex(int i) {
    char escape[4] = {'x', '\0', '\0', '\0'};
    if (i == string_len) {  errorLex(); }
    escape[1] = string_buffer[i];
    if (i + 1 == string_len) {  errorLex(); }
    int d1 = hexToInt(escape[1]);
    if (d1 == -1) {  errorLex(); }
    escape[2] = string_buffer[i + 1];
    int d2 = hexToInt(escape[2]);
    if (d2 == -1) { errorLex(); }
    int value = d1 * 16 + d2;
    if (value < 32 || value > 126) {
         errorLex();
    }
    return value;
}

int processEscapeSequence(int i) {
    if (i == string_len) {
        errorLex();
    }
    
    switch (string_buffer[i]) {
        case '\\':
            string_buffer[i] = '\\'; return i;
        case '"':
            string_buffer[i] = '"'; return i;
        case 'n':
            string_buffer[i] = '\n'; return i;
        case 'r':
            string_buffer[i] = '\r'; return i;
        case 't':
            string_buffer[i] = '\t'; return i;
        case '0':
            string_buffer[i] = '\0'; return i;
        case 'x':
            string_buffer[i + 2] = processHex(i + 1); return i + 2;
        default:
            char escape[2] = {string_buffer[i], '\0'};
            errorLex();
    }
}

void processString() {
    int index = 0;
    for (int i = 0; i < string_len; i++) {
        if (string_buffer[i] == '\\') {
            i = processEscapeSequence(i + 1);
        }
        string_buffer[index++] = string_buffer[i];
    }
    string_buffer[index] = '\0';
    llval = std::make_shared<ast::String>(string_buffer);
   
    empty_buffer(string_len);
}

void empty_buffer(int size){
    for(int i = 0; i < size;i++){
        string_buffer[i] = '\0';
    }
    string_len = 0;
}



void printToken(enum tokentype token) {
    // output::printToken(yylineno, token, yytext);
}

void errorLex(){
    output::errorLex(lineno);
}

tokentype AddTokenType( tokentype token){
    printToken(token);
    return token;
}
