local game = {}

function game:enter()
	log.trace 'entered scene.game'
	self.tween = flux.group()
	self.level = json.decode(assert(love.filesystem.read(('asset/map_export/%d.json'):format(levelStack[#levelStack]))))
	
	self.bump = bump.newWorld(200)
	self.tiny = tiny.world()
	for _, s in ipairs {
		'system.physical',
		'system.input_player',
		'system.next_target',
		'system.draw',
	} do
		self.tiny:addSystem(require(s)())
	end
	
	for _, object in ipairs(lume.match(self.level.layers, function(l) return l.name == 'Objects' end).objects) do
		if object.name:match('^level%d+$') then
			local tile = {
				level = tonumber((object.name:match('^level(%d+)$'))),
				draw = require 'draw.level_end'
			}
			assert(tile.level)
			self.tiny:addEntity(tile)
			self.bump:add(tile, snapRectToTile(object.x, object.y, object.width, object.height))
		end
	end
	
	local player
	for i, id in ipairs(lume.match(self.level.layers, function(l) return l.name == 'Tiles' end).data) do
		local type = properties.tiles[id] or 'undefined'
		local x, y = (i - 1) % self.level.width, math.floor((i - 1) / self.level.width)
		if type == 'player' then
			assert(not player, 'only one player per level allowed')
			player = {
				input = true,
				move = vector(),
				speed = properties.player.speed,
				draw = require 'draw.player'
			}
			self.tiny:addEntity(player)
			self.bump:add(player, tileToRect(x, y))
		elseif type:match('^redirect_') then
			local redirect = {
				redirector = true,
				direction = type:match('_([^_]+)$')
			}
			assert(redirect.direction)
			self.tiny:addEntity(redirect)
			self.bump:add(redirect, tileToRect(x, y))
		end
	end
	self.player = assert(player)
	
	self.camera = require 'hump.camera' (0, 0)
end

function game:update(dt)
	self.tween:update(love.timer.getDelta())
	self.tiny:update(love.timer.getDelta(), function(_, s) return not s.draw end)
	if self.newLevel then
		if self.newLevel == 'pop' then
			popLevel()
		else
			pushLevel(self.newLevel)
		end
		self.newLevel = nil
		return
	end
	local ww, wh = love.graphics.getDimensions()
	local vw, vh = unpack(properties.window.virtual_size, 1, 2)
	self.camera:zoomTo(math.min(
		ww / vw * vw / self.level.tilewidth / self.level.width,
		wh / vh * vh / self.level.tileheight / self.level.height
	))
	self.camera:lookAt(self.level.tilewidth * (self.level.width / 2), self.level.tileheight * (self.level.height / 2))
end

local function drawHUD(self)
	if cli.debug then
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.print(string.format('%0.1fms, %d entities, %d systems', love.timer.getAverageDelta() * 1000, self.tiny:getEntityCount(), self.tiny:getSystemCount()), 4, 4)
	end
end

local function drawGame(self)
	self.tiny:update(love.timer.getDelta(), function(_, s) return s.draw end)
end

function game:draw()
	local ww, wh = love.graphics.getDimensions()
	love.graphics.clear(properties.color.background)
	self.camera:attach()
	drawGame(self)
	self.camera:detach()
	drawHUD(self, ww, wh)
end

return game