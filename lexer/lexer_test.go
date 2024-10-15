package lexer_test

import (
	"fmt"
	"testing"

	"github.com/thacuber2a03/cymbal/lexer"
)

func TestBasicLexing(t *testing.T) {
	source := `main {
	deo 'a', 0x18
}
+-*/()
# this is a comment`

	expected := []struct {
		tokType lexer.TokenType
		lexeme  string
		line    uint
	}{
		{lexer.TT_MAIN, "main", 1},
		{lexer.TT_LBRACE, "{", 1},
		{lexer.TT_DEO, "deo", 2},
		{lexer.TT_CHAR, "'a'", 2},
		{lexer.TT_COMMA, ",", 2},
		{lexer.TT_INT, "0x18", 2},
		{lexer.TT_RBRACE, "}", 3},
		{lexer.TT_PLUS, "+", 4},
		{lexer.TT_MINUS, "-", 4},
		{lexer.TT_STAR, "*", 4},
		{lexer.TT_SLASH, "/", 4},
		{lexer.TT_LPAREN, "(", 4},
		{lexer.TT_RPAREN, ")", 4},
		{lexer.TT_EOF, "<eof>", 5},
	}

	l := lexer.New(source)

	for i, state := range expected {
		tok := l.Next()
		if tok.Type == lexer.TT_ERROR {
			t.Errorf("lexer threw an error: %s (at line %d)", tok.Lexeme, tok.Line)
			continue
		}

		at := fmt.Sprintf("expected token @ index %d", i)

		if tok.Type != state.tokType {
			t.Errorf("%s to have type %v, had type %v", at, state.tokType, tok.Type)
		} else if tok.Lexeme != state.lexeme {
			t.Errorf("%s's lexeme to be %q, was %q", at, state.lexeme, tok.Lexeme)
		} else if tok.Line != state.line {
			t.Errorf("%s to be at line %d, was at line %d", at, state.line, tok.Line)
		}
	}
}
