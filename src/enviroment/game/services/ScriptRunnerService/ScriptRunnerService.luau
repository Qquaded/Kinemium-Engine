-- devcell
local Instance = require("@Instance")
local signal = require("@Kinemium.signal")
local Enum = require("@EnumMap")
local sandboxer = require("@sandboxer")
local task = zune.task
local fs = zune.fs
local process = zune.process

local ScriptRunnerService = Instance.new("ScriptRunnerService")
ScriptRunnerService.ExplorerHidden = true

local threads = { luau = {}, python = {}, duktape = {}, quickjs = {}, luajit = {} }
local userThreads = {}

ScriptRunnerService.InitEnviroment = function(enviroment, datamodel)
	local ScriptRan = signal.new()

	ScriptRunnerService:SetProperties({
		RunLuauScript = function(ScriptInstance)
			local LogService = datamodel:GetService("LogService")
			local outsideSuccess, outsideResult
			local object = task.spawn(function()
				enviroment.script = ScriptInstance

				local _, success, result = sandboxer.run(ScriptInstance.Source, ScriptInstance.Name, enviroment)

				enviroment.script = nil
				outsideSuccess = success
				outsideResult = result
			end)
			threads.luau[ScriptInstance.Name] = object
			if not outsideSuccess and outsideResult ~= nil then
				LogService.CreateLog("error", outsideResult)
			end
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

		RunQuickJS = function(ScriptInstance)
			local qjsvm = require("@quickjs")

			local object = task.spawn(function()
				local VM = qjsvm.new()
				VM.Evaluate(ScriptInstance.Source)
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
				return ScriptRunnerService.RunQuickJS(ScriptInstance)
			end
			return
		end,

		GetActive = function()
			return threads
		end,

		RegisterUserThread = function(thread)
			table.insert(userThreads, thread)
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

			for _, thread in pairs(userThreads) do
				pcall(task.cancel, thread)
			end

			threads = { luau = {}, python = {}, duktape = {}, quickjs = {}, luajit = {} }
			userThreads = {}
		end,

		OpenInExternalEditor = function(script, program, folderPath)
			if program == "vscode" then
				local path = folderPath .. "/" .. script.UniqueId .. ".luau"
				fs.writeFile(path, script.Source)

				script.IsOverridden = true

				local abs = fs.realPath(path)

				task.spawn(function()
					process.run("code", { abs }, { shell = true })
				end)
				task.spawn(function()
					while true do
						if fs.stat(path).kind ~= "none" then
							script.Source = fs.readFile(path)
							task.wait(0.3)
						else
							print("File not found")
							break
						end
					end
				end)
			end
		end,
	})

	return ScriptRunnerService
end

return ScriptRunnerService
