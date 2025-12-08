#include "BisonUtilis.h"
#include "nodes.hpp"
#include <memory> 

namespace bisonutils{
    std::shared_ptr<Call> BuildCall(std::shared_ptr<Node> func_id_node,
    std::shared_ptr<Node> explist_node){
        shared_ptr<ExpList> explist = dynamic_pointer_cast<ExpList>(explist_node);
        shared_ptr<ID> func_id = dynamic_pointer_cast<ID>(func_id_node); 
        if(explist == nullptr){
            return make_shared<Call>(func_id);
        }

        return make_shared<Call>(func_id,explist);
    }

       shared_ptr<Statements> BuildStatements(shared_ptr<Node> statement_list_node, 
    shared_ptr<Node> statement_node){
        shared_ptr<Statements> list = dynamic_pointer_cast<Statements>(statement_list_node);
        shared_ptr<Statement> item = 
        dynamic_pointer_cast<Statement>(statement_node);
     
        if(list == nullptr){
            return make_shared<Statements>(item);
        }
        
        list->push_back(item);
        return list;
    }

    shared_ptr<FuncDecl> BuildFuncDecl(shared_ptr<Node> return_type_node,shared_ptr<Node> id_node,
    std::shared_ptr<Node> formals_node,std::shared_ptr<Node> body_node){

        shared_ptr<Type> return_type = dynamic_pointer_cast<Type>(return_type_node);
        shared_ptr<ID> id = dynamic_pointer_cast<ID>(id_node); 
        shared_ptr<Statements> body = dynamic_pointer_cast<Statements>(body_node); 
        shared_ptr<Formals> formals = dynamic_pointer_cast<Formals>(formals_node); 

        return make_shared<FuncDecl>(id,return_type,formals,body);
    }

    shared_ptr<Type> BuildType(BuiltInType type){
        return make_shared<Type>(type);
    }


    shared_ptr<Formal> BuildFormalDecl(shared_ptr<Node> type_node,shared_ptr<Node> id_node){
        shared_ptr<Type> type = dynamic_pointer_cast<Type>(type_node);
        shared_ptr<ID> id = dynamic_pointer_cast<ID>(id_node); 
        return make_shared<Formal>(id,type);
    }

    shared_ptr<VarDecl> BuildVarDecl(shared_ptr<Node> id_node,shared_ptr<Node> type_node,
    shared_ptr<Node> exp_node){
        shared_ptr<Type> type = dynamic_pointer_cast<Type>(type_node);
        shared_ptr<ID> id = dynamic_pointer_cast<ID>(id_node); 
        shared_ptr<Exp> exp = dynamic_pointer_cast<Exp>(exp_node); 

        return make_shared<VarDecl>(id,type,exp);
    }

    shared_ptr<Assign> BuildAssign(shared_ptr<Node> id_node,shared_ptr<Node> exp_node){
        shared_ptr<ID> id = dynamic_pointer_cast<ID>(id_node); 
        shared_ptr<Exp> exp = dynamic_pointer_cast<Exp>(exp_node); 
        return make_shared<Assign>(id,exp);
    }

        shared_ptr<If> BuildIf(shared_ptr<Node> cond_node,shared_ptr<Node> then_node, 
    shared_ptr<Node> otherwise_node){
        shared_ptr<Exp> cond = dynamic_pointer_cast<Exp>(cond_node);
        shared_ptr<Statement> then = dynamic_pointer_cast<Statement>(then_node); 
        shared_ptr<Statement> otherwise = dynamic_pointer_cast<Statement>(otherwise_node); 
        return make_shared<If>(cond,then,otherwise);
    }

    shared_ptr<While> BuildWhile(shared_ptr<Node> cond_node,shared_ptr<Node> body_node){
        shared_ptr<Exp> cond = dynamic_pointer_cast<Exp>(cond_node);
        shared_ptr<Statement> body = dynamic_pointer_cast<Statement>(body_node);
        return make_shared<While>(cond,body); 

    }


    shared_ptr<BinOp> BuildBinOp(BinOpType op,shared_ptr<Node> left_node,
    shared_ptr<Node> right_node){
        shared_ptr<Exp> left = dynamic_pointer_cast<Exp>(left_node);
        shared_ptr<Exp> right = dynamic_pointer_cast<Exp>(right_node);
        return make_shared<BinOp>(left,right,op);
    }

    shared_ptr<RelOp> BuildRelop(RelOpType op,shared_ptr<Node> left_node,
    shared_ptr<Node> right_node){
        shared_ptr<Exp> left= dynamic_pointer_cast<Exp>(left_node);
        shared_ptr<Exp> right = dynamic_pointer_cast<Exp>(right_node);
        return make_shared<RelOp>(left,right,op);
    }


    shared_ptr<Not> BuildNot(shared_ptr<Node> exp_node){
        shared_ptr<Exp> exp = dynamic_pointer_cast<Exp>(exp_node);
        return make_shared<Not>(exp);
    }

    shared_ptr<Cast> BuildCast(shared_ptr<Node> exp_node,shared_ptr<Node> target_type_node){
        shared_ptr<Exp> exp = dynamic_pointer_cast<Exp>(exp_node);
        shared_ptr<Type> target_type = dynamic_pointer_cast<Type>(target_type_node);
        return make_shared<Cast>(exp,target_type);
    }



};

