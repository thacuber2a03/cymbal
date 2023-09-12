local Object = require 'lib.classic'

local Context = Object:extend()

function Context:new()
	self.types = {}
	self.variables = {}
end

function Context:addType(value, typ)
	self.types[value] = self.types[value] or {}
	if type(typ) == "table" then
		for _, v in ipairs(typ) do
			self.types[value][v] = true
		end
	else
		self.types[value][typ] = true
	end
end

function Context:containsType(value, type) return not not self.types[value][type] end
function Context:getType(value) return self.types[value] end

function Context:declareVariable(tok)
	self.variables[tok.value] = {}
end

function Context:defineVariable(id, type, value)
	self.variables[id.value].type = type
	self.variables[id.value].value = value
	self.types[type] = type
end

---@param tok Token
function Context:getVariable(tok) return self.variables[tok.value] end

return Context
