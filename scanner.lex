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
eq "="
gt ">"
lt "<"
not "!"

cmp_op {gt}|{lt}
relop {cmp_op}{eq}?|({eq}|{not}){eq}


%%
{mul}|{sub}|{plus}|{div}     {ShowToken("BinOp");}
{relop}                      {ShowToken("Relop");}

%%


void ShowToken(const char* name){
    printf("<%s, %s>",name,yytext);
}
