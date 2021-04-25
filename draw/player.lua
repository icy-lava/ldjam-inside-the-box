return function (e)
	local scene = getEntityScene(e)
	local t = getLevelTween(scene)
	if t <= 0 then
		t = getExitTween(scene)
		love.graphics.setColor(lerpColorLab(t * t * t, properties.color.player, properties.color.energy))
		local x, y, w, h = scene.bump:getRect(e)
		love.graphics.push()
		love.graphics.translate(x + w / 2, y + h / 2)
		love.graphics.scale(1 - t * 0.6)
		love.graphics.rectangle('fill', 0 - w / 2, 0 - h / 2, w, h, 4, nil, 50)
		love.graphics.pop()
	end
end