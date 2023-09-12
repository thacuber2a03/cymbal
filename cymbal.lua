#!/usr/bin/env lua

local reporter = require 'reporter'
local lexer = require 'lexer'
local parser = require 'parser'
local compiler = require 'compiler'

if #arg ~= 2 then
	io.write("usage: ", arg[0], " <input file> <output file>")
	os.exit(-1)
end

local inputfname = arg[1]
local outputfname = arg[2]

local source
do
	local inputfile <close>, err = io.open(inputfname, "rb")
	if not inputfile then
		io.write("couldn't open input file: ", err)
		os.exit(-1)
	end

	source = inputfile:read "*a"
end

reporter:setSource(source)
lexer:init(source)
if reporter:didError() then os.exit(-1) end
parser:init(lexer:scan())
local ast = parser:parse()
if reporter:didError() then os.exit(-1) end
compiler:init(ast)
local result = compiler:compile()

do
	local outputfile <close>, err = io.open(outputfname, "w+b")
	if not outputfile then
		io.write("couldn't open output file: ", err)
		os.exit(-1)
	end

	outputfile:write(string.char(table.unpack(result)))
end
