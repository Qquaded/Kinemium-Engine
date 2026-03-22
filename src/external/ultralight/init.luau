--!strict
--!optimize 2
-- Made by FFIGen (Kinemium)

local dll = "./src/external/ultralight/bin/"
local ffi = zune.ffi
local platform = zune.platform

local structs = require("./ultralight/structs")
local funcs = require("./ultralight/funcs")
local constants = require("./ultralight/constants")

ffi.dlopen(dll .. "UltralightCore." .. ffi.suffix, {})

local webCore = ffi.dlopen(dll .. "WebCore." .. ffi.suffix, {
	JSContextGetGlobalObject = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	JSObjectSetProperty = {
		returns = ffi.types.void,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.u32,
			ffi.types.pointer,
		},
	},
	JSObjectMakeFunctionWithCallback = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JSStringCreateWithUTF8CString = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	JSStringRelease = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JSValueMakeString = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	JSValueMakeUndefined = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	JSValueMakeNull = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	JSValueIsString = { returns = ffi.types.u8, args = { ffi.types.pointer, ffi.types.pointer } },
	JSValueToStringCopy = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JSStringGetUTF8CString = {
		returns = ffi.types.u64,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u64 },
	},
	JSStringGetMaximumUTF8CStringSize = { returns = ffi.types.u64, args = { ffi.types.pointer } },
	JSObjectMakeArray = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.u64, ffi.types.pointer, ffi.types.pointer },
	},
	JSObjectMake = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer } },
	JSObjectSetPropertyAtIndex = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u32, ffi.types.pointer, ffi.types.pointer },
	},
})

local ultralight: funcs.Fns = ffi.dlopen(dll .. "Ultralight." .. ffi.suffix, funcs)

return {
	lib = ultralight,
	structs = structs,
	constants = constants,
	WebCore = webCore,
	AppCore = require("./ultralight/appcore"),
}
