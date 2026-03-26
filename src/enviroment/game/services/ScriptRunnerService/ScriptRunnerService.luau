-- devcell
local Instance = require("@Instance")
local signal = require("@Kinemium.signal")
local Enum = require("@EnumMap")
local sandboxer = require("@sandboxer")
local task = zune.task
local fs = zune.fs
local process = zune.process
local platform = zune.platform

local ScriptRunnerService = Instance.new("ScriptRunnerService")
ScriptRunnerService.ExplorerHidden = true

local threads = { luau = {}, python = {}, duktape = {}, quickjs = {}, luajit = {} }
local userThreads = {}

-- Thread metadata: { name, thread, env, status, memoryLimit, memoryUsed }
local threadMeta = {}

-- Global memory limit: 1GB per thread
local DEFAULT_MEMORY_LIMIT = 1024 * 1024 * 1024 -- 1GB
-- Max buffer size: 1GB
local MAX_BUFFER_SIZE = 1024 * 1024 * 1024 -- 1GB

local function getMemoryUsage()
	local ok, result = platform.getTotalMemory()
	if ok then
		return result
	end
	return 0
end

local function createThreadInfo(name, thread, env, language)
	local info = {
		name = name,
		thread = thread,
		env = env,
		language = language or "luau",
		status = "running",
		memoryLimit = DEFAULT_MEMORY_LIMIT,
		memoryAtStart = getMemoryUsage(),
		createdAt = os.clock(),
		globals = {},
	}
	threadMeta[name] = info
	return info
end

ScriptRunnerService.InitEnviroment = function(enviroment, datamodel)
	local ScriptRan = signal.new()

	-- Wrap buffer.create to enforce max buffer size
	local originalBufferCreate = buffer.create
	enviroment.buffer = enviroment.buffer or {}
	local envBuffer = setmetatable({}, { __index = buffer })

	envBuffer.create = function(size)
		if size >= MAX_BUFFER_SIZE then
			error(`Cannot create buffer of size {size} bytes. Maximum allowed is {MAX_BUFFER_SIZE} bytes (1GB).`)
		end
		return originalBufferCreate(size)
	end

	-- Override buffer in environment
	enviroment.buffer = envBuffer

	ScriptRunnerService:SetProperties({
		RunLuauScript = function(ScriptInstance)
			local LogService = datamodel:GetService("LogService")
			local outsideSuccess, outsideResult
			local scriptEnv = setmetatable({}, { __index = enviroment })
			scriptEnv.script = ScriptInstance

			local object = task.spawn(function()
				local _, success, result = sandboxer.run(ScriptInstance.Source, ScriptInstance.Name, scriptEnv)

				scriptEnv.script = nil
				outsideSuccess = success
				outsideResult = result
			end)

			threads.luau[ScriptInstance.Name] = object
			createThreadInfo(ScriptInstance.Name, object, scriptEnv, "luau")

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
			createThreadInfo(ScriptInstance.Name, VM, nil, "python")

			return VM:execute(ScriptInstance.Source), VM
		end,

		RunQuickJS = function(ScriptInstance)
			local qjsvm = require("@quickjs")

			local object = task.spawn(function()
				local VM = qjsvm.new()
				VM.Evaluate(ScriptInstance.Source)
			end)

			threads.duktape[ScriptInstance.Name] = object
			createThreadInfo(ScriptInstance.Name, object, nil, "quickjs")
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

		-- Get all raw thread objects (legacy)
		GetActive = function()
			return threads
		end,

		-- Get thread metadata by script name
		GetThread = function(name)
			return threadMeta[name]
		end,

		-- Get all thread metadata
		GetAllThreads = function()
			local result = {}
			for name, info in pairs(threadMeta) do
				result[name] = {
					name = info.name,
					language = info.language,
					status = info.status,
					memoryLimit = info.memoryLimit,
					createdAt = info.createdAt,
					globals = info.globals,
				}
			end
			return result
		end,

		-- Get thread status
		GetThreadStatus = function(name)
			local info = threadMeta[name]
			if not info then
				return "unknown"
			end
			return info.status
		end,

		-- Insert a global variable into a running thread's environment
		SetGlobal = function(name, key, value)
			local info = threadMeta[name]
			if not info then
				warn(`[ScriptRunner] Thread '{name}' not found`)
				return false
			end

			if info.env then
				info.env[key] = value
				info.globals[key] = true
				return true
			else
				warn(`[ScriptRunner] Thread '{name}' does not have an accessible environment`)
				return false
			end
		end,

		-- Get a global variable from a thread's environment
		GetGlobal = function(name, key)
			local info = threadMeta[name]
			if not info or not info.env then
				return nil
			end
			return info.env[key]
		end,

		-- Set memory limit for a specific thread
		SetMemoryLimit = function(name, bytes)
			local info = threadMeta[name]
			if not info then
				warn(`[ScriptRunner] Thread '{name}' not found`)
				return false
			end
			info.memoryLimit = math.min(bytes, DEFAULT_MEMORY_LIMIT)
			return true
		end,

		-- List all globals injected into a thread
		GetThreadGlobals = function(name)
			local info = threadMeta[name]
			if not info then
				return {}
			end
			local globals = {}
			for key in pairs(info.globals) do
				table.insert(globals, key)
			end
			return globals
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

			-- Mark all thread metadata as dead
			for name, info in pairs(threadMeta) do
				info.status = "dead"
			end

			threads = { luau = {}, python = {}, duktape = {}, quickjs = {}, luajit = {} }
			userThreads = {}
			threadMeta = {}
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

		-- Memory limit getter
		GetDefaultMemoryLimit = function()
			return DEFAULT_MEMORY_LIMIT
		end,

		-- Max buffer size getter
		GetMaxBufferSize = function()
			return MAX_BUFFER_SIZE
		end,
	})

	return ScriptRunnerService
end

return ScriptRunnerService
