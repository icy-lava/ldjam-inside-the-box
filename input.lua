local input = {}

function input.isAction(action)
	return love.keyboard.isDown(unpack((assert(properties.keyboard[action], 'action ' .. action .. ' is not defined'))))
end

function input.getDirection()
	local x, y = (input.isAction 'right' and 1 or 0) - (input.isAction 'left' and 1 or 0), (input.isAction 'down' and 1 or 0) - (input.isAction 'up' and 1 or 0)
	local length = math.sqrt(x * x + y * y)
	if length == 0 then length = 1 end
	return x / length, y / length
end

return input