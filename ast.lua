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
---@field public left Token|Binary
---@field public op Token
---@field public right Token|Binary

---@param left Token|Binary
---@param op Token
---@param right Token|Binary
---@return Binary
function ast.Binary(left, op, right, startPos, endPos)
	---@type Binary
	local n = newNode(startPos, endPos)
	n.type = "Binary"
	n.left = left
	n.op = op
	n.right = right
	return n
end

---@class Number : ASTNode
---@field public value integer
---@field public short boolean

---@param value integer
---@param short boolean
function ast.Number(value, short, startPos, endPos)
	---@type Number
	local n = newNode(startPos, endPos)
	n.value = value
	n.short = short
	return n
end

---@class String : ASTNode
---@field public chars string

---@param chars string
---@param startPos Position
---@param endPos Position
function ast.String(chars, startPos, endPos)
	local n = newNode(startPos, endPos)
	n.chars = chars
	return n
end

return ast
