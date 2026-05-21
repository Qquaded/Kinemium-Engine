local kinec = require("@kinec")
local ffi = zune.ffi

local int = ffi.types.i32

return function(luaENV)
	kinec.func("get_service", int, { ffi.types.pointer }, function(pointer)
		iodebug("Got call from C!", pointer)
		return 42
	end)
	kinec.func("log", ffi.types.void, { ffi.types.pointer }, function(pointer)
		iodebug("Got log call from C!", pointer)
		return
	end)
	return kinec
end
