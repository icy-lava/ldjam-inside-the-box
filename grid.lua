local grid = {}
grid.__index = grid

function grid:new()
	return setmetatable({}, grid)
end

function grid:get(x, y)
	local v = self[x]
	if v then
		v = v[y]
	end
	return v
end

function grid:set(x, y, value)
	if not self[x] then self[x] = {} end
	self[x][y] = value
	return self
end

return grid