return function()
	local drawSystem = tiny.sortedProcessingSystem()
	drawSystem.draw = true
	drawSystem.filter = tiny.requireAll(isPhysical)

	function drawSystem:compare(a, b) return (a.z or 9999) > (b.z or 9999) end
	function drawSystem:process(e, dt)
		if e.draw then
			if type(e.draw) == 'function' then
				e:draw()
			end
		else
			love.graphics.setColor(1, 1, 1, 1)
			local x, y, w, h = getScene().bump:getRect(e)
			love.graphics.rectangle('line', x, y, w, h)
		end
	end

	return drawSystem
end