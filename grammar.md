## grammar (not done)

| nonterminal | production                            |
| :---------- | :------------------------------------ |
| PROGRAM     | `expr`                                |
| expr        | `term ((PLUS/MINUS) term)*`           |
| term        | `factor ((STAR/SLASH) factor)*`       |
| factor      | `NUMBER / CHARLIT / STRING`           |
