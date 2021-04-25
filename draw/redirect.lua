local directionMap = {
	right = 0,
	up = math.pi / 2,
	left = math.pi,
	down = math.pi * 3 / 4,
}
return function (e)
	love.graphics.setColor(properties.color.level_end)
	local x, y, w, h = getEntityScene(e).bump:getRect(e)
	local lineWidth = love.graphics.getLineWidth()
	love.graphics.setLineWidth(8)
	love.graphics.push()
	love.graphics.translate(x + w * 0.5, y + h * 0.5)
	love.graphics.rotate(-directionMap[e.direction])
	love.graphics.scale(0.75)
	love.graphics.translate(-0.5 * w, -0.5 * h)
	love.graphics.line(0, 0, 0.5 * w, 0.5 * h, 0, 1 * h)
	love.graphics.line(0.5 * w, 0, 1 * w, 0.5 * h, 0.5 * w, 1 * h)
	love.graphics.pop()
	love.graphics.setLineWidth(lineWidth)
end