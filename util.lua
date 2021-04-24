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

function util.export()
	for k, v in pairs(util) do
		_G[k] = v
	end
end

return util