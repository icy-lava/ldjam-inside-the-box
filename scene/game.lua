return function()
	local game = {}

	function game:enter(_, level, popFrom)
		log.trace('entered scene.game with level ', (''..level))
		self.tween = flux.group()
		self.level = json.decode(assert(love.filesystem.read(('asset/map_export/%d.json'):format(level))))
		self.level.id = level
		
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
		
		local player
		for _, object in ipairs(lume.match(self.level.layers, function(l) return l.name == 'Objects' end).objects) do
			if object.name:match('^level%d+$') then
				local tile = {
					level = tonumber((object.name:match('^level(%d+)$'))),
					draw = require 'draw.level_end',
					z = 1
				}
				assert(tile.level)
				self.tiny:addEntity(tile)
				self.bump:add(tile, snapRectToTile(object.x, object.y, object.width, object.height))
			elseif object.name == 'player' then
				assert(not player, 'only one player per level allowed')
				player = {
					input = true,
					move = vector(),
					speed = properties.player.speed,
					draw = require 'draw.player',
					z = 2
				}
				self.tiny:addEntity(player)
				self.bump:add(player, snapRectToTile(object.x, object.y, object.width, object.height))
			elseif object.name:match('^lock%$[^%$]+$') then
				local tile = {
					lock = object.name:match('^lock%$([^%$]+)$'),
					draw = require 'draw.lock',
					z = 1
				}
				assert(tile.lock)
				self.tiny:addEntity(tile)
				self.bump:add(tile, snapRectToTile(object.x, object.y, object.width, object.height))
			elseif object.name:match('^key%$[^%$]+$') then
				local tile = {
					key = object.name:match('^key%$([^%$]+)$'),
					draw = require 'draw.key'
				}
				assert(tile.key)
				if not collectedKeys[tile.key] then
					self.tiny:addEntity(tile)
					self.bump:add(tile, snapRectToTile(object.x, object.y, object.width, object.height))
				end
			end
		end
		
		for i, id in ipairs(lume.match(self.level.layers, function(l) return l.name == 'Tiles' end).data) do
			local type = properties.tiles[id] or 'undefined'
			local x, y = (i - 1) % self.level.width, math.floor((i - 1) / self.level.width)
			if type == 'player' then
				assert(not player, 'only one player per level allowed')
				player = {
					input = true,
					move = vector(),
					speed = properties.player.speed,
					draw = require 'draw.player',
					z = 2
				}
				self.tiny:addEntity(player)
				self.bump:add(player, tileToRect(x, y))
			elseif type:match('^redirect_') then
				local redirect = {
					redirector = true,
					direction = type:match('_([^_]+)$'),
					draw = require 'draw.redirect'
				}
				assert(redirect.direction)
				self.tiny:addEntity(redirect)
				self.bump:add(redirect, tileToRect(x, y))
			elseif type == 'stop' then
				local stop = {
					stop = true,
					draw = require 'draw.stop'
				}
				self.tiny:addEntity(stop)
				self.bump:add(stop, tileToRect(x, y))
			elseif type == 'block' then
				local block = {
					block = true,
					draw = require 'draw.block'
				}
				self.tiny:addEntity(block)
				self.bump:add(block, tileToRect(x, y))
			elseif type == 'checkpoint' then
				local checkpoint = {
					checkpoint = true,
					draw = require 'draw.checkpoint'
				}
				self.tiny:addEntity(checkpoint)
				self.bump:add(checkpoint, tileToRect(x, y))
			elseif type:match('^spike_') then
				local spike = {
					spike = true,
					direction = type:match('_([^_]+)$'),
					draw = require 'draw.spike'
				}
				assert(spike.direction)
				self.tiny:addEntity(spike)
				self.bump:add(spike, tileToRect(x, y))
			end
		end
		self.player = assert(player)
		
		self.tiny:refresh()
		
		if popFrom then
			local e = lume.match(self.tiny.entities, function(e)
				return e.level == popFrom[1]
			end)
			assert(e)
			local x, y = rectToTile(self.bump:getRect(e))
			self.zoomOut = {x = x, y = y, value = 0}
			self.tween:to(self.zoomOut, 0.4, {value = 1})
			:oncomplete(function()
				self.zoomOut = nil
			end)
			:ease('quadinout')
			self.bump:update(player, tileToRect(x, y))
			player.redirect = popFrom[2]
		end
		
		self.camera = require 'hump.camera' (0, 0)
		updateCamera(self)
		
		-- print(#self.tiny.entities)
		
		-- print(#self.tiny.entities)
		-- local stream = io.open('scene' .. self.level.id .. '.txt', 'wb')
		-- stream:write(inspect(self))
		-- stream:close()
		
		-- print(#lume.match(self.tiny.systems, function(s)
		-- 	return s.draw
		-- end).entities)
	end

	function game:update(dt)
		self.tween:update(love.timer.getDelta() / 1)
		self.tiny:update(love.timer.getDelta(), function(_, s) return not s.draw end)
		if self.newLevel and not self.newLevelTween then
			if self.newLevel == 'pop' then
				popLevel(getPlayer(self).lastDirection)
			else
				pushLevel(self.newLevel)
			end
			self.newLevel = nil
			return
		end
	end

	local function drawHUD(self, w, h)
		if collectedKeys.x and collectedKeys.y and collectedKeys.z then
			local prevFont = love.graphics.getFont()
			local scale = w / properties.window.virtual_width
			local wantSize = (scale * 80 + 0.5)
			local actualSize = 10
			for _, size in ipairs(properties.font.HUDSizes) do
				if size > wantSize then break end
				actualSize = size
			end
			
			local font = getFont(properties.font.main, actualSize)
			local text = 'GO BACK'
			local tw, th = font:getWidth(text), font:getHeight()
			
			local pad = actualSize / 2
			local vOffset = math.floor(h - th - pad - actualSize / 2 + 0.5)
			love.graphics.setColor(colorAlpha(properties.color.go_back_background, 0.5))
			love.graphics.rectangle(
				'fill',
				math.floor((w - tw) / 2 - pad + 0.5), vOffset - pad,
				math.floor(tw + pad * 2 + 0.5), math.floor(th + pad * 2 + 0.5),
				actualSize / 4, nil, 50
			)
			
			love.graphics.setColor(properties.color.go_back_text)
			love.graphics.setFont(font)
			love.graphics.print(text, math.floor((w - tw) / 2 + 0.5), vOffset)
			
			love.graphics.setFont(prevFont)
		end
		
		if cli.debug then
			love.graphics.setColor(1, 1, 1, 1)
			love.graphics.print(string.format('%0.1fms, %d entities, %d systems', love.timer.getAverageDelta() * 1000, self.tiny:getEntityCount(), self.tiny:getSystemCount()), 4, 4)
		end
	end

	local function drawGame(self)
		local prevFont = love.graphics.getFont()
		
		local scale = getLevelZoom(self, 1, 1)
		scale = scale / getTransitionMultiplier(self)
		local fontSize = math.floor(properties.font.size * scale + 0.5)
		local font = getFont(properties.font.main, fontSize)
		love.graphics.setFont(font)
		
		local text = getLevelLabel(self.level.id)
		local tw, th = font:getWidth(text), font:getHeight()
		
		love.graphics.push()
		love.graphics.translate(
			math.floor(self.level.tilewidth  / 2 * self.level.width  * scale + 0.5) / scale,
			math.floor(self.level.tileheight / 2 * self.level.height * scale + 0.5) / scale
		)
		love.graphics.scale(1 / scale * math.min(self.level.width, self.level.height))
		love.graphics.translate(-tw / 2, -th / 2)
		
		local alpha = 1 - getExitTween(self)
		if isPopScene(self) then
			alpha = getLevelTween(self.from)
		end
		love.graphics.setColor(colorAlpha(properties.color.background_label, alpha))
		love.graphics.print(text)
		
		love.graphics.pop()
		love.graphics.setColor(1, 1, 1, 1)
		
		love.graphics.setFont(prevFont)
		
		self.tiny:update(love.timer.getDelta(), function(_, s) return s.draw end)
	end

	function game:draw()
		updateCamera(self)
		local ww, wh = love.graphics.getDimensions()
		local vw, vh = unpack(properties.window.virtual_size, 1, 2)
		local aspectDiff = (vw / vh) / (ww / wh)
		local sx, sy, sw, sh
		if math.abs(aspectDiff - 1) > 0.001 then
			if aspectDiff < 1 then
				local scale = wh / vh
				local bw, bh = vw * scale, vh * scale
				sx, sy, sw, sh = math.floor((ww - bw) / 2 + 0.5), 0, bw, bh
			else
				local scale = ww / vw
				local bw, bh = vw * scale, vh * scale
				sx, sy, sw, sh = 0, math.floor((wh - bh) / 2 + 0.5), bw, bh
			end
		end
		local scissor = {love.graphics.getScissor()}
		love.graphics.setScissor(sx, sy, sw, sh)
		-- if getLevelTween(self) <= 0 then
			local alpha = 1
			if self.from and self.from.newLevel == 'pop' then
				alpha = getLevelTween(self.from)
			end
			love.graphics.setColor(colorAlpha(properties.color.background, alpha))
			love.graphics.rectangle('fill', 0, 0, ww, wh)
		-- end
		if self.newScene and self.newLevel ~= 'pop' then
			self.newScene:draw()
		end
		self.camera:attach(sx, sy, sw, sh, true)
		drawGame(self)
		self.camera:detach()
		if self.newScene and self.newLevel == 'pop' then
			self.newScene:draw()
		end
		if not self.from then
			love.graphics.push()
			love.graphics.translate(sx or 0, sy or 0)
			drawHUD(self, sw or ww, sh or wh)
			love.graphics.pop()
		end
		love.graphics.setScissor(unpack(scissor, 1, 4))
	end

	return game
end