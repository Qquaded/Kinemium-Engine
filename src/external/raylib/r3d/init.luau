--!strict
--!optimize 2

if _G.IsHeadless == true then
	local function noop()
		return 0
	end

	local mockStruct = {
		new = function()
			return buffer.create(0)
		end,
		offset = function()
			return 0
		end,
		size = function()
			return 0
		end,
	}

	return {
		lib = setmetatable({}, {
			__index = function()
				return noop
			end,
		}),
		structs = setmetatable({}, {
			__index = function()
				return mockStruct
			end,
		}),
		constants = setmetatable({}, {
			__index = function()
				return 0
			end,
		}),
	}
end

local dll = "./src/external/raylib/native/bin/"
local zembed = require("@zembed")
if zembed.IsEmbedded() then
	dll = zembed.ExecutableDir()
end
local ffi = zune.ffi

local structs = require("./r3d/structs")
local funcs = require("./r3d/funcs")
local constants = require("./r3d/constants")

local libname = "r3d." .. ffi.suffix
local assimpname = "assimp-vc145-mt." .. ffi.suffix
if zune.platform.os ~= "windows" then
	assimpname = "assimp-vc143-mt." .. ffi.suffix
end
local raylibname = "raylib." .. ffi.suffix

local asmpPath = zembed.IsEmbedded() and zune.fs.path.join(dll, assimpname) or (dll .. assimpname)
local raylibPath = zembed.IsEmbedded() and zune.fs.path.join(dll, raylibname) or (dll .. raylibname)
local r3dPath = zembed.IsEmbedded() and zune.fs.path.join(dll, libname) or (dll .. libname)

local stat = zune.fs.stat(asmpPath)

if stat.kind == "none" then
	print("Did not find assimp LIB, Listing all files in searching directory")
	local entries = zune.fs.entries(dll)
	print(entries)
	return {}
end

ffi.dlopen(asmpPath, {})
ffi.dlopen(raylibPath, {})

print(r3dPath)
local r3d: typeof(funcs) = ffi.dlopen(r3dPath, funcs)

return {
	lib = r3d,
	structs = structs,
	constants = constants,
}
