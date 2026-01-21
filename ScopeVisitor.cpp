
#include "ScopeVisitor.hpp"
#include "Scope.hpp"

using namespace output;

const int MAX_BYTE_VALUE = 255;

ScopeVisitor::ScopeVisitor() {
    scopes.push_back(Scope(0));
    
    std::vector<BuiltInType> printParams = { BuiltInType::STRING };
    std::vector<BuiltInType> printiParams = { BuiltInType::INT };
    std::shared_ptr<FunctionSymbol> print_func = 
    make_shared<FunctionSymbol>("print", BuiltInType::VOID, printParams);
    std::shared_ptr<FunctionSymbol> printi_func = 
    make_shared<FunctionSymbol>("printi", BuiltInType::VOID, printiParams);
    scopes.back().PushSymbol(print_func);
    scopes.back().PushSymbol(printi_func);

    printer.emitFunc(print_func->id, print_func->type, print_func->paramTypes);
    printer.emitFunc(printi_func->id, printi_func->type, printi_func->paramTypes);
}

void ScopeVisitor::beginScope() {
    printer.beginScope();
    scopes.push_back(Scope(scopes.back().getOffset()));
}

void ScopeVisitor::endScope() {
    scopes.pop_back();
    printer.endScope();
}

void ScopeVisitor::visitNode(std::shared_ptr<Node> node, bool openScope) {
    if (!openScope) {
        node->accept(*this);
        return;
    }
    beginScope();
    data.openScope = true;
    node->accept(*this);
    endScope();
}

std::shared_ptr<Symbol> ScopeVisitor::GetSymbol(const ID& id) const {
    std::shared_ptr<Symbol> symbol = nullptr;
    for (auto it = scopes.rbegin(); it != scopes.rend(); ++it) {
        symbol = it->find(id.value);
        if (symbol != nullptr) break;
    }
    return symbol;
}

void ScopeVisitor::checkMainExists() {
    std::shared_ptr<Symbol> mainSymbol = scopes.back().find("main");
    if (mainSymbol == nullptr) 
        errorMainMissing();
    std::shared_ptr<FunctionSymbol> mainFuncSymbol = dynamic_pointer_cast<FunctionSymbol>(mainSymbol);
    if (mainFuncSymbol->type != BuiltInType::VOID || mainFuncSymbol->paramTypes.size() != 0)
        errorMainMissing();
}

std::vector<std::string> getParamTypes(const std::vector<BuiltInType>& paramTypes) {
    std::vector<std::string> types;
    for(BuiltInType type : paramTypes) {
        switch (type) {
            case BuiltInType::BOOL:
                types.push_back("BOOL");
                break;
            case BuiltInType::BYTE:
                types.push_back("BYTE");
                break;
            case BuiltInType::INT:
                types.push_back("INT");
                break;
            case BuiltInType::STRING:
                types.push_back("STRING");
                break;
        }
    }
    return types;
}

bool isNumberType(BuiltInType type) { return type == BuiltInType::INT || type == BuiltInType::BYTE; }

bool isConvertable(BuiltInType src, BuiltInType dest) {
    return src == dest || src == BuiltInType::BYTE && dest == BuiltInType::INT;
}


/* ===== Literals & Identifiers ===== */
void ScopeVisitor::visit(Num& node) {
    data.type = BuiltInType::INT;
}

void ScopeVisitor::visit(NumB& node) {
    data.type = BuiltInType::BYTE;
    if (node.value > MAX_BYTE_VALUE)
        errorByteTooLarge(node.line, node.value);
}

void ScopeVisitor::visit(String& node) {
    data.type = BuiltInType::STRING;
}

void ScopeVisitor::visit(Bool& node) {
    data.type = BuiltInType::BOOL;
}

void ScopeVisitor::visit(ID& node) {
    std::shared_ptr<Symbol> symbol = GetSymbol(node);
    if (symbol == nullptr)
        errorUndef(node.line, node.value);
    if (dynamic_pointer_cast<VarSymbol>(symbol) == nullptr)
        errorDefAsFunc(node.line, node.value);
    data.type = symbol->type;
}



/* ===== Types & Casting ===== */
void ScopeVisitor::visit(Type& node) {
    //Should not reach here
    cout << node.line << ": Internal error: visiting Type node directly" << endl;
    exit(1);
}

void ScopeVisitor::visit(Cast& node) {
    visitNode(node.exp);
    if (!isNumberType(data.type) || !isNumberType(node.target_type->type))
        errorMismatch(node.line);
    data.type = node.target_type->type;
}



/* ===== Expressions ===== */
void ScopeVisitor::visit(BinOp& node) {
    visitNode(node.left);
    if (!isNumberType(data.type)) {
        errorMismatch(node.left->line);
    }
    BuiltInType leftType = data.type;

    visitNode(node.right);
    if (!isNumberType(data.type)) {
        errorMismatch(node.right->line);
    }
    data.type = leftType == BuiltInType::INT ? leftType : data.type;
}

void ScopeVisitor::visit(RelOp& node) {
    visitNode(node.left);
    if (!isNumberType(data.type)) {
        errorMismatch(node.left->line);
    }
    visitNode(node.right);
    if (!isNumberType(data.type)) {
        errorMismatch(node.right->line);
    }
    data.type = BuiltInType::BOOL;
}

void ScopeVisitor::visit(Not& node) {
    visitNode(node.exp);
    if (data.type != BuiltInType::BOOL) {
        errorMismatch(node.exp->line);
    }
    data.type = BuiltInType::BOOL;
}

