---@diagnostic disable-next-line: unused-local
local reporter = require 'reporter'
local Position = require 'position'
local Token = require 'token'
local Type = Token.Type

local lexer = {}

local oneCharToks = {
	['+'] = Type.PLUS,
	['-'] = Type.MINUS,
	['*'] = Type.STAR,
	['/'] = Type.SLASH,
}

---@param source string
function lexer:init(source)
	self.source = source
	self.pos = Position()
	self.curChar = self.source:sub(1,1)

	self.didInit = true
end

---@return string? oldChar
function lexer:advance()
	assert(self.didInit, "lexer not yet initialized")

	local oldChar = self.curChar
	self.pos:advance()
	if self.pos.char <= #self.source then
		self.curChar = self.source:sub(self.pos.char, self.pos.char)
	else
		self.curChar = nil
	end

	return oldChar
end

---@return Token
function lexer:number()
	local num = ""
	local start = self.pos:copy()

	while self.curChar and self.curChar:match "%d" do
		num = num .. self:advance()
	end

	return Token(Type.NUMBER, tonumber(num), start, self.pos:copy())
end

---@return Token[]
function lexer:scan()
	local tokens = {}

	while self.curChar do
		while self.curChar and self.curChar:match "%s" do
			self:advance()
		end

		if not self.curChar then break end

		if self.curChar:match "%d" then
			tokens[#tokens+1] = self:number()
		elseif oneCharToks[self.curChar] then
			local type = oneCharToks[self.curChar]
			local here = self.pos:copy()
			tokens[#tokens+1] = Token(type, self.curChar, here, here)
			self:advance()
		else
			io.write("unknown character '", self.curChar, "'\n")
			self:advance()
		end
	end

	self:init(self.source)
	return tokens
end

return lexer
