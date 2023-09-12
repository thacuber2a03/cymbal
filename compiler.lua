local Opcode = require 'ops'.Opcode
local Mode = require 'ops'.Mode
local Type = require 'token'.Type

local compiler = {}

---@param ast ASTNode
function compiler:init(ast)
	self.ast = ast
	self.code = {}
	self.short = false
end

---@param b number
function compiler:emitByte(b)
	table.insert(self.code, b & 0xff)
end

---@param s number
function compiler:emitShort(s)
	table.insert(self.code, (s >> 8) & 0xff)
	table.insert(self.code,  s       & 0xff)
end

---@param node ASTNode
---@return string
function compiler:visit(node)
	return self["visit" .. node.type](self, node)
end

function compiler:compile()
	self:visit(self.ast)
	return self.code
end

---@param node Binary
function compiler:visitBinary(node)
	self:visit(node.left)
	self:visit(node.right)

	local op = node.op.type

	---@type Opcode
	local b
	if     op == Type.PLUS  then b = Opcode.ADD
	elseif op == Type.MINUS then b = Opcode.SUB
	elseif op == Type.STAR  then b = Opcode.MUL
	elseif op == Type.SLASH then b = Opcode.DIV
	end

	if self.short then b = b | Mode.SHORT end

	self:emitByte(b)
end

---@param node Number
function compiler:visitNumber(node)
	-- TODO(thacuber2a03): either somehow predict if
	-- the whole expression will be shorts only,
	-- or only compile shorts
	if node.short then
		self.short = true
		self:emitByte(Opcode.LIT2)
		self:emitShort(node.value)
	else
		self:emitByte(Opcode.LIT)
		self:emitByte(node.value)
	end
end

---@param node String
function compiler:visitString(node)
	error "todo"
end

return compiler
