return function (e)
	local scene = getEntityScene(e)
	local t = getLevelTween(scene)
	
	local x, y, w, h = scene.bump:getRect(e)
	local color = properties.color.level_end
	love.graphics.setColor(color[1], color[2], color[3], 1 - t)
	love.graphics.rectangle('fill', x, y, w, h, 4 * (1 - t), nil, 100)
	
	local prevFont = love.graphics.getFont()
	
	local scale
	if getLevelTween(scene) > 0 then
		scale = getLevelZoom(scene, 1, 1)
	elseif getExitTween(scene) > 0 then
		scale = getLevelZoom(scene, 2, 2)
	else
		scale = getLevelZoom(scene)
	end
	
	scale = scale / getTransitionMultiplier(scene)
	
	local fontSize = math.floor(properties.font.size * scale + 0.5)
	local font = getFont(properties.font.main, fontSize)
	love.graphics.setFont(font)
	
	local text = getLevelLabel(e.level)
	local tw, th = font:getWidth(text), font:getHeight()
	
	love.graphics.push()
	love.graphics.translate(math.floor((x + w / 2) * scale + 0.5) / scale, math.floor((y + h / 2) * scale + 0.5) / scale)
	love.graphics.scale(1 / scale)
	love.graphics.translate(-tw / 2, -th / 2)
	
	local color2 = properties.color.level_label
	love.graphics.setColor(color2[1], color2[2], color2[3], 1 - t * t * t)
	love.graphics.print(text)
	
	love.graphics.pop()
	love.graphics.setColor(1, 1, 1, 1)
	
	love.graphics.setFont(prevFont)
end