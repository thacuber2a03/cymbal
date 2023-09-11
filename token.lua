local Object = require 'lib.classic'

---@class Token
---@field public type Token.Type
---@field public value any
---@field public startPos Position
---@field public endPos Position
local Token = Object:extend()

---@enum Token.Type
Token.Type = {
	NUMBER = "NUMBER",
	PLUS = "PLUS",
	MINUS = "MINUS",
	STAR = "STAR",
	SLASH = "SLASH",

	EOF = "EOF",
}

function Token:new(type, value, startPos, endPos)
	self.type = type
	self.value = value
	self.startPos = startPos
	self.endPos = endPos
end

function Token:__tostring()
	local s = self.type
	if self.value then s = s .. '(' .. self.value .. ')' end
	return s
end

return Token
