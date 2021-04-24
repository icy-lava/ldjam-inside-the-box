local drawSystem = tiny.sortedProcessingSystem()
drawSystem.filter = tiny.requireAll(isPhysical)

local order = lume.invert {'planet', 'ship'}
function drawSystem:compare(a, b) return (order[a.type] or 9999) < (order[b.type] or 9999) end

function drawSystem:process(e, dt)
	local scene = getScene()
	local x, y, w, h = scene.bump:getRect(e)
	love.graphics.rectangle('line', x, y, w, h)
end

return drawSystem
