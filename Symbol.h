#pragma once
#include <iostream>
#include "nodes.hpp"
#include <vector>

using namespace ast;

 
struct Symbol {
    Symbol(const std::string &id);
    std::string id;
    int offset;
    virtual ~Symbol() = default;
};


struct VarSymbol : public Symbol {
    VarSymbol(const std::string &id,BuiltInType type);
    BuiltInType type;
};

struct FunctionSymbol : public Symbol{
    FunctionSymbol(const std::string& id,BuiltInType ret_type,
    std::vector<BuiltInType> paramTypes);
    BuiltInType returnTypes;
    std::vector<BuiltInType> paramTypes;
};
