local targetSystem = tiny.processingSystem()
targetSystem.filter = tiny.requireAll(isPhysical, hasInput, tiny.rejectAll('tween'))

function targetSystem:process(e, dt)
	local scene = getScene()
	
	local tx, ty = rectToTile(scene.bump:getRect(e))
	local mx, my = e.move.x, e.move.y
	if mx ~= 0 then
		my = 0
		mx = lume.sign(mx)
	elseif my ~= 0 then
		my = lume.sign(my)
	end
	local nx, ny = tx, ty
	for _, o in ipairs(require 'system.physical'.entities) do
		local ox, oy = rectToTile(scene.bump:getRect(o))
		if     mx > 0 then -- right
			nx, ny = scene.level.width, ty
			if ox > tx and oy == ty then
				nx, ny = ox - 1, oy
			end
		elseif mx < 0 and oy == ty then -- left
			nx, ny = -1, ty
			if ox < tx then
				nx, ny = ox + 1, oy
			end
		elseif my > 0 and ox == tx then -- down
			nx, ny = tx, scene.level.height
			if oy > ty then
				nx, ny = ox, oy - 1
			end
		elseif my < 0 and ox == tx then -- up
			nx, ny = tx, -1
			if oy < ty then
				nx, ny = ox, oy + 1
			end
		end
	end
	if tx ~= nx or ty ~= ny then
		local position = {tx, ty}
		local dist = math.max(math.abs(tx - nx), math.abs(ty - ny))
		e.tween = scene.tween:to(position, 0.1 * math.sqrt(dist), {nx, ny})
		:onupdate(function()
			local x, y = tileToRect(position[1], position[2])
			scene.bump:move(e, x, y)
		end)
		:oncomplete(function()
			e.tween = nil
			scene.tiny:addEntity(e)
		end)
		:ease('quadin')
		scene.tiny:addEntity(e)
	end
end

return targetSystem
