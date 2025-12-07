%{

#include "nodes.hpp"
#include "output.hpp"

extern int yylineno;
extern int yylex();

void yyerror(const char* msg) {
    output::errorSyn(yylineno);
}

std::shared_ptr<ast::Node> program;

#include "BisonUtilis.h"
using namespace std;
using namespace bisonutils;

%}

/* Tokens */
%token ID
%token LPAREN RPAREN
%token COMMA
%token INT BYTE BOOL VOID
%token LBRACE RBRACE
%token RETURN IF ELSE WHILE BREAK CONTINUE
%token ASSIGN
%token SC
%token NUM
%token STRING

/* 순서 והעדפות (אם תרצה בהמשך לביטויים) */
%left COMMA

%%

Program:
    Funcs     { program = $1; }
;

Funcs:
      FuncDecl Funcs   { $$ = BuildList($2, $1); }
    | /* epsilon */    { $$ = BuildList<Funcs,FuncDecl>(nullptr, nullptr); }
;

FuncDecl:
      RetType ID LPAREN Formals RPAREN LBRACE Statements RBRACE
        { $$ = BuildFuncDecl($1, $2, $4, $7); }
;

RetType:
      Type             { $$ = $1; }
    | VOID             { $$ = BuildType(BuiltInType::VOID); }
;

Formals:
      /* epsilon */     { $$ = BuildList<Formals,Formal>(nullptr, nullptr); }
    | FormalsList       { $$ = $1; }
;

FormalsList:
      FormalDecl                           { $$ = BuildList<Formals,Formal>(nullptr, $1); }
    | FormalDecl COMMA FormalsList         { $$ = BuildList($3, $1); }
;

FormalDecl:
      Type ID   { $$ = BuildFormalDecl($1, $2); }
;

Call:
      ID LPAREN ExpList RPAREN         { $$ = BuildCall($1, $3); }
    | ID LPAREN RPAREN                 { $$ = BuildCall($1, nullptr); }
;

Statements:
      Statement
    | Statements Statement             { $$ = BuildList<Statements,Statement>($1, $2); }
;

Statement:
      LBRACE Statements RBRACE         { $$ = $2; }
    | Type ID SC                       { $$ = BuildVarDecl($2, $1); }
    | Type ID ASSIGN EXP SC            { $$ = BuildVarDecl($2, $1, $4); }
    | ID ASSIGN EXP SC                 { $$ = BuildAssign($1, $3); }
    | Call SC                          { $$ = $1; }
    | RETURN SC                        { $$ = $1; }
    | IF LPAREN EXP RPAREN Statements  { $$ = BuildIf($3, $5); }
    | IF 
;

ExpList:
      EXP                          { $$ = BuildList<ExpList,Exp>(nullptr, $1); }
    | EXP COMMA ExpList            { $$ = BuildList($3, $1); }
;

%%

