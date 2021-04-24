local inputSystem = tiny.processingSystem()
inputSystem.filter = tiny.requireAll('input', 'move')
local input = require 'input'

function inputSystem:process(e, dt)
	local pmx, pmy = e.move.x, e.move.y
	e.move.x, e.move.y = input.getDirection()
	if pmx ~= e.move.x or pmy ~= e.move.y then getScene().tiny:addEntity(e) end
end

return inputSystem
