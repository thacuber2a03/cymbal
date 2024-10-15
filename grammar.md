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

block       -> LBRACE statement* RBRACE
statement   -> deo | block
deo         -> DEO expression COMMA expression

expression  -> term
term        -> factor ((PLUS | MINUS) factor)*
factor      -> unary ((STAR | SLASH) unary)*
unary       -> (BANG | MINUS) primary | primary
primary     -> DEI primary | LPAREN expresion RPAREN | CHAR | INT
```
