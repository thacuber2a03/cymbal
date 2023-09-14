local ast = {}

---@class ASTNode
---@field public type string
---@field public startPos Position
---@field public endPos Position

---@param startPos Position
---@param endPos Position
---@return ASTNode
local function newNode(startPos, endPos)
	return {
		type = "ASTNode",
		startPos = startPos,
		endPos = endPos,
	}
end

---@class Binary : ASTNode
---@field public left ASTNode
---@field public op Token
---@field public right ASTNode

---@param left ASTNode
---@param op Token
---@param right ASTNode
---@param startPos Position
---@param endPos Position
---@return Binary
function ast.Binary(left, op, right, startPos, endPos)
	local n = newNode(startPos, endPos)
	---@cast n Binary
	n.type = "Binary"
	n.left = left
	n.op = op
	n.right = right
	return n
end

---@class Unary : ASTNode
---@field public op Token
---@field public value ASTNode

---@param op Token
---@param value ASTNode
---@param startPos Position
---@param endPos Position
---@return Unary
function ast.Unary(op, value, startPos, endPos)
	local n = newNode(startPos, endPos)
	---@cast n Unary
	n.type = "Unary"
	n.op = op
	n.value = value
	return n
end

---@class Deref : ASTNode
---@field public var Token

---@param var Token
---@param startPos Position
---@param endPos Position
---@return Deref
function ast.Deref(var, startPos, endPos)
	local n = newNode(startPos, endPos)
	---@cast n Deref
	n.type = "Deref"
	n.var = var
	return n
end

---@class Variable : ASTNode
---@field public id Token

---@param id Token
---@param startPos Position
---@param endPos Position
---@return Variable
function ast.Variable(id, startPos, endPos)
	local n = newNode(startPos, endPos)
	---@cast n Variable
	n.type = "Variable"
	n.id = id
	return n
end

---@class VarDecl : ASTNode
---@field public id Token
---@field public typename Token
---@field public value ASTNode

---@param id Token
---@param typename Token
---@param value ASTNode
---@param startPos Position
---@param endPos Position
---@return VarDecl
function ast.VarDecl(id, typename, value, startPos, endPos)
	local n = newNode(startPos, endPos)
	---@cast n VarDecl
	n.type = "VarDecl"
	n.id = id
	n.typename = typename -- inconvenient
	n.value = value
	return n
end

---@class FuncDecl : ASTNode
---@field public id Token
---@field public parameters Token[]
---@field public block Block

---@param id Token
---@param parameters Token[]
---@param block Block
---@param startPos Position
---@param endPos Position
---@return FuncDecl
function ast.FuncDecl(id, parameters, block, startPos, endPos)
	local n = newNode(startPos, endPos)
	---@cast n FuncDecl
	n.type = "FuncDecl"
	n.id = id
	n.parameters = parameters
	n.block = block
	return n
end

---@class Block : ASTNode
---@field public declarations ASTNode[]

---@param declarations ASTNode[]
---@param startPos Position
---@param endPos Position
---@return Block
function ast.Block(declarations, startPos, endPos)
	local n = newNode(startPos, endPos)
	---@cast n Block
	n.type = "Block"
	n.declarations = declarations
	return n
end

---@class While : ASTNode
---@field public condition Binary | Literal
---@field public block Block

---@param condition Binary | Literal
---@param block Block
---@param startPos Position
---@param endPos Position
---@return Block
function ast.While(condition, block, startPos, endPos)
	local n = newNode(startPos, endPos)
	---@cast n While
	n.type = "While"
	n.condition = condition
	n.block = block
	return n
end

---Represents all constants in the code.
---@class Literal : ASTNode

---@class Number : Literal
---@field public value integer
---@field public short boolean

---@param value integer
---@param short boolean
---@return Number
function ast.Number(value, short, startPos, endPos)
	local n = newNode(startPos, endPos)
	---@cast n Number
	n.type = "Number"
	n.value = value
	n.short = short
	return n
end

---@class String : Literal
---@field public chars string

---@param chars string
---@param startPos Position
---@param endPos Position
function ast.String(chars, startPos, endPos)
	local n = newNode(startPos, endPos)
	---@cast n String
	n.type = "String"
	n.chars = chars
	return n
end

---@class Boolean : Literal
---@field public state boolean

---@param state boolean
---@param startPos Position
---@param endPos Position
function ast.Boolean(state, startPos, endPos)
	local n = newNode(startPos, endPos)
	---@cast n Boolean
	n.type = "Boolean"
	n.state = state
	return n
end

---@class Null : Literal

---@param startPos Position
---@param endPos Position
function ast.Null(startPos, endPos)
	local n = newNode(startPos, endPos)
	---@cast n Null
	n.type = "Null"
	return n
end

---Internal error representation.
---@class Error : ASTNode

---@param startPos Position
---@param endPos Position
---@return Error
function ast.Error(startPos, endPos)
	local n = newNode(startPos, endPos)
	---@cast n Error
	n.type = "Error"
	return n
end

return ast
