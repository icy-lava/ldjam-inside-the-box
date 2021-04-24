if love then
	local fs = require 'love.filesystem'
	fs.setRequirePath('lib/?/init.lua;lib/?.lua;' .. fs.getRequirePath())
else
	package.path = '?/init.lua;lib/?/init.lua;lib/?.lua;' .. package.path
end
