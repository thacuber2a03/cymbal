package codegen_test

import (
	"testing"

	"github.com/thacuber2a03/cymbal/lexer"
	"github.com/thacuber2a03/cymbal/parser"
	"github.com/thacuber2a03/cymbal/sema"
	"github.com/thacuber2a03/cymbal/codegen"
)

// FIXME(thacuber2a03): these next two functions are probably going
// to be copied often with barely any changes besides the next step

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

func compile(t *testing.T, input string) []byte {
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

	c := codegen.New(prog)
	b := c.Compile()
	if b == nil {
		printErrorsAndDie(t, "codegen", c.Errors)
	}
	return b
}

func TestBasicCodeGeneration(t *testing.T) {
	tests := []struct{
		input string
		expected []byte
	}{
		{
			input: `main { deo 0x18, 'a' }`,
			expected: []byte{
				0xa0, 0x00, 0x61, // LIT2 00 "a
				0xa0, 0x00, 0x18, // #0018
				0x03, 0x37,       // NIP DEO2
				0x00,             // BRK
			},
		},
	}

	for _, tt := range tests {
		bytes := compile(t, tt.input)

		if len(bytes) != len(tt.expected) {
			t.Fatalf("length of output doesn't match expected value; expected %d but got %d",
				len(bytes), len(tt.expected))
		}

		for i, b := range bytes {
			if b != tt.expected[i] {
				t.Errorf(
					"byte mismatch at index %d; expected 0x%x but got 0x%x",
					i, b, tt.expected[i],
				)
			}
		}
	}
}
