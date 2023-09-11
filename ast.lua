local ast = {}

---@class ASTNode
---@field public type string

---@class Binary : ASTNode
---@field public left Token|Binary
---@field public op Token
---@field public right Token|Binary

---@param left Token|Binary
---@param op Token
---@param right Token|Binary
---@return Binary
function ast.Binary(left, op, right)
	return {
		type = "Binary",
		left = left,
		op = op,
		right = right,
	}
end

---@class Literal: ASTNode
---@field public value any
function ast.Literal(value)
	return {
		type = "Literal",
		value = value
	}
end

return ast
