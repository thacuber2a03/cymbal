> [!NOTE]
> work in progress.

<!--
	TODO(thacuber2a03): should the reset vector code
	be separate from other functions?
	some Uxn programs use a pointer to it...
-->

```
program     -> declaration* EOF
declaration -> mainDecl
mainDecl    -> MAIN block

statement   -> deoStmt
block       -> LBRACE statement* RBRACE
deoStmt     -> DEO expression COMMA expression

expression  -> literal
literal     -> CHAR | INT
```
