#include "Symbol.hpp"

Symbol::Symbol(const std::string &id, int offset, BuiltInType type)
 : id(id), offset(offset), type(type) {}

VarSymbol::VarSymbol(const std::string &id, int offset, BuiltInType type)
 : Symbol(id , offset, type) {}

FunctionSymbol::FunctionSymbol(const std::string& id, 
BuiltInType returnType, std::vector<BuiltInType> paramTypes)
 : Symbol(id, 0, returnType), paramTypes(paramTypes) {}

FunctionSymbol::FunctionSymbol(const FuncDecl& func)
 : Symbol(func.id->value, 0, func.return_type->type) {
    for(auto& param : func.formals->formals){
        paramTypes.push_back(param->type->type);
    }
}