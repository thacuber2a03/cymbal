package lexer

type TokenType int

const (
	TT_EOF TokenType = iota

	TT_IDENT
	TT_INT
	TT_CHAR

	TT_LBRACE
	TT_COMMA
	TT_RBRACE

	TT_FN
	TT_DEO
)

//go:generate stringer -type TokenType -trimprefix "TT_"

type Token struct {
	Type   TokenType
	Lexeme string
	Line   uint
}
