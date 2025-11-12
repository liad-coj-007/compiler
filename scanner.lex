%{
#include <stdio.h>
/**
 * @brief print the token
 * @param name - the name of the token
*/
void ShowToken(const char* name);
%}

%option yylineno
%option noyywrap
mul  \*
plus \+
div "/"
sub -

%%
{mul}|{sub}|{plus}|{div}     {ShowToken("BinOp");}
%%


void ShowToken(const char* name){
    printf("<%s, %s>",name,yytext);
}
