local Object = require 'lib.classic'

---@class Position
---@field public char integer
---@field public line integer
---@field public col integer
local Position = Object:extend()

function Position:new(char, line, col)
	self.char = char or 1
	self.line = line or 1
	self.col = col or 1
end

function Position:advance(curChar)
	self.char = self.char + 1

	if curChar == '\n' then
		self.line = self.line + 1
		self.col = 1
	else
		self.col = self.col + 1
	end
end

function Position:copy() return Position(self.char, self.line, self.col) end
function Position:__tostring() return string.format("(%i, %i)", self.line, self.col) end

return Position
