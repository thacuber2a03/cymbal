local Opcode = require 'ops'.Opcode

local compiler = {}

---@param ast ASTNode
function compiler:init(ast)
	self.ast = ast
	self.code = {}
end

---@param b number
function compiler:emitByte(b)
	table.insert(self.code, b & 0xff)
end

---@param s number
function compiler:emitShort(s)
	table.insert(self.code,  s       & 0xff)
	table.insert(self.code, (s << 4) & 0xff)
end

---@param node ASTNode
---@return string
function compiler:visit(node)
	return self["visit" .. node.type](self, node)
end

function compiler:compile()
end

---@param node Binary
function compiler:visitBinary(node)

end

---@param node Number
function compiler:visitNumber(node)
	self:emitByte(Opcode.LIT)
	self:emitByte(node.value & 0xff)
end

return compiler
