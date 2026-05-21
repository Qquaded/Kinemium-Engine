local Instance = require("@Instance")
local Enum = require("@EnumMap")

local ProjectSyncService = Instance.new("LogService")
ProjectSyncService.ExplorerHidden = true

local toml = zune.serde.toml
local fs = zune.fs
local task = zune.task

local ATTR_PROJECT = "ProjectSyncProject"
local ATTR_POINTER = "ProjectSyncPointer"
local ATTR_SOURCE = "ProjectSyncSource"
local ATTR_RELATIVE = "ProjectSyncRelative"

local DEFAULT_IGNORE = {
	[".git"] = true,
	[".vscode"] = true,
	["autosave"] = true,
}

local activeState = nil

local function resolvePath(root, path)
	local current = root

	for segment in path:gmatch("[^%.]+") do
		if segment == "game" then
			current = root
		else
			if not current then
				return nil
			end
			current = current:FindFirstChild(segment)
		end
	end

	return current
end

local serverExts = {
	[".server.luau"] = Enum.Language.Luau,
	[".server.ts"] = Enum.Language.JavaScript,
	[".server.py"] = Enum.Language.Python,
	[".server.wasm"] = Enum.Language.WASM,
}
local clientExts = {
	[".client.luau"] = Enum.Language.Luau,
	[".client.ts"] = Enum.Language.JavaScript,
	[".client.py"] = Enum.Language.Python,
	[".client.wasm"] = Enum.Language.WASM,
}
local moduleExts = {
	[".luau"] = Enum.Language.Luau,
	[".ts"] = Enum.Language.JavaScript,
	[".py"] = Enum.Language.Python,
	[".wasm"] = Enum.Language.WASM,
}

local function makeScript(scriptType, name, source, language, runContext)
	local new = Instance.new(scriptType)
	new.Source = source
	new.Name = name
	new.Language = language
	new.RunContext = runContext or Enum.RunContext.Server
	new.BaseClass = "ScriptContainer"
	return new
end

local function getExtension(name: string): string
	local double = name:match("%.[^.]+%.[^.]+$")
	if double then
		return double
	end
	return name:match("%.[^.]+$") or ""
end

