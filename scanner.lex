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
quote    [\042] /* this means a " */
forbid_chars       [\012\015\042]
str_letters [^\012\015\042]
/* %x STRING {quote} */

%%
{mul}|{sub}|{plus}|{div}     {ShowToken("BinOp");}
{relop}                      {ShowToken("RelOp");}
{str_letters}+               {ShowToken("lf");}
%%


void ShowToken(const char* name){
    printf("<%s, %s>",name,yytext);
}
