local parser = require 'argparse' ()

parser:help_max_width(120)
parser:help_description_margin(30)

local windows = jit.os == 'Windows'
parser:group('Developer options',
	parser:flag('--debug -d'):description('Turn on debug mode' .. (windows and ' (implies --show-console)' or '')),
	parser:flag('--show-console'):description('Show a console window (ignored on non-Windows OSs)'):hidden(not windows),
	parser:flag('--color'):description('Use colored output in the console window'),
	parser:flag('--no-color'):description('Use colored output in the console window'):target("color"):action("store_false")
)

local fs = parser:flag('--fullscreen -f'):description('Start in fullscreen mode')
local nfs = parser:flag('--no-fullscreen'):description('Start in windowed mode'):target("fullscreen"):action("store_false")
parser:mutex(fs, nfs)

parser:group('Window options',
	fs, nfs,
	parser:flag('--vsync'):description('Turn on vsync'),
	parser:flag('--borderless'):description('Start in a borderless window'),
	parser:option('--width -w'):description('Set startup window width'):convert(tonumber),
	parser:option('--height -p'):description('Set startup window height'):convert(tonumber)
)

cli = parser:parse(love.arg.parseGameArguments(arg))

cli.color = (cli.color == nil) and (not windows) or cli.color

cli.fullscreen = cli.fullscreen or not cli.debug and cli.fullscreen == nil

-- TODO: move outside of cli.lua
local defaultW, defaultH = properties.window.virtual_size:match('%s*(%d+)%s*:%s*(%d+)%s*')
defaultW, defaultH = assert(tonumber(defaultW)), assert(tonumber(defaultH))

properties.window.virtual_width  = defaultW
properties.window.virtual_height = defaultH
properties.window.virtual_size   = {defaultW, defaultH}

cli.height = cli.height or math.floor(cli.width and (cli.width * defaultH / defaultW) or defaultH)
cli.width = cli.width or math.floor(cli.height * defaultW / defaultH)
