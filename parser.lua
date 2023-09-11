local Type = require 'token'.Type
local ast = require 'ast'

---@class Parser
---@field private tokens Token[]
---@field private pos integer
---@field private curToken Token
local parser = {}

function parser:init(tokens)
	self.tokens = tokens
	self.pos = 1
	self.curToken = self.tokens[self.pos]
end

---@return Token oldToken
function parser:advance()
	local oldToken = self.curToken
	self.pos = self.pos + 1
	self.curToken = self.tokens[self.pos]
	return oldToken
end

---@param type Token.Type
---@return boolean doesMatch
---@private
---@nodiscard
function parser:check(type) return self.curToken.type == type end

---@return boolean
---@private
---@nodiscard
function parser:atEnd() return self:check(Type.EOF) end

---@param type Token.Type
---@return boolean doesMatch
---@private
---@nodiscard
function parser:match(type)
	if self:check(type) then
		self:advance()
		return true
	end
	return false
end

---@param type Token.Type
---@param msg string
---@return Token
---@private
function parser:consume(type, msg)
	if self:check(type) then
		return self:advance() --[[@as Token]]
	else
		error(msg)
	end
end

---@param msg string
---@param node ASTNode
function parser:error(msg, node)
	reporter:error(msg, node.startPos, node.endPos)
end

---@return ASTNode
---@nodiscard
function parser:parse()
	local program = self:expression()
	if not self:atEnd() then error "expected end of file" end
	return program
end

---@return Binary
---@nodiscard
function parser:binary(method, tokTypes)
	local left = self[method](self)

	for _, v in ipairs(tokTypes) do
		if self:check(v) then
			local op = self:advance()
			local right = self[method](self)
			left = ast.Binary(left, op, right)
		end
	end

	return left
end

---@return Binary
---@nodiscard
function parser:expression() return self:binary("term",   { Type.PLUS, Type.MINUS }) end

---@return Binary
---@nodiscard
function parser:term()       return self:binary("factor", { Type.STAR, Type.SLASH }) end

---@return Number
---@nodiscard
function parser:factor()
	if self:check(Type.NUMBER) then
		local num = self:advance()
		local short = false

		if num.value > 0xffff then
			self:warning "integer literal out of range; clamping"
			num.value = num.value & 0xffff
		end

		if num.value > 0xff then short = true end

		return ast.Number(num.value, short)
	else
		self:error("unexpected token "..tostring(self.curToken))
	end
end

return parser
