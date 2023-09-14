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

---Returns a pointer to the current byte in memory.
---@return integer
function compiler:where()
	return #self.code + self.memOff
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
		local here = self:where()
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
	self:visit(node.left, context)
	self:visit(node.right, context)

	--[[
	local function failedAttempt(n)
		self:error("attempt to perform arithmetic on "..n.type:lower(), n)
	end
	--]]

	context:setType(node, "number")

	local op = node.op.type

	---@type Opcode
	local b
	if     op == Type.PLUS    then b = Opcode.ADD
	elseif op == Type.MINUS   then b = Opcode.SUB
	elseif op == Type.STAR    then b = Opcode.MUL
	elseif op == Type.SLASH   then b = Opcode.DIV
	end

	if not b then context:setType(node, "boolean") end

	if     op == Type.LESS    then b = Opcode.LTH
	elseif op == Type.GREATER then b = Opcode.GTH
	end

	if not b then error("no support for operator "..op) end

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
	local var = context:getVariable(node.var)
	if not var then self:error("undefined variable", node.var) end
	error "todo"
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

---@param node Boolean
function compiler:visitBoolean(node, context)
	self:emitBytes(Opcode.LIT, node.state and 1 or 0)
	context:setType(node, "boolean")
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

---@param node FuncDecl
function compiler:visitFuncDecl(node, context)
	self:visit(node.block, context)

	if node.id.value ~= "main" then error "todo func decl" end
end

function compiler:visitBlock(node, context)
	for _, d in ipairs(node.declarations) do
		self:visit(d, context)
	end
end

---@param node While
function compiler:visitWhile(node, context)
	self:visit(node.condition, context)
	if context:getType(node.condition) ~= "boolean" then
		self:error("loop condition must be an expression that resolves to a boolean", node.condition)
	end

	self:emitBytes(Opcode.LIT, 0)
	local checkCondPtr = self:where()
	self:emitByte(Opcode.EQU | Mode.KEEP)
	self:emitByte(Opcode.JCI)
	local blockEndPtr = self:where() - self.memOff + 1
	self:emitShort(0)
	local blockStart = self:where()

	self:visit(node.block, context)

	self:emitByte(Opcode.JMI)
	self:emitShort(checkCondPtr-self:where()-2)
	local blockEndOff = self:where() - blockStart
	self:emitByte(Opcode.POP | Mode.SHORT) -- zero to compare it to
	self:emitByte(Opcode.POP | Mode.SHORT) -- condition

	self.code[blockEndPtr + 0] = (blockEndOff >> 8) & 0xff
	self.code[blockEndPtr + 1] =  blockEndOff       & 0xff
end

return compiler
