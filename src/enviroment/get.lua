local datatypes = require("@Kinemium.datatypes.get")
local Registry = require("@Kinemium.registry")
local DataModel = require("@DataModel")
local EnumMap = require("@EnumMap")
local PlayerGui = require("@PlayerGui")
local rules = require("@kilang.rules")

return function(renderer)
	local mainDatamodel = DataModel.new(renderer, { "StarterGui" })
	local data = datatypes

	local shared = {}

	data.Instance = {
		new = function(class)
			return Registry.new(class, renderer, mainDatamodel)
		end,
		getClasses = Registry.getClasses,
	}
	data.Enum = EnumMap
	data.task = {
		cancel = zune.task.cancel,
		defer = zune.task.defer,
		delay = zune.task.delay,
		spawn = zune.task.spawn,
		wait = zune.task.wait,
	}
	data.game = mainDatamodel
	data.workspace = mainDatamodel:GetService("Workspace")
	data.shared = shared
	data._VERSION = "Kilang 1.0.5"
	data.wait = zune.task.wait
	data.typeof = function(v)
		if type(v) == "table" then
			if v.type then
				return v.type
			elseif v.ClassName then
				return "Instance"
			else
				return "table"
			end
		else
			return type(v)
		end
	end

	data.kinemium = {
		version = 1.0,

		--jolt = require("@Kinemium.jolt"),
	}

	local players = mainDatamodel:GetService("Players")
	players.LocalPlayer.PlayerGui = PlayerGui.InitRenderer(renderer, renderer.Signal)
	players.LocalPlayer.Parent = players

	renderer.SetLightingService(mainDatamodel:GetService("Lighting"))
	renderer.Kinemium_camera.Parent = mainDatamodel:GetService("Workspace")

	local ScriptRunnerService = mainDatamodel:GetService("ScriptRunnerService")
	ScriptRunnerService.InitEnviroment(data, mainDatamodel)

	local LogService = mainDatamodel:GetService("LogService")

	data.print = function(...)
		print("RUNTIME", ...)

		return LogService.CreateLog("print", tostring(...))
	end
	data.warn = function(...)
		print("RUNTIME", ...)

		return LogService.CreateLog("warn", tostring(...))
	end

	data.error = function(...)
		warn("RUNTIME", ...)

		return LogService.CreateLog("error", tostring(...))
	end

	data.require = function(Instance)
		local sandboxer = require("@sandboxer")

		if type(Instance) == "table" then
			if Instance.ClassName == "ModuleScript" then
				local source = Instance.Source

				data.script = Instance

				local returned = ScriptRunnerService.RunScript(Instance)
				log(returned)
				if returned then
					return returned
				end
			end
		elseif type(Instance) == "string" then
			error("Cannot require string")
			return
		else
			error("require: cannot require table; expected ModuleScript")
		end
	end

	data.import = function(v)
		local callerEnv = getfenv(2)
		--print(callerEnv)
		if callerEnv.SecurityCapabilities ~= EnumMap.SecurityCapabilities.Internals then
			print("Security capabilities not equal to level 2")
			return {}
		end
		return require(v)
	end

	data.include = function(object: Instance)
		local callerEnv = getfenv(2)
		local result = data.require(object)
		if result then
			for p, v in pairs(result) do
				callerEnv[p] = v
			end
			print("Successfully included header " .. object.Name)
		end
	end

	for _, lib in pairs(rules) do
		if lib.InitEnviroment then
			lib.InitEnviroment(data)
		end
	end

	return data
end
