local game = {}

function game:enter()
	log.trace 'entered scene.game'
	
	self.tween = flux.group()
	self.level = json.decode(assert(love.filesystem.read(('asset/map_export/%s.json'):format(level))))
	
	self.bump = bump.newWorld(200)
	self.tiny = tiny.world()
	for _, s in ipairs {
		'system.physical',
		'system.input_player',
		'system.next_target',
		'system.draw',
	} do
		self.tiny:addSystem(require(s))
	end
	
	local player
	for _, object in ipairs(lume.match(self.level.layers, function(l) return l.name == 'Objects' end).objects) do
		if object.type == 'player' then
			assert(not player)
			player = {input = true, move = vector(), speed = properties.player.speed}
			self.tiny:addEntity(player)
			self.bump:add(player, snapRectToTile(object.x, object.y, object.width, object.height))
		elseif object.type:match('^level%d+$') then
			local tile = {level = tonumber((object.type:match('^level(%d+)$')))}
			assert(tile.level)
			self.tiny:addEntity(tile)
			self.bump:add(tile, snapRectToTile(object.x, object.y, object.width, object.height))
		else
			error('unknown level object type: ' .. object.type)
		end
	end
	self.player = assert(player)
	
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
		ww / vw * vw / self.level.tilewidth / self.level.width,
		wh / vh * vh / self.level.tileheight / self.level.height
	))
	love.graphics.translate(
		-self.level.tilewidth * (self.level.width / 2),
		-self.level.tileheight * (self.level.height / 2)
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