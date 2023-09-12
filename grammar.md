## grammar

**NOTE**: work in progress.

| nonterminal    | production                                          |
| :------------- | :-------------------------------------------------- |
| PROGRAM        | `topLevelDecl*`                                     |
| topLevelDecl   | `funcDecl`                                          |
| funcDecl       | `FN IDENTIFIER LPAREN parameters? RPAREN block`     |
| block          | `LBRACE declaration* RBRACE`                        |
| declaration    | `varDecl / statement`                               |
| varDecl        | `LET IDENTIFIER COLON typename ASSIGN expr NEWLINE` |
| typename       | `BYTE / SHORT / STRING_TYPE`                        |
| statement      | `expressionStmt`                                    |
| expressionStmt | `expr NEWLINE`                                      |
| expr           | `term ((PLUS/MINUS) term)*`                         |
| term           | `primary ((STAR/SLASH) primary)*`                   |
| primary        | `(MINUS / BANG)* factor`                            |
| factor         | `NUMBER / CHARLIT / IDENTIFIER CARET?`              |
