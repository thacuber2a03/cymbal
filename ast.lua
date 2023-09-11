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
	return setmetatable({
		type = "Binary",
		left = left,
		op = op,
		right = right,
	}, {
		__tostring = function(self)
			local s = "Binary("
			s = s .. tostring(self.left) .. ", "
			s = s .. tostring(self.op) .. ", "
			s = s .. tostring(self.right)
			return s .. ")"
		end
	})
end

---@class Literal: ASTNode
---@field public value any
function ast.Literal(value)
	return setmetatable({
		type = "Literal",
		value = value
	}, {
		__tostring = function(self)
			return "Literal(" .. tostring(self.value) .. ")"
		end
	})
end

return ast
