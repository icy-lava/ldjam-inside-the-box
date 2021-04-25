return function (e)
	local scene = getEntityScene(e)
	local t = getLevelTween(scene)
	
	if isPopScene(scene) then
		t = 1 - getLevelTween(scene.from)
	end
	
	local x, y, w, h = scene.bump:getRect(e)
	local color = properties.color.level_end
	love.graphics.setColor(color[1], color[2], color[3], 1 - t)
	love.graphics.push()
	love.graphics.translate(x + w / 2, y + h / 2)
	love.graphics.scale(0.9 + t * 0.1)
	love.graphics.rectangle('fill', 0 - w / 2, 0 - h / 2, w, h, 4, nil, 50)
	love.graphics.pop()
	
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
	love.graphics.setColor(colorAlpha(lerpColorLab(t, color2, properties.color.background_label), 1 - t))
	love.graphics.print(text)
	
	love.graphics.pop()
	love.graphics.setColor(1, 1, 1, 1)
	
	love.graphics.setFont(prevFont)
end