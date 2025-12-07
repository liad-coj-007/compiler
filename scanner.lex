%{
#define BUFFER_SIZE 1024
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "parser.tab.h"      
#include "output.hpp"
#include "nodes.hpp"

extern int yylineno;
extern YYSTYPE yylval;

char string_buffer[BUFFER_SIZE] = {0};
int string_len = 0;

int hexToInt(char c);
int processHex(int i);
int processEscapeSequence(int i);
void processString();
void printToken(int token);
void empty_buffer(int size);
void errorLex();

int AddToken(int token);
%}

%option yylineno
%option noyywrap

LETTER      [a-zA-Z]
DIGIT       [0-9]
NOT0DIGIT   [1-9]
CHAR        [\x20-\x21\x23-\x7E]

ID          {LETTER}({LETTER}|{DIGIT})*
NUM         (0|{NOT0DIGIT}{DIGIT}*)
NUM_B       {NUM}b
WHITE_SPACE [ \t\r\n ]

%x COMMENT_STATE
%x STRING_STATE
%x BLACKSLASH_STATE

%%

"void"          { return AddToken(VOID); }
"int"           { return AddToken(INT); }
"byte"          { return AddToken(BYTE); }
"bool"          { return AddToken(BOOL); }

"and"           { return AddToken(AND); }
"or"            { return AddToken(OR); }
"not"           { return AddToken(NOT); }

"true"          { return AddToken(TRUE); }
"false"         { return AddToken(FALSE); }

"return"        { return AddToken(RETURN); }
"if"            { return AddToken(IF); }
"else"          { return AddToken(ELSE); }
"while"         { return AddToken(WHILE); }
"break"         { return AddToken(BREAK); }
"continue"      { return AddToken(CONTINUE); }

";"             { return AddToken(SC); }
","             { return AddToken(COMMA); }
"("             { return AddToken(LPAREN); }
")"             { return AddToken(RPAREN); }
"{"             { return AddToken(LBRACE); }
"}"             { return AddToken(RBRACE); }
"["             { return AddToken(LBRACK); }
"]"             { return AddToken(RBRACK); }

"="             { return AddToken(ASSIGN); }
">"             { return AddToken(GT); }
"<"             { return AddToken(LT); }
">="            { return AddToken(GE); }
"<="            { return AddToken(LE); }
"=="            { return AddToken(EQ); }
"!="            { return AddToken(NE); }

"+"             { return AddToken(PLUS); }
"-"             { return AddToken(MINUS); }
"*"             { return AddToken(MUL); }
"/"             { return AddToken(DIV); }

{ID} {
    printToken(ID);
    yylval.node = std::make_shared<ast::Id>(yytext);
    return ID;
}

{NUM} {
    printToken(NUM);
    yylval.node = std::make_shared<ast::Num>(yytext);
    return NUM;
}

{NUM_B} {
    printToken(NUM_B);
    yylval.node = std::make_shared<ast::NumB>(yytext);
    return NUM_B;
}

{WHITE_SPACE}   { /* skip */ }

"//"                { BEGIN(COMMENT_STATE); }
<COMMENT_STATE>[^\n]* {
    printToken(COMMENT);
    BEGIN(INITIAL);
}

\"                  { BEGIN(STRING_STATE); }

<STRING_STATE>\\ {
    string_buffer[string_len++] = '\\';
    BEGIN(BLACKSLASH_STATE);
}

<STRING_STATE>{CHAR} {
    string_buffer[string_len++] = yytext[0];
}

<STRING_STATE>\" {
    processString();
    printToken(STRING);
    yylval.node = std::make_shared<ast::String>(string_buffer);
    BEGIN(INITIAL);
    return STRING;
}

<STRING_STATE>\n    { errorLex(); }

<BLACKSLASH_STATE>{CHAR}|\" {
    string_buffer[string_len++] = yytext[0];
    BEGIN(STRING_STATE);
}

<BLACKSLASH_STATE>\n { errorLex(); }

.                   { errorLex(); }

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



void printToken(int token) {
    // output::printToken(yylineno, token, yytext);
}

void errorLex(){
    output::errorLex(lineno);
}

int AddToken(int token){
    printToken(token);
    return token;
}
