%{
#define BUFFER_SIZE 1024
#include <stdio.h>
#include <stdlib.h>
#include "output.hpp"



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

"void"                      { printToken(VOID); }
"int"                       { printToken(INT); }
"byte"                      { printToken(BYTE); }
"bool"                      { printToken(BOOL); }
"and"                       { printToken(AND); }
"or"                        { printToken(OR); }
"not"                       { printToken(NOT); }
"true"                      { printToken(TRUE); }
"false"                     { printToken(FALSE); }
"return"                    { printToken(RETURN); }
"if"                        { printToken(IF); }
"else"                      { printToken(ELSE); }
"while"                     { printToken(WHILE); }
"break"                     { printToken(BREAK); }
"continue"                  { printToken(CONTINUE); }

";"                         { printToken(SC); }
","                         { printToken(COMMA); }
"("                         { printToken(LPAREN); }
")"                         { printToken(RPAREN); }
"{"                         { printToken(LBRACE); }
"}"                         { printToken(RBRACE); }
"["                         { printToken(LBRACK); }
"]"                         { printToken(RBRACK); }
"="                         { printToken(ASSIGN); }
{RELOP}                     { printToken(RELOP); }
{BINOP}                     { printToken(BINOP); }
{ID}                        { printToken(ID); }
{NUM}                       { printToken(NUM); }
{NUM_B}                     { printToken(NUM_B); }

{WHITE_SPACE}              { /* skip whitespace */ }

"//"                        { BEGIN(COMMENT_STATE); }
<COMMENT_STATE>[^\n]*       { printToken(COMMENT); BEGIN(INITIAL); }

{QUOTE}                     { BEGIN(STRING_STATE); }
<STRING_STATE>{BLACKSLASH}  {string_buffer[string_len++] = yytext[0];
                            BEGIN(BLACKSLASH_STATE);}
<STRING_STATE>{CHAR}        { string_buffer[string_len++] = yytext[0]; }

<STRING_STATE>{QUOTE}       { processString(); BEGIN(INITIAL); }
<STRING_STATE>\n            { output::errorUnclosedString(); }

<BLACKSLASH_STATE>{CHAR}|{QUOTE} {string_buffer[string_len++] = yytext[0];BEGIN(STRING_STATE);}
<BLACKSLASH_STATE>\n            { output::errorUnclosedString(); }

.                           { output::errorUnknownChar(yytext[0]); }

%%


int hexToInt(char c) {
    if (c >= '0' && c <= '9') return c - '0';
    if (c >= 'a' && c <= 'f') return c - 'a' + 10;
    if (c >= 'A' && c <= 'F') return c - 'A' + 10;
    return -1; // invalid hex digit
}

int processHex(int i) {
    char escape[4] = {'x', '\0', '\0', '\0'};
    if (i == string_len) { output::errorUndefinedEscape(escape); }
    escape[1] = string_buffer[i];
    if (i + 1 == string_len) { output::errorUndefinedEscape(escape); }
    int d1 = hexToInt(escape[1]);
    if (d1 == -1) { output::errorUndefinedEscape(escape); }
    escape[2] = string_buffer[i + 1];
    int d2 = hexToInt(escape[2]);
    if (d2 == -1) { output::errorUndefinedEscape(escape); }
    int value = d1 * 16 + d2;
    if (value < 32 || value > 126) {
        output::errorUndefinedEscape(escape);
    }
    return value;
}

int processEscapeSequence(int i) {
    if (i == string_len) {
        output::errorUndefinedEscape("");
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
            output::errorUndefinedEscape(escape);
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
    output::printToken(yylineno,STRING,string_buffer);
   
    empty_buffer(string_len);
}

void empty_buffer(int size){
    for(int i = 0; i < size;i++){
        string_buffer[i] = '\0';
    }
    string_len = 0;
}



void printToken(enum tokentype token) {
    output::printToken(yylineno, token, yytext);
}
