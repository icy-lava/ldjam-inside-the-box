return function (e)
	local scene = getEntityScene(e)
	love.graphics.setColor(properties.color.stop)
	local x, y, w, h = scene.bump:getRect(e)
	-- love.graphics.rectangle('fill', x, y, w, h, 4, nil, 50)
	local hc, vc = 3, 3
	for dy = 1, vc do
		for dx = 1, hc do
			love.graphics.circle('fill', x + w * (dx - 0.5) / hc, y + h * (dy - 0.5) / vc, scene.level.tilewidth / math.max(hc, vc) / 2 * 0.5, 50)
		end
	end
end