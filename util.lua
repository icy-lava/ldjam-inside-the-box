local util = {}

function util.getScene(n)
	n = n or 1
	return manager._scenes[#manager._scenes - n + 1]
end

function util.isPhysical(s, e)
	local scene = util.getScene()
	return scene.bump:hasItem(e)
end

function util.hasInput(s, e)
	return e.move and (e.move.x ~= 0 or e.move.y ~= 0)
end

function util.positionToTile(x, y)
	local scene = util.getScene()
	return math.floor(x / scene.level.tilewidth), math.floor(y / scene.level.tileheight)
end

function util.rectToTile(x, y, w, h)
	return util.positionToTile(x + w / 2, y + h / 2)
end

function util.tileToPosition(x, y)
	local scene = util.getScene()
	return x * scene.level.tilewidth, y * scene.level.tileheight
end

function util.tileToRect(x, y)
	local scene = util.getScene()
	local tw, th = scene.level.tilewidth, scene.level.tileheight
	return x * tw + epsilon, y * th + epsilon, tw - epsilon * 2, th - epsilon * 2
end

function util.snapRectToTile(x, y, w, h)
	return tileToRect(rectToTile(x, y, w or (util.getScene().level.tilewidth - epsilon * 2), h or (util.getScene().level.tileheight - epsilon * 2)))
end

function util.pushLevel(l)
	levelStack[#levelStack + 1] = l
	manager:enter(require 'scene.game')
end

function util.popLevel()
	levelStack[#levelStack] = nil
	manager:enter(require 'scene.game')
end

local _map = {[0] = 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 'a', 'b', 'c', 'd', 'e', 'f'}
local map = {}
for i = 0, 15 do
	map[tostring(_map[i])] = i
end
function util.codeToColor(colorCode)
	colorCode = colorCode:lower():gsub('^#', '')
	local color = {}
	local parsed = false
	for value in colorCode:gmatch('%w%w') do
		table.insert(color, (map[value:sub(1, 1)] * 16 + map[value:sub(2, 2)]) / 255)
		parsed = true
	end
	if not parsed then return nil, 'could not parse color code' end
	color[4] = color[4] or 1
	return color
end

local maxFonts = 10
local fonts = {}
function util.getFont(path, size)
	size = math.floor(size + 0.5)
	for i = 1, #fonts do
		if fonts[i][1] == path and fonts[i][2] == size then return fonts[i][3] end
	end
	table.insert(fonts, 1, {path, size, love.graphics.newFont(path, size)})
	while fonts[maxFonts + 1] do table.remove(fonts, maxFonts + 1) end
	return fonts[#fonts][3]
end

function util.export()
	for k, v in pairs(util) do
		_G[k] = v
	end
end

return util