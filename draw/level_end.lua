return function (e)
	local scale = getScene().camera.scale
	love.graphics.setColor(properties.color.level_end)
	local x, y, w, h = getScene().bump:getRect(e)
	love.graphics.rectangle('fill', x, y, w, h, 4, nil, 100)
	love.graphics.setColor(properties.color.player)
	local prevFont = love.graphics.getFont()
	local font = getFont(properties.font.main, 36 * scale)
	love.graphics.setFont(font)
	
	local text = '#' .. e.level
	local tw, th = font:getWidth(text), font:getHeight()
	
	love.graphics.push()
	local tx, ty = math.floor((x + w / 2) * scale - tw / 2), math.floor((y + h / 2) * scale - th / 2)
	love.graphics.translate(tx / scale, ty / scale)
	love.graphics.scale(1 / scale)
	love.graphics.print(text)
	love.graphics.pop()
	love.graphics.setColor(1, 1, 1, 0.2)
	-- love.graphics.rectangle('fill', x, y + (h - th / scale) / 2, tw / scale, th / scale)
	
	love.graphics.setFont(prevFont)
end