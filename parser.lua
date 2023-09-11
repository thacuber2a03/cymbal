local Type = require 'token'.Type
local ast = require 'ast'

---@class Parser
---@field private tokens Token[]
---@field private pos integer
---@field private curToken Token?
local parser = {}

function parser:init(tokens)
	self.tokens = tokens
	self.pos = 1 -- position in self.tokens
	self.curToken = self.tokens[self.pos]
end

---@return Token? oldToken
function parser:advance()
	local oldToken = self.curToken
	self.pos = self.pos + 1
	self.curToken = self.tokens[self.pos]
	return oldToken
end

---@return Binary
function parser:parse() return self:expression() end

function parser:binary(method, tokTypes)
	local left = self[method](self)

	for _, v in ipairs(tokTypes) do
		if self.curToken == v then
			local op = self:advance()
			local right = self[method](self)
			left = ast.Binary(left, op, right)
		end
	end

	return left
end

function parser:expression() return self:binary("term",   { Type.PLUS, Type.MINUS }) end
function parser:term()       return self:binary("factor", { Type.STAR, Type.SLASH }) end

function parser:factor()
	if self:check(Type.NUMBER) then
		return node.Literal(self:advance())
	end
end

return parser
