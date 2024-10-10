package parser_test

import (
	"testing"

	"github.com/thacuber2a03/cymbal/lexer"
	"github.com/thacuber2a03/cymbal/parser"
)

func parseProgram(t *testing.T, source string) *parser.Program {
	l := lexer.New(source)
	p := parser.New(l)
	prog := p.Parse()

	if prog == nil {
		t.Errorf("parser failed with %d errors", len(p.Errors))
		for _, e := range p.Errors {
			t.Error(e)
		}
		t.FailNow()
	}

	return prog
}

func matchLiteral(t *testing.T, e parser.Expression, n string, v int16) bool {
	lit, ok := e.(*parser.Literal)
	if !ok {
		t.Errorf("expected %s to be a Literal, got %T", n, e)
	}

	if lit.Value != v {
		t.Errorf("expected %s to equal %d, got %d instead",
			n, v, lit.Value)
		return false
	}

	return true
}

func TestBasicParsing(t *testing.T) {
	prog := parseProgram(t, `main {
	deo 0x18, 'a'
}`)

	if len(prog.Declarations) != 1 {
		t.Fatalf("expected 1 declaration in the source, got %d",
			len(prog.Declarations))
	}

	main, ok := prog.Declarations[0].(*parser.MainDecl)
	if !ok {
		t.Fatalf("expected single declaration to be a MainDecl, got %T",
			prog.Declarations[0])
	}

	deo, ok := main.Statements[0].(*parser.DEOStatement)
	if !ok {
		t.Fatalf("expected single main statement to be a DEOStatement, got %T",
			main.Statements[0])
	}

	if !matchLiteral(t, deo.Port, "Port", 0x18) { return }
	if !matchLiteral(t, deo.Value, "Value", int16('a')) { return }
}
