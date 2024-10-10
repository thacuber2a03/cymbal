package parser

import (
	"fmt"
	"strconv"

	"github.com/thacuber2a03/cymbal/lexer"
)

type ParseError struct {
	Token   lexer.Token
	Message string
}

func (pe *ParseError) Error() string {
	return fmt.Sprintf("Error at line %d: %s", pe.Token.Line, pe.Message)
}

type Parser struct {
	*lexer.Lexer
	curTok, nextTok lexer.Token

	Errors    []ParseError
	panicMode bool
}

func (p *Parser) error(tok lexer.Token, msg string) {
	// error engineering taken from clox
	// yeah, the language from Crafting Interpreters

	if p.panicMode {
		return
	}
	p.panicMode = true

	p.Errors = append(p.Errors, ParseError{
		Token:   tok,
		Message: msg,
	})
}

func (p *Parser) advance() (res bool) {
	p.curTok = p.nextTok
	res = true
	for {
		p.nextTok = p.Lexer.Next()
		if p.nextTok.Type != lexer.TT_ERROR {
			return
		}
		res = false
		p.error(p.nextTok, p.nextTok.Lexeme)
	}
}

func (p *Parser) check(tt lexer.TokenType) bool { return p.curTok.Type == tt }

func (p *Parser) atEnd() bool { return p.curTok.Type == lexer.TT_EOF }

func (p *Parser) match(tt lexer.TokenType) bool {
	if p.check(tt) {
		p.advance()
		return true
	}
	return false
}

func (p *Parser) expect(tt lexer.TokenType) bool {
	if !p.match(tt) {
		msg := fmt.Sprintf("expected %v, but got %v", tt, p.curTok.Type)
		p.error(p.curTok, msg)
		return false
	}
	return true
}

func (p *Parser) expression() (res Expression) {
	// TODO(thacuber2a03): insert an actual expression parser here

	if p.check(lexer.TT_INT) {
		val, err := strconv.ParseInt(p.curTok.Lexeme, 0, 16)
		if err != nil {
			p.error(p.curTok, "integer overflow/underflow")
			return nil
		}

		res = &Literal{Value: int16(val)}
		p.advance()
		return
	} else if p.check(lexer.TT_CHAR) {
		res = &Literal{Value: int16(p.curTok.Lexeme[1])}
		p.advance()
		return
	}

	p.error(p.curTok, "expected expression")
	return nil
}

func (p *Parser) deoStmt() *DEOStatement {
	deo := &DEOStatement{}

	if deo.Port = p.expression(); deo.Port == nil {
		return nil
	}

	if !p.expect(lexer.TT_COMMA) {
		return nil
	}

	if deo.Value = p.expression(); deo.Value == nil {
		return nil
	}

	return deo
}

func (p *Parser) statement() Statement {
	if p.match(lexer.TT_DEO) {
		return p.deoStmt()
	}
	return nil
}

func (p *Parser) block() *Block {
	b := &Block{}

	for !(p.atEnd() || p.check(lexer.TT_RBRACE)) {
		s := p.statement()
		if s != nil {
			b.Statements = append(b.Statements, s)
		}
	}

	if !p.expect(lexer.TT_RBRACE) {
		return nil
	}

	return b
}

func (p *Parser) mainDecl() *MainDecl {
	if !p.expect(lexer.TT_LBRACE) {
		return nil
	}
	return (*MainDecl)(p.block())
}

func (p *Parser) declaration() Declaration {
	if p.match(lexer.TT_MAIN) {
		return p.mainDecl()
	}
	return nil
}

func (p *Parser) program() *Program {
	prog := &Program{}

	for !p.check(lexer.TT_EOF) {
		d := p.declaration()
		if d != nil {
			prog.Declarations = append(prog.Declarations, d)
		}
	}

	return prog
}

// Parses the program and returns an AST representation of it.
// Returns nil if there has been any errors.
func (p *Parser) Parse() *Program {
	if !p.advance() {
		return nil
	}
	if !p.advance() {
		return nil
	}

	prog := p.program()
	if !p.expect(lexer.TT_EOF) {
		return nil
	}
	return prog
}

func New(l *lexer.Lexer) *Parser { return &Parser{Lexer: l} }
