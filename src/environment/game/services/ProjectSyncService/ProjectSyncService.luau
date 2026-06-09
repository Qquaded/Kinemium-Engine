local Instance = require("@Instance")
local Enum = require("@EnumMap")

local ProjectSyncService = Instance.new("LogService")
ProjectSyncService.ExplorerHidden = true
ProjectSyncService._Intents = Enum.PluginIntents.Filesystem

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
	["backups"] = true,
}

local activeState = nil
local closeRequestConnection = nil
local shutdownHookBound = false
local registerManagedInstance
local disconnectSyncListeners
local deleteRecursive
local writeInstanceToDisk
local getScriptExtension

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

-- all luau for now

local serverExts = {
	[".server.luau"] = Enum.Language.Luau,
	[".server.ts"] = Enum.Language.Luau,
	[".server.py"] = Enum.Language.Luau,
	[".server.wasm"] = Enum.Language.Luau,
}
local clientExts = {
	[".client.luau"] = Enum.Language.Luau,
	[".client.ts"] = Enum.Language.Luau,
	[".client.py"] = Enum.Language.Luau,
	[".client.wasm"] = Enum.Language.Luau,
}
local moduleExts = {
	[".luau"] = Enum.Language.Luau,
	[".ts"] = Enum.Language.Luau,
	[".py"] = Enum.Language.Luau,
	[".wasm"] = Enum.Language.Luau,
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
			ignore = { ".git", ".vscode", "autosave", "backups" },
		},
		backups = {
			interval = 300,
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

local function isSerializableInstance(instance)
	return instance.ClassName == "Folder"
		or instance.BaseClass == "ScriptContainer"
		or instance.ClassName == "Script"
		or instance.ClassName == "LocalScript"
		or instance.ClassName == "ModuleScript"
end

local function markDiskWrite(state, path)
	if state and path then
		state.localWrites[path] = true
	end
end

local function writeFileFromEngine(state, path, contents)
	markDiskWrite(state, path)
	fs.writeFile(path, contents or "")
end

local function scheduleSourceWrite(state, instance, path, contents)
	if not state or activeState ~= state or state.active ~= true then
		return
	end

	state.pendingSourceWrites = state.pendingSourceWrites or {}
	state.pendingSourceWriteTasks = state.pendingSourceWriteTasks or {}
	state.pendingSourceWrites[path] = {
		instance = instance,
		contents = contents or "",
	}

	if state.pendingSourceWriteTasks[path] then
		return
	end

	state.pendingSourceWriteTasks[path] = task.spawn(function()
		task.wait(0.5)
		state.pendingSourceWriteTasks[path] = nil

		if activeState ~= state or state.active ~= true then
			return
		end

		local pending = state.pendingSourceWrites and state.pendingSourceWrites[path]
		if not pending then
			return
		end
		state.pendingSourceWrites[path] = nil

		if pending.instance ~= instance then
			return
		end

		local nextSource = pending.contents
		local okRead, currentSource = pcall(fs.readFile, path)
		if okRead and currentSource == nextSource then
			return
		end

		local okWrite, err = pcall(writeFileFromEngine, state, path, nextSource)
		if not okWrite then
			state.lastError = tostring(err)
			warn(`[ProjectSync] Failed writing script source '{path}': {state.lastError}`)
		end
	end)
end

local function connectSyncListener(state, connection)
	state.syncConnections = state.syncConnections or {}
	table.insert(state.syncConnections, connection)
end

local function getDiskPathForAddedChild(parent, child)
	local parentSource = parent:GetAttribute(ATTR_SOURCE)
	if not parentSource then
		return nil
	end

	local diskParentPath = parentSource
	local statOk, stat = pcall(fs.stat, parentSource)
	if statOk and stat and stat.kind == "file" then
		diskParentPath = fs.path.dirname(parentSource)
	end

	if child.ClassName == "Folder" then
		return fs.path.join(diskParentPath, child.Name)
	end

	if
		child.BaseClass == "ScriptContainer"
		or child.ClassName == "Script"
		or child.ClassName == "LocalScript"
		or child.ClassName == "ModuleScript"
	then
		local serializableChildren = {}
		for _, grandchild in ipairs(child:GetChildren()) do
			if isSerializableInstance(grandchild) then
				table.insert(serializableChildren, grandchild)
			end
		end

		local ext = getScriptExtension(child.ClassName, child.Language)
		if #serializableChildren == 0 then
			return fs.path.join(diskParentPath, child.Name .. ext)
		end
		return fs.path.join(diskParentPath, child.Name, "init" .. ext)
	end

	return nil
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

local function getManagedRemovalPath(instance)
	local sourcePath = instance:GetAttribute(ATTR_SOURCE)
	if not sourcePath then
		return nil
	end

	if instance.ClassName == "Folder" then
		return sourcePath
	end

	local sourceName = fs.path.basename(sourcePath)
	if sourceName and sourceName:match("^init%.") then
		return fs.path.dirname(sourcePath)
	end

	return sourcePath
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
		registerManagedInstance(state, pointerName, container)
	else
		local dirName = fs.path.basename(dirPath)
		container = Instance.new("Folder")
		container.Name = dirName
		tagManagedInstance(state, pointerName, container, dirPath, relativePath)
		container.Parent = parentObject
		registerManagedInstance(state, pointerName, container)
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
			registerManagedInstance(state, pointerName, child)
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

disconnectSyncListeners = function(state)
	if not state or not state.syncConnections then
		return
	end

	for _, connection in ipairs(state.syncConnections) do
		pcall(function()
			connection:Disconnect()
		end)
	end

	state.syncConnections = {}
	state.registeredInstances = {}
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
		lastBackupPath = state.lastBackupPath,
		lastBackupAt = state.lastBackupAt,
		roots = roots,
	}
