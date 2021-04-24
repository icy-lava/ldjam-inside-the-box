local accelerationSystem = tiny.processingSystem()
accelerationSystem.filter = tiny.requireAll('velocity')

function accelerationSystem:process(e, dt)
	-- e.velocity.x, e.velocity.y = 0, 0
	if e.move and e.speed then
		if e.move.x ~= 0 or e.move.y ~= 0 or true then
			local dtt = math.min(1, dt * 15)
			e.velocity.x, e.velocity.y = e.velocity.x * (1 - dtt) + e.move.x * dtt, e.velocity.y * (1 - dtt) + e.move.y * dtt
		else
			
		end
	end
end

return accelerationSystem
