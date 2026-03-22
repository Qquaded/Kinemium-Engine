--[[
local KinemiumRaylib = game:GetService("KinemiumRaylib")
local RunService = game:GetService("RunService")
local PlaytestService = game:GetService("PlaytestService")

local rl = KinemiumRaylib.lib
local structs = KinemiumRaylib.structs
local renderer = KinemiumRaylib.renderer

local WebviewService = game:GetService("WebviewService")
local HTMLObj = WebviewService.MakeULHTMLObj()
local raylibTex = HTMLObj.MakeRaylibImage(nil, 500, 500)

evalJS = raylibTex.evalJS

local view = raylibTex.view
local lastULms = 0

-- ── Icon map ─────────────────────────────────────────────────────────────────

local function getIcon(className)
	local icons = {
		Workspace = "🌐",
		Camera = "📷",
		Terrain = "🏔",
		Part = "⬜",
		Players = "👥",
		Lighting = "💡",
		ReplicatedStorage = "🗄",
		ServerScriptService = "⚙",
		ServerStorage = "💾",
		StarterGui = "🖼",
		CoreGui = "📦",
		Script = "📄",
		LocalScript = "📄",
		Module = "📜",
		ModuleScript = "📜",
		Model = "🗂",
		Folder = "📁",
		SpotLight = "💡",
		PointLight = "💡",
		Sound = "🔊",
		SurfaceGui = "🖼",
		ScreenGui = "🖼",
		BillboardGui = "🖼",
	}
	return icons[className] or "📦"
end

-- ── State ────────────────────────────────────────────────────────────────────

local selectedId = nil
local instanceById = {} -- UniqueId → instance

-- Playtest state
local isPlaytesting = false
local isPaused = false

local function rebuildInstanceLookup()
	instanceById = {}
	for _, inst in ipairs(game:GetDescendants()) do
		if inst.UniqueId then
			instanceById[tostring(inst.UniqueId)] = inst
		end
	end
end

-- ── JSON helpers ─────────────────────────────────────────────────────────────

-- Escape a Lua string into a JSON double-quoted string literal
local function jStr(s)
	s = tostring(s or "")
	s = s:gsub("\\", "\\\\")
	s = s:gsub('"', '\\"')
	s = s:gsub("\n", "\\n")
	s = s:gsub("\r", "\\r")
	s = s:gsub("\t", "\\t")
	return '"' .. s .. '"'
end

local function jBool(b)
	return b and "true" or "false"
end

local function jNum(n)
	return tostring(tonumber(n) or 0)
end

-- ── Tree building ─────────────────────────────────────────────────────────────

local function serializeNode(node)
	local childParts = {}
	for _, c in ipairs(node.children or {}) do
		table.insert(childParts, serializeNode(c))
	end
	return string.format(
		"{id:%s,name:%s,icon:%s,className:%s,selected:%s,children:[%s]}",
		jStr(node.id or ""),
		jStr(node.name or ""),
		jStr(node.icon or "📦"),
		jStr(node.className or ""),
		jBool(node.selected),
		table.concat(childParts, ",")
	)
end

local function buildNode(instance)
	local children = {}
	for _, child in ipairs(instance:GetChildren()) do
		table.insert(children, buildNode(child))
	end
	return {
		id = tostring(instance.UniqueId or ""),
		name = instance.Name,
		className = instance.ClassName,
		icon = getIcon(instance.ClassName),
		selected = (tostring(instance.UniqueId) == selectedId),
		children = children,
	}
end

local function sendTree()
	rebuildInstanceLookup()
	local parts = {}
	for _, service in ipairs(game:GetChildren()) do
		table.insert(parts, serializeNode(buildNode(service)))
	end
	evalJS(view, "updateTree([" .. table.concat(parts, ",") .. "])")

	-- Also send a flat map of id → inspector payload so JS can update the
	-- inspector on click without a Lua roundtrip (fixes selection update bug).
	local mapParts = {}
	for id, inst in pairs(instanceById) do
		local ok, properties = pcall(extractProperties, inst)
		if not ok then
			properties = {}
		end

		local propParts = {}
		for _, p in ipairs(properties) do
			table.insert(
				propParts,
				string.format(
					"{label:%s,key:%s,type:%s,value:%s,section:%s}",
					jStr(p.label),
					jStr(p.key),
					jStr(p.type),
					valueToJson(p.value, p.type),
					jStr(p.section)
				)
			)
		end

		table.insert(
			mapParts,
			string.format(
				"%s:{id:%s,name:%s,className:%s,properties:[%s]}",
				jStr(id),
				jStr(id),
				jStr(inst.Name),
				jStr(inst.ClassName),
				table.concat(propParts, ",")
			)
		)
	end
	evalJS(view, "loadPropertiesMap({" .. table.concat(mapParts, ",") .. "})")
end

-- ── Property inspection ───────────────────────────────────────────────────────

local function getPropType(value, key)
	if type(value) == "boolean" then
		return "bool"
	elseif type(value) == "number" then
		return "number"
	elseif type(value) == "string" then
		-- Detect Vector3-style string e.g. "(1.5, 2, 3)"
		if value:match("^%(%-?%d+%.?%d*,%s*%-?%d+%.?%d*,%s*%-?%d+%.?%d*%)$") then
			return "vec3"
		end
		return "string"
	elseif type(value) == "table" then
		if value.R ~= nil and value.G ~= nil and value.B ~= nil then
			return "color"
		end
		if value.X ~= nil and value.Y ~= nil and value.Z ~= nil then
			return "vec3"
		end
		if value.EnumType then
			return "select"
		end
	end
	return "readonly"
end

local function convertValue(value, ptype)
	if ptype == "vec3" then
		if type(value) == "table" then
			return { value.X or 0, value.Y or 0, value.Z or 0 }
		end
		-- Parse string form "(x, y, z)"
		local x, y, z = tostring(value):match("%(([^,]+),%s*([^,]+),%s*([^,]+)%)")
		return { tonumber(x) or 0, tonumber(y) or 0, tonumber(z) or 0 }
	elseif ptype == "color" and type(value) == "table" then
		return {
			math.floor((value.R or 1) * 255),
			math.floor((value.G or 1) * 255),
			math.floor((value.B or 1) * 255),
		}
	elseif ptype == "select" and type(value) == "table" then
		return tostring(value)
	end
	return value
end

local function valueToJson(value, ptype)
	if ptype == "bool" then
		return jBool(value)
	elseif ptype == "number" then
		return jNum(value)
	elseif ptype == "vec3" then
		local v = value or { 0, 0, 0 }
		return string.format("[%s,%s,%s]", jNum(v[1]), jNum(v[2]), jNum(v[3]))
	elseif ptype == "color" then
		local v = value or { 255, 255, 255 }
		return string.format("[%d,%d,%d]", v[1] or 255, v[2] or 255, v[3] or 255)
	else
		return jStr(tostring(value or ""))
	end
end

-- Sections and which properties belong to each (ordered display)
local SECTION_ORDER = { "Transform", "Appearance", "Behavior" }
local SECTION_KEYS = {
	Transform = { "Position", "Rotation", "Size", "Scale", "CFrame" },
	Appearance = { "Color", "BrickColor", "Transparency", "Reflectance", "Material", "CastShadow" },
	Behavior = { "Anchored", "CanCollide", "CanQuery", "Locked", "Visible", "Enabled" },
}

local EXCLUDE_PROPS = {
	UniqueId = true,
	_parent = true,
	Children = true,
	Parent = true,
}

local function extractProperties(instance)
	-- Try GetProperties() if available; fall back to empty table
	local propsRaw = instance._props
	print(propsRaw)

	-- Helper: read a value from raw props, then try direct instance access
	local function getVal(key)
		if propsRaw[key] ~= nil then
			return propsRaw[key]
		end
		local ok, v = pcall(function()
			return instance[key]
		end)
		if ok and v ~= nil then
			return v
		end
		return nil
	end

	local seen = {}
	local properties = {}

	-- Priority sections (Transform / Appearance / Behavior)
	for _, section in ipairs(SECTION_ORDER) do
		for _, key in ipairs(SECTION_KEYS[section]) do
			if not seen[key] then
				local val = getVal(key)
				if val ~= nil then
					seen[key] = true
					local ptype = getPropType(val, key)
					table.insert(properties, {
						label = key,
						key = key,
						type = ptype,
						value = convertValue(val, ptype),
						section = section,
					})
				end
			end
		end
	end

	-- Remaining keys from GetProperties() under "Properties"
	for key, value in pairs(propsRaw) do
		if not EXCLUDE_PROPS[key] and not seen[key] then
			seen[key] = true
			local ptype = getPropType(value, key)
			table.insert(properties, {
				label = key,
				key = key,
				type = ptype,
				value = convertValue(value, ptype),
				section = "Properties",
			})
		end
	end

	-- Always guarantee Name and ClassName appear
	if not seen["Name"] then
		local ok, v = pcall(function()
			return instance.Name
		end)
		if ok and v ~= nil then
			table.insert(properties, 1, {
				label = "Name",
				key = "Name",
				type = "string",
				value = tostring(v),
				section = "Properties",
			})
		end
	end
	if not seen["ClassName"] then
		local ok, v = pcall(function()
			return instance.ClassName
		end)
		if ok and v ~= nil then
			table.insert(properties, 1, {
				label = "ClassName",
				key = "ClassName",
				type = "readonly",
				value = tostring(v),
				section = "Properties",
			})
		end
	end

	return properties
end

local function sendInspector(inst)
	if not inst then
		return
	end
	local properties = extractProperties(inst)

	local propParts = {}
	for _, p in ipairs(properties) do
		table.insert(
			propParts,
			string.format(
				"{label:%s,key:%s,type:%s,value:%s,section:%s}",
				jStr(p.label),
				jStr(p.key),
				jStr(p.type),
				valueToJson(p.value, p.type),
				jStr(p.section)
			)
		)
	end

	local payload = string.format(
		"{id:%s,name:%s,className:%s,properties:[%s]}",
		jStr(tostring(inst.UniqueId or "")),
		jStr(inst.Name),
		jStr(inst.ClassName),
		table.concat(propParts, ",")
	)

	evalJS(view, "updateInspector(" .. payload .. ")")
end

-- ── Logging ───────────────────────────────────────────────────────────────────

local function uiLog(text, level, src)
	local t = string.format("%.3f", rl.GetTime())
	evalJS(
		view,
		string.format(
			"addLog({text:%s,level:%s,src:%s,time:%s})",
			jStr(tostring(text or "")),
			jStr(level or ""),
			jStr(src or ""),
			jStr(t)
		)
	)
end

-- ── HTML callback wiring (Native via WebCore bindings) ────────────────────────

local UltraLight = require("@Ultralight")
local ffi = zune.ffi

-- Helper to safely get a string from JS context via eval (bypasses pointer array issues)
local function evalGetJSString(script)
	local jsStr = UltraLight.lib.ulCreateString(script)
	local jsVal = UltraLight.lib.ulViewEvaluateScript(view, jsStr, nil)
	UltraLight.lib.ulDestroyString(jsStr)

	local ctx = UltraLight.lib.ulViewLockJSContext(view)
	local res = nil
	local WebCore = UltraLight.WebCore

	if WebCore.JSValueIsString(ctx, jsVal) == 1 then
		local cpy = WebCore.JSValueToStringCopy(ctx, jsVal, nil)
		local size = WebCore.JSStringGetMaximumUTF8CStringSize(cpy)
		local buf = ffi.alloc(size)
		WebCore.JSStringGetUTF8CString(cpy, buf, size)
		res = ffi.string(buf)
		WebCore.JSStringRelease(cpy)
	end

	UltraLight.lib.ulViewUnlockJSContext(view)
	return res
end

-- Called when the user clicks a tree item in the HTML
local function onSelectObject(id)
	print("Selected item " .. id)
	selectedId = tostring(id)
	-- call sendInspector here as a secondary update (refreshes live data).
	local instance = instanceById[selectedId]
	if instance then
		sendInspector(instance)
	end
end

-- Called when the user edits a property in the inspector
local function onPropertyChange(objectId, key, axis, value)
	local inst = instanceById[tostring(objectId or "")]
	if not inst then
		return
	end

	local ok, err = pcall(function()
		local props = inst:GetProperties()
		local existing = props[key]

		if axis and type(existing) == "table" then
			-- vec3 / color component update
			local axisUpper = tostring(axis):upper()
			existing[axisUpper] = tonumber(value) or value
			inst[key] = existing
		elseif type(existing) == "boolean" then
			inst[key] = (value == true or value == "true")
		elseif type(existing) == "number" then
			inst[key] = tonumber(value) or existing
		else
			inst[key] = value
		end
	end)

	if not ok then
		uiLog("Property write failed (" .. tostring(key) .. "): " .. tostring(err), "warn", "ultesttex.luau")
	end
end

local _KEEP_ALIVE_CLOSURES = {}

local function setupHtmlCallbacks()
	local WebCore = UltraLight.WebCore
	local ctx = UltraLight.lib.ulViewLockJSContext(view)
	local globalObj = WebCore.JSContextGetGlobalObject(ctx)

	-- We bind a single native callback. Arguments are communicated via JS global variables
	-- because Zune FFI does not support extracting items from void** pointer arrays natively.
	local nameStr = WebCore.JSStringCreateWithUTF8CString("_notifyKinemium")
	local cb = ffi.closure({
		returns = ffi.types.pointer,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.u64,
			ffi.types.pointer,
			ffi.types.pointer,
		},
	}, function(c_ctx, c_func, c_this, argc, argv, exc)
		local callType = evalGetJSString("window._bridgeCall")

		if callType == "onSelectObject" then
			local id = evalGetJSString("window._bridgeArg0")
			pcall(onSelectObject, id)
		elseif callType == "onPropertyChange" then
			local id = evalGetJSString("window._bridgeArg0")
			local key = evalGetJSString("window._bridgeArg1")
			local axis = evalGetJSString("window._bridgeArg2")
			local val = evalGetJSString("window._bridgeArg3")

			if axis == "" then
				axis = nil
			end
			local parsedVal = val
			if val == "true" then
				parsedVal = true
			elseif val == "false" then
				parsedVal = false
			else
				parsedVal = tonumber(val) or val
			end

			pcall(onPropertyChange, id, key, axis, parsedVal)
		elseif callType == "onRunPressed" then
			if not isPlaytesting then
				-- Start playtesting
				PlaytestService.CreatePlaytestAsync()
				isPlaytesting = true
				isPaused = false
				uiLog("Playtest started", "info", "ultesttex.luau")
			elseif isPaused then
				-- Resume from pause
				RunService:Resume()
				isPaused = false
				uiLog("Playtest resumed", "info", "ultesttex.luau")
			end
		elseif callType == "onPausePressed" then
			if isPlaytesting and not isPaused then
				-- Pause the game
				RunService:Pause()
				isPaused = true
				uiLog("Playtest paused", "info", "ultesttex.luau")
			end
		elseif callType == "onStopPressed" then
			if isPlaytesting then
				-- Stop playtesting
				PlaytestService.StopCurrentPlaytest()
				isPlaytesting = false
				isPaused = false
				uiLog("Playtest stopped", "info", "ultesttex.luau")
			end
		end

		return WebCore.JSValueMakeUndefined(c_ctx)
	end)

	local jsFunc = WebCore.JSObjectMakeFunctionWithCallback(ctx, nameStr, cb)
	WebCore.JSObjectSetProperty(ctx, globalObj, nameStr, jsFunc, 0, nil)

	WebCore.JSStringRelease(nameStr)
	UltraLight.lib.ulViewUnlockJSContext(view)

	table.insert(_KEEP_ALIVE_CLOSURES, cb)
end

-- ── Initialisation ────────────────────────────────────────────────────────────

local function initializeUI()
	-- Default selection: Workspace
	local workspace = game:FindFirstChild("Workspace")
	if workspace then
		selectedId = tostring(workspace.UniqueId)
	end

	sendTree()

	if workspace then
		sendInspector(workspace)
	end

	uiLog("Kinemium Engine initialized", "info", "Engine.lua:1")
	uiLog("Renderer started", "ok", "Renderer.lua:44")
end

-- Small delay so the HTML document is ready before we push data into it
task.delay(0.5, function()
	task.spawn(function()
		setupHtmlCallbacks()
		initializeUI()
	end)
end)

-- ── Render loop ───────────────────────────────────────────────────────────────

renderer.Pool.new("2d", function(data)
	rl.DrawTexture(raylibTex.texture, 0, 0, KinemiumRaylib.const.WHITE)

	local stats = renderer.PerfStats

	-- Update stats ~6x/sec (every 10 frames at 60 fps)
	local frame = math.floor(rl.GetTime() * 60)
	if frame % 10 ~= 0 then
		return
	end

	evalJS(
		view,
		string.format(
			"updateStats({fps:%d,draw:'%d',mem:'%dMB',frame_ms:'%.2f',dispatch_ms:'%.2f',ul_ms:'%.2f',batches:%d,pool_ms:'%.2f'})",
			stats.fps,
			stats.batches_3d,
			math.floor(gcinfo() / 1024),
			stats.frame_ms,
			stats.dispatch_ms,
			lastULms,
			stats.batches_3d,
			stats.render3d_update_ms
		)
	)
end)
--]]
