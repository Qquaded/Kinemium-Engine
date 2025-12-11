_G.warn = function(...)
	print("[\x1b[33mWARN\x1b[0m]", ...)
end

local sandboxer = require("./modules/sandboxer")
local filesystem = require("./modules/filesystem")
local Instance = require("@Instance")
local ModuleScript = require("@ModuleScript")
local Kinemium_env = require("./enviroment/get")
local task = zune.task
local threads = {}
local Kinemium = {}
local luacss = "./src/rblx/luacss/init.luau"

local renderer = require("@Kinemium.3d")
Kinemium_env = Kinemium_env(renderer)

--local raygui = require("@raygui")

sandboxer.enviroment = Kinemium_env

local game = Kinemium_env.game

local function execute(path, entry, env)
	if threads[path] then
		return
	end -- Prevent double execution
	local code = filesystem.read(path)
	local thread = task.spawn(function()
		sandboxer.run(code, entry.name, env)
	end)
	threads[path] = thread
end

local function callback(entry, base, env)
	local base = base or "src/sandboxed"
	local path = base .. "/" .. entry.name

	if entry.kind == "directory" then
		filesystem.entryloop(path, function(e)
			callback(e, path)
		end)
	else
		execute(path, entry, env)
	end
end

filesystem.entryloop("src/sandboxed/internals", function(e)
	sandboxer.enviroment.SecurityCapabilities = sandboxer.enviroment.Enum.SecurityCapabilities.Internals
	callback(e, "src/sandboxed/internals")
end)

function Kinemium:playtest()
	filesystem.entryloop("src/sandboxed", function(e)
		sandboxer.enviroment.SecurityCapabilities = sandboxer.enviroment.Enum.SecurityCapabilities.UserScript
		callback(e, "src/sandboxed")
	end)
end

--[[
sandboxer.rblxrequire(luacss, function(code, path)
	local scriptInstance = Instance.new("ModuleScript")
	ModuleScript.callback(scriptInstance)
	scriptInstance.Source = code

	local function processDirectory(dirPath, parentInstance)
		local entries = zune.fs.entries(dirPath)
		for _, entry in pairs(entries) do
			if entry.kind == "directory" then
				local folder = Instance.new("Folder")
				folder.Name = entry.name
				folder.Parent = parentInstance
				processDirectory(dirPath .. "/" .. entry.name, folder) -- recursive call
			elseif entry.kind == "file" and entry.name:match("%.lu[au]$") then
				local childModule = Instance.new("ModuleScript")
				ModuleScript.callback(childModule)

				childModule.Name = entry.name:gsub("%.lu[au]$", "")
				childModule.Source = zune.fs.readFile(dirPath .. "/" .. entry.name)
				childModule.Parent = parentInstance
			end
		end
	end

	processDirectory("./src/rblx/luacss", scriptInstance)

	return scriptInstance
end)
--]]

print(threads)

renderer.Kinemium_camera.Parent = sandboxer.enviroment.workspace

game.EngineSignal:Connect(function(route)
	if route == "playtest" then
		Kinemium:playtest()
	end
end)

renderer.Run()
