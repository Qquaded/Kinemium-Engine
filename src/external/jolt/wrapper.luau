local dll = "./vendor/"
local ffi = zune.ffi
local platform = zune.platform

local zembed = require("@zembed")
if zembed.IsEmbedded() then
	dll = zembed.ExecutableDir()
end

local structs = require("./structs")
local funcs = require("./funcs")

ffi.dlopen(dll .. `Jolt.{ffi.suffix}`, {})

local libname = "joltc_double." .. ffi.suffix

local joltPath = zembed.IsEmbedded() and zune.fs.path.join(dll, libname) or (dll .. libname)
print(joltPath)
local jolt: typeof(funcs) = ffi.dlopen(joltPath, funcs)

return {
	lib = jolt,
	structs = structs,
}