local function stripExtension(name: string, ext: string): string
	return name:sub(1, #name - #ext)
end

local function buildDefaultProjectConfig(projectPath)
	local projectName = fs.path.basename(projectPath)

	return {
		info = {
			name = projectName,
		},
		pointers = {
			assets = "game.ReplicatedStorage",
			server = "game.ServerScriptService",
			client = "game.StarterPlayerScripts",
			gui = "game.StarterGui",
			objects = "game.Workspace",
		},
		sync = {
			live = false,
			debounce = 0.35,
			ignore = { ".git", ".vscode", "autosave" },
		},
		scripting = {
			polyglot = true,
			ntvcg = true,
		},
	}
end

local function canRepairProjectConfig(projectPath)
	local required = { "assets", "server", "client", "gui", "objects" }

	for _, dirName in ipairs(required) do
		local stat = fs.stat(fs.path.join(projectPath, dirName))
		if stat.kind ~= "directory" then
			return false
		end
	end

	return true
end

local function joinRelative(base, child)
	if not base or base == "" then
		return child
	end
	return base .. "/" .. child
end

local function normalizeProjectId(projectPath)
	local ok, result = pcall(fs.realPath, projectPath)
	if ok and result and result ~= "" then
		return result
	end
	return projectPath
end

local function makeIgnoreLookup(configIgnore)
	local lookup = {}

	for name, enabled in pairs(DEFAULT_IGNORE) do
		if enabled then
			lookup[name] = true
		end
	end

	if type(configIgnore) == "table" then
		for _, name in ipairs(configIgnore) do
			if type(name) == "string" and name ~= "" then
				lookup[name] = true
			end
		end

		for name, enabled in pairs(configIgnore) do
			if type(name) == "string" and enabled == true then
				lookup[name] = true
			end
		end
	end

	return lookup
end

local function shouldIgnoreName(name, ignoreLookup)
	if ignoreLookup[name] then
		return true
	end

	if name:sub(1, 1) == "." and not name:match("^init%.") then
		return true
	end

	return false
end

local function getScriptDescriptor(name)
	local ext = getExtension(name)
	local scriptType = "ModuleScript"
	local language = Enum.Language.Luau
	local runContext = Enum.RunContext.Server

	if serverExts[ext] then
		scriptType = "Script"
		language = serverExts[ext]
		runContext = Enum.RunContext.Server
	elseif clientExts[ext] then
		scriptType = "LocalScript"
		language = clientExts[ext]
		runContext = Enum.RunContext.Client
	elseif moduleExts[ext] then
		language = moduleExts[ext]
	else
		return nil
	end

	return {
		ext = ext,
		scriptType = scriptType,
		language = language,
		runContext = runContext,
	}
end

local function tagManagedInstance(state, pointerName, instance, sourcePath, relativePath)
	instance:SetAttribute(ATTR_PROJECT, state.projectId)
	instance:SetAttribute(ATTR_POINTER, pointerName)
	instance:SetAttribute(ATTR_SOURCE, sourcePath)
	instance:SetAttribute(ATTR_RELATIVE, relativePath)
	state.syncedObjects += 1
end

local function clearManagedChildren(target, projectId, pointerName)
	local children = target:GetChildren()

	for _, child in ipairs(children) do
		if child:GetAttribute(ATTR_PROJECT) == projectId and child:GetAttribute(ATTR_POINTER) == pointerName then
			child:Destroy()
		end
	end
end

local function sortEntries(entries)
	table.sort(entries, function(a, b)
		if a.kind ~= b.kind then
			return a.kind == "directory"
		end
		return string.lower(a.name) < string.lower(b.name)
	end)
end

local function syncDirectory(state, pointerName, dirPath, parentObject, isRoot, ignoreLookup, relativePath)
	local entries = fs.entries(dirPath)
	sortEntries(entries)

	local initEntry = nil
	for _, entry in ipairs(entries) do
		if entry.kind == "file" and not shouldIgnoreName(entry.name, ignoreLookup) and entry.name:match("^init%.") then
			initEntry = entry
			break
		end
	end

	local container
	if isRoot then
		container = parentObject
	elseif initEntry then
		local initPath = fs.path.join(dirPath, initEntry.name)
		local source = fs.readFile(initPath)
		local descriptor = getScriptDescriptor(initEntry.name)
		if not descriptor then
			error(`[ProjectSync] Unsupported init script '{initEntry.name}' in '{dirPath}'`)
		end

		local dirName = fs.path.basename(dirPath)
		container = makeScript(descriptor.scriptType, dirName, source, descriptor.language, descriptor.runContext)
		tagManagedInstance(state, pointerName, container, initPath, relativePath)
		container.Parent = parentObject
	else
		local dirName = fs.path.basename(dirPath)
		container = Instance.new("Folder")
		container.Name = dirName
		tagManagedInstance(state, pointerName, container, dirPath, relativePath)
		container.Parent = parentObject
	end

	for _, entry in ipairs(entries) do
		if shouldIgnoreName(entry.name, ignoreLookup) then
			continue
		end

		if entry.kind == "file" and entry.name:match("^init%.") then
			continue
		end

		local entryPath = fs.path.join(dirPath, entry.name)
		local entryRelativePath = joinRelative(relativePath, entry.name)

		if entry.kind == "directory" then
			syncDirectory(state, pointerName, entryPath, container, false, ignoreLookup, entryRelativePath)
		elseif entry.kind == "file" then
			local descriptor = getScriptDescriptor(entry.name)
			if not descriptor then
				continue
			end

			local source = fs.readFile(entryPath)
			local name = stripExtension(entry.name, descriptor.ext)
			local child = makeScript(descriptor.scriptType, name, source, descriptor.language, descriptor.runContext)
			tagManagedInstance(state, pointerName, child, entryPath, entryRelativePath)
			child.Parent = container
		end
	end
end

local function readProjectConfig(projectPath)
	local configPath = projectPath .. "/kproj.toml"
	local okRead, configFile = pcall(fs.readFile, configPath)

	if not okRead then
		error(`[ProjectSync] Failed to read project config '{configPath}': {tostring(configFile)}`)
	end

	local trimmed = string.gsub(configFile or "", "%s+", "")
	if trimmed == "" then
		if canRepairProjectConfig(projectPath) then
			local repaired = buildDefaultProjectConfig(projectPath)
			fs.writeFile(configPath, toml.encode(repaired))
			warn(`[ProjectSync] Repaired empty project config at '{configPath}'`)
			return repaired, configPath
		end

		error(`[ProjectSync] Project config is empty: '{configPath}'`)
	end

	local okDecode, decoded = pcall(toml.decode, configFile)
	if not okDecode then
		if canRepairProjectConfig(projectPath) then
			local repaired = buildDefaultProjectConfig(projectPath)
			fs.writeFile(configPath, toml.encode(repaired))
			warn(`[ProjectSync] Repaired invalid project config at '{configPath}'`)
			return repaired, configPath
		end

		error(`[ProjectSync] Failed to decode project config '{configPath}': {tostring(decoded)}`)
	end

	if decoded == nil then
		if canRepairProjectConfig(projectPath) then
			local repaired = buildDefaultProjectConfig(projectPath)
			fs.writeFile(configPath, toml.encode(repaired))
			warn(`[ProjectSync] Repaired undecodable project config at '{configPath}'`)
			return repaired, configPath
		end

		error(`[ProjectSync] Project config decoded to nil: '{configPath}'`)
	end

	return decoded, configPath
end

local function resolveRoots(projectPath, config, game)
	local roots = {}
	local missing = {}
	local pointers = config.pointers or {}

	for dirName, pointer in pairs(pointers) do
		local service = resolvePath(game, pointer)
		if not service then
			table.insert(missing, `[ProjectSync] Could not resolve pointer '{pointer}' for '{dirName}'`)
			continue
		end

		local dirPath = fs.path.join(projectPath, dirName)
		local stat = fs.stat(dirPath)
		if stat.kind ~= "directory" then
			table.insert(missing, `[ProjectSync] Missing project directory '{dirPath}'`)
			continue
		end

		table.insert(roots, {
			name = dirName,
			pointer = pointer,
			dirPath = dirPath,
			target = service,
		})
	end

	table.sort(roots, function(a, b)
		return string.lower(a.name) < string.lower(b.name)
	end)

	return roots, missing
end

local function shouldEnableWatch(state)
	if state.options.watch ~= nil then
		return state.options.watch == true
	end

	local syncConfig = state.config and state.config.sync or nil
	if type(syncConfig) == "table" then
		if syncConfig.live ~= nil then
			return syncConfig.live == true
		end
		if syncConfig.watch ~= nil then
			return syncConfig.watch == true
		end
	end

	return false
end

local function getDebounceDelay(state)
	if type(state.options.debounce) == "number" then
		return math.max(state.options.debounce, 0)
	end

	local syncConfig = state.config and state.config.sync or nil
	if type(syncConfig) == "table" and type(syncConfig.debounce) == "number" then
		return math.max(syncConfig.debounce, 0)
	end

	return 0.35
end

local function stopWatcher(state)
	if state and state.watcher then
		pcall(function()
			state.watcher:stop()
		end)
		state.watcher = nil
	end
end

local function cancelPendingRefresh(state)
	if state and state.pendingRefresh then
		pcall(task.cancel, state.pendingRefresh)
		state.pendingRefresh = nil
	end
end

local function snapshotState(state)
	if not state then
		return {
			active = false,
		}
	end

	local roots = {}
	for _, root in ipairs(state.roots or {}) do
		table.insert(roots, {
			name = root.name,
			pointer = root.pointer,
			dirPath = root.dirPath,
			target = root.target and root.target:GetFullName() or nil,
		})
	end

	return {
		active = state.active == true,
		projectPath = state.projectPath,
		projectId = state.projectId,
		watching = state.watcher ~= nil,
		lastReason = state.lastReason,
		lastError = state.lastError,
		lastSyncAt = state.lastSyncAt,
		syncCount = state.syncCount or 0,
		syncedObjects = state.syncedObjects or 0,
		lastWatchPath = state.lastWatchPath,
		lastWatchEvents = state.lastWatchEvents,
		roots = roots,
	}
end

local function cleanupManagedRoots(state)
	if not state or state.options.clearManaged == false then
		return
	end

	for _, root in ipairs(state.roots or {}) do
		clearManagedChildren(root.target, state.projectId, root.name)
	end
end

local function performSync(state, reason)
	local config, configPath = readProjectConfig(state.projectPath)
	local roots, warnings = resolveRoots(state.projectPath, config, state.game)
	local ignoreLookup = makeIgnoreLookup(config.sync and config.sync.ignore)

	cleanupManagedRoots(state)

	state.config = config
	state.roots = roots
	state.ignoreLookup = ignoreLookup
	state.lastReason = reason or "manual"
	state.lastError = nil
	state.syncedObjects = 0
	state.lastConfigPath = configPath

	for _, warningMessage in ipairs(warnings) do
		warn(warningMessage)
	end

	for _, root in ipairs(roots) do
		syncDirectory(state, root.name, root.dirPath, root.target, true, ignoreLookup, "")
	end

	state.syncCount = (state.syncCount or 0) + 1
	state.lastSyncAt = os.time()
end

local function scheduleRefresh(state, reason, changedPath, events)
	cancelPendingRefresh(state)
	state.lastWatchPath = changedPath
	state.lastWatchEvents = events

	state.pendingRefresh = task.spawn(function()
		task.wait(getDebounceDelay(state))
		state.pendingRefresh = nil

		if activeState ~= state or state.active ~= true then
			return
		end

		local ok, err = pcall(function()
			performSync(state, reason or "watch")
		end)

		if not ok then
			state.lastError = tostring(err)
			warn(`[ProjectSync] Refresh failed: {state.lastError}`)
		end
	end)
end

local function startWatcher(state)
	stopWatcher(state)

	if not shouldEnableWatch(state) then
		return
	end

	state.watcher = fs.watch(state.projectPath, function(changedPath, events)
		scheduleRefresh(state, "watch", changedPath, events)
	end)
end

local function stopState(state, clearManaged)
	if not state then
		return
	end

	cancelPendingRefresh(state)
	stopWatcher(state)
	state.active = false

	if clearManaged == true then
		local old = state.options.clearManaged
		state.options.clearManaged = true
		cleanupManagedRoots(state)
		state.options.clearManaged = old
	end
end

local function getScriptExtension(className, language)
	local langExt = "luau"
	if language == Enum.Language.JavaScript then
		langExt = "ts"
	elseif language == Enum.Language.Python then
		langExt = "py"
	elseif language == Enum.Language.WASM then
		langExt = "wasm"
	end

	if className == "Script" then
		return ".server." .. langExt
	elseif className == "LocalScript" then
		return ".client." .. langExt
	else
		return "." .. langExt
	end
end

local function deleteRecursive(path)
	local ok, stat = pcall(fs.stat, path)
	if not ok or not stat or stat.kind == "none" then
		return
	end
	if stat.kind == "file" then
		pcall(fs.deleteFile, path)
	elseif stat.kind == "directory" then
		local entries = fs.entries(path)
		if entries then
			for _, entry in ipairs(entries) do
				deleteRecursive(fs.path.join(path, entry.name))
			end
		end
		pcall(fs.deleteDir, path)
		pcall(fs.removeDir, path)
		pcall(fs.deleteFile, path)
		pcall(fs.removeFile, path)
	end
end

local function writeInstanceToDisk(instance, diskParentPath)
	if instance.ClassName == "Folder" then
		local dirPath = fs.path.join(diskParentPath, instance.Name)
		pcall(fs.makeDir, dirPath, true)
		for _, child in ipairs(instance:GetChildren()) do
			writeInstanceToDisk(child, dirPath)
		end
	elseif instance.BaseClass == "ScriptContainer" or instance.ClassName == "Script" or instance.ClassName == "LocalScript" or instance.ClassName == "ModuleScript" then
		local serializableChildren = {}
		for _, child in ipairs(instance:GetChildren()) do
			if child.ClassName == "Folder" or child.BaseClass == "ScriptContainer" or child.ClassName == "Script" or child.ClassName == "LocalScript" or child.ClassName == "ModuleScript" then
				table.insert(serializableChildren, child)
			end
		end

		if #serializableChildren == 0 then
			local ext = getScriptExtension(instance.ClassName, instance.Language)
			local fileName = instance.Name .. ext
			pcall(fs.writeFile, fs.path.join(diskParentPath, fileName), instance.Source or "")
		else
			local dirPath = fs.path.join(diskParentPath, instance.Name)
			pcall(fs.makeDir, dirPath, true)
			local ext = getScriptExtension(instance.ClassName, instance.Language)
			local initName = "init" .. ext
			pcall(fs.writeFile, fs.path.join(dirPath, initName), instance.Source or "")
			for _, child in ipairs(serializableChildren) do
				writeInstanceToDisk(child, dirPath)
			end
		end
	end
end

ProjectSyncService.InitRenderer = function(renderer, renderer_signal, game)
	ProjectSyncService:SetProperties({
		StartSyncing = function(self, projectPath, options)
			if not projectPath or projectPath == "" then
				return nil
			end

			if activeState then
				stopState(activeState, true)
			end

			local state = {
				active = true,
				projectPath = projectPath,
				projectId = normalizeProjectId(projectPath),
				game = game,
				options = options or {},
				roots = {},
				config = nil,
				ignoreLookup = nil,
				watcher = nil,
				pendingRefresh = nil,
				lastError = nil,
				lastReason = "start",
				lastSyncAt = nil,
				syncCount = 0,
				syncedObjects = 0,
			}

			activeState = state
			print(`[ProjectSync] StartSyncing: {projectPath}`)

			local ok, err = pcall(function()
				performSync(state, "start")
				startWatcher(state)
			end)

			if not ok then
				state.lastError = tostring(err)
				activeState = nil
				stopState(state, true)
				error(err)
			end

			return snapshotState(state)
		end,

		Refresh = function(self)
			if not activeState then
				return nil
			end

			local ok, err = pcall(function()
				performSync(activeState, "manual_refresh")
				startWatcher(activeState)
			end)

			if not ok then
				activeState.lastError = tostring(err)
				error(err)
			end

			return snapshotState(activeState)
		end,

		StopSyncing = function(self, clearManaged)
			if not activeState then
				return {
					active = false,
				}
			end

			local state = activeState
			activeState = nil
			stopState(state, clearManaged == true)
			return snapshotState(state)
		end,

		SyncToDirectory = function(self, projectPath)
			if not projectPath or projectPath == "" then
				if activeState then
					projectPath = activeState.projectPath
				else
					return nil, "No active project and no project path provided"
				end
			end

			local ok, err = pcall(function()
				local config = readProjectConfig(projectPath)
				local roots, warnings = resolveRoots(projectPath, config, game)

				for _, root in ipairs(roots) do
					local dirPath = root.dirPath
					-- Clean the directory on disk recursively
					local statOk, stat = pcall(fs.stat, dirPath)
					if statOk and stat and stat.kind == "directory" then
						local entries = fs.entries(dirPath)
						if entries then
							for _, entry in ipairs(entries) do
								deleteRecursive(fs.path.join(dirPath, entry.name))
							end
						end
					else
						pcall(fs.makeDir, dirPath, true)
					end

					-- Sync children of root.target to disk
					for _, child in ipairs(root.target:GetChildren()) do
						writeInstanceToDisk(child, dirPath)
					end
				end
			end)

			if not ok then
				warn(`[ProjectSync] SyncToDirectory failed: {tostring(err)}`)
				return false, tostring(err)
			end

			return true
		end,

		IsSyncing = function()
			return activeState ~= nil and activeState.active == true
		end,

		GetStatus = function()
			return snapshotState(activeState)
		end,

		GetConfig = function(self, projectPath)
			if projectPath == nil or projectPath == "" then
				if not activeState then
					return nil
				end
				return activeState.config
			end

			local config = readProjectConfig(projectPath)
			return config
		end,

		ScheduleRefresh = function(self, reason)
			if not activeState then
				return nil
			end

			scheduleRefresh(activeState, reason or "scheduled")
			return true
		end,
	})
end

return ProjectSyncService
