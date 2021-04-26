manager = roomy.new()
levelStack = {}
collectedKeys = {}

function love.load()
	local ww, wh = love.window.getMode()
	log.debug(
		string.format('resolution: %dx%d', ww, wh),
		cli.fullscreen and ', fullscreen' or ', windowed',
		cli.vsync and ', vsync on' or ''
	)
	
	manager:hook()
	require 'sounds'
	sound.music:play()
	-- manager:enter(require 'scene.game')
	-- pushLevel(0)
	manager:enter(newScene 'scene.menu')
end

function love.keypressed(key)
	if key == 'f11' or key == 'return' and love.keyboard.isDown('ralt', 'lalt') then
		love.window.setFullscreen(not love.window.getFullscreen())
		log.trace('switched to ', love.window.getFullscreen() and 'fullscreen' or 'windowed', ' mode')
	elseif cli.debug and key == 'f5' then
		log.trace('restarting game ...')
		love.event.quit('restart')
	elseif cli.debug and key == 'escape' then
		love.event.quit()
	end
end

function love.quit()
	log.trace 'quiting game ...'
end
