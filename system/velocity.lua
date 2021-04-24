local velocitySystem = tiny.processingSystem()
velocitySystem.filter = tiny.requireAll(isPhysical, 'velocity')

function velocitySystem:process(e, dt)
	local scene = getScene()
	local x, y = scene.bump:getRect(e)
	local gx, gy = x + e.velocity.x * dt * e.speed, y + e.velocity.y * dt * e.speed
	local ax, ay = scene.bump:move(e, gx, gy)
	if ax ~= gx then e.velocity.x = 0 end
	if ay ~= gy then e.velocity.y = 0 end
end

return velocitySystem