end

local function getBackupInterval(config)
	local backupsConfig = config and config.backups or nil
	if type(backupsConfig) == "table" and type(backupsConfig.interval) == "number" then
		return math.max(backupsConfig.interval, 0)
	end

	local syncConfig = config and config.sync or nil
	if type(syncConfig) == "table" then
		if type(syncConfig.backupInterval) == "number" then
			return math.max(syncConfig.backupInterval, 0)
		end
		if type(syncConfig.backup_interval) == "number" then
			return math.max(syncConfig.backup_interval, 0)
		end
		if type(syncConfig.backupEvery) == "number" then
			return math.max(syncConfig.backupEvery, 0)
		end
	end

	return 300
end

local function getBackupDirectory(projectPath)
	return fs.path.join(projectPath, "backups")
end

local function getBackupName()
	return os.date("backup-%Y%m%d-%H%M%S.kine")
end

local function getBackupInstances(datamodel)
	local saved = {}
	for _, service in ipairs(datamodel:GetChildren()) do
		if service.Name == "Players" then
			continue
		end

		if service:GetChildren()[1] ~= nil then
			table.insert(saved, service)
		end
	end
	return saved
end

local function saveProjectBackup(state, reason)
	if not state or state.active ~= true then
		return nil
	end

	local SerializationService = state.game:GetService("SerializationService")
	local serialized = SerializationService.SerializeInstancesAsync(getBackupInstances(state.game))
	if not serialized then
		return nil
	end

	local backupsPath = getBackupDirectory(state.projectPath)
	fs.makeDir(backupsPath, true)

	local backupPath = fs.path.join(backupsPath, getBackupName())
	fs.writeFile(backupPath, serialized)
	state.lastBackupPath = backupPath
	state.lastBackupAt = os.time()
	state.lastBackupReason = reason or "interval"
	return backupPath
end

local function saveProjectBackupSafe(state, reason)
	if not state or state.active ~= true then
		return nil
	end

	local isCloseSave = reason == "close_request" or reason == "shutdown_hook" or reason == "stop_syncing"
	if isCloseSave and state.closeRequestBackupSaved then
		return state.lastBackupPath
	end

	local ok, result = pcall(saveProjectBackup, state, reason)
	if not ok then
		state.lastError = tostring(result)
		warn(`[ProjectSync] Backup failed ({reason or "manual"}): {state.lastError}`)
		return nil
	end

	if isCloseSave and result ~= nil then
		state.closeRequestBackupSaved = true
	end

	return result
end

local function saveActiveProjectBackup(reason)
	if not activeState or activeState.active ~= true then
		return nil
	end

	return saveProjectBackupSafe(activeState, reason)
end

local function getLatestBackupPath(projectPath)
	local backupsPath = getBackupDirectory(projectPath)
	local ok, entries = pcall(fs.entries, backupsPath)
	if not ok or not entries then
		return nil
	end

	local latest = nil
	for _, entry in ipairs(entries) do
		if entry.kind == "file" and entry.name:match("%.kine$") then
			if not latest or entry.name > latest.name then
				latest = entry
			end
		end
	end

	return latest and fs.path.join(backupsPath, latest.name) or nil
end

local function shouldPreserveRuntimeChild(target, child)
	if not target or not child then
		return false
	end

	if target.ClassName == "Workspace" and child.ClassName == "Camera" then
		return true
	end

	return false
