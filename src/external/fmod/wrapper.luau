local bin = "./src/external/fmod/bin/"
local ffi = zune.ffi
local platform = zune.platform

local zembed = require("@zembed")
if zembed.IsEmbedded() then
	bin = "./"
end

local libname
if platform.os == "windows" then
	libname = ".dll"
elseif platform.os == "linux" then
	libname = ".so"
elseif platform.os == "macos" then
	libname = ".dylib"
end

local function constructPath(file)
	return bin .. file .. libname
end

local fmod_bindings = require("./fmod")
local fmod: typeof(fmod_bindings.funcs) = ffi.dlopen(constructPath("fmod"), fmod_bindings.funcs)

local studio_bindings = require("./studio")
local studio: typeof(studio_bindings.funcs) = ffi.dlopen(constructPath("fmodstudio"), studio_bindings.funcs)

local fsbank_bindings = require("./fsbank")
local fsbank: typeof(fsbank_bindings.funcs) = ffi.dlopen(constructPath("fsbank"), fsbank_bindings.funcs)

return {
	fmod = fmod,
	fsbank = fsbank,
	studio = studio,
}
