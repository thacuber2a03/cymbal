package ast

import (
	// NOTE(thacuber2a03): might use later
	// "github.com/thacuber2a03/cymbal/lexer"
)

type (
	Node = interface {}

	Declaration = interface {
		Node
		declNode()
	}

	Statement = interface {
		Node
		stmtNode()
	}

	Expression = interface {
		Node
		exprNode()
	}
)

// Represents a single file.
type Program struct {
	Declarations []Declaration
}

// Represents the code in the reset vector,
// i.e. the code starting directly at 0x100 in the memory.
type MainDecl Block

func (_ *MainDecl) declNode() {}

// Represents a delimited block of code.
type Block struct {
	// The line that the start of the block (the left brace) is located in.
	Start int

	Statements []Statement
}

func (_ *Block) stmtNode() {}
func (_ *Block) exprNode() {}

type DEOStatement struct {
	Port, Value Expression
}

func (_ *DEOStatement) stmtNode() {}

type Literal struct {
	Value int16
}

func (_ *Literal) exprNode() {}
