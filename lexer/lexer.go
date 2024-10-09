package lexer

type Lexer struct {
	source string
	index  int
}

func New(source string) *Lexer {
	return &Lexer{
		source: source,
	}
}

func (l *Lexer) Next() Token {
	return Token{Type: TT_EOF, Lexeme: "<eof>"}
}
