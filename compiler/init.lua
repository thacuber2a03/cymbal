local Context = require 'compiler.context'
local reporter = require 'reporter'
local ast = require 'parser.ast'
local ops = require 'compiler.ops'
local Opcode, Mode = ops.Opcode, ops.Mode
local Type = require 'lexer.token'.Type

local compiler = {}

---@param tree ASTNode
function compiler:init(tree)
	self.ast = tree
	self.code = {}
	self.short = false

	self.memOff = 0x100
	self.stringPtrs = {}
end

function compiler:error(msg, node)
	reporter:error(msg, node.startPos, node.endPos)
end

---@param b integer
function compiler:emitByte(b)
	table.insert(self.code, b & 0xff)
end

---@param a integer
---@param b integer
function compiler:emitBytes(a, b)
	self:emitByte(a); self:emitByte(b)
end

---@param s number
function compiler:emitShort(s)
	table.insert(self.code, (s >> 8) & 0xff)
	table.insert(self.code,  s       & 0xff)
end

---@param node ASTNode
---@return string
function compiler:visit(node, ...)
	local method = self["visit" .. node.type]
	assert(method, "fatal: no visit method for " .. node.type .. " node")
	return method(self, node, ...)
end

function compiler:compile()
	local context = Context()
	for _, stmt in ipairs(self.ast) do
		self:visit(stmt, context)
	end
	self.short = false
	self:emitByte(Opcode.BRK)

	-- fix pointers to strings
	for _, s in ipairs(self.stringPtrs) do
		local here = #self.code + self.memOff
		for i=1, #s.str do
			self:emitByte(string.byte(s.str:sub(i,i)))
		end
		self:emitByte(0) -- zero termination
		self.code[s.ptr] = (here >> 8) & 0xff
		self.code[s.ptr+1] = here & 0xff
	end

	return self.code
end

---@param node Unary
function compiler:visitUnary(node, context)
	local op = node.op.type
	if op == Type.MINUS then
		self:emitByte(Opcode.LIT2)
		self:emitShort(0)
	end

	self:visit(node.value, context)

	if op == Type.BANG then
		self:emitByte(Opcode.LIT2)
		self:emitShort(0)
		self:emitByte(Opcode.EQU | Mode.SHORT)
	elseif op == Type.MINUS then
		self:emitByte(Opcode.SUB | Mode.SHORT)
	end
end

---@param node Binary
function compiler:visitBinary(node, context)
	if context:isType(node, "byte") then
		context:setType(node.left, "byte")
		context:setType(node.right, "byte")
	end

	self:visit(node.left, context)
	self:visit(node.right, context)

	--[[
	local function failedAttempt(n)
		self:error("attempt to perform arithmetic on "..n.type:lower(), n)
	end
	--]]

	local op = node.op.type

	---@type Opcode
	local b
	if     op == Type.PLUS  then b = Opcode.ADD
	elseif op == Type.MINUS then b = Opcode.SUB
	elseif op == Type.STAR  then b = Opcode.MUL
	elseif op == Type.SLASH then b = Opcode.DIV
	end

	self:emitByte(b | Mode.SHORT)
end

---@param node Number
function compiler:visitNumber(node, context)
	if context:isType(node, "byte") then
		self:emitBytes(Opcode.LIT, node.value)
	else
		self:emitByte(Opcode.LIT2)
		self:emitShort(node.value)
	end
end

---@param node Deref
function compiler:visitDeref(node, context)
	require 'debugger' ()
	local var = context:getVariable(node.var)
	if not var then self:error("undefined variable", node.var) end
	self:emitByte(Opcode.LDR)
end

---@param node String
function compiler:visitString(node, context) ---@diagnostic disable-line: unused-local
	self:emitByte(Opcode.LIT2)
	table.insert(self.stringPtrs, {
		str = node.chars,
		ptr = #self.code+1,
	})
	self:emitShort(0) -- space for pointer placeholder
	context:setType(node, "string")
end

local function getTypeNameFromTok(tok)
	local v = tok.type
	if v == Type.BYTE then return "byte" end
	if v == Type.SHORT then return "short" end
	if v == Type.STRING_TYPE then return "string" end
	return "unknown"
end

function compiler:visitVarDecl(node, context)
	if context:declareVariable(node.id) then
		self:error("variable already defined", node.id)
	end
	context:defineVariable(node.id, node.type, node.value)
	context:setType(node.value, getTypeNameFromTok(node.type))
	self:visit(node.value, context)
	self:emitByte(Opcode.STH | Mode.SHORT)
end

function compiler:visitFuncDecl(node, context)
	self:visit(node.block, context)
end

function compiler:visitBlock(node, context)
	for _, d in ipairs(node.declarations) do
		self:visit(d, context)
	end
end

return compiler
