package sema

import (
	"github.com/thacuber2a03/cymbal/ast"
)

type Analyzer struct {
	program *ast.Program
}

func (a *Analyzer) Visit(n ast.Node) ast.Visitor {
	switch v := n.(type) {
	case *ast.MainDecl:
		return ast.WalkStatements(a, v.Statements)
	case *ast.Block:
		return ast.WalkStatements(a, v.Statements)
	}

	panic("(should be) unreachable")
}

func (a *Analyzer) Analyze() {
	ast.WalkDeclarations(a, a.program.Declarations)
}

func New(program *ast.Program) *Analyzer {
	return &Analyzer{program: program}
}
