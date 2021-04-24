return function()
	local targetSystem = tiny.processingSystem()
	targetSystem.nocache = true
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
		assert(mx ~= 0 or my ~= 0)
		local nx, ny
		if     mx > 0 then -- right
			nx, ny = scene.level.width, ty
		elseif mx < 0 then -- left
			nx, ny = -1, ty
		elseif my > 0 then -- down
			nx, ny = tx, scene.level.height
		elseif my < 0 then -- up
			nx, ny = tx, -1
		end
		local other
		local syst = lume.match(scene.tiny.systems, function(s) return s.physical end)
		for _, o in ipairs(syst.entities) do
			local ox, oy = rectToTile(scene.bump:getRect(o))
			if     mx > 0 then -- right
				if ox > tx and oy == ty and (ox - tx < nx - tx) then
					nx, ny = ox, oy
					other = o
				end
			elseif mx < 0 then -- left
				if ox < tx and oy == ty and (ox - tx > nx - tx) then
					nx, ny = ox, oy
					other = o
				end
			elseif my > 0 then -- down
				if oy > ty and ox == tx and (oy - ty < ny - ty) then
					nx, ny = ox, oy
					other = o
				end
			elseif my < 0 then -- up
				if oy < ty and ox == tx and (oy - ty > ny - ty) then
					nx, ny = ox, oy
					other = o
				end
			end
		end
		
		if other then
			if other.redirector then
				e.redirect = vector(unpack(properties.direction_mapping[other.direction], 1, 2))
			end
		end
		
		if tx ~= nx or ty ~= ny then
			local position = {tx, ty}
			local dist = math.max(math.abs(tx - nx), math.abs(ty - ny))
			e.tween = scene.tween:to(position, 0.1 * math.sqrt(dist), {nx, ny})
			:onupdate(function()
				local x, y = tileToRect(position[1], position[2])
				scene.bump:move(e, x, y, function(e, o)
					return 'cross'
				end)
			end)
			:oncomplete(function()
				if other and other.level then
					scene.newLevel = other.level
				end
				if not other then
					scene.newLevel = "pop"
				end
				e.tween = nil
				scene.tiny:addEntity(e)
			end)
			:ease('quadin')
			scene.tiny:addEntity(e)
		end
	end

	return targetSystem
end