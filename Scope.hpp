#pragma once

#include <memory>
#include <vector>

#include "Symbol.hpp"

using namespace std;

class Scope {
    int offset;
    vector<shared_ptr<Symbol>> declaredSymbols;
    BuiltInType returnType;

public:
    Scope(const int offset);

    shared_ptr<Symbol> find(const string &id) const;

    void PushSymbol(shared_ptr<Symbol> symbol);
    void InsertParameter(shared_ptr<VarSymbol> var, int i);

    int getOffset();
};