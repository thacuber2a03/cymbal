## grammar

**NOTE**: work in progress.

| nonterminal | production                            |
| :---------- | :------------------------------------ |
| PROGRAM     | `expr`                                |
| expr        | `term ((PLUS/MINUS) term)*`           |
| term        | `primary ((STAR/SLASH) primary)*`     |
| primary     | `(MINUS / BANG)* factor`              |
| factor      | `NUMBER / CHARLIT`                    |
