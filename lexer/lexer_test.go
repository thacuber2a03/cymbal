package lexer_test

import (
	"testing"

	"github.com/thacuber2a03/cymbal/lexer"
)

func TestBasicSourceLexing(t *testing.T) {
	source := `fn main {
	deo 0x18, 'a'
}`

	expected := []struct {
		tokType lexer.TokenType
		lexeme  string
		line    uint
	}{
		{lexer.TT_FN, "fn", 1},
		{lexer.TT_IDENT, "main", 1},
		{lexer.TT_LBRACE, "{", 1},
		{lexer.TT_DEO, "deo", 2},
		{lexer.TT_INT, "0x18", 2},
		{lexer.TT_COMMA, ",", 2},
		{lexer.TT_CHAR, "'a'", 2},
		{lexer.TT_RBRACE, "}", 3},
		{lexer.TT_EOF, "<eof>", 3},
	}

	l := lexer.New(source)

	for i, state := range expected {
		tok := l.Next()

		if tok.Type != state.tokType {
			t.Errorf("Expected token %d to have type %v, had type %v",
				i, state.tokType, tok.Type)
			continue
		}

		if tok.Lexeme != state.lexeme {
			t.Errorf("Expected token %d's lexeme to be %q, was %q",
				i, state.lexeme, tok.Lexeme)
			continue
		}

		if tok.Line != state.line {
			t.Errorf("Expected token %d to be at line %d, was at line %d",
				i, state.line, tok.Line)
			continue
		}
	}
}
