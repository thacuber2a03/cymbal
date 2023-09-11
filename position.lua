local Object = require 'lib.classic'

local Position = Object:extend()

---@class Position
---@field public char integer
---@field public line integer
---@field public col integer

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

function Position:copy()

end

return Position
