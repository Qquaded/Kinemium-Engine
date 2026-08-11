local dll = "./vendor/"
local ffi = zune.ffi
local platform = zune.platform

local zembed = require("@zembed")
if zembed.IsEmbedded() then
	dll = zembed.ExecutableDir()
end

local structs = require("./structs")
local funcs = require("./funcs")

local libname = "JoltWrapper." .. ffi.suffix

local joltPath = zembed.IsEmbedded() and zune.fs.path.join(dll, libname) or (dll .. libname)
local jolt: typeof(funcs) = ffi.dlopen(joltPath, funcs)

return {
	lib = jolt,
	structs = structs,
}
