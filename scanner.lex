%{
#include <stdio.h>
/**
 * @brief print the token
 * @param name - the name of the token
*/
void ShowToken(const char* name);

/**
 * @brief print the string u got from the user
*/
void PrintStr();

/**
 * @brief printing a backslash cmd
*/
void PrintBlackSlash();


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

blackslash "\\"
quote  "\""

forbid_chars [\042\092\012\015]

str_letters ^{forbid_chars}

str_cmd {blackslash}|"n"|"r"|"t"|"\""

%x STRING

%x STRCMD

%%

{mul}|{sub}|{plus}|{div}     {ShowToken("BinOp");}
{relop}                      {ShowToken("RelOp");}
{quote}                      {BEGIN(STRING);printf("=======begin string====\n");}

<STRING>{quote}             { BEGIN(INITIAL); printf("\n========ending string====\n"); }
<STRING>{str_letters}+      { PrintStr(); }

<STRING>{blackslash} {BEGIN(STRCMD);}

<STRCMD>{str_cmd}       {PrintBlackSlash();BEGIN(STRING);}


%%


void ShowToken(const char* name){
    printf("<%s, %s>",name,yytext);
}

void PrintStr(){
    printf("%s",yytext);
}

void PrintBlackSlash(){
    char cmd = yytext[0];
    switch(cmd) {
        case '\\':
            putchar('\\');
            break;
        case '"':
            putchar('"');
            break;
        case 'n':
            putchar('\n');   // newline
            break;
        case 'r':
            putchar('\r');   // carriage return
            break;
        case 't':
            putchar('\t');   // tab
            break;
        case '0':
            putchar('\0');   // null char
            break;
        default:
            putchar(cmd);    
            break;
    }
   


}
