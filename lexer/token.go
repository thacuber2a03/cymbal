package lexer

type TokenType int

const (
	TT_EOF TokenType = iota
	TT_ERROR

	TT_LBRACE
	TT_RBRACE
	TT_LPAREN
	TT_RPAREN
	TT_COMMA
	TT_PLUS
	TT_MINUS
	TT_STAR
	TT_SLASH

	TT_IDENT
	TT_INT
	TT_CHAR

	TT_FN
	TT_MAIN
	TT_DEO
)

//go:generate stringer -type TokenType -trimprefix "TT_"

type Token struct {
	Type   TokenType
	Lexeme string
	Line   uint
}
