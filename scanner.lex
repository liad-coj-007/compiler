%{
#define BUFFER_SIZE 1024
#include <stdio.h>
#include <stdlib.h>
#include <memory>

     
#include "output.hpp"
#include "nodes.hpp"
#include "parser.tab.h" 

void printToken(int token);
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
"-"             { return AddToken(SUB); }
"*"             { return AddToken(MUL); }
"/"             { return AddToken(DIV); }

{ID} {
    printToken(ID);
    yylval = std::make_shared<ast::ID>(yytext);
    return ID;
}

{NUM} {
    printToken(NUM);
    yylval = std::make_shared<ast::Num>(yytext);
    return NUM;
}

{NUM_B} {
    printToken(NUM_B);
    yylval = std::make_shared<ast::NumB>(yytext);
    return NUM_B;
}

{WHITE_SPACE}   { /* skip */ }


\"([^\n\r\"\\]|\\[rnt\"\\])+\" {
    yylval = std::make_shared<ast::String>(yytext);
    return STRING;
}

"//"                { BEGIN(COMMENT_STATE); }
<COMMENT_STATE>[^\n]* {
    printToken(COMMENT);
    BEGIN(INITIAL);
}

.                   { errorLex(); }

%%



void printToken(int token) {
    // output::printToken(yylineno, token, yytext);
}

void errorLex(){
    //printf
    output::errorLex(yylineno);
}

int AddToken(int token){
    printToken(token);
    return token;
}
