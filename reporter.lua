local reporter = {
	errors = 0,
	warnings = 0,
}

local function writeFmt(format, ...) io.write(string.format(format, ...)) end

---@param source string
function reporter:setSource(source)
	self.source = source
end

---@param msg string
---@param startPos Position
---@param endPos Position
function reporter:error(msg, startPos, endPos)
	io.write("error ")
	writeFmt("[%i, %i]", startPos.line, startPos.col)

	if startPos.line ~= endPos.line
	or startPos.col ~= endPos.col then
		writeFmt("-[%i, %i]", endPos.line, endPos.col)
	end

	writeFmt(": %s\n", msg)

	reporter:printLocText(startPos, endPos)

	self.errors = self.errors + 1
end

---@param msg string
---@param startPos Position
---@param endPos Position
function reporter:warn(msg, startPos, endPos)
	io.write("warn ")
	writeFmt("[%i, %i]", startPos.line, startPos.col)

	if startPos.line ~= endPos.line
	or startPos.col ~= endPos.col then
		writeFmt("-[%i, %i]", endPos.line, endPos.col)
	end

	writeFmt(": %s\n", msg)

	reporter:printLocText(startPos, endPos)

	self.warnings = self.warnings + 1
end

---@return boolean
---@nodiscard
function reporter:didError() return self.errors > 0 end

local PREFIX = "..."
local MULTI_PREFIX = "..."
local LINE_NUM_LEN = 4

---@private
function reporter:printLocText(startPos, endPos)
	writeFmt("%s\n", PREFIX)

	local lines = {}
	for m in self.source:gmatch "[^\n]*" do
		table.insert(lines, m)
	end

	if startPos.line == endPos.line then
		writeFmt("%."..LINE_NUM_LEN.."i\t%s\n", startPos.line, lines[startPos.line])
		local s = string.rep(" ", startPos.col-1)
		if startPos.col == endPos.col then
			s = s .. "^"
		else
			s = s .. "|" .. string.rep("-", math.max(1, endPos.col - startPos.col-2)) .. "|"
		end
		writeFmt("%s\t%s\n", PREFIX, s)
	else
		local chosenLines = { table.unpack(lines, startPos.line, endPos.line) }
		chosenLines[1] = chosenLines[1]:sub(startPos.col)
		chosenLines[#chosenLines] = chosenLines[#chosenLines]:sub(1, endPos.col)

		for i, t in ipairs(chosenLines) do
			writeFmt("%."..LINE_NUM_LEN.."i\t%s\n", startPos.line + i-1, t)

			---@type string
			local s
			if i == 1 then
				s = string.rep(" ", startPos.col-1)
				s = s .. "|" .. string.rep("-", #t - startPos.col-1) .. ">"
			elseif i == #chosenLines then
				s = "<" .. string.rep("-", endPos.col-1) .. "|"
			else
				s = "<" .. string.rep("-", #t-2) .. ">"
			end
			writeFmt("%s\t%s\n", MULTI_PREFIX, s)
		end
	end -- startPos.line == endPos.line

	writeFmt("%s\n", PREFIX)
end

return reporter
