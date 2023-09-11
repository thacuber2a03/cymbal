local ast = {}

---@class Binary
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

return ast
