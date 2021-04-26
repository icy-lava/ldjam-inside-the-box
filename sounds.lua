sound = {}
sound.music = love.audio.newSource('asset/audio/music.ogg', 'stream')
sound.music:setVolume(0.6)
sound.music:setLooping(true)

local soundDir = 'asset/audio/sfx'
for _, f in ipairs(love.filesystem.getDirectoryItems(soundDir)) do
	local name = f:gsub('%.[^%.]+$', '', 1)
	sound[name] = love.audio.newSource(soundDir .. '/' .. f, 'static')
	sound[name]:setVolume(properties.sound[name].volume or 0.5)
end