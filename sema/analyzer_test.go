package sema_test

import (
	"testing"

	"github.com/thacuber2a03/cymbal/lexer"
	"github.com/thacuber2a03/cymbal/parser"
	"github.com/thacuber2a03/cymbal/sema"
)

func printErrorsAndDie(
	t *testing.T, thing string, errors interface{},
) {
	err := errors.([]string)
	t.Errorf("%s failed with %d errors", thing, len(err))
	for _, e := range err {
		t.Errorf("%v", e)
	}
	t.FailNow()
}

func analyze(t *testing.T, input string) *sema.Analyzer {
	t.Helper()

	l := lexer.New(input)
	p := parser.New(l)
	prog := p.Parse()
	if prog == nil {
		printErrorsAndDie(t, "parser", p.Errors)
	}

	s := sema.NewAnalyzer(prog)
	if !s.Analyze() {
		printErrorsAndDie(t, "sema", s.Errors)
	}

	return s
}

func TestBasicSemanticAnalysis(t *testing.T) {
	// TODO(thacuber2a03): currently the only thing I can test is whether it fails or not
	analyze(t, `main {
	deo 0x18, 'a'
}`)
}
