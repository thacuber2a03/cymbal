#!/usr/bin/env lua

local debugger = require 'debugger'

local reporter = require 'reporter'
local lexer = require 'lexer'
local parser = require 'parser'

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

reporter:setSource(source)
lexer:init(source)
if reporter:didError() then os.exit(-1) end
parser:init(lexer:scan())
local node = parser:parse()
if reporter:didError() then os.exit(-1) end
