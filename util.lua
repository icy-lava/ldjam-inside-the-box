local util = {}

function util.getScene(n)
	n = n or 1
	return manager._scenes[#manager._scenes - n + 1]
end

function util.isPhysical(s, e)
	local scene = util.getEntityScene(e)
	return scene.bump:hasItem(e)
end

function util.hasInput(s, e)
	return e.move and (e.move.x ~= 0 or e.move.y ~= 0)
end

function util.positionToTile(x, y)
	local scene = util.getScene() -- TODO: technically a bug but shouldn't manifest since tile sizes are the same for all levels
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

local scenes = setmetatable({}, {__mode = 'k'})
function util.newScene(scene)
	local s = require(scene)()
	scenes[s] = true
	return s
end

function util.getEntityScene(entity)
	for scene in pairs(scenes) do
		for _, e in ipairs((scene.tiny or util.empty).entities or util.empty) do
			if e == entity then return scene end
		end
	end
end

function util.pushLevel(l)
	levelStack[#levelStack + 1] = l
	manager:enter(util.newScene('scene.game'), l)
end

function util.popLevel()
	levelStack[#levelStack] = nil
	manager:enter(util.newScene('scene.game'), levelStack[#levelStack])
end

function util.colorAlpha(color, alpha)
	return {color[1], color[2], color[3], alpha}
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
	while fonts[maxFonts + 1] do
		fonts[maxFonts + 1][3]:release()
		table.remove(fonts, maxFonts + 1)
	end
	return fonts[1][3]
end

function util.getTransitionMultiplier(scene)
	local div = 1
	if scene.transitionTween then div = 2 - scene.transitionTween.value end
	return 1 / div
end

function util.getLevelZoom(scene, w, h)
	local ww, wh = love.graphics.getDimensions()
	-- local vw, vh = unpack(properties.window.virtual_size, 1, 2)
	w = w or scene.level.width
	h = h or scene.level.height
	-- return ww / vw * vw / scene.level.tilewidth  / fw, wh / vh * vh / scene.level.tileheight / fh
	return math.min(ww / scene.level.tilewidth / w, wh / scene.level.tileheight / h) * util.getTransitionMultiplier(scene)
end

function util.updateCamera(scene)
	local t, x, y = util.getExitTween(scene)
	local tw = getLevelTween(scene)
	local fw, fh = scene.level.width  * (1 - t) + 2 * t, scene.level.height * (1 - t) + 2 * t
	fw, fh = fw * (1 - tw) + 1 * tw, fh * (1 - tw) + 1 * tw
	scene.camera:zoomTo(util.getLevelZoom(scene, fw, fh))
	
	scene.camera:lookAt(
		scene.level.tilewidth  * (scene.level.width  / 2 * (1 - t) + x * t),
		scene.level.tileheight * (scene.level.height / 2 * (1 - t) + y * t)
	)
end

function util.getPlayer(scene)
	return (scene or getScene()).player
end

function util.getExitTween(scene)
	local transition = (getPlayer(scene).finishLevel or empty)
	return transition.value or 0, (transition.x or 0) + 0.5, (transition.y or 0) + 0.5
end

function util.getLevelTween(scene)
	return (((scene or getScene()).newLevelTween or empty).value or 0)
end

function util.lerpColor(v, c1, c2)
	return {c1[1] * (1 - v) + c2[1] * v, c1[2] * (1 - v) + c2[2] * v, c1[3] * (1 - v) + c2[3] * v, (c1[4] or 1) * (1 - v) + (c2[4] or 1) * v}
end

function util.lerpColorLab(v, c1, c2)
	return {vivid.LabtoRGB(util.lerpColor(v, {vivid.RGBtoLab(c1)}, {vivid.RGBtoLab(c2)}))}
end

function util.getCurrentLevel(scene)
	return (scene or getScene()).level.id
end

function util.getLevelLabel(l)
	return '#' .. (l or getCurrentLevel())
end

util.empty = {}

function util.export()
	for k, v in pairs(util) do
		_G[k] = v
	end
end

return util