end

local function restoreBackupInstance(datamodel, instance)
	local target = datamodel:FindFirstChild(instance.Name)
	if target then
		for _, child in ipairs(target:GetChildren()) do
			if child:GetAttribute(ATTR_PROJECT) == nil and not shouldPreserveRuntimeChild(target, child) then
				child:Destroy()
			end
		end

		for _, child in ipairs(instance:GetChildren()) do
			if shouldPreserveRuntimeChild(target, child) then
				child:Destroy()
				continue
			end
			child.Parent = target
		end

		instance:Destroy()

		if target.ClassName == "Workspace" and target.Camera == nil then
			for _, child in ipairs(target:GetChildren()) do
				if child.ClassName == "Camera" then
					pcall(function()
						target.Camera = child
					end)
					break
				end
			end
		end
	else
		instance.Parent = datamodel
	end
end

local function loadLatestProjectBackup(state)
	local backupPath = getLatestBackupPath(state.projectPath)
	if not backupPath then
		return nil
	end

	local SerializationService = state.game:GetService("SerializationService")
	local read = fs.readFile(backupPath, true)
	local deserialized = SerializationService.Deserialize(read, nil, true)
	if not deserialized then
		return nil
	end

	local restored = 0
	if type(deserialized) == "table" and deserialized[1] ~= nil then
		for _, instance in ipairs(deserialized) do
			restoreBackupInstance(state.game, instance)
			restored += 1
		end
	else
		restoreBackupInstance(state.game, deserialized)
		restored += 1
	end

	state.lastBackupPath = backupPath
	return restored
end

local function stopBackupLoop(state)
	if state and state.backupTask then
		pcall(task.cancel, state.backupTask)
		state.backupTask = nil
	end
end

local function startBackupLoop(state)
	stopBackupLoop(state)

	local interval = getBackupInterval(state.config)
	if interval <= 0 then
		return
	end

	state.backupTask = task.spawn(function()
		while activeState == state and state.active == true do
			task.wait(interval)
			if activeState ~= state or state.active ~= true then
				break
			end

			saveProjectBackupSafe(state, "interval")
		end
	end)
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

	disconnectSyncListeners(state)
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

	state.syncingFromDisk = true
	local okSync, syncErr = pcall(function()
		for _, root in ipairs(roots) do
			syncDirectory(state, root.name, root.dirPath, root.target, true, ignoreLookup, "")
		end
	end)
	state.syncingFromDisk = false

	if not okSync then
		error(syncErr)
	end

	for _, root in ipairs(roots) do
		registerManagedInstance(state, root.name, root.target, root.dirPath, "")
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
		if state.localWrites and state.localWrites[changedPath] then
			state.localWrites[changedPath] = nil
			return
		end
		if type(changedPath) == "string" and changedPath:gsub("\\", "/"):find("/backups/", 1, true) then
			return
		end
		scheduleRefresh(state, "watch", changedPath, events)
	end)
end

local function stopState(state, clearManaged)
	if not state then
		return
	end

	cancelPendingRefresh(state)
	stopWatcher(state)
	stopBackupLoop(state)
	disconnectSyncListeners(state)
	state.active = false

	if clearManaged == true then
		local old = state.options.clearManaged
		state.options.clearManaged = true
		cleanupManagedRoots(state)
		state.options.clearManaged = old
	end
end

getScriptExtension = function(className, language)
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

deleteRecursive = function(path)
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

writeInstanceToDisk = function(instance, diskParentPath)
	if instance.ClassName == "Folder" then
		local dirPath = fs.path.join(diskParentPath, instance.Name)
		pcall(fs.makeDir, dirPath, true)
		for _, child in ipairs(instance:GetChildren()) do
			writeInstanceToDisk(child, dirPath)
		end
	elseif
		instance.BaseClass == "ScriptContainer"
		or instance.ClassName == "Script"
		or instance.ClassName == "LocalScript"
		or instance.ClassName == "ModuleScript"
	then
		local serializableChildren = {}
		for _, child in ipairs(instance:GetChildren()) do
			if
				child.ClassName == "Folder"
				or child.BaseClass == "ScriptContainer"
				or child.ClassName == "Script"
				or child.ClassName == "LocalScript"
				or child.ClassName == "ModuleScript"
			then
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

