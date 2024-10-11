package sema

import (
	"github.com/thacuber2a03/cymbal/ast"
)

type Analyzer struct {
	program *ast.Program
	// TODO(thacuber2a03): this doesn't have an use yet
	Errors  []string
}

func (a *Analyzer) Visit(n ast.Node) ast.Visitor {
	switch v := n.(type) {
	case *ast.MainDecl:
		return ast.WalkStatements(a, v.Statements)
	case *ast.Block:
		return ast.WalkStatements(a, v.Statements)
	case *ast.DEOStatement:
		if a = a.Visit(v.Port).(*Analyzer); a == nil {
			return a
		}
		return a.Visit(v.Value)
	case *ast.Literal:
		return a // all right
	}

	panic("(should be?) unreachable")
}

func (a *Analyzer) Analyze() bool {
	ast.WalkDeclarations(a, a.program.Declarations)

	// TODO(thacuber2a03): design and return a
	// format with more info if necessary
	return len(a.Errors) == 0
}

func NewAnalyzer(program *ast.Program) *Analyzer {
	return &Analyzer{program: program}
}
