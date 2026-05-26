--!optimize 2
--!native

local zembed = require("@zembed")
if zembed.IsEmbedded() then
	_G.IsExecutable = true
	print("Running embedded mode.")
	print("EXE Path: " .. zune.fs.getExePath())
	print("Current working directory: " .. zune.process.cwd())
else
	_G.IsExecutable = false
end

if zune.platform.os == "windows" then
	require("@vcredistInstaller")
end

local auto_flags = {}

local httpServerViewer = require("@httpServerViewer")
local filesystem = require("@filesystem")

if filesystem.exists("./exported") then
	local read = filesystem.read("./exported/flags.toml")
	if read then
		local flags_toml = zune.serde.toml.decode(read)
		if flags_toml then
			local default = flags_toml.default

			for _, flag in pairs(default) do
				auto_flags[flag] = 1
			end
		end
	end
end

filesystem.createFolder(".", ".temp")
filesystem.createFolder(".", "plugins")

if zembed.IsEmbedded() then
	filesystem.createFolder(".", "projects")
	filesystem.createFile(".", "projects.toml", "")
else
	filesystem.createFolder("./src", "projects")
	filesystem.createFile("./src", "projects.toml", "")
end

_G.ENGINE_PROFILER = require("@profiler")
_G.ENGINE_VERSION = "1.10.7"
_G.ENGINE_ENDPOINT = {
	MARKETPLACE = "https://quadigen.github.io/Kinemium-Engine-Plugins/plugins.json",
}

_G.warn = function(...)
	print("[\x1b[33mWARN\x1b[0m]", ...)
end

_G.log = function(...)
	print("[\x1b[94mLOG\x1b[0m]", ...)
end

_G.runtime = function(...)
	print("[\x1b[91mRUNTIME\x1b[0m]", ...)
end

_G.evalError = function(...)
	print("[\x1b[91mERROR\x1b[0m]", ...)
end

_G.iodebug = function(...)
	print("\x1b[38;5;208m[DEBUG]\x1b[0m", ...)
end

_G.task = zune.task

_G.FlagExists = function(flag)
	if auto_flags[flag] then
		return true
	end
	local args = zune.process.args
	for _, v in pairs(args) do
		if v == "--" .. flag then
			return true
		end
	end
	return false
end

_G.include = function(path)
	local required = require(path)
	local caller = getfenv(2)
	for k, v in pairs(required) do
		caller[k] = v
	end
	return required
end

_G.plug = function(lib)
	local caller = getfenv(2)
	for k, v in pairs(lib) do
		caller[k] = v
	end
	return lib
end

_G.GetFlagShell = function(flag)
	local args = zune.process.env

	if args[flag] then
		return args[flag]
	end

	local upperFlag = string.upper(flag)
	if args[upperFlag] then
		return args[upperFlag]
	end

	for i, v in ipairs(args) do
		if v == "--" .. flag then
			return args[i + 1]
		end
	end
	return nil
end

_G.GetFlagValue = function(flag)
	local args = zune.process.args
	for i, v in ipairs(args) do
		if v == "--" .. flag then
			return args[i + 1]
		end
	end
	local shellValue = GetFlagShell(flag)
	if shellValue then
		return shellValue
	end
	return nil
end

_G.debugstep = function()
	local callerEnv = getfenv(2)
	if not callerEnv._cdebug then
		callerEnv._cdebug = 0
	end
	callerEnv._cdebug = callerEnv._cdebug + 1
	log(`Debug step {callerEnv._cdebug}`)
end

_G.float = function(value)
	local buf = buffer.create(4)
	buffer.writef32(buf, 0, value or 0)
	return buf
end

_G.readFloat = function(buf)
	return buffer.readf32(buf, 0)
end

_G.color = {
	new = function(r, g, b, a)
		local colorBuf = buffer.create(4)
		buffer.writeu8(colorBuf, 0, r) -- r
		buffer.writeu8(colorBuf, 1, g) -- g
		buffer.writeu8(colorBuf, 2, b) -- b
		buffer.writeu8(colorBuf, 3, a) -- a
		return colorBuf
	end,
}

