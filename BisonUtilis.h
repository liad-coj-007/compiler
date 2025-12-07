#pragma once
#include "nodes.hpp"
#include <memory> 
using namespace ast;
using namespace std;
namespace bisonutils{
    /**
     * @brief build a call node and return the node
     * @param func_id - function identifier
     * @param explist - list of experssions
     * 
    */
    std::shared_ptr<Call> BuildCall(std::shared_ptr<ID> func_id,
    std::shared_ptr<ExpList> explist);

    /**
     * @brief build a list of items
     * with the item we want to add
     * @param list - list node
     * @param item - the item we want to add
    */
    template<typename ListT, typename ItemT>
    shared_ptr<ListT> BuildList( shared_ptr<ListT> list,shared_ptr<ItemT> item){
        if(item == nullptr){
            return make_shared<ListT>();
        }
        
        if(list == nullptr){
            return make_shared<ListT>(list);
        }
        list->push_front(item);
        return list;
    }   
    
   

    shared_ptr<FuncDecl> BuildFuncDecl(shared_ptr<Type> return_type,shared_ptr<ID> id,
    std::shared_ptr<Formals> formals,std::shared_ptr<Statements> body);

    shared_ptr<Type> BuildType(BuiltInType type);

    shared_ptr<Formal> BuildFormalDecl(shared_ptr<Type> type,shared_ptr<ID> id);

    shared_ptr<VarDecl> BuildVarDecl(shared_ptr<ID> id,shared_ptr<Type> type,
    shared_ptr<Exp> exp = nullptr);

    shared_ptr<Assign> BuildAssign(shared_ptr<ID> id,shared_ptr<Exp> exp);

    shared_ptr<If> BuildIf(shared_ptr<Exp> cond,shared_ptr<Statement> then, 
    shared_ptr<Statement> otherwise = nullptr);
    
};