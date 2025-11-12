%{
#include <stdio.h>
#include <stdlib.h>

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


/**
 * @brief print the hex number
*/
void PrintHex();


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

digit [0-9]
hex_sign [A-F]
hex_num x({digit}|{hex_sign})({digit}|{hex_sign})

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
<STRCMD>{hex_num}       {PrintHex();BEGIN(STRING);}

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

void PrintHex(){
    char value = strtol(yytext + 1, NULL, 16);
    printf("%c",value);
}
