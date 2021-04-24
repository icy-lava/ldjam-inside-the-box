local game = {}

function game:enter()
	log.trace 'entered scene.game'
	
	self.tween = flux.group()
	self.level = {
		start = vector(-2, -2),
		stop  = vector(2, 2),
	}
	
	self.bump = bump.newWorld(200)
	self.tiny = tiny.world()
	for _, s in ipairs {
		'system.input_player',
		'system.next_target',
		'system.draw',
	} do
		self.tiny:addSystem(require(s))
	end
	
	local player = {
		input = true,
		move = vector(),
		speed = properties.player.speed
	}
	self.tiny:addEntity(player)
	self.bump:add(
		player,
		0 * properties.tile_width, 0 * properties.tile_height,
		properties.tile_width - epsilon, properties.tile_height - epsilon
	)
	local e = {}
	self.tiny:addEntity(e)
	self.bump:add(
		e,
		-1 * properties.tile_width, 0 * properties.tile_height,
		properties.tile_width - epsilon, properties.tile_height - epsilon
	)
	
	self.camera = require 'hump.camera' (0, 0)
end

function game:update(dt)
	self.tween:update(love.timer.getDelta())
	self.tiny:update(love.timer.getDelta(), function(_, s) return s ~= require 'system.draw' end)
end

local function drawHUD(self)
	if cli.debug then
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.print(string.format('%0.1fms', love.timer.getAverageDelta() * 1000), 4, 4)
	end
end

local function drawGame(self)
	local ww, wh = love.graphics.getDimensions()
	local vw, vh = unpack(properties.window.virtual_size, 1, 2)
	love.graphics.push()
	love.graphics.scale(math.min(
		ww / vw * vw / properties.tile_width / (self.level.stop.x - self.level.start.x + 1),
		wh / vh * vh / properties.tile_height / (self.level.stop.y - self.level.start.y + 1)
	))
	love.graphics.translate(
		-properties.tile_width * ((self.level.start.x + self.level.stop.x) / 2 + 0.5),
		-properties.tile_height * ((self.level.start.y + self.level.stop.y) / 2 + 0.5)
	)
	self.tiny:update(love.timer.getDelta(), function(_, s) return s == require 'system.draw' end)
	love.graphics.pop()
end

function game:draw()
	local ww, wh = love.graphics.getDimensions()
	
	love.graphics.push()
	self.camera:attach()
	drawGame(self)
	self.camera:detach()
	love.graphics.pop()
	drawHUD(self, ww, wh)
end

return game