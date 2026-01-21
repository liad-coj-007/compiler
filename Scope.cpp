
#include "Scope.hpp"

Scope::Scope(int offset) : offset(offset) {}

shared_ptr<Symbol> Scope::find(const string& id) const {
    for(auto& symbol : declaredSymbols){
        if (symbol->id == id){
            return symbol;
        }
    }
    return nullptr;
}

void Scope::PushSymbol(shared_ptr<Symbol> symbol) {
    if (dynamic_pointer_cast<FunctionSymbol>(symbol) == nullptr){
        symbol->offset = offset;
        offset++;
    }
    declaredSymbols.push_back(symbol);
}

void Scope::InsertParameter(shared_ptr<VarSymbol> param, int i) {
    param->offset = -i;
    declaredSymbols.push_back(param);
}

int Scope::getOffset() { return offset; }
