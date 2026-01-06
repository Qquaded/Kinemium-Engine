local ffi = zune.ffi

local info = require("./r3dfuncs")
local zembed = require("@zembed")

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

local dir = getPath("src/external/raylib/native")

-- Preload dependencies first
if platform == "windows" then
	local s, r = pcall(function()
		if zembed.IsEmbedded() then
			ffi.dlopen("./raylib." .. fileFormat, {})
			ffi.dlopen("./assimp-vc143-mt." .. fileFormat, {})
		else
			ffi.dlopen(dir .. "/bin/raylib." .. fileFormat, {})
			ffi.dlopen(dir .. "/bin/assimp-vc143-mt." .. fileFormat, {})
		end
	end)
	warn(s, r)
end

local result = dir .. "/bin/r3d." .. fileFormat
if zembed.IsEmbedded() then
	result = "./r3d." .. fileFormat
end

local r3d: typeof(info.funcs) = ffi.dlopen(result, info.funcs)

return {
	lib = r3d,
	structs = info.structs,
}
