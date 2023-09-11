## grammer

| nonterminal | production                            |
| :---------- | :------------------------------------ |
| program     | `expr`                                |
| expr        | `term ((PLUS/MINUS) term)*`           |
| term        | `factor ((STAR/SLASH) factor)*`       |
| factor      | `NUMBER`                              |
