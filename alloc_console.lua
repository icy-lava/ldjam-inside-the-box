if jit.os ~= 'Windows' then return function() end end

local ffi = require 'ffi'
local C = ffi.C

ffi.cdef[[
	typedef int BOOL;
	typedef void FILE;
	
	BOOL AllocConsole(void);
	FILE *freopen(const char *path, const char *mode, FILE *stream);
]]

-- https://github.com/love2d/love/blob/c59c85e04ce9bdc0e79c97a15eff55ff336dfee8/src/modules/love/love.cpp#L511
return function()
	log.info 'allocating a new console as per request'
	if C.AllocConsole() ~= 0 then
		if C.freopen("CONOUT$", "w", io.stderr) == 0 then
			log.warn 'could not reopen stderr for new console'
		end
		if C.freopen("CONOUT$", "w", io.stdout) == 0 then
			log.warn 'could not reopen stdout for new console'
		end
		if C.freopen("CONIN$",  "r", io.stdin) == 0 then
			log.warn 'could not reopen stdin for new console'
		end
	else
		local err = 'could not allocate new console, maybe already allocated?'
		log.warn(err)
		return false, err
	end
	log.info 'allocated a new console'
	return true
end
