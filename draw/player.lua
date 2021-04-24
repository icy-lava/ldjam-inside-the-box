return function (e)
	love.graphics.setColor(properties.color.player)
	local x, y, w, h = getScene().bump:getRect(e)
	love.graphics.rectangle('fill', x, y, w, h, 4, nil, 50)
end