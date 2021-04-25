return function()
	local inputSystem = tiny.processingSystem()
	inputSystem.filter = tiny.requireAll('input', 'move')
	local input = require 'input'

	function inputSystem:process(e, dt)
		local scene = getEntityScene(e)
		if not scene.newLevelTween then
			if not e.redirect then
				local pmx, pmy = e.move.x, e.move.y
				e.move.x, e.move.y = input.getDirection()
				if pmx ~= e.move.x or pmy ~= e.move.y then scene.tiny:addEntity(e) end
			else
				e.move.x, e.move.y = e.redirect.x, e.redirect.y
				scene.tiny:addEntity(e)
			end
		end
	end

	return inputSystem
end