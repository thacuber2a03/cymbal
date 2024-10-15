package codegen

import (
	"fmt"

	"github.com/thacuber2a03/cymbal/ast"
)

// Generates unoptimized Uxn machine code.
type CodeGen struct {
	program          *ast.Program
	mainBuf, codeBuf []byte
	curBuf           *[]byte

	Errors []string
}

func (cg *CodeGen) write(b byte)         { *cg.curBuf = append(*cg.curBuf, b) }
func (cg *CodeGen) writeOpVal(op OpCode) { cg.write(byte(op)) }

func (cg *CodeGen) writeOp(op string) {
	if op, ok := Opcodes[op]; ok {
		cg.writeOpVal(op)
		return
	}
	panic(fmt.Sprintf("'%s' isn't a valid opcode", op))
}

func (cg *CodeGen) Visit(n ast.Node) ast.Visitor {
	// fmt.Printf("visiting %T...\n", n)
	switch v := n.(type) {
	case *ast.MainDecl:
		cg.curBuf = &cg.mainBuf
		cg.block((*ast.Block)(v))
		cg.writeOp("BRK")
		cg.curBuf = &cg.codeBuf
		return cg

	case *ast.DEOStatement:
		cg = cg.Visit(v.Value).(*CodeGen)
		if cg == nil {
			return nil
		}

		// FIXME(thacuber2a03): the port number is always supposed to be a byte,
		// so I'd rather have something better than visiting the expression,
		// outputting a short value and then taking out the first byte with NIP
		//
		// ...is this the job of an optimizer?
		cg = cg.Visit(v.Port).(*CodeGen)
		if cg == nil {
			return nil
		}
		cg.writeOp("NIP")

		cg.writeOp("DEO2")
		return cg

	case *ast.Literal:
		cg.writeOp("LIT2")
		cg.write(byte(v.Value >> 8))
		cg.write(byte(v.Value))
		return cg
	}

	panic(fmt.Sprintf("hit unreachable case %T", n))
}

func (cg *CodeGen) block(b *ast.Block) {
	ast.WalkStatements(cg, b.Statements)
}

// Compiles the AST into a `[]byte`.
// All references within the code are relative to the reset vector,
// so all labels/jumps point to `<location> + 0x100`.
func (cg *CodeGen) Compile() []byte {
	ast.WalkDeclarations(cg, cg.program.Declarations)

	if len(cg.mainBuf) != 0 {
		// reset vector must always come first if it's not missing
		cg.codeBuf = append(cg.mainBuf, cg.codeBuf...)
	}

	return cg.codeBuf
}

func New(prog *ast.Program) *CodeGen {
	// codeBuf is initialized here for curBuf to have something to point to
	c := &CodeGen{program: prog, codeBuf: []byte{}}
	c.curBuf = &c.codeBuf
	return c
}
