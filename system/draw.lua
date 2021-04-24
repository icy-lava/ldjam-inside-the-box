local drawSystem = tiny.sortedProcessingSystem()
drawSystem.filter = tiny.requireAll(isPhysical)

function drawSystem:compare(a, b) return (a.z or 9999) < (b.z or 9999) end
function drawSystem:process(e, dt)
	local scene = getScene()
	local x, y, w, h = scene.bump:getRect(e)
	love.graphics.rectangle('line', x, y, w, h)
end

return drawSystem
