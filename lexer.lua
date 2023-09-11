local reporter = require 'reporter'
local Position = require 'position'
local Token = require 'token'
local Type = Token.Type

local hexDigitPattern = "[0-9a-fA-F]"

---@class Lexer
---@field private source string
---@field private startPos Position[]
---@field private pos Position
---@field private curChar string
---@field private tokens Token[]
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
	self.startPos = {}
	self.pos = Position()
	self.curChar = self.source:sub(1,1)
	self.tokens = {}
end

---@return boolean
---@nodiscard
function lexer:atEnd() return self.pos.char > #self.source end

function lexer:pushStart() table.insert(self.startPos, self.pos:copy()) end
function lexer:popStart() table.remove(self.startPos) end
function lexer:setStart() self.startPos[#self.startPos] = self.pos:copy() end
---@return Position
function lexer:getStart() return self.startPos[#self.startPos] end

---@param msg string
function lexer:error(msg)
	local start = self:getStart()
	self:popStart()
	reporter:error(msg, start or self.pos:copy(), self.pos:copy())
end

function lexer:token(type, value)
	local start = self:getStart()
	self:popStart()
	table.insert(self.tokens, Token(type, value, start or self.pos:copy(), self.pos:copy()))
end

---@return string? oldChar
function lexer:advance()
	local oldChar = self.curChar
	self.pos:advance(oldChar)
	if self.pos.char <= #self.source then
		self.curChar = self.source:sub(self.pos.char, self.pos.char)
	else
		self.curChar = nil
	end

	return oldChar
end

---@param off integer?
---@return string?
function lexer:peek(off)
	off = off or 1
	local next = self.pos + off
	if next <= #self.source then return self.source:sub(next, next) end
end

---@return string
function lexer:parseEscape()
	self:pushStart()
	self:advance()
	if self:atEnd() then self:error("expected escape sequence after '\\'") end
	local c = self:advance()

	---@type string
	local e
	if     c == 'n' then e = '\n'
	elseif c == 't' then e = '\t'
	elseif c == 'r' then e = '\r'
	elseif c == "'" then e = "'"
	elseif c == '"' then e = '"'
	elseif c == 'x' then
		-- hex char, \x0a == \n
		local hex = ""
		for _=1, 2 do
			if self:atEnd() then self:error("expected hex digit") end
			hex = hex .. self:advance()
		end
		e = string.char(tonumber(hex, 16) --[[@as integer]])
	else
		self:error("unknown escape sequence")
		e = ""
	end

	self:popStart()
	return e
end

function lexer:character()
	---@type string
	local c
	self:setStart()

	self:advance() -- skip "'"

	if self:atEnd() or self.curChar == "'" then
		self:error "missing character literal"
	end

	if self.curChar == '\\' then
		self:advance()
		c = self:parseEscape()
	else
		c = self:advance() --[[@as string]]
	end

	if self:atEnd() then self:error "missing ending \"'\"" end

	self:advance() -- skip "'"

	self:token(Type.CHARLIT, string.byte(c))
end

function lexer:string(quote)
	self:setStart()
	local str = ""
	local raw = quote == '`'

	local function missingEndQuote()
		self:error("missing end quote (did you intend to make a `raw string`?)")
	end

	self:advance()

	while not self:atEnd() do
		if not raw then
			if self.curChar == '\n' then
				self:setStart()
				missingEndQuote()
				return
			elseif self.curChar == '\\' then
				str = str .. self:parseEscape()
			end
		end
		if self.curChar == quote then break end
		str = str .. self:advance()
	end

	if self:atEnd() then
		missingEndQuote()
	end

	self:advance()

	self:token(Type.STRING, str)
end

function lexer:number()
	local num = ""
	self:setStart()

	while self.curChar and self.curChar:match "%d" do
		num = num .. self:advance()
	end

	self:token(Type.NUMBER, tonumber(num))
end

---@return Token[]
function lexer:scan()
	while self.curChar do
		while self.curChar and self.curChar:match "%s" do
			self:advance()
		end

		if not self.curChar then break end

		if self.curChar:match "%d" then self:number()

		elseif self.curChar == "'" then self:character()

		elseif self.curChar == '"'
		    or self.curChar == '`' then
			self:string(self.curChar)

		elseif oneCharToks[self.curChar] then
			local type = oneCharToks[self.curChar]
			local here = self.pos:copy()
			table.insert(self.tokens, Token(type, self.curChar, here, here))
			self:advance()
		else
			self:error("unknown character '"..self.curChar.."'")
			self:advance()
		end
	end

	self:token(Type.EOF)
	return self.tokens
end

return lexer
