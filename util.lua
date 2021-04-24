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

function util.export()
	for k, v in pairs(util) do
		_G[k] = v
	end
end

return util