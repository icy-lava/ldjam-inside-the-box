local targetSystem = tiny.processingSystem()
targetSystem.filter = tiny.requireAll(isPhysical, hasInput, tiny.rejectAll('tween'))

function targetSystem:process(e, dt)
	local scene = getScene()
	local x, y = scene.bump:getRect(e)
	local mx, my = e.move.x, e.move.y
	if mx ~= 0 then
		my = 0
		mx = lume.sign(mx)
	end
	local position = {x, y}
	local nx, ny = snapRectToTile(x + scene.level.tilewidth * mx, y + scene.level.tileheight * my)
	e.tween = scene.tween:to(position, 0.2, {nx, ny})
	:onupdate(function()
		scene.bump:move(e, position[1], position[2])
	end)
	:oncomplete(function()
		e.tween = nil
		scene.tiny:addEntity(e)
	end)
	scene.tiny:addEntity(e)
end

return targetSystem
