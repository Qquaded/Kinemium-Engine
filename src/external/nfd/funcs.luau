local ffi = zune.ffi

-- Type aliases for FFI
type int = number
type float = number
type bool = boolean
type cstring = string
type FFIPointer = typeof(ffi.types.pointer)

-- Import struct types
local structs = require("./structs")
type nfdnfilteritem_t = structs.nfdnfilteritem_t
type nfdopendialognargs_t = structs.nfdopendialognargs_t
type nfdopendialogu8args_t = structs.nfdopendialogu8args_t
type nfdpathsetenum_t = structs.nfdpathsetenum_t
type nfdpickfoldernargs_t = structs.nfdpickfoldernargs_t
type nfdpickfolderu8args_t = structs.nfdpickfolderu8args_t
type nfdsavedialognargs_t = structs.nfdsavedialognargs_t
type nfdsavedialogu8args_t = structs.nfdsavedialogu8args_t
type nfdu8filteritem_t = structs.nfdu8filteritem_t
type nfdwindowhandle_t = structs.nfdwindowhandle_t

export type Fns = {
	NFD_ClearError: () -> (),
	NFD_FreePathN: (filePath: FFIPointer) -> (),
	NFD_FreePathU8: (filePath: FFIPointer) -> (),
	NFD_GetError: () -> cstring,
	NFD_Init: () -> FFIPointer,
	NFD_OpenDialogMultipleN: (
		outPaths: FFIPointer,
		filterList: FFIPointer,
		filterCount: FFIPointer,
		defaultPath: FFIPointer
	) -> FFIPointer,
	NFD_OpenDialogMultipleN_With_Impl: (arg: FFIPointer, arg: FFIPointer, arg: FFIPointer) -> FFIPointer,
	NFD_OpenDialogMultipleU8: (
		outPaths: FFIPointer,
		filterList: FFIPointer,
		filterCount: FFIPointer,
		defaultPath: FFIPointer
	) -> FFIPointer,
	NFD_OpenDialogMultipleU8_With_Impl: (arg: FFIPointer, arg: FFIPointer, arg: FFIPointer) -> FFIPointer,
	NFD_OpenDialogN: (
		outPath: FFIPointer,
		filterList: FFIPointer,
		filterCount: FFIPointer,
		defaultPath: FFIPointer
	) -> FFIPointer,
	NFD_OpenDialogN_With_Impl: (arg: FFIPointer, arg: FFIPointer, arg: FFIPointer) -> FFIPointer,
	NFD_OpenDialogU8: (
		outPath: FFIPointer,
		filterList: FFIPointer,
		filterCount: FFIPointer,
		defaultPath: FFIPointer
	) -> FFIPointer,
	NFD_OpenDialogU8_With_Impl: (arg: FFIPointer, arg: FFIPointer, arg: FFIPointer) -> FFIPointer,
	NFD_PathSet_EnumNextN: (enumerator: FFIPointer, outPath: FFIPointer) -> FFIPointer,
	NFD_PathSet_EnumNextU8: (enumerator: FFIPointer, outPath: FFIPointer) -> FFIPointer,
	NFD_PathSet_Free: (pathSet: FFIPointer) -> (),
	NFD_PathSet_FreeEnum: (enumerator: FFIPointer) -> (),
	NFD_PathSet_FreePathN: (filePath: FFIPointer) -> (),
	NFD_PathSet_FreePathU8: (filePath: FFIPointer) -> (),
	NFD_PathSet_GetCount: (pathSet: FFIPointer, count: FFIPointer) -> FFIPointer,
	NFD_PathSet_GetEnum: (pathSet: FFIPointer, outEnumerator: FFIPointer) -> FFIPointer,
	NFD_PathSet_GetPathN: (pathSet: FFIPointer, index: FFIPointer, outPath: FFIPointer) -> FFIPointer,
	NFD_PathSet_GetPathU8: (pathSet: FFIPointer, index: FFIPointer, outPath: FFIPointer) -> FFIPointer,
	NFD_PickFolderMultipleN: (outPaths: FFIPointer, defaultPath: FFIPointer) -> FFIPointer,
	NFD_PickFolderMultipleN_With_Impl: (arg: FFIPointer, arg: FFIPointer, arg: FFIPointer) -> FFIPointer,
	NFD_PickFolderMultipleU8: (outPaths: FFIPointer, defaultPath: FFIPointer) -> FFIPointer,
	NFD_PickFolderMultipleU8_With_Impl: (arg: FFIPointer, arg: FFIPointer, arg: FFIPointer) -> FFIPointer,
	NFD_PickFolderN: (outPath: FFIPointer, defaultPath: FFIPointer) -> FFIPointer,
	NFD_PickFolderN_With_Impl: (arg: FFIPointer, arg: FFIPointer, arg: FFIPointer) -> FFIPointer,
	NFD_PickFolderU8: (outPath: FFIPointer, defaultPath: FFIPointer) -> FFIPointer,
	NFD_PickFolderU8_With_Impl: (arg: FFIPointer, arg: FFIPointer, arg: FFIPointer) -> FFIPointer,
	NFD_Quit: () -> (),
	NFD_SaveDialogN: (
		outPath: FFIPointer,
		filterList: FFIPointer,
		filterCount: FFIPointer,
		defaultPath: FFIPointer,
		defaultName: FFIPointer
	) -> FFIPointer,
	NFD_SaveDialogN_With_Impl: (arg: FFIPointer, arg: FFIPointer, arg: FFIPointer) -> FFIPointer,
	NFD_SaveDialogU8: (
		outPath: FFIPointer,
		filterList: FFIPointer,
		filterCount: FFIPointer,
		defaultPath: FFIPointer,
		defaultName: FFIPointer
	) -> FFIPointer,
	NFD_SaveDialogU8_With_Impl: (arg: FFIPointer, arg: FFIPointer, arg: FFIPointer) -> FFIPointer,
}

