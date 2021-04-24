local _map = {[0] = 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 'a', 'b', 'c', 'd', 'e', 'f'}
local map = {}
for i = 0, 15 do
	map[tostring(_map[i])] = i
end

local function codeToColor(colorCode)
	colorCode = colorCode:lower():gsub('^#', '')
    local color = {}
    for value in colorCode:gmatch('%w%w') do
        table.insert(color, (map[value:sub(1, 1)] * 16 + map[value:sub(2, 2)]) / 255)
    end
	color[4] = color[4] or 1
	return color
end

local palette = {}

palette.good = codeToColor '#0000ff'
palette.planet_good = codeToColor '#000080'
palette.evil = codeToColor '#ff0000'
palette.planet_evil = codeToColor '#800000'
palette.neutral = codeToColor '#808080'
palette.planet_neutral = codeToColor '#404040'
palette.selection = codeToColor '#aaaaff80'
palette.selected = codeToColor '#aaaaff'

return palette