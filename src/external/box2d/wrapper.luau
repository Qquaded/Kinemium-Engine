local ffi = zune.ffi

local info = require("./bindings")

local process = zune.process
local platform = zune.platform.os

local function getPath(destination)
	local src = process.cwd() .. "/" .. destination
	src = string.gsub(src, [[\]], "/")
	return src
end

local fileFormat = ffi.suffix

local dir = getPath("src/external/box2d")

local result = "./vendor/box2d." .. fileFormat
local zembed = require("@zembed")
if zembed.IsEmbedded() then
	result = zembed.RuntimePath("box2d." .. fileFormat)
end
print(result)
local box2d: typeof(info.funcs) = ffi.dlopen(result, info.funcs)

return {
	lib = box2d,
	structs = info.structs,
}
