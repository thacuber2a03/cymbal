package lexer

import (
	"fmt"
	"strings"
	"unicode"
	"unicode/utf8"
)

type Lexer struct {
	Source []byte
	index  int
	line   uint
}

func New(source string) *Lexer {
	return &Lexer{
		Source: []byte(source),
		line:   1,
	}
}

func (l *Lexer) peekCharSize() (rune, int) {
	ch, sz := utf8.DecodeRune(l.Source[l.index:])
	if ch == utf8.RuneError && sz == 0 {
		return 0, 0
	}
	return ch, sz
}

func (l *Lexer) peekChar() rune {
	ch, _ := l.peekCharSize()
	return ch
}

func (l *Lexer) nextChar() (ch rune) {
	ch, sz := l.peekCharSize()
	if ch == utf8.RuneError {
		return
	} else if ch == '\n' {
		l.line++
	}
	l.index += sz
	return
}

func (l *Lexer) atEnd() bool { return l.index >= len(l.Source) }

func (l *Lexer) token(tt TokenType, lexeme string) Token {
	return Token{Type: tt, Lexeme: lexeme, Line: l.line}
}

func (l *Lexer) error(msg string, args ...any) Token {
	return l.token(TT_ERROR, fmt.Sprintf(msg, args...))
}

func (l *Lexer) invalidRune(r rune) Token { return l.error("invalid UTF-8 rune %U", r) }

var keywords = map[string]TokenType{
	"fn":  TT_FN,
	"deo": TT_DEO,
}

func (l *Lexer) ident() Token {
	var id strings.Builder

	for {
		if l.atEnd() {
			break
		}

		c := l.peekChar()
		if c == utf8.RuneError {
			return l.invalidRune(c)
		}

		if unicode.IsLetter(c) || unicode.IsDigit(c) {
			id.WriteRune(c)
			l.nextChar()
		} else {
			break
		}
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

func isValidDigit(r rune) bool { return '0' <= r && r <= '9' }

var validBases = map[rune]struct {
	f    func(r rune) bool
	name string
}{
	'x': {
		f:    func(r rune) bool { l := unicode.ToLower(r); return isValidDigit(l) || 'a' <= l && l <= 'f' },
		name: "hexadecimal",
	},
	'b': {
		f:    func(r rune) bool { return r == '0' || r == '1' },
		name: "binary",
	},
}

func (l *Lexer) number() Token {
	// TODO(thacuber2a03): this and ident() use really similar code
	var num strings.Builder

	for {
		if l.atEnd() {
			break
		}

		c := l.peekChar()
		if c == utf8.RuneError {
			return l.invalidRune(c)
		}

		if isValidDigit(c) {
			num.WriteRune(c)
			l.nextChar()
		} else {
			break
		}
	}

	if num.Len() == 0 {
		panic("(*Lexer).number was called but no integer literal was scanned")
	}

	if l.atEnd() {
		goto end
	}

	if b, ok := validBases[l.peekChar()]; ok {
		num.WriteRune(l.nextChar())
		scanned := false

		for {
			if l.atEnd() {
				break
			}

			c := l.peekChar()
			if c == utf8.RuneError {
				return l.invalidRune(c)
			}

			if b.f(c) {
				num.WriteRune(c)
				scanned = true
				l.nextChar()
			} else {
				break
			}
		}

		if !scanned {
			return l.error("no digits in %s literal", b.name)
		}
	}

end:
	return l.token(TT_INT, num.String())
}

func (l *Lexer) charLit() Token {
	var lit strings.Builder
	lit.WriteRune(l.nextChar())
	if l.atEnd() { return l.error("unterminated character literal") }

	if c := l.nextChar(); c == '\\' {

	} else {
		lit.WriteRune(c)
	}

	if l.atEnd() { return l.error("unterminated character literal") }
	lit.WriteRune(l.nextChar())
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
	case utf8.RuneError:
		l.nextChar()
		return l.error("invalid UTF-8 rune")
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

	if unicode.IsLetter(c) {
		return l.ident()
	} else if unicode.IsDigit(c) {
		return l.number()
	}

	return l.error("unrecognized character '%q'", c)
}
