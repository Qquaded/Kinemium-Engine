local ffi = zune.ffi
local c = ffi.c

local pointer = ffi.types.pointer
local void = ffi.types.void
local float = ffi.types.float
local httpServerViewer = require("@httpServerViewer")

_G.warn = function(...)
	print("[\x1b[33mWARN\x1b[0m]", ...)
end

_G.log = function(...)
	print("[\x1b[94mLOG\x1b[0m]", ...)
end

_G.task = zune.task

_G.debugPart = function(data)
	_G.log(`Created body to part {data.Name}`)
	_G.log(`{data.Name}       Property       Value`)
	for k, v in pairs(data._props) do
		_G.log(`{data.Name}       {k}       {tostring(v)}`)
	end
end

_G.FlagExists = function(flag)
	local args = zune.process.args
	for _, v in pairs(args) do
		if v == "--" .. flag then
			return true
		end
	end
	return false
end

_G.GetFlagValue = function(flag)
	local args = zune.process.args
	for i, v in ipairs(args) do
		if v == "--" .. flag then
			return args[i + 1] -- may be nil if no value is provided
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

local sandboxer = require("./modules/sandboxer")
local Instance = require("@Instance")
local filesystem = require("./modules/filesystem")
local Enum = require("@EnumMap")
local kilang = require("@kilang")
local task = zune.task
local Kinemium = {}

local dummy = require("./renderer/dummy")

local renderer

if FlagExists("client") then
	_G.IsClient = true
	_G.IsServer = false
elseif FlagExists("server") then
	_G.IsServer = true
	_G.IsClient = false
	_G.IsHeadless = true

	log("Running engine headless mode (Server).")
end

if FlagExists("headless") then
	_G.IsHeadless = true
end

if FlagExists("cli") then
	_G.IsHeadless = true

	task.spawn(function()
		task.wait(10)
		print("Ran CLI successfully")
		zune.process.exit(0)
	end)
end

if IsHeadless then
	kilang.renderer = dummy
else
	kilang.renderer = require("@Kinemium.3d")
end

kilang:init()

local game = kilang.env.game
kilang.renderer.DatamodelObject(game)

local function loop(base, callback)
	base = base or "src/sandboxed"
	filesystem.entryloop(base, function(entry)
		local path = base .. "/" .. entry.name

		if entry.kind == "directory" then
			loop(path, callback)
		else
			callback(path, entry)
		end
	end)
end

local Folder = Instance.new("Folder")
Folder.Name = "Studio"
Folder.Parent = kilang.env.game.CoreGui

loop("src/sandboxed/internals", function(path, entry)
	if kilang.threads[path] then
		return
	end

	local code = zune.fs.readFile(path)
	kilang:execute(code, {
		SecurityCapabilities = Enum.SecurityCapabilities.Internals,
		StackId = path,
	})

	local luauCleaned = string.gsub(entry.name, ".luau", "")
	local luaCleaned = string.gsub(luauCleaned, ".lua", "")

	local object = Instance.new("LocalScript")
	object.Source = filesystem.read(path)
	object.Name = luaCleaned
	object.Parent = Folder
end)

function Kinemium:playtest()
	loop("src/sandboxed", function(path, entry)
		if kilang.threads[path] then
			return
		end

		local code = filesystem.read(path)
		local superset = "kilang"

		if string.find(entry.name, ".cpp") then
			superset = "cpp"
		end
		kilang:execute(code, {
			superset = superset,
			SecurityCapabilities = Enum.SecurityCapabilities.UserScript,
			StackId = path,
		})
	end)
end

kilang.renderer.Kinemium_camera.Parent = sandboxer.enviroment.Workspace

game.EngineSignal:Connect(function(route)
	if route == "playtest" then
		Kinemium:playtest()
	end
end)

if FlagExists("kilang") then
	require("./repl"):init(function(line)
		task.spawn(function()
			local success, result = pcall(function(...)
				kilang:execute(line, {
					SecurityCapabilities = Enum.SecurityCapabilities.Internals,
				})
			end)
		end)
	end)
end

httpServerViewer:Init()
Kinemium:playtest()

kilang.renderer.Run()
