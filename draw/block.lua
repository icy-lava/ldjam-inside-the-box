local sizing = 0.9
return function (e)
	local scene = getEntityScene(e)
	love.graphics.setColor(colorAlpha(properties.color.block, 0.5))
	local x, y, w, h = scene.bump:getRect(e)
	-- love.graphics.rectangle('fill', x, y, w, h, 4, nil, 50)
	local tw, th = scene.level.tilewidth, scene.level.tileheight
	local hc, vc = 2, 2
	local mc = math.max(hc, vc)
	for dy = 1, vc do
		for dx = 1, hc do
			love.graphics.rectangle(
				'fill',
				x + w * (dx - 1 + (1 - sizing) / 2) / hc, y + h * (dy - 1 + (1 - sizing) / 2) / vc,
				tw / mc * sizing,
				th / mc * sizing,
				4, nil, 50
			)
		end
	end
end