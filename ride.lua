#!/usr/bin/env lua

local lexer = require 'lexer'

-- ride
-- an expression-based programming language
-- that compiles to Uxn machine code

if #arg ~= 2 then
	io.write("usage: ", arg[0], " <input file> <output file>")
	os.exit(-1)
end

local inputfname = arg[1]
local source
do
	local inputfile <close>, err = io.open(inputfname, "rb")
	if not inputfile then
		io.write("couldn't open input file: ", err)
		os.exit(-1)
	end

	source = inputfile:read "*a"
end

lexer:init()
local tokens = lexer:scan(source)
for _, t in ipairs(tokens) do print(t) end