void ScopeVisitor::visit(And& node) {
    visitNode(node.left);
    if (data.type != BuiltInType::BOOL) {
        errorMismatch(node.left->line);
    }
    visitNode(node.right);
    if (data.type != BuiltInType::BOOL) {
        errorMismatch(node.right->line);
    }
    data.type = BuiltInType::BOOL;
}

void ScopeVisitor::visit(Or& node) {
    visitNode(node.left);
    if (data.type != BuiltInType::BOOL) {
        errorMismatch(node.left->line);
    }
    visitNode(node.right);
    if (data.type != BuiltInType::BOOL) {
        errorMismatch(node.right->line);
    }
    data.type = BuiltInType::BOOL;
}

void ScopeVisitor::visit(ExpList& node) {
    for(const auto& exp : node.exps){
        visitNode(exp);
    }
}

void ScopeVisitor::visit(Call& node) {
    shared_ptr<Symbol> symbol = GetSymbol(*node.func_id);
    if (symbol == nullptr)
        errorUndefFunc(node.line, node.func_id->value);
    shared_ptr<FunctionSymbol> funcSymbol = dynamic_pointer_cast<FunctionSymbol>(symbol);
    if (funcSymbol == nullptr)
        errorDefAsVar(node.line, node.func_id->value);

    std::vector<std::string> paramTypes = getParamTypes(funcSymbol->paramTypes);
    if (node.args->exps.size() != funcSymbol->paramTypes.size())
        errorPrototypeMismatch(node.line, node.func_id->value, paramTypes);
    for(int i = 0; i < funcSymbol->paramTypes.size(); i++) {
        visitNode(node.args->exps[i]);
        if (!isConvertable(data.type, funcSymbol->paramTypes[i])) 
            errorPrototypeMismatch(node.line, node.func_id->value, paramTypes);
    }
    data.type = symbol->type;
}



/* ===== Statements ===== */
void ScopeVisitor::visit(Assign& node) {
    visitNode(node.id);
    BuiltInType type = data.type;
    visitNode(node.exp);
    if (!isConvertable(data.type, type)) {
        errorMismatch(node.line);
    }
}

void ScopeVisitor::visit(Return& node) {
    if (node.exp == nullptr)
        data.type = BuiltInType::VOID;
    else
        visitNode(node.exp);
    if (!isConvertable(data.type, data.returnType))
        errorMismatch(node.exp == nullptr ? node.line : node.exp->line);
}

void ScopeVisitor::visit(Break& node) {
    if (!data.inLoop) errorUnexpectedBreak(node.line);
}

void ScopeVisitor::visit(Continue& node) {
    if (!data.inLoop) errorUnexpectedContinue(node.line);
}

void ScopeVisitor::visit(If& node) {
    visitNode(node.condition);
    if (data.type != BuiltInType::BOOL)
        errorMismatch(node.condition->line);
    visitNode(node.then, true);
    if (node.otherwise != nullptr)
        visitNode(node.otherwise, true);
}
    
void ScopeVisitor::visit(While& node) {
    visitNode(node.condition);
    if (data.type != BuiltInType::BOOL)
        errorMismatch(node.condition->line);
    bool loop = data.inLoop;
    data.inLoop = true;
    visitNode(node.body, true);
    data.inLoop = loop;
}

void ScopeVisitor::visit(Statements& node) {
    if (data.openScope) {
        beginScope();
        for(const std::shared_ptr<Statement>& statement : node.statements)
            visitNode(statement);
        endScope();
    }
    else {
        for(const std::shared_ptr<Statement>& statement : node.statements)
            visitNode(statement);
    }
}



/* ===== Declarations ===== */
void ScopeVisitor::visit(VarDecl& node) {
    if (GetSymbol(*node.id) != nullptr)
        errorDef(node.line, node.id->value);

    if (node.init_exp) {
        visitNode(node.init_exp);
        if (!isConvertable(data.type, node.type->type))
            errorMismatch(node.init_exp->line);
    }

    std::shared_ptr<VarSymbol> varSymbol = std::make_shared<VarSymbol>(node.id->value, 0, node.type->type);
    scopes.back().PushSymbol(varSymbol);
    printer.emitVar(varSymbol->id, node.type->type, varSymbol->offset);

}

void ScopeVisitor::visit(Formal& node) {
    if(GetSymbol(*node.id) != nullptr)
        errorDef(node.line, node.id->value);
    auto varSymbol = make_shared<VarSymbol>(node.id->value, 0, node.type->type);
    scopes.back().InsertParameter(varSymbol, data.paramIndex);
    printer.emitVar(varSymbol->id, node.type->type, varSymbol->offset);
}

void ScopeVisitor::visit(Formals& node) {
    data.paramIndex = 0;
    for(auto& formal : node.formals) {
        data.paramIndex++;
        visitNode(formal);
    } 
}



/* ===== Functions / Program ===== */
void ScopeVisitor::visit(FuncDecl& node) {
    data.returnType = node.return_type->type;
    beginScope();
    visitNode(node.formals);
    data.openScope = false;
    visitNode(node.body);
    endScope();
}

void ScopeVisitor::visit(Funcs& node) {
    for(auto& funcDecl : node.funcs){
        if (GetSymbol(*funcDecl->id) != nullptr)
            errorDef(funcDecl->id->line,funcDecl->id->value);
        auto funcSymbol = std::make_shared<FunctionSymbol>(*funcDecl);
        scopes.back().PushSymbol(funcSymbol);
        printer.emitFunc(funcSymbol->id, funcSymbol->type, funcSymbol->paramTypes);
    }
    checkMainExists();
    for(auto& funcDecl : node.funcs){
        visitNode(funcDecl);
    }
}

void ScopeVisitor::Print(){
    cout << printer;
}
