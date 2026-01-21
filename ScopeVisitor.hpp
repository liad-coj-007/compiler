#pragma once

#include <memory>
#include <vector>

#include "visitor.hpp"
#include "nodes.hpp"
#include "output1.hpp"
#include "Scope.hpp"

using namespace std;
using namespace ast;
using namespace output;

struct MetaData {
    BuiltInType type = BuiltInType::VOID;
    bool openScope = false;
    bool inLoop = false;
    BuiltInType returnType = BuiltInType::VOID;
    int paramIndex = 0;
};

class ScopeVisitor : public Visitor {
protected:
    vector<Scope> scopes;

private:
    MetaData data;
    ScopePrinter printer;

    void beginScope();
    void endScope();

    void visitNode(std::shared_ptr<Node> node, bool openScope = false);

    std::shared_ptr<Symbol> GetSymbol(const ID& id) const;

    void checkMainExists();

public:
    void Print();


    /**
     * @brief visitor constractor
     * 
    */
    ScopeVisitor();

    /* ===== Literals & Identifiers ===== */
    virtual void visit(Num& node) override;
    virtual void visit(NumB& node) override;
    virtual void visit(String& node) override;
    virtual void visit(Bool& node) override;
    virtual void visit(ID& node) override; 

    /* ===== Types & Casting ===== */
    virtual void visit(Type& node) override;
    virtualvoid visit(Cast& node) override;

    /* ===== Expressions ===== */
    virtual void visit(BinOp& node) override;
    virtual void visit(RelOp& node) override;
    virtual void visit(Not& node) override;
    virtual void visit(And& node) override;
    virtual void visit(Or& node) override;
    virtual void visit(ExpList& node) override;
    virtual void visit(Call& node) override;

    /* ===== Statements ===== */
    virtual void visit(Assign& node) override;
    virtual void visit(Return& node) override;
    virtual void visit(Break& node) override;
    virtual void visit(Continue& node) override;
    virtual void visit(If& node) override;
    virtual void visit(While& node) override;
    virtual void visit(Statements& node) override;

    /* ===== Declarations ===== */
    virtual void visit(VarDecl& node) override;
    virtual void visit(Formal& node) override;
    virtual void visit(Formals& node) override;

    /* ===== Functions / Program ===== */
    virtual void visit(FuncDecl& node) override;
    virtual void visit(Funcs& node) override;
};
