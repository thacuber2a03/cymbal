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

local function endIfError()
	if reporter:didError() then
		io.write("errors found; must fix to compile")
		os.exit(-1)
	end
end

reporter:setSource(source)
lexer:init(source)

local start = os.clock()
parser:init(lexer:scan())
endIfError()
compiler:init(parser:parse())
endIfError()
local result = compiler:compile()
endIfError()
local finish = os.clock()

io.write(string.format(
	"successfully finished compilation in %ims",
	math.floor((finish - start) * 1e6)
))

do
	local outputfile <close>, err = io.open(outputfname, "w+b")
	if not outputfile then
		io.write("couldn't open output file: ", err)
		os.exit(-1)
	end

	outputfile:write(string.char(table.unpack(result)))
end
