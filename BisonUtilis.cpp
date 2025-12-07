#include "BisonUtilis.h"
#include "nodes.hpp"
#include <memory> 

namespace bisonutilis{
    std::shared_ptr<Call> BuildCall(std::shared_ptr<ID> func_id,
    std::shared_ptr<ExpList> explist){
        if(explist == nullptr){
            return make_shared<Call>(func_id);
        }

        return make_shared<Call>(func_id,explist);
    }

    shared_ptr<FuncDecl> BuildFuncDecl(shared_ptr<Type> return_type,shared_ptr<ID> id,
    std::shared_ptr<Formals> formals,std::shared_ptr<Statements> body){
        return make_shared<FuncDecl>(id,return_type,formals,body);
    }

    shared_ptr<Type> BuildType(BuiltInType type){
        return make_shared<Type>(type);
    }


    shared_ptr<Formal> BuildFormalDecl(shared_ptr<Type> type,shared_ptr<ID> id){
        return make_shared<Formal>(id,type);
    }

    shared_ptr<VarDecl> BuildVarDecl(shared_ptr<ID> id,shared_ptr<Type> type,shared_ptr<Exp> exp){
        return make_shared<VarDecl>(id,type,exp);
    }

    shared_ptr<Assign> BuildAssign(shared_ptr<ID> id,shared_ptr<Exp> exp){
        return make_shared<Assign>(id,exp);
    }

        shared_ptr<If> BuildIf(shared_ptr<Exp> cond,shared_ptr<Statement> then, 
    shared_ptr<Statement> otherwise){
        return make_shared<If>(cond,then,otherwise);
    }



};

