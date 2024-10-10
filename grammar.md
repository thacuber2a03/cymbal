> [!NOTE]
> work in progress.

<!--
	TODO(thacuber2a03): should the reset vector code
	be separate from other functions?
	some Uxn programs use a pointer to it...
-->

```
program     -> declaration* EOF
declaration -> MAIN block
block       -> LBRACE statement* RBRACE
statement   -> deoStmt
deoStmt     -> DEO expression COMMA expression
expression  -> CHAR | INT
```
