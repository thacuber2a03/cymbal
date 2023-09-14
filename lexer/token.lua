local Object = require 'lib.classic'

---@class Token
---@field public type Token.Type
---@field public value any
---@field public startPos Position
---@field public endPos Position
local Token = Object:extend()

---@enum Token.Type
Token.Type = {
	IDENTIFIER = "IDENTIFIER",
	NUMBER = "NUMBER",
	STRING = "STRING",
	CHARLIT = "CHARLIT",

	PLUS = "PLUS",
	MINUS = "MINUS",
	STAR = "STAR",
	SLASH = "SLASH",
	BANG = "BANG",
	CARET = "CARET",
	COLON = "COLON",
	LPAREN = "LPAREN",
	RPAREN = "RPAREN",
	LBRACE = "LBRACE",
	RBRACE = "RBRACE",

	EQ = "EQ",
	NEQ = "NEQ",
	LESS = "LESS",
	LEQ = "LEQ",
	GREATER = "GREATER",
	GEQ = "GEQ",

	BYTE = "BYTE",
	SHORT = "SHORT",
	STRING_TYPE = "STRING_TYPE",
	BOOL = "BOOL",

	TRUE = "TRUE",
	FALSE = "FALSE",
	NULL = "NULL",

	FN = "FN",
	LET = "LET",
	WHILE = "WHILE",

	NEWLINE = "NEWLINE",

	EOF = "EOF",
}

---@param type Token.Type
---@param value any
---@param startPos Position
---@param endPos Position
function Token:new(type, value, startPos, endPos)
	self.type = type
	self.value = value
	self.startPos = startPos
	self.endPos = endPos
end

---@return string
function Token:__tostring()
	local s = self.type
	if self.value then
		if type(self.value) == "string" then
			s = s .. '(' .. string.format("%q", self.value) .. ')'
		else
			s = s .. '(' .. tostring(self.value) .. ')'
		end
	end
	return s
end

return Token