_G.writeFloat = function(buf, v)
	buffer.writef32(buf, 0, v)
end

_G.printi = function(tbl)
	for i, _ in pairs(tbl) do
		iodebug(i)
	end
end

-- DEPENDENCIES
-- DETERMINE ENGINE MODE
_G.IsClient = false
_G.IsServer = false
_G.IsHeadless = false

if FlagExists("client") then
	_G.IsClient = true
elseif FlagExists("server") then
	_G.IsServer = true
end

if FlagExists("headless") or FlagExists("cli") then
	_G.IsHeadless = true
end

if FlagExists("cli") then
	task.spawn(function()
		task.wait(10)
		iodebug("Ran CLI successfully")
		zune.process.exit(0)
	end)
end

if _G.IsServer then
	if _G.IsHeadless then
		log("Running engine in headless server mode.")
	else
		log("Running engine in graphical server mode.")
	end
elseif _G.IsClient then
	log("Running engine in client mode.")
elseif _G.IsHeadless then
	log("Running engine in headless mode.")
end

local Instance = require("@Instance")
local Enum = require("@EnumMap")
local kilang = require("@kilang")
local task = zune.task
local cam = require("@camera")

-- LOAD APPROPRIATE RENDERER
local renderer
local KiRend

if _G.IsHeadless then
	KiRend = require("./renderer/dummy")
	renderer = KiRend.new({
		width = 800,
		height = 600,
		maxFps = 120,
		title = "Kinemium Headless",
	})
	log("Loaded headless renderer")
else
	KiRend = require("@Kinemium.3d")
	local autoScale3D = not FlagExists("native3d")
	local max3DRenderPixels = tonumber(GetFlagValue("max3dpixels")) or 1280000
	local min3DRenderScale = math.clamp(tonumber(GetFlagValue("min3dscale")) or 0.5, 0.1, 1)

	renderer = KiRend.new({
		width = 1000,
		height = 800,
		autoScale3D = autoScale3D,
		max3DRenderPixels = if max3DRenderPixels > 0 then math.floor(max3DRenderPixels) else 0,
		min3DRenderScale = min3DRenderScale,
		maxFps = 0,
		title = "Kinemium Engine",
	})
	log("Loaded GPU renderer")
end

if FlagExists("perfoverlay") then
	renderer.ShowPerfOverlay = true
end

-- SETUP CAMERA
local instancePointer = Instance.new("Camera")

local Kinemium_camera = cam.callback(instancePointer, renderer)
Kinemium_camera.Parent = kilang.env.Workspace

-- SETUP KILANG
kilang.renderer = renderer
local CEnv = kilang:init(Kinemium_camera)

local game = kilang.env.game
kilang.env.FlagExists = FlagExists
kilang.env.GetFlagValue = GetFlagValue

-- SETUP PROFILER
renderer:SetProfiler(ENGINE_PROFILER)
renderer:UseRlCamera(Kinemium_camera._raylibcam)

-- FILE SYSTEM UTILITIES
local function normalizeScriptPath(path)
	return (path:gsub([[\]], "/"))
end

local function isScriptPath(path)
	return path:match("%.luau$") ~= nil or path:match("%.lua$") ~= nil
end

local function isUserScriptPath(path)
	return isScriptPath(path) or path:match("%.cpp$") ~= nil or path:match("%.ts$") ~= nil
end

local function readBundledScript(path)
	if zembed.IsEmbedded() then
		local normalized = normalizeScriptPath(path)
		local variants = {
			path,
			normalized,
			normalized:gsub("/", [[\]]),
			"./" .. normalized,
			[[.\]] .. normalized:gsub("/", [[\]]),
			"../" .. normalized,
			[[..\]] .. normalized:gsub("/", [[\]]),
		}

		for _, variant in ipairs(variants) do
			local success, data = pcall(zune.fs.embedFile, variant)
			if success and data then
				if type(data) == "buffer" then
					return buffer.tostring(data)
				end
				return data
			end
		end

		return nil
	end
	return zune.fs.readFile(path)
end

local function loop(base, callback)
	base = base or "src/sandboxed"
	filesystem.entryloop(base, function(entry)
		local path = entry.path or base .. "/" .. entry.name

		if entry.kind == "directory" then
			loop(path, callback)
		else
			callback(path, entry)
		end
	end)
end

-- KINEMIUM ENGINE
local Kinemium = {}

-- LOAD INTERNAL SCRIPTS
local function loadInternals()
	if _G.IsHeadless then
		return
	end

	local loadedCount = 0
	loop("src/sandboxed/internals", function(path, entry)
		if kilang.threads[path] then
			return
		end

		local readPath = zembed.IsEmbedded() and (entry.readPath or entry.path) or path
		local code = readBundledScript(readPath)

		if not code then
			warn("Failed to read file: " .. tostring(readPath))
			return
		end

		if isScriptPath(path) then
			loadedCount += 1
			task.spawn(function()
				local threadid, success, result = kilang:execute(code, {
					SecurityCapabilities = Enum.SecurityCapabilities.Internals,
					StackId = path,
				})

				if not success and result ~= nil then
					error(`Error loading internal {threadid}: {tostring(result)}`)
				end
			end)
		elseif path:match("%.c$") then
			iodebug("Found C file!", path)
			CEnv.runC(code)
		end
	end)

	log(string.format("[Internals] Queued %d internal scripts", loadedCount))
end

-- LOAD USER SCRIPTS
function Kinemium:run()
	local loadedCount = 0
	loop("src/sandboxed", function(path, entry)
		local normalizedPath = normalizeScriptPath(path)
		if normalizedPath:find("src/sandboxed/internals/", 1, true) then
			return
		end

		if kilang.threads[path] then
			return
		end

		if not isUserScriptPath(path) then
			return
		end

		local readPath = zembed.IsEmbedded() and (entry.readPath or entry.path) or path
		local code = readBundledScript(readPath)
		if not code then
			warn("Failed to read file: " .. tostring(readPath))
			return
		end

		local superset = "kilang"

		if entry.name:match("%.cpp$") then
			superset = "cpp"
		elseif entry.name:match("%.ts$") then
			superset = "typescript"
		end

		loadedCount += 1
		task.spawn(function()
			local id, success, result = kilang:execute(code, {
				superset = superset,
				SecurityCapabilities = Enum.SecurityCapabilities.UserScript,
				StackId = path,
			})
			if not success then
				evalError(`{id}: {tostring(result)}`)
			end
		end)
	end)

	log(string.format("[Scripts] Queued %d user scripts", loadedCount))
end

-- ENGINE SIGNAL HANDLER
game.EngineSignal:Connect(function(route)
	if route == "playtest" then
		Kinemium:playtest()
	end
end)

-- KILANG REPL
if FlagExists("kilang") then
	require("./repl"):init(function(line)
		task.spawn(function()
			local _, success, result = kilang:execute(line, {
				SecurityCapabilities = Enum.SecurityCapabilities.Internals,
			})
			if not success then
				evalError(result)
			end
		end)
	end)
end

-- INITIALIZE ENGINE
loadInternals()
httpServerViewer:Init(renderer)
Kinemium:run()

if FlagExists("rojo") then
	local port = GetFlagValue("rojo")
	if not port or type(port) == "boolean" or type(port) == "string" and port == "" then
		port = 3487
	else
		port = tonumber(port) or 3487
	end
	log("Rojo flag detected, connecting to Rojo server on port " .. tostring(port) .. "...")
	local RojoSyncService = game:GetService("RojoSyncService")
	if RojoSyncService then
		task.spawn(function()
			RojoSyncService:Connect(port)
		end)
	end
end

-- RUN RENDERER
renderer:Run()
