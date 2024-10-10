package lexer

import (
	"fmt"
	"strings"
	"unicode"
)

type Lexer struct {
	Source string
	index  int
	line   uint
}

func New(source string) *Lexer {
	return &Lexer{
		Source: source,
		line:   1,
	}
}

func (l *Lexer) atEnd() bool { return l.index >= len(l.Source) }

func (l *Lexer) peekChar() byte {
	if l.atEnd() {
		return 0
	}
	return l.Source[l.index]
}

func (l *Lexer) nextChar() byte {
	ch := l.peekChar()
	l.index++

	if ch == '\n' {
		l.line++
	}
	return ch
}

func (l *Lexer) token(tt TokenType, lexeme string) Token {
	return Token{Type: tt, Lexeme: lexeme, Line: l.line}
}

func (l *Lexer) error(msg string, args ...any) Token {
	return l.token(TT_ERROR, fmt.Sprintf(msg, args...))
}

func isValidIdent(ch byte) bool {
	return unicode.IsLetter(rune(ch)) || ch == '_'
}

var keywords = map[string]TokenType{
	"fn":  TT_FN,
	"main": TT_MAIN,
	"deo": TT_DEO,
}

func (l *Lexer) ident() Token {
	var id strings.Builder

	for !l.atEnd() && isValidIdent(l.peekChar()) ||
		unicode.IsDigit(rune(l.peekChar())) {
		id.WriteByte(l.nextChar())
	}

	if id.Len() == 0 {
		panic("(*Lexer).ident was called but no identifier was scanned")
	}

	str := id.String()
	if k, ok := keywords[str]; ok {
		return l.token(k, str)
	}
	return l.token(TT_IDENT, str)
}

var validBases = map[byte]struct {
	fn   func(r byte) bool
	name string
}{
	'x': {
		fn:   func(ch byte) bool { return unicode.Is(unicode.ASCII_Hex_Digit, rune(ch)) },
		name: "hexadecimal",
	},
	'b': {
		fn:   func(ch byte) bool { return ch == '0' || ch == '1' },
		name: "binary",
	},
}

func (l *Lexer) number() Token {
	var num strings.Builder

	for !l.atEnd() && unicode.IsDigit(rune(l.peekChar())) {
		num.WriteByte(l.nextChar())
	}

	if num.Len() == 0 {
		panic("(*Lexer).number was called but no integer literal was scanned")
	}

	if b, ok := validBases[l.peekChar()]; !l.atEnd() && ok {
		num.WriteByte(l.nextChar())

		var res strings.Builder

		for !l.atEnd() && b.fn(l.peekChar()) {
			res.WriteByte(l.nextChar())
		}

		if res.Len() == 0 {
			return l.error("no digits in %s literal", b.name)
		}

		num.WriteString(res.String())
	}

	return l.token(TT_INT, num.String())
}

func (l *Lexer) charLit() Token {
	var lit strings.Builder
	lit.WriteByte(l.nextChar())
	if l.atEnd() {
		return l.error("unterminated character literal")
	}

	if c := l.nextChar(); c == '\\' {

	} else {
		lit.WriteByte(c)
	}

	if l.atEnd() {
		return l.error("unterminated character literal")
	}
	lit.WriteByte(l.nextChar())
	return l.token(TT_CHAR, lit.String())
}

func (l *Lexer) Next() Token {
	for unicode.IsSpace(rune(l.peekChar())) {
		l.nextChar()
	}

	if l.atEnd() {
		return l.token(TT_EOF, "<eof>")
	}

	c := l.peekChar()

	switch c {
	case '{':
		l.nextChar()
		return l.token(TT_LBRACE, "{")
	case '}':
		l.nextChar()
		return l.token(TT_RBRACE, "}")
	case ',':
		l.nextChar()
		return l.token(TT_COMMA, ",")
	case '\'':
		return l.charLit()
	}

	if isValidIdent(c) {
		return l.ident()
	} else if unicode.IsDigit(rune(c)) {
		return l.number()
	}

	return l.error("unrecognized character '%q'", c)
}
