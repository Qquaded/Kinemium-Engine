local Instance = require("@Instance")
local BufferUtils = require("@bufferutils")
local Enum = require("@EnumMap")

local FileDialogService = Instance.new("FileDialogService")
FileDialogService.ExplorerHidden = true
FileDialogService._Intents = Enum.PluginIntents.Filesystem

local ffi = zune.ffi

FileDialogService.InitRenderer = function(renderer, renderer_signal)
	local nfd = require("@nfd")
	local lib = nfd.lib
	local structs = nfd.structs

	local function stringToOSPtr(str)
		if zune.platform.os ~= "windows" then
			return BufferUtils.stringToPtr(str)
		end

		local utf16 = buffer.create((#str + 1) * 2)
		local i = 0
		for _, code in utf8.codes(str) do
			buffer.writeu16(utf16, i, code)
			i += 2
		end
		buffer.writeu16(utf16, i, 0)
		return ffi.dupe(utf16)
	end

	local function buildFilterList(filters)
		if type(filters) ~= "table" or #filters == 0 then
			return nil, nil
		end

		local items = {}
		for _, filter in ipairs(filters) do
			local name = tostring(filter.name or "Files")
			local exts = filter.extensions or {}
			local parts = {}
			for _, ext in ipairs(exts) do
				ext = tostring(ext or "")
				if ext == "*" or ext == ".*" then
					parts = { "*" }
					break
				end
				if ext:sub(1, 1) == "." then
					ext = ext:sub(2)
				end
				if ext ~= "" then
					table.insert(parts, ext)
				end
			end
			local spec = table.concat(parts, ",")
			if spec ~= "" then
				table.insert(items, { name = name, spec = spec })
			end
		end

		if #items == 0 then
			return nil, nil
		end

		local itemSize = structs.nfdnfilteritem_t:size()
		local itemAlign = structs.nfdnfilteritem_t:alignment()
		local listPtr = ffi.alloc(itemSize * #items, itemAlign)
		for i, item in ipairs(items) do
			local namePtr = stringToOSPtr(item.name)
			local specPtr = stringToOSPtr(item.spec)
			local base = (i - 1) * itemSize
			listPtr:writeptr(base + structs.nfdnfilteritem_t:offset("name"), namePtr)
			listPtr:writeptr(base + structs.nfdnfilteritem_t:offset("spec"), specPtr)
		end

		return listPtr, #items
	end

	lib.NFD_Init()

	FileDialogService:SetProperties({
		RequestFile = function(filters)
			local outPath = ffi.alloc(ffi.types.pointer:size())
			local filterList, filterCount = buildFilterList(filters)
			local success: FFIPointer = lib.NFD_OpenDialogN(outPath, filterList, filterCount or 0, nil)
			local code = BufferUtils:readhexa(success)
			if code == 2 then
				return ""
			end
			return BufferUtils.string.ReadOSBased(outPath)
		end,

		RequestFolder = function(filters)
			local outPath = ffi.alloc(ffi.types.pointer:size())
			local success: FFIPointer = lib.NFD_PickFolderN(outPath, nil)
			local code = BufferUtils:readhexa(success)
			if code == 2 then
				return ""
			end
			return BufferUtils.string.ReadOSBased(outPath)
		end,

		RequestSaveFile = function(defaultName, filters)
			local outPath = ffi.alloc(ffi.types.pointer:size())
			local filterList, filterCount = buildFilterList(filters)

			local success: FFIPointer = lib.NFD_SaveDialogN(outPath, filterList, filterCount or 0, nil, defaultName)
			local code = BufferUtils:readhexa(success)

			if code == 2 then -- cancel
				return ""
			end

			return BufferUtils.string.ReadOSBased(outPath)
		end,
	})

	renderer_signal:Connect(function(route, dt) end)
end

return FileDialogService
