%{

#include "nodes.hpp"
#include "output.hpp"
#include <memory>
#include "BisonUtilis.h"
using namespace std;
using namespace bisonutils;
using namespace ast;

extern int yylineno;
extern int yylex();

void yyerror(const char* msg) {
    // cout << msg << endl;
    output::errorSyn(yylineno);
}

std::shared_ptr<ast::Node> program;




%}

%code requires {
    #include <memory>
    #include "nodes.hpp" // must declare namespace ast { struct Node; }
}

%define api.value.type {std::shared_ptr<ast::Node>}

/* Tokens */
%token ID
%token LPAREN RPAREN
%token COMMA
%token INT BYTE BOOL VOID
%token LBRACE RBRACE
%token RETURN WHILE BREAK CONTINUE
%token NOT
%token EQ NE LT GT LE GE 
%token TRUE FALSE
%token LBRACK RBRACK COMMENT
%token SC IF NUM NUM_B STRING

%right ASSIGN
%left OR
%left AND
%left EQ NE LT GT LE GE 
%left PLUS SUB MUL DIV
%right NOT
%left LPAREN RPAREN LBRACK RBRACK
%right ELSE 
%%



Program:
    Funcs   { program = $1; }
;

Funcs:
      /* epsilon */       { $$ = BuildList<Funcs,FuncDecl>(nullptr, nullptr); }  
      | FuncDecl Funcs    { $$ = BuildList<Funcs,FuncDecl>($2, $1); }

;

FuncDecl:
      RetType ID LPAREN Formals RPAREN LBRACE Statements RBRACE   { $$ = BuildFuncDecl($1, $2, $4, $7); }
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
    | FormalDecl COMMA FormalsList         { $$ = BuildList<Formals,Formal>($3, $1); }
;

FormalDecl:
      Type ID   { $$ = BuildFormalDecl($1, $2); }
;

Call:
      ID LPAREN ExpList RPAREN          { $$ = BuildCall($1, $3); }
    | ID LPAREN RPAREN                  { $$ = BuildCall($1, nullptr); }
;

Statements:
      Statement                         { $$ = BuildStatements(nullptr,$1);}
    | Statements Statement              { $$ = BuildStatements($1,$2); }
;

Statement:
      LBRACE Statements RBRACE          { $$ = $2; }
    | Type ID SC                        { $$ = BuildVarDecl($2, $1); }
    | Type ID ASSIGN EXP SC             { $$ = BuildVarDecl($2, $1, $4); }
    | ID ASSIGN EXP SC                  { $$ = BuildAssign($1, $3); }
    | Call SC                           { $$ = $1; }
    | RETURN SC                         { $$ = make_shared<Return>(); }
    | RETURN EXP SC                     { $$ = make_shared<Return>(dynamic_pointer_cast<Exp>($2)); }
    | IF LPAREN EXP RPAREN Statement    { $$ = BuildIf($3, $5); }
    | IF LPAREN EXP RPAREN Statement ELSE Statement   {$$ = BuildIf($3,$5,$7);}
    | WHILE LPAREN EXP RPAREN Statement               {$$ = BuildWhile($3,$5);}
    | BREAK SC        {$$ = make_shared<Break>();}
    | CONTINUE SC     {$$ = make_shared<Continue>();}
;

ExpList:
      EXP                          { $$ = BuildList<ExpList,Exp>(nullptr, $1); }
    | EXP COMMA ExpList            { $$ = BuildList<ExpList,Exp>($3, $1); }
;

Type: INT       {$$ = BuildType(BuiltInType::INT);}
      | BYTE    {$$ = BuildType(BuiltInType::BYTE);}
      | BOOL    {$$ = BuildType(BuiltInType::BOOL);}

EXP:
    LPAREN EXP RPAREN {$$ = $2;}
    | EXP PLUS EXP   {$$ = BuildBinOp(BinOpType::ADD,$1,$3);}
    | EXP SUB EXP   {$$ = BuildBinOp(BinOpType::SUB,$1,$3);}
    | EXP MUL EXP   {$$ = BuildBinOp(BinOpType::MUL,$1,$3);}
    | EXP DIV EXP   {$$ = BuildBinOp(BinOpType::DIV,$1,$3);}
    |ID        {$$ = $1;}
    | Call    {$$ = $1;}
    | NUM     {$$ = $1;}
    | NUM_B   {$$ = $1;}
    | STRING  {$$ = $1;}
    | TRUE    {$$ = make_shared<Bool>(true);}
    | FALSE   {$$ = make_shared<Bool>(false);}
    | NOT EXP  {$$ = BuildNot($2);}
    | EXP AND EXP   {$$ = BuildLogicalOp<And>($1,$3);}
    | EXP OR EXP   {$$ = BuildLogicalOp<Or>($1,$3);}
    | EXP EQ EXP {$$ = BuildRelop(RelOpType::EQ,$1,$3);}
    | EXP NE EXP {$$ = BuildRelop(RelOpType::NE,$1,$3);}
    | EXP LT EXP {$$ = BuildRelop(RelOpType::LT,$1,$3);}
    | EXP GT EXP {$$ = BuildRelop(RelOpType::GT,$1,$3);}
    | EXP LE EXP {$$ = BuildRelop(RelOpType::LE,$1,$3);}
    | EXP GE EXP {$$ = BuildRelop(RelOpType::GE,$1,$3);}
    | LPAREN Type RPAREN EXP {$$ = BuildCast($4,$2);}

%%