local funcs = {
	NFD_FreePathN = { returns = ffi.types.void, args = { ffi.types.pointer } },
	NFD_FreePathU8 = { returns = ffi.types.void, args = { ffi.types.pointer } },
	NFD_Init = { returns = ffi.types.i32, args = {} },
	NFD_Quit = { returns = ffi.types.void, args = {} },
	NFD_OpenDialogN = {
		returns = ffi.types.pointer,
		args = {
			ffi.types.pointer, -- nfdnchar_t**
			ffi.types.pointer, -- filter list
			ffi.types.u32, -- filterCount
			ffi.types.pointer, -- defaultPath
		},
	},
	NFD_OpenDialogU8 = {
		returns = ffi.types.i32,
		args = {
			ffi.types.pointer, -- nfdu8char_t**
			ffi.types.pointer, -- filter list
			ffi.types.u32, -- filterCount
			ffi.types.pointer, -- defaultPath
		},
	},
	NFD_OpenDialogN_With_Impl = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	NFD_OpenDialogU8_With_Impl = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	NFD_OpenDialogMultipleN = {
		returns = ffi.types.pointer,
		args = {
			ffi.types.pointer, -- nfdpathset_t**
			ffi.types.pointer, -- filter list
			ffi.types.u32, -- filterCount
			ffi.types.pointer, -- defaultPath
		},
	},
	NFD_OpenDialogMultipleU8 = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	NFD_OpenDialogMultipleN_With_Impl = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	NFD_OpenDialogMultipleU8_With_Impl = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	NFD_SaveDialogN = {
		returns = ffi.types.pointer,
		args = {
			ffi.types.pointer, -- nfdnchar_t**
			ffi.types.pointer, -- filter list
			ffi.types.u32, -- filterCount
			ffi.types.pointer, -- defaultPath
			ffi.types.pointer, -- defaultName
		},
	},
	NFD_SaveDialogU8 = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	NFD_SaveDialogN_With_Impl = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	NFD_SaveDialogU8_With_Impl = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	NFD_PickFolderN = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	NFD_PickFolderU8 = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	NFD_PickFolderN_With_Impl = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	NFD_PickFolderU8_With_Impl = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	NFD_PickFolderMultipleN = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	NFD_PickFolderMultipleU8 = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	NFD_PickFolderMultipleN_With_Impl = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	NFD_PickFolderMultipleU8_With_Impl = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	NFD_GetError = { returns = ffi.types.pointer, args = {} },
	NFD_ClearError = { returns = ffi.types.void, args = {} },
	NFD_PathSet_GetCount = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	NFD_PathSet_GetPathN = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	NFD_PathSet_GetPathU8 = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	NFD_PathSet_FreePathN = { returns = ffi.types.void, args = { ffi.types.pointer } },
	NFD_PathSet_FreePathU8 = { returns = ffi.types.void, args = { ffi.types.pointer } },
	NFD_PathSet_GetEnum = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	NFD_PathSet_FreeEnum = { returns = ffi.types.void, args = { ffi.types.pointer } },
	NFD_PathSet_EnumNextN = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	NFD_PathSet_EnumNextU8 = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	NFD_PathSet_Free = { returns = ffi.types.void, args = { ffi.types.pointer } },
}

return funcs
