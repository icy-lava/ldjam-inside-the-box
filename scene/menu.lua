return function()
	local menu = {}
	
	function menu:enter()
		self.logo = love.graphics.newImage('asset/sprite/logo.png')
		self.tween = flux.group()
		self.fade = {value = 1}
		self.tween:to(self.fade, 1, {value = 0})
		:ease('quadout')
	end
	
	function menu:keypressed(key)
		if key == 'e' or key == 'space' then
			pushLevel(0)
		end
	end
	
	function menu:update(dt)
		self.tween:update(dt)
	end
	
	function menu:draw()
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
		love.graphics.clear(properties.color.background)
		love.graphics.push()
		love.graphics.translate((sw or ww) / 2 + (sx or 0), (sh or wh) / 4 * 1.25 + (sy or 0))
		love.graphics.scale((sh or wh) / self.logo:getWidth() / 1.5)
		love.graphics.translate(-self.logo:getWidth() / 2, -self.logo:getHeight() / 2)
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.draw(self.logo, 0, 0)
		love.graphics.pop()
		
		do
			local font = getFont(properties.font.main, 48)
			local prevFont = love.graphics.getFont()
			love.graphics.setFont(font)
			local text = 'Press SPACE to begin'
			local tw, th = font:getWidth(text), font:getHeight()
			love.graphics.setColor(properties.color.player)
			love.graphics.print(text, (sx or 0) + ((sw or ww) - tw) / 2, (sy or 0) + ((sh or wh) - th) * 3 / 4)
			love.graphics.setFont(prevFont)
		end
		
		-- do
		-- 	local font = getFont(properties.font.main, 48)
		-- 	local prevFont = love.graphics.getFont()
		-- 	love.graphics.setFont(font)
		-- 	local text = 'Press F11 for fullscreen'
		-- 	local tw, th = font:getWidth(text), font:getHeight()
		-- 	love.graphics.setColor(properties.color.player)
		-- 	love.graphics.print(text, (sx or 0) + ((sw or ww) - tw) / 2, (sy or 0) + ((sh or wh) - th) * 14 / 16)
		-- 	love.graphics.setFont(prevFont)
		-- end
		
		do
			local font = getFont(properties.font.main, 48)
			local prevFont = love.graphics.getFont()
			love.graphics.setFont(font)
			local text = '@icylavah'
			local tw, th = font:getWidth(text), font:getHeight()
			love.graphics.setColor(properties.color.redirect)
			love.graphics.print(text, (sx or 0) + ((sw or ww) - tw) - 16, (sy or 0) + ((sh or wh) - th) - 16)
			love.graphics.setFont(prevFont)
		end
		
		love.graphics.setScissor(unpack(scissor, 1, 4))
		love.graphics.setColor(0, 0, 0, self.fade.value)
		love.graphics.rectangle('fill', 0, 0, ww, wh)
	end
	
	return menu
end