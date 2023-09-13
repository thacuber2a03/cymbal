local Object = require 'lib.classic'

local Context = Object:extend()

function Context:new()
	self.types = {}
	self.variables = {}
end

function Context:setType(value, type) self.types[value] = type end
function Context:getType(value) return self.types[value] end
function Context:isType(value, type) return self.types[value] == type end

function Context:declareVariable(tok)
	if self.variables[tok.value] then return true end
	self.variables[tok.value] = {}
	return false
end

function Context:defineVariable(id, type, value)
	self.variables[id.value].type = type
	self.variables[id.value].value = value
	self.types[type] = type
end

---@param tok Token
function Context:getVariable(tok) return self.variables[tok.value] end

return Context