registerManagedInstance = function(state, pointerName, instance, sourcePath, relativePath)
	if not state or not instance or state.active == false then
		return
	end

	if state.registeredInstances and state.registeredInstances[instance] then
		return
	end

	state.registeredInstances = state.registeredInstances or {}
	state.registeredInstances[instance] = true

	if sourcePath then
		instance:SetAttribute(ATTR_PROJECT, state.projectId)
		instance:SetAttribute(ATTR_POINTER, pointerName)
		instance:SetAttribute(ATTR_SOURCE, sourcePath)
		instance:SetAttribute(ATTR_RELATIVE, relativePath or "")
	end

	if
		instance.BaseClass == "ScriptContainer"
		or instance.ClassName == "Script"
		or instance.ClassName == "LocalScript"
		or instance.ClassName == "ModuleScript"
	then
		connectSyncListener(
			state,
			instance:GetPropertyChangedSignal("Source"):Connect(function()
				if activeState ~= state or state.active ~= true or state.syncingFromDisk == true then
					return
				end

				local path = instance:GetAttribute(ATTR_SOURCE)
				if not path then
					return
				end

				scheduleSourceWrite(state, instance, path, instance.Source or "")
			end)
		)
	end

	connectSyncListener(
		state,
		instance.ChildAdded:Connect(function(child)
			if activeState ~= state or state.active ~= true or state.syncingFromDisk == true then
				return
			end

			if not isSerializableInstance(child) then
				return
			end

			task.spawn(function()
				local path = getDiskPathForAddedChild(instance, child)
				if not path then
					return
				end

				local parentRelative = instance:GetAttribute(ATTR_RELATIVE) or ""
				local relativeName = child.ClassName == "Folder" and child.Name or fs.path.basename(path)
				local childRelative = joinRelative(parentRelative, relativeName)

				local okWrite, err = pcall(function()
					local parentSource = instance:GetAttribute(ATTR_SOURCE)
					local diskParentPath = parentSource
					local okStat, stat = pcall(fs.stat, parentSource)
					if okStat and stat and stat.kind == "file" then
						diskParentPath = fs.path.dirname(parentSource)
					end
					writeInstanceToDisk(child, diskParentPath)
				end)

				if not okWrite then
					state.lastError = tostring(err)
					warn(`[ProjectSync] Failed writing added instance '{child.Name}': {state.lastError}`)
					return
				end

				tagManagedInstance(state, pointerName, child, path, childRelative)
				registerManagedInstance(state, pointerName, child)
			end)
		end)
	)

	connectSyncListener(
		state,
		instance.ChildRemoved:Connect(function(child)
			if activeState ~= state or state.active ~= true or state.syncingFromDisk == true then
				return
			end

			task.spawn(function()
				local path = getManagedRemovalPath(child)
				if not path or child:GetAttribute(ATTR_PROJECT) ~= state.projectId then
					return
				end

				local okDelete, err = pcall(deleteRecursive, path)
				if not okDelete then
					state.lastError = tostring(err)
					warn(`[ProjectSync] Failed deleting removed instance '{path}': {state.lastError}`)
				end
			end)
		end)
	)
end

ProjectSyncService.InitRenderer = function(renderer, renderer_signal, game)
	if not shutdownHookBound and renderer and renderer.Hook and renderer.Hook.new then
		shutdownHookBound = true
		renderer.Hook.new("Shutdown", function()
			saveActiveProjectBackup("shutdown_hook")
		end)
	end

	if closeRequestConnection == nil and renderer_signal and renderer_signal.Connect then
		closeRequestConnection = renderer_signal:Connect(function(route)
			if route == "CloseRequested" or route == "ShutdownRequested" then
				saveActiveProjectBackup("close_request")
			end
		end)
	end

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
				syncConnections = {},
				registeredInstances = {},
				localWrites = {},
				pendingSourceWrites = {},
				pendingSourceWriteTasks = {},
				backupTask = nil,
				lastBackupPath = nil,
				lastBackupAt = nil,
				lastBackupReason = nil,
				closeRequestBackupSaved = false,
				syncingFromDisk = false,
				lastError = nil,
				lastReason = "start",
				lastSyncAt = nil,
				syncCount = 0,
				syncedObjects = 0,
			}

			activeState = state
			print(`[ProjectSync] StartSyncing: {projectPath}`)

			local ok, err = pcall(function()
				loadLatestProjectBackup(state)
				performSync(state, "start")
				startWatcher(state)
				startBackupLoop(state)
			end)

			if not ok then
				state.lastError = tostring(err)
				activeState = nil
				stopState(state, true)
				print("Failed syncing project: " .. err)
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
				startBackupLoop(activeState)
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
			saveProjectBackupSafe(state, "stop_syncing")
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
