%{
#include <stdio.h>
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
