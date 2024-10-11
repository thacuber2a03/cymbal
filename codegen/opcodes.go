package codegen

// Serves as a type alias for a byte; it only has
// methods attached to it that operate on it.
type OpCode byte

const (
	ShortFlag  = 1 << (iota + 5) // The short flag bit. (0b0010_0000)
	KeepFlag                     // The keep flag bit. (0b0100_0000)
	ReturnFlag                   // The return flag bit. (0b1000_0000)

	// NOTE(thacuber2a03): I love iota
)

// Sets the short flag in the opcode.
func (op OpCode) short() OpCode { return op | ShortFlag }

// Sets the keep flag in the opcode.
func (op OpCode) keep() OpCode { return op | KeepFlag }

// Sets the return flag in the opcode.
func (op OpCode) ret() OpCode { return op | ReturnFlag }

// Unsets the short flag in the opcode.
// Unsets the keep flag in the opcode.
// Unsets the return flag in the opcode.

// The values of most of the opcodes used while generating code.
var Opcodes = map[string]OpCode{
	"BRK":  0x00,
	"NIP":  0x03,
	"DEO":  0x17,
	"DEO2": 0x37,
	"LIT2": 0xa0,
}
