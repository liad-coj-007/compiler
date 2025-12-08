└──Funcs
    └──FuncDecl
        ├──ID: main
        ├──Type: int
        ├──Formals
        └──Statements
            ├──VarDecl
            │   ├──ID: i
            │   ├──Type: int
            │   └──Num: 0
            ├──VarDecl
            │   ├──ID: length
            │   ├──Type: int
            │   └──Num: 3
            └──While
                ├──RelOp: <
                │   ├──ID: i
                │   └──ID: length
                └──Statements
                    ├──Assign
                    │   ├──ID: i
                    │   └──BinOp: +
                    │       ├──ID: i
                    │       └──Num: 1
                    └──If
                        ├──RelOp: ==
                        │   ├──ID: i
                        │   └──Num: 0
                        ├──Statements
                        │   └──Call
                        │       ├──ID: print
                        │       └──ExpList
                        │           └──String: wow
                        └──If
                            ├──RelOp: ==
                            │   ├──ID: i
                            │   └──Num: 1
                            ├──Statements
                            │   └──Call
                            │       ├──ID: print
                            │       └──ExpList
                            │           └──String: lol
                            └──Statements
                                ├──Call
                                │   ├──ID: print
                                │   └──ExpList
                                │       └──String: fuck!
                                └──Break
