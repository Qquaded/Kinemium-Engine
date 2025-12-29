-- devcell
local Instance = require("@Instance")
local signal = require("@Kinemium.signal")
local Enum = require("@EnumMap")
local sandboxer = require("@sandboxer")
local task = zune.task

local ScriptRunnerService = Instance.new("ScriptRunnerService")
ScriptRunnerService.ExplorerHidden = true

--local lua = require("@lua")

local threads = { luau = {}, python = {}, duktape = {}, quickjs = {}, luajit = {} }

ScriptRunnerService.InitEnviroment = function(enviroment, datamodel)
	ScriptRunnerService:SetProperties({
		RunLuauScript = function(ScriptInstance)
			local LogService = datamodel:GetService("LogService")
			local outsideSuccess, outsideResult
			local object = task.spawn(function()
				enviroment.script = ScriptInstance

				local thread, success, result = sandboxer.run(ScriptInstance.Source, ScriptInstance.Name, enviroment)

				enviroment.script = nil
				outsideSuccess = success
				outsideResult = result
			end)
			if outsideSuccess then
				threads.luau[ScriptInstance.Name] = object
			else
				LogService.CreateLog("error", outsideResult)
			end
			print(outsideSuccess)
			print(outsideResult)
			return outsideResult
		end,

		RunPythonScript = function(ScriptInstance)
			local python = require("@python")

			local VM = python.PythonVM.new()

			for k, p in pairs(enviroment) do
				VM:setGlobal(k, p)
			end

			threads.python[ScriptInstance.Name] = VM

			return VM:execute(ScriptInstance.Source), VM
		end,

		RunDuktapeScript = function(ScriptInstance)
			local duktape = require("@duktape")

			local object = task.spawn(function()
				local VM = duktape.DuktapeVM.new()

				for k, p in pairs(enviroment) do
					if type(p) == "table" then
						continue
					end
					VM:setGlobal(k, p)
				end

				VM:execute(ScriptInstance.Source)
			end)

			threads.duktape[ScriptInstance.Name] = object
			return object
		end,

		RunScript = function(ScriptInstance)
			local language = ScriptInstance.Language

			if language == Enum.Language.Luau then
				return ScriptRunnerService.RunLuauScript(ScriptInstance)
			elseif language == Enum.Language.Python then
				return ScriptRunnerService.RunPythonScript(ScriptInstance)
			elseif language == Enum.Language.JavaScript then
				return ScriptRunnerService.RunDuktapeScript(ScriptInstance)
			end
			return
		end,

		GetActive = function()
			return threads
		end,

		Clear = function()
			for _, thread in pairs(threads.luau) do
				task.cancel(thread)
			end

			for _, thread in pairs(threads.python) do
				thread:close()
			end

			for _, thread in pairs(threads.duktape) do
				thread:close()
			end
		end,
	})

	return ScriptRunnerService
end

return ScriptRunnerService
