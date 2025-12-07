%{

#include "nodes.hpp"
#include "output.hpp"
#include "tokens.hpp"

extern int yylineno;
extern int yylex();
void yyerror(const char*){
    oytput::
}

std::shared_ptr<ast::Node> program;

#include "BisonUtilis.h"
using namespace std;
using namespace bisonutils;

%}

/* Tokens */
%token TOKEN_ID
%token TOKEN_LPAREN
%token TOKEN_RPAREN
%left  TOKEN_COMMA
%token TOKEN_INT
%token TOKEN_BYTE
%token TOKEN_BOOL
%token TOKEN_LBRACE
%token TOKEN_RBRACE
%token TOKEN_VOID

%%

Program:
    Funcs    { program = $1; }
;

Funcs:
      FuncDecl Funcs   { $$ = bisonutils::BuildList($2, $1); }
    | /*epsilon*/       { $$ = bisonutils::BuildList<Funcs,FuncDecl>(nullptr,nullptr); }
;

FuncDecl:
    RetType TOKEN_ID TOKEN_LPAREN Formals TOKEN_RPAREN TOKEN_LBRACE Statements TOKEN_RBRACE
        { $$ = bisonutils::BuildFuncDecl($1, $2, $4, $7); }
;

RetType:
      Type         { $$ = $1; }
    | TOKEN_VOID   { $$ = bisonutils::BuildType(BuiltInType::VOID); }
;

Formals:
      /* epsilon */   { $$ = bisonutils::BuildList<Formals,Formal>(nullptr, nullptr); }
    | FormalsList     { $$ = $1; }
;

FormalsList:
      FormalDecl                         { $$ = bisonutils::BuildList<Formals,Formal>(nullptr, $1); }
    | FormalDecl TOKEN_COMMA FormalsList { $$ = bisonutils::BuildList($3, $1); }
;

FormalDecl:
    Type TOKEN_ID { $$ = bisonutils::BuildFormalDecl($1, $2); }
;



Call:
      TOKEN_ID TOKEN_LPAREN ExpList TOKEN_RPAREN
        { $$ = bisonutils::BuildCall($1, $3); }
    | TOKEN_ID TOKEN_LPAREN TOKEN_RPAREN
        { $$ = bisonutils::BuildCall($1, nullptr); }
;

Statements: Statement
            | Statements Statement {$$ = BuildList<Statements,Statement>($1,$2);}

Statement: TOKEN_LBRACE Statements TOKEN_RBRACE {$$ = $2;}
           | Type TOKEN_ID TOKEN_SC {$$ = BuildVarDecl($2,$1);}
           | Type TOKEN_ID TOKEN_ASSIGN EXP TOKEN_SC {$$ = BuildVarDecl($2,$1,$4);}
           | TOKEN_ID TOKEN_ASSIGN EXP TOKEN_SC {$$ = BuildAssign($1,$3);}
           | Call TOKEN_SC {$$ = $1};
           | TOKEN_RETURN TOKEN_SC {$$ = $1;}
           | TOKEN_IF TOKEN_LPAREN EXP TOKEN_RPAREN Statements {$$ = BuildIf($2,$5);}

ExpList:
      EXP                    { $$ = bisonutils::BuildList<ExpList,Exp>(nullptr, $1); }
    | EXP TOKEN_COMMA ExpList { $$ = bisonutils::BuildList($3, $1); }
;

%%

