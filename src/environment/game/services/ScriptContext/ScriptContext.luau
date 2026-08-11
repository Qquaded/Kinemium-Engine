local Instance = require("@Instance")
local Enum = require("@EnumMap")
local kilang = require("@kilang")
local datatypes = require("@Kinemium.datatypes.get")

local ScriptContext = Instance.new("ScriptContext")
ScriptContext.ExplorerHidden = true
ScriptContext._Intents = Enum.PluginIntents.Threading

local activeThreads = {}

export type LanguageRuntime = {
	newthread: (Instance, DataModel) -> (),
	killthread: (thread) -> (),
}

local console_log = function(log)
	print(log)
end

ScriptContext.InitRenderer = function(renderer, signal, datamodel)
	local requiredCache = {}
	local REQUIRE_LOADING = {}
	local REQUIRE_NIL = {}

	local function hasExplicitNilReturn(source)
		if type(source) ~= "string" then
			return false
		end

		local withoutTrailingWhitespace = source:gsub("%s+$", "")
		return withoutTrailingWhitespace:match("return%s+nil%s*$") ~= nil
			or withoutTrailingWhitespace:match("return%s+nil%s*::") ~= nil
	end

	local function hasReturnStatement(source)
		if type(source) ~= "string" then
			return false
		end

		return source:match("^%s*return[%s%(]") ~= nil or source:match("\n%s*return[%s%(]") ~= nil
	end

	local function tryResolveModuleScript(target)
		if type(target) ~= "table" then
			return nil
		end

		if target.ClassName == "ModuleScript" then
			return target
		end

		if target.FindFirstChild then
			local initModule = target:FindFirstChild("init") or target:FindFirstChild("Init")
			if initModule and initModule.ClassName == "ModuleScript" then
				return initModule
			end
		end

		return nil
	end

	local function getSourceLine(source, lineNumber, contextAfter, contextBefore)
		if not source or not lineNumber then
			return nil
		end

		contextAfter = contextAfter or 4
		contextBefore = contextBefore or 0

		local lines = {}
		local currentLine = 0
		for line in (source .. "\n"):gmatch("(.-)\n") do
			currentLine += 1
			lines[currentLine] = line
		end

		local startLine = math.max(1, lineNumber - contextBefore)
		local endLine = math.min(#lines, lineNumber + contextAfter)

		local result = {}
		for i = startLine, endLine do
			local marker = (i == lineNumber) and ">> " or "   "
			table.insert(result, string.format("%s%d: %s", marker, i, lines[i]))
		end

		return table.concat(result, "\n")
	end

	local function getModuleStackId(moduleScript)
		local fullName = moduleScript.Name
		if moduleScript.GetFullName then
			fullName = moduleScript:GetFullName()
		end
		return `{fullName}#{moduleScript.UniqueId}`
	end

	task.spawn(function()
		local function getserv(service)
			repeat
				task.wait()
			until datamodel.Loaded == true
			return datamodel:GetService(service)
		end

		local pluginLoader = getserv("PluginLoader")

		local runtimes = {
			Luau = {
				newthread = function(scriptObject: Instance, datamodel: DataModel)
					local script_environment

					script_environment = datatypes
					script_environment.script = scriptObject
					script_environment.require = function(target)
						if type(target) == "string" then
							if target:match("^@kine/") then
								local name = string.sub(target, 7)
								local api = require(`@{name}`) or require("../src/environment/builtin/" .. name)
								if api then
									return api:init(renderer, datamodel)
								end
							end
							local api = pluginLoader.GetPluginApi(target)
							if api then
								return api
							end
							return require(target)
						end

						if type(target) ~= "table" then
							print("require: expected ModuleScript or string, got " .. type(target), 2)
							return
						end

						if target.ClassName == nil then
							print("DEBUG require target is plain table:", target)
							print(debug.traceback())
						end

						local moduleScript = tryResolveModuleScript(target)
						if not moduleScript then
							if type(target) == "table" and rawget(target, "Destroyed") then
								console_log(
									`require: target was Destroyed before require completed. `
										.. `UniqueId={rawget(target, "_props") and rawget(target, "_props").UniqueId or "?"}`,
									2
								)
							else
								print(
									`require: cannot require {target.ClassName} '{target.Name}'; expected ModuleScript`,
									2
								)
							end
							return
						end
						target = moduleScript

						local cached = requiredCache[target]
						if cached == REQUIRE_NIL then
							return nil
						end
						if cached == REQUIRE_LOADING then
							console_log(`require: circular dependency detected on '{target.Name}'`, 2)
							return
						end
						if cached ~= nil then
							return cached
						end

						requiredCache[target] = REQUIRE_LOADING

						local source = target.Source
						local success, result, id, thread, getResult
						if source and type(source) == "string" then
							id, success, result, thread, getResult = kilang:execute(
								source,
								{ StackId = getModuleStackId(target) },
								{
									script = target,
									src = target,
									loader = scriptObject,
									require = script_environment.require,
								}
							)
						end

						if getResult then
							success, result = getResult()
							if id then
								kilang:remove(id)
							end
						end

						if thread then
							-- save thread
							if not activeThreads["Luau"] then
								activeThreads["Luau"] = {}
							end
							activeThreads["Luau"][target.UniqueId] = thread
						end

						if success == false then
							requiredCache[target] = nil

							local errMsg = tostring(result)
							local lineNumber = tonumber(errMsg:match(":(%d+):"))
							local sourceContext = getSourceLine(source, lineNumber)

							if sourceContext then
								console_log(
									`require: ModuleScript '{target.Name}' failed: {errMsg}\n{sourceContext}`,
									2
								)
							else
								console_log(`require: ModuleScript '{target.Name}' failed: {errMsg}`, 2)
							end

							return
						end

						if result == nil and not hasExplicitNilReturn(source) then
							requiredCache[target] = REQUIRE_NIL
							if not hasReturnStatement(source) then
								console_log(`require: ModuleScript '{target.Name}' did not return a value`, 2)
							end
							return nil
						elseif result == nil then
							requiredCache[target] = REQUIRE_NIL
							return nil
						end

						requiredCache[target] = result
						return result
					end

					local source = scriptObject.Source
					print("DEBUG Source length for", scriptObject.Name, ":", source and #source or "NIL SOURCE")
					if not activeThreads["Luau"] then
						activeThreads["Luau"] = {}
					end

					local id, success, result, thread = kilang:execute(
						source,
						{ StackId = `{scriptObject.Name} ({scriptObject:GetFullName()})` },
						script_environment
					)

					print(success, result)

					-- add to thread table
					activeThreads["Luau"][scriptObject.UniqueId] = thread

					return thread, id, success, result
				end,

				killthread = function(uniqueId)
					local thread = activeThreads["Luau"][uniqueId]
					if thread then
						task.cancel(thread)
						activeThreads["Luau"][uniqueId] = nil
					end
				end,
			},
		}

		local function runScriptOfClass(object, class)
			for _, descendant in pairs(object:GetDescendantsOfClass(class)) do
				if descendant.Enabled == false then
					return
				end
				task.spawn(function()
					ScriptContext.MakeThreadObject(descendant)
				end)
			end

			object.DescendantAdded:Connect(function(descendant)
				if descendant.ClassName == class then
					if descendant.Enabled == false then
						return
					end
					task.spawn(function()
						ScriptContext.MakeThreadObject(descendant)
					end)
				end
			end)

			object.DescendantRemoving:Connect(function(descendant)
				if descendant.ClassName == class then
					ScriptContext.KillThread(descendant.UniqueId, descendant.Language)
				end
			end)
		end

		ScriptContext:SetProperties({
			NewRuntime = function(api: LanguageRuntime)
				local name = api.name

				if not api.newthread then
					print("Runtime function newthread not found")
					return
				end

				if not api.killthread then
					print("Runtime function killthread not found")
					return
				end

				runtimes[name] = api

				Enum.newValue(name, math.random(1, 1000), Enum.Language)

				return Enum.Language[name]
			end,

			GetActiveThreads = function()
				return activeThreads
			end,

			GetRuntimeThreadsActive = function(language)
				return activeThreads[language.Name]
			end,

			KillThread = function(uniqueId: string, language: Enum.Language)
				local api = runtimes[language.Name]
				if api then
					api.killthread(uniqueId)
				end
			end,

			MakeThreadObject = function(scriptInstance: Script | LocalScript)
				local language = scriptInstance.Language.Name
				if language then
					if runtimes[language] then
						local api: LanguageRuntime? = runtimes[language]
						if api then
							print("Made thread")
							return api.newthread(scriptInstance, datamodel)
						end
					else
						print("No runtime found for language " .. language)
						return
					end
				end
				return
			end,

			RunSource = function(source: string, language: string, name: string?)
				language = language or "Luau"
				name = name or "AnonymousScript" .. tostring(math.random(1, 1e9))

				local fakeScript = {
					ClassName = "Script",
					Name = name,
					Source = source,
					Enabled = true,
					UniqueId = name .. "_" .. tostring(math.random(1, 1e9)),
					Language = Enum.Language[language],
					GetFullName = function()
						return name
					end,
				}

				local api = runtimes[language]
				if not api then
					print("No runtime found for language " .. language)
					return nil
				end

				return api.newthread(fakeScript, datamodel)
			end,

			RunClientScripts = function()
				local StarterPlayer, Players, CoreGui, InternalStorage, StarterClientScripts, StarterCharacterScripts =
					getserv("StarterPlayer"),
					getserv("Players"),
					getserv("CoreGui"),
					getserv("InternalStorage"),
					datamodel.StarterPlayer.StarterPlayerScripts,
					datamodel.StarterPlayer.StarterCharacterScripts

				runScriptOfClass(StarterPlayer, "LocalScript")
				runScriptOfClass(Players, "LocalScript")
				runScriptOfClass(CoreGui, "LocalScript")
				runScriptOfClass(InternalStorage, "LocalScript")
				runScriptOfClass(StarterClientScripts, "LocalScript")
				runScriptOfClass(StarterCharacterScripts, "LocalScript")

				return true
			end,

			RunServerScripts = function()
				local ServerScriptService, ServerStorage, Workspace, StarterGui =
					getserv("ServerScriptService"),
					getserv("ServerStorage"),
					getserv("Workspace"),
					getserv("StarterGui")

				runScriptOfClass(ServerScriptService, "Script")
				runScriptOfClass(ServerStorage, "Script")
				runScriptOfClass(Workspace, "Script")
				runScriptOfClass(StarterGui, "Script")

				return true
			end,
		})
	end)
end

return ScriptContext
