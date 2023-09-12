local reporter = require 'reporter'
local ast = require 'parser.ast'
local Token = require 'lexer.token'
local Type = Token.Type

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
function parser:match(type)
	if self:check(type) then
		self:advance()
		return true
	end
	return false
end

---@param type Token.Type
---@param msg string
---@return Token?
---@private
function parser:expect(type, msg)
	if self:check(type) then
		return self:advance() --[[@as Token]]
	else
		self:advance()
		self:error(msg, self.curToken)
	end
end

---@param msg string
---@param elem ASTNode|Token
function parser:error(msg, elem)
	reporter:error(msg, elem.startPos, elem.endPos)
	return ast.Error(elem.startPos, elem.endPos)
end

---@param msg string
---@param elem ASTNode|Token
function parser:warn(msg, elem) reporter:warn(msg, elem.startPos, elem.endPos) end

---@return ASTNode
---@nodiscard
function parser:parse()
	local declarations = {}
	while not self:atEnd() do
		while self:match(Type.NEWLINE) do end
		table.insert(declarations, self:topLevelDecl())
		while self:match(Type.NEWLINE) do end
	end
	return declarations
end

function parser:topLevelDecl()
	if self:check(Type.FN) then return self:funcDecl() end
	self:advance()
	return self:error("invalid top level declaration", self.curToken)
end

function parser:funcDecl()
	local fn = self:advance()
	local name = self:expect(Type.IDENTIFIER, "expected identifier")
	self:expect(Type.LPAREN, "expected '('")
	local parameters = {}
	if not self:check(Type.RPAREN) then
		parameters = self:parameters()
	end
	self:expect(Type.RPAREN, "expected ')'")
	self:match(Type.NEWLINE)
	local block = self:block()
	return ast.FuncDecl(name, parameters, block, fn.startPos, block.endPos)
end

function parser:parameters()
	local parameters = { self:advance() }
	while self:match(Type.COMMA) do
		table.insert(parameters, self:expect(Type.IDENTIFIER, "expected identifier"))
	end
	return parameters
end

function parser:block()
	local lbrace = self:expect(Type.LBRACE, "expected '{'")
	---@cast lbrace -?
	self:match(Type.NEWLINE)
	local declarations = {}
	while not (self:atEnd() or self:check(Type.RBRACE)) do
		table.insert(declarations, self:declaration())
	end
	self:match(Type.NEWLINE)
	local rbrace = self:expect(Type.RBRACE, "expected '}'")
	---@cast rbrace -?
	return ast.Block(declarations, lbrace.startPos, rbrace.endPos)
end

function parser:declaration()
	if self:check(Type.LET) then return self:varDecl() end
	return self:statement()
end

function parser:varDecl()
	local let = self:advance()
	local id = self:expect(Type.IDENTIFIER, "expected identifier")
	---@cast id -?
	self:expect(Type.COLON, "expected ':'") -- should probably make it optional
	local type = self:typename()
	self:expect(Type.ASSIGN, "expected '='")
	local value = self:expr()
	local nl = self:expect(Type.NEWLINE, "expected newline")
	---@cast nl -?
	return ast.VarDecl(id, type, value, let.startPos, nl.endPos)
end

function parser:typename()
	if self:check(Type.BYTE)
	or self:check(Type.SHORT)
	or self:check(Type.STRING_TYPE) then
		return self:advance()
	end

	self:error("expected a typename", self.curToken)
end

function parser:statement()
	return self:exprStmt()
end

function parser:exprStmt()
	local expr = self:expr()
	self:expect(Type.NEWLINE, "expected newline")
	return expr
end

---@return ASTNode | Binary
---@nodiscard
---@private
function parser:binary(method, tokTypes)
	---@type ASTNode
	local left = self[method](self)

	while true do
		local match = false
		for _, v in ipairs(tokTypes) do
			if self:check(v) then
				match = true
				local op = self:advance()
				---@type ASTNode
				local right = self[method](self)
				left = ast.Binary(left, op, right, left.startPos, right.endPos)
				---@cast left Binary
			end
		end

		if not match then break end
	end

	return left
end

---@return ASTNode | Binary
---@nodiscard
---@private
function parser:expr() return self:binary("term",   { Type.PLUS, Type.MINUS }) end

---@return ASTNode | Binary
---@nodiscard
---@private
function parser:term()       return self:binary("primary", { Type.STAR, Type.SLASH }) end

function parser:primary()
	if not (self:check(Type.MINUS) or self:check(Type.BANG)) then
		return self:factor()
	end

	local op = self:advance()
	local primary = self:primary()
	return ast.Unary(op, primary, op.startPos, primary.endPos)
end

---@return Number | Error | String | Deref | Variable
---@nodiscard
---@private
function parser:factor()
	if self:check(Type.NUMBER) then
		local num = self:advance()
		local short = false

		if num.value > 0xffff then
			self:warn("integer literal out of range; clamping", num)
			num.value = num.value & 0xffff
		end

		if num.value > 0xff then short = true end

		return ast.Number(num.value, short, num.startPos, num.endPos)

	elseif self:check(Type.CHARLIT) then
		local char = self:advance()
		return ast.Number(char.value, false, char.startPos, char.endPos)

	elseif self:check(Type.STRING) then
		local str = self:advance()
		return ast.String(str.value, str.startPos, str.endPos)

	elseif self:check(Type.IDENTIFIER) then
		local id = self:advance()
		if self:check(Type.CARET) then
			local caret = self:advance()
			return ast.Deref(id, id.startPos, caret.endPos)
		end
		return ast.Variable(id.value, id.startPos, id.endPos)
	else
		return self:error("unexpected token "..tostring(self.curToken), self.curToken)
	end
end

return parser
