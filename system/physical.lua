return function()
	return tiny.system {
		filter = tiny.requireAll(isPhysical),
		physical = true
	}
end