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
