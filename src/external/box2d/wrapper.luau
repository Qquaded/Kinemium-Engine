local ffi = zune.ffi

local info = require("./bindings")

local process = zune.process
local platform = zune.platform.os

local function getPath(destination)
	local src = process.cwd() .. "/" .. destination
	src = string.gsub(src, [[\]], "/")
	return src
end

local fileFormat = ""

if platform == "windows" then
	fileFormat = "dll"
elseif platform == "macos" then
	fileFormat = "dylib"
elseif platform == "linux" then
	fileFormat = "so"
end

local dir = getPath("src/external/box2d")

local result = dir .. "/bin/box2d." .. fileFormat
local zembed = require("@zembed")
if zembed.IsEmbedded() then
	result = "./box2d." .. fileFormat
end
local box2d: typeof(info.funcs) = ffi.dlopen(result, info.funcs)

return {
	lib = box2d,
	structs = info.structs,
}
