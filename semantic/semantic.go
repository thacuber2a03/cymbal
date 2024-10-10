package semantic

import (
	"github.com/thacuber2a03/cymbal/ast"
)

type Analyzer struct {
	program *ast.Program
}

func (a *Analyzer) Visit(n ast.Node) ast.Visitor {
	// TODO(thacuber2a03): fill this in
	// (I'm not even totally sure I'm doing this right...)
}

func (a *Analyzer) Analyze() {
	for _, d := range a.program.Declarations {
		if a = a.Visit(d); a == nil {
			return
		}
	}
}

func New(program *ast.Program) *Analyzer {
	return &Analyzer{program: program}
}
