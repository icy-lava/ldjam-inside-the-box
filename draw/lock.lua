return function (e)
	local scene = getEntityScene(e)
	local x, y, w, h = scene.bump:getRect(e)
	local lineWidth = love.graphics.getLineWidth()
	love.graphics.setLineWidth(5)
	love.graphics.push()
	love.graphics.translate(x + w / 2, y + h / 2)
	-- love.graphics.scale(1.2)
	-- love.graphics.scale(1 - t * 0.6)
	-- love.graphics.rectangle('fill', 0 - w / 2, 0 - h / 2, w, h, 4, nil, 50)
	-- love.graphics.circle('line', 0, 0, w / 2 / 4, 50)
	-- love.graphics.line(w / 2 / 4, 0, w / 2 / 4 * 4, 0)
	love.graphics.setColor(colorAlpha(properties.color.player, 0.3))
	love.graphics.rectangle('fill', -w / 9 * 4, -h / 9 * 4, w / 9 * 8, h / 9 * 8, 4, nil, 50)
	love.graphics.push()
	love.graphics.translate(0, -h / 16)
	love.graphics.setColor(colorAlpha(properties.color.player, 1))
	love.graphics.rectangle('fill', -w / 4, 0, w / 2, w / 3, 2)
	local r = w / 8
	local points = {-r, 0}
	local maxPoints = 50
	for i = 0, maxPoints do
		points[i * 2 + 3], points[i * 2 + 4] = -math.cos(i / maxPoints * math.pi) * r, -math.sin(i / maxPoints * math.pi) * r - r / 2
	end
	lume.push(points, r, 0)
	love.graphics.line(points)
	love.graphics.setColor(colorAlpha(properties.color.background, 1))
	love.graphics.circle('fill', 0, h / 8, 4, 50)
	love.graphics.rectangle('fill', -h / 32, h / 8, h / 16, h / 8)
	love.graphics.pop()
	love.graphics.pop()
	love.graphics.setLineWidth(lineWidth)
end