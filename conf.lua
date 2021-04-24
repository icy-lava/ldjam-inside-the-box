require 'path'
require 'libraries'

properties = json.decode(love.filesystem.read('properties.json'))
epsilon = assert(properties.epsilon)
require 'cli'

log.usecolor = cli.color
if cli.debug then log.outfile = 'log.txt'
else log.level = 'fatal' end

if cli.show_console or cli.debug then require 'alloc_console' () end

log.trace 'patching in util.lua'
require 'util'.export()
levelStack = {0}

for k, c in pairs(properties.color) do
	properties.color[k] = assert(codeToColor(c))
end

log.debug('starting in ', cli.debug and 'debug mode' or 'release mode')

function love.conf(t)
	log.trace 'setting config'
	t.identity = assert(properties.identity, 'identity not defined in properties.json')
	t.appendidentity = false
	t.version = "11.3"
	t.console = false -- we manually allocate a console when needed
	t.accelerometerjoystick = true
	t.externalstorage = false
	t.gammacorrect = false
	
	t.audio.mic = false
	t.audio.mixwithsystem = true
	
	t.window.title = string.format(assert(properties.title, 'title not defined in properties.json') .. "%s", cli.debug and ' - Debug Mode' or '')
	t.window.icon = nil
	t.window.width = cli.width
	t.window.height = cli.height
	t.window.borderless = cli.borderless
	t.window.resizable = true
	t.window.minwidth = 100
	t.window.minheight = 100
	t.window.fullscreen = cli.fullscreen
	t.window.fullscreentype = "desktop"
	t.window.vsync = cli.vsync and 1 or 0
	t.window.msaa = 8
	t.window.depth = nil
	t.window.stencil = nil
	t.window.display = 1
	t.window.highdpi = false
	t.window.usedpiscale = true
	t.window.x = nil
	t.window.y = nil
	
	t.modules.audio = false
	t.modules.data = true
	t.modules.event = true
	t.modules.font = true
	t.modules.graphics = true
	t.modules.image = true
	t.modules.joystick = false
	t.modules.keyboard = true
	t.modules.math = true
	t.modules.mouse = true
	t.modules.physics = false
	t.modules.sound = false
	t.modules.system = true
	t.modules.thread = true
	t.modules.timer = true
	t.modules.touch = false
	t.modules.video = false
	t.modules.window = true
end
