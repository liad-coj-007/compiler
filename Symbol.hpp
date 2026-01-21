#pragma once
#include <iostream>
#include "nodes.hpp"
#include <vector>

using namespace ast;

 
struct Symbol {
    std::string id;
    int offset;
    BuiltInType type;

    Symbol(const std::string &id, int offset, BuiltInType type);
    virtual ~Symbol() = default;
};


struct VarSymbol : public Symbol {
    VarSymbol(const std::string &id, int offset, BuiltInType type);
};

struct FunctionSymbol : public Symbol {
    std::vector<BuiltInType> paramTypes;

    FunctionSymbol(const std::string& id, BuiltInType ret_type, std::vector<BuiltInType> paramTypes);
    FunctionSymbol(const FuncDecl& func);
};
