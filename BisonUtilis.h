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
    std::shared_ptr<Call> BuildCall(std::shared_ptr<Node> func_id_node,
    std::shared_ptr<Node> explist_node);


    shared_ptr<Statements> BuildStatements(shared_ptr<Node> statement_list_node, 
    shared_ptr<Node> statement_node);

    /**
     * @brief build a list of items
     * with the item we want to add
     * @param list - list node
     * @param item - the item we want to add
    */
    template<typename ListT, typename ItemT>
    shared_ptr<ListT> BuildList( shared_ptr<Node> list_node,shared_ptr<Node> item_node){
        shared_ptr<ListT> list = dynamic_pointer_cast<ListT>(list_node);
        shared_ptr<ItemT> item = dynamic_pointer_cast<ItemT>(item_node);
        if(item == nullptr){
            return make_shared<ListT>();
        }
        
        if(list == nullptr){
            return make_shared<ListT>(item);
        }
        
        list->push_front(item);
        return list;
    }   
    
   

   shared_ptr<FuncDecl> BuildFuncDecl(shared_ptr<Node> return_type_node,shared_ptr<Node> id_node,
    std::shared_ptr<Node> formals_node,std::shared_ptr<Node> body_node);

    shared_ptr<Type> BuildType(BuiltInType type);

    shared_ptr<Formal> BuildFormalDecl(shared_ptr<Node> type_node,shared_ptr<Node> id_node);

    shared_ptr<VarDecl> BuildVarDecl(shared_ptr<Node> id_node,shared_ptr<Node> type_node,
    shared_ptr<Node> exp_node = nullptr);

    shared_ptr<Assign> BuildAssign(shared_ptr<Node> id_node,shared_ptr<Node> exp_node);

    shared_ptr<If> BuildIf(shared_ptr<Node> cond_node,shared_ptr<Node> then_node, 
    shared_ptr<Node> otherwise_node = nullptr);
    
    shared_ptr<While> BuildWhile(shared_ptr<Node> cond_node,shared_ptr<Node> body_node);

    shared_ptr<BinOp> BuildBinOp(BinOpType op,shared_ptr<Node> left_node,
    shared_ptr<Node> right_node);

   shared_ptr<RelOp> BuildRelop(RelOpType op,shared_ptr<Node> left_node,
    shared_ptr<Node> right_node);  

    shared_ptr<Not> BuildNot(shared_ptr<Node> exp_node);  

    shared_ptr<Cast> BuildCast(shared_ptr<Node> exp_node,
    shared_ptr<Node> target_type_node);

    template<typename OP>
    shared_ptr<OP> BuildLogicalOp(shared_ptr<Node> left_node,shared_ptr<Node> right_node){
        shared_ptr<Exp> left = dynamic_pointer_cast<Exp>(left_node);
        shared_ptr<Exp> right = dynamic_pointer_cast<Exp>(right_node);
        return make_shared<OP>(left,right);
    }
     


}