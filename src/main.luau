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
local httpServerViewer = require("@httpServerViewer")

_G.ENGINE_PROFILER = require("@profiler")

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

_G.GetFlagValue = function(flag)
	local args = zune.process.args
	for i, v in ipairs(args) do
		if v == "--" .. flag then
			return args[i + 1]
		end
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

_G.cfunc = function(code)
	local compiled = ffi.c.compile(code)
	local ptr = compiled:getSymbol("callbackFunc")
	return ptr
end

-- DEPENDENCIES
local sandboxer = require("./modules/sandboxer")
local Instance = require("@Instance")
local filesystem = require("./modules/filesystem")
local Enum = require("@EnumMap")
local kilang = require("@kilang")
local task = zune.task
local cam = require("@camera")

-- DETERMINE ENGINE MODE
_G.IsClient = false
_G.IsServer = false
_G.IsHeadless = false

if FlagExists("client") then
	_G.IsClient = true
elseif FlagExists("server") then
	_G.IsServer = true
	_G.IsHeadless = true
	log("Running engine in headless mode (Server).")
end

if FlagExists("headless") then
	_G.IsHeadless = true
end

if FlagExists("cli") then
	_G.IsHeadless = true
	task.spawn(function()
		task.wait(10)
		iodebug("Ran CLI successfully")
		zune.process.exit(0)
	end)
end

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
	renderer = KiRend.new({
		width = 1000,
		height = 800,
		maxFps = 0,
		title = "Kinemium Engine",
	})
	log("Loaded GPU renderer")
end

-- SETUP CAMERA
local instancePointer = Instance.new("Camera")
local Kinemium_camera = cam.callback(instancePointer, renderer)
Kinemium_camera.Parent = sandboxer.enviroment.Workspace

-- SETUP KILANG
kilang.renderer = renderer
local CEnv = kilang:init(Kinemium_camera)

local game = kilang.env.game
kilang.env.FlagExists = FlagExists

-- SETUP PROFILER
renderer:SetProfiler(ENGINE_PROFILER)
renderer:UseRlCamera(Kinemium_camera._raylibcam)

-- FILE SYSTEM UTILITIES
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

	local Folder

	if not _G.IsClient then
		Folder = Instance.new("Folder")
		Folder.Name = "Studio"
		Folder.Parent = kilang.env.game.CoreGui
	end

	loop("src/sandboxed/internals", function(path, entry)
		if kilang.threads[path] then
			return
		end

		local readPath = path
		if zembed.IsEmbedded() and entry.path then
			readPath = "../" .. entry.path
		end

		local code = zune.fs.readFile(readPath)

		if not code then
			warn("Failed to read file: " .. tostring(readPath))
			return
		end

		if string.find(path, ".luau") or string.find(path, ".lua") then
			local threadid, success, result = kilang:execute(code, {
				SecurityCapabilities = Enum.SecurityCapabilities.Internals,
				StackId = path,
			})

			if not success and result ~= nil then
				error(`Error loading internal {threadid}: {tostring(result)}`)
			end
		elseif string.find(path, ".c") then
			iodebug("Found C file!", path)
			CEnv.runC(code)
		end

		local luauCleaned = string.gsub(entry.name, ".luau", "")
		local luaCleaned = string.gsub(luauCleaned, ".lua", "")

		if Folder then
			local object = Instance.new("LocalScript")
			object.Source = code
			object.Name = luaCleaned
			object.Parent = Folder
		end
	end)
end

-- LOAD USER SCRIPTS
function Kinemium:run()
	loop("src/sandboxed", function(path, entry)
		if string.find(path, "internals") or string.find(path, "Core") then
			return
		end

		if kilang.threads[path] then
			return
		end

		local readPath = path
		if zembed.IsEmbedded() and entry.path then
			readPath = entry.path
		end

		local code = filesystem.read(readPath)
		local superset = "kilang"

		if string.find(entry.name, ".cpp") then
			superset = "cpp"
		elseif string.find(entry.name, ".ts") then
			superset = "typescript"
		end

		local id, success, result = kilang:execute(code, {
			superset = superset,
			SecurityCapabilities = Enum.SecurityCapabilities.UserScript,
			StackId = path,
		})
		if not success then
			evalError(`{id}: {tostring(result)}`)
		end
	end)
end

-- ENGINE SIGNAL HANDLER
game.EngineSignal:Connect(function(route)
	if route == "playtest" then
		Kinemium:playtest()
	end
end)

-- KILANG REPL
if FlagExists("kilang") or IsServer then
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
print("son")

loadInternals()
print("son")

httpServerViewer:Init(renderer)
print("son")

Kinemium:run()
print("son")

-- RUN RENDERER
renderer:Run()
