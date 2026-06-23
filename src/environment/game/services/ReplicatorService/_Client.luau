local Client = {}

local Protocol = require("../NetworkService/Protocol")
local Shared = require("./Shared")
local PredictionBuffer = require("./PredictionBuffer")
local CFrame = require("@CFrame")
local Vector3 = require("@Vector3")
local Enum = require("@EnumMap")
local InputActionService = require("../InputActionService/InputActionService")
local GNS = require("@GNS")

-- ═══ CONFIGURATION ═══

local OWNED_STATE_SEND_RATE = 15 -- Target Hz for owned-state sends from client
local NO_OWNED_STATE_LOG_INTERVAL_SECONDS = 10 -- Log interval when no owned objects exist
local DEBUG_CREATE_TRACE = false -- Verbose Create message logging

-- ═══ HELPERS ═══

local function packArgs(...)
	return table.pack(...)
end

-- ═══ Client.init(context) ═══
-- Called once by ReplicatorService.InitRenderer when running as client.
-- Sets up lookup table, event handlers, message handlers, and tick/render hooks.
function Client.init(context)
	print("[Replicator][Client] ===== Client.init START =====")
	local game = context.game
	local serializationService = context.SerializationService
	local networkService = context.NetworkService
	local stateRegistry = context.StateRegistry
	local networkOwnership = context.NetworkOwnership
	local userdata = serializationService.userdata
	local runService = game:GetService("RunService")
	print("[Replicator][Client] Services resolved")

	-- Register custom serializer adapters with error handling
	local ok, SerializerAdapters = pcall(function()
		return GNS.SerializerAdapters
	end)
	if ok and SerializerAdapters and SerializerAdapters.EnsureRegistered then
		SerializerAdapters.EnsureRegistered()
	elseif not ok then
		print("[Replicator][Client] SerializerAdapters not available, using default serializers")
	end

	-- ═══ CORE STATE ═══

	local lookup = {} -- NetworkId → Instance (client-side object map)
	local singletonByClass = {} -- ClassName → existing local singleton (e.g. Camera)
	local characterModelsByUserId = {}
	local characterModelsByName = {}
	local ignoredCreateNetIds = {} -- NetworkIds to silently ignore on Create
	local processedCreateNetIds = {} -- Track all NetworkIds we've successfully created (for duplicate detection)
	local deferredReferencePatches = {} -- Patches waiting for referenced object to arrive
	local MAX_DEFERRED_PATCHES = 256 -- Cap on deferred patch queue
	local DEFERRED_PATCH_TTL = 30 -- Seconds; discard entries older than this
	local remoteTargets = {} -- NetId → latest snapshot state for interpolation
	local pendingSnapshots = {} -- netId → latest snapshot state received before the object existed in lookup
	local pendingSnapshotsCount = 0
	local MAX_PENDING_SNAPSHOTS = 512
	local monitors = {} -- Instance → Changed connection
	local mutedObjects = setmetatable({}, { __mode = "k" })
	local predictionBuffer = PredictionBuffer.new(128) -- For owned-state prediction/reconciliation
	local clientBaselineCache = {} -- tick → { netId → fullState } for delta decompression
	local MAX_BASELINE_CACHE_SIZE = 64 -- Limit cache size to prevent memory leaks
	local workspace = game:GetService("Workspace")
	local protectedWorkspaceSingletonClasses = {
		Camera = true,
		Terrain = true,
	}
	local ownedStateSequence = 0
	local outboundOwnedPatchEntries = {} -- Queued owned property patches
	local lastNoOwnedStateLogTick = -math.huge
	local lastOwnedStateSendTick = -math.huge
	local lastOwnedStatesById = {} -- For change detection (only send if state changed)
	local terrain = game:GetService("Workspace"):FindFirstChild("Terrain")
	local humanoidRootDebugAt = {}
	local flushPendingSnapshot -- Forward-declared; assigned below
	local remoteFunctionRequestId = 0
	local pendingRemoteFunctionInvocations = {}
	local worldLoadedHandled = false

	-- ═══ OBJECT IDENTIFICATION ═══

	local function isHumanoidRootObject(object)
		if object == nil then
			return false
		end

		if object.GetAttribute and object:GetAttribute("__humanoidRigRoot") == true then
			return true
		end

		return object.Name == "HumanoidRootPart"
	end

	local function shouldLogHumanoidRoot(stage, object, interval)
		if not isHumanoidRootObject(object) then
			return false
		end

		local key = `{stage}:{object.NetworkId or "?"}`
		local now = os.clock()
		local minInterval = interval or 0.5
		if now - (humanoidRootDebugAt[key] or -math.huge) < minInterval then
			return false
		end

		humanoidRootDebugAt[key] = now
		return true
	end

	local function formatVector3(value)
		if type(value) ~= "table" or type(value.X) ~= "number" then
			return "nil"
		end

		return `({string.format("%.2f", value.X)}, {string.format("%.2f", value.Y)}, {string.format("%.2f", value.Z)})`
	end

	-- ═══ BASELINE MAP CACHE ═══
	-- Find the best baseline map for a given tick. Used for delta decompression.

	local function getBestBaselineMap(baseTick)
		local exact = clientBaselineCache[baseTick]
		if exact then
			return exact, baseTick
		end

		local bestTick = nil
		for tick in pairs(clientBaselineCache) do
			if tick <= baseTick and (bestTick == nil or tick > bestTick) then
				bestTick = tick
			end
		end

		if bestTick ~= nil then
			return clientBaselineCache[bestTick], bestTick
		end

		return {}, nil
	end

	-- ═══ STATE POSITION DECODING ═══

	local function decodeStatePosition(state)
		if type(state) ~= "table" or type(state.cframe) ~= "table" then
			return nil
		end

		local ok, cframe = pcall(CFrame.FromTable, state.cframe)
		if not ok or cframe == nil then
			return nil
		end

		return cframe.Position
	end

	local function logHumanoidRootState(stage, object, state, extra)
		if not shouldLogHumanoidRoot(stage, object) then
			return
		end

		local owner = object.NetworkOwner and object.NetworkOwner.Name or "Server"
		local livePos = (object.CFrame and object.CFrame.Position) or object.Position
		--[[ Debug logging; uncomment for humanoid state tracking
		local statePos = decodeStatePosition(state)
		if DEBUG_CREATE_TRACE then
			print(
			`[HumanoidDebug][Client][{stage}] object={object.Name}#{object.NetworkId or "?"} owner={owner} live={formatVector3(
				livePos
			)} state={formatVector3(statePos)} {extra or ""}`
		)
		end
		--]]
	end

	-- ═══ TRANSFORM INTERPOLATION ═══
	-- Interpolates BasePart CFrame for smooth remote object movement.

	local function applyInterpolatedBasePartTransform(object, cframe)
		if not object or not cframe then
			return
		end

		object.CFrame = cframe

		if cframe.Position then
			object.Position = cframe.Position
		end

		if cframe.ToOrientation then
			local rx, ry, rz = cframe:ToOrientation()
			local orientation = Vector3.new(rx, ry, rz)
			object.Orientation = orientation
			object.Rotation = orientation
		end
	end

	-- ═══ TERRAIN ACCESS ═══

	local function getTerrain()
		if not terrain or terrain.Parent == nil then
			terrain = game:GetService("Workspace"):FindFirstChild("Terrain")
		end

		return terrain
	end

	local function tryGetService(className)
		local ok, service = pcall(function()
			return game:GetService(className)
		end)
		if ok then
			return service
		end
		return nil
	end

	-- ═══ CORE SINGLETON SETUP ═══
	-- Populate the singleton table with locally-existing core services.

	local coreServices = {
		["DataModel"] = game,
		["Workspace"] = game:GetService("Workspace"),
		["Players"] = game:GetService("Players"),
		["ReplicatedStorage"] = game:GetService("ReplicatedStorage"),
		["InternalStorage"] = game:GetService("InternalStorage"),
		["StarterGui"] = game:GetService("StarterGui"),
		["CoreGui"] = tryGetService("CoreGui"),
		["StarterPlayer"] = tryGetService("StarterPlayer"),
		["ServerScriptService"] = tryGetService("ServerScriptService"),
		["ServerStorage"] = tryGetService("ServerStorage"),
		["Lighting"] = tryGetService("Lighting"),
	}

	for className, service in pairs(coreServices) do
		singletonByClass[className] = service
	end

	local localCamera = workspace:FindFirstChild("Camera")
	if localCamera then
		singletonByClass["Camera"] = localCamera
	end
	local localTerrain = getTerrain()
	if localTerrain then
		singletonByClass["Terrain"] = localTerrain
	end

	-- Register the reserved singleton IDs in the lookup
	lookup[0] = game
	lookup[1] = game:GetService("Workspace")
	lookup[2] = game:GetService("Players")
	lookup[3] = game:GetService("ReplicatedStorage")
	lookup[4] = game:GetService("StarterGui")
	lookup[5] = coreServices["CoreGui"]
	lookup[6] = game:GetService("InternalStorage")

	-- ═══ PENDING PARENT QUEUE ═══
	-- Objects whose parent hasn't arrived yet are queued here.

	local pendingParentQueue = {}

	local function isReplicationSettled()
		return pendingSnapshotsCount == 0 and #deferredReferencePatches == 0
	end

	-- ═══ COLLECT KNOWN NETWORK IDS ═══
	-- Gather all NetworkIds currently in the client's object tree.
	-- Sent to server for inventory handshake (delta-based initial sync).

	local function collectKnownNetworkIds()
		local known = {}
		local ids = { 0, 1, 2, 3, 4, 5, 6 }
		for _, id in ipairs(ids) do
			known[id] = true
		end

		for _, object in ipairs(game:GetDescendants()) do
			local netId = object.NetworkId
			if type(netId) == "number" then
				known[netId] = true
			end
		end

		local list = {}
		for netId in pairs(known) do
			table.insert(list, netId)
		end
		table.sort(list)
		return list
	end

	local function sendObjectInventoryToServer()
		if game.GetMetadata and game:GetMetadata("__blobLoading") == true then
			task.delay(0.25, sendObjectInventoryToServer)
			return
		end

		local netIds = collectKnownNetworkIds()
		print(`[Replicator][Client] Sending object inventory to server: {#netIds} netIds`)
		networkService:SendToServer(Protocol.Channels.Control, Protocol.Kinds.ClientObjectInventoryResponse, {
			netIds = netIds,
			blobFingerprint = game.GetMetadata and game:GetMetadata("__blobFingerprint") or nil,
		}, true)
	end

	-- ═══ MUTED OBJECT HELPER ═══
	-- Prevents the Changed monitor from re-queuing writes during client-initiated mutations.

	local function withMutedObject(object, callback)
		mutedObjects[object] = (mutedObjects[object] or 0) + 1

		local ok, result = pcall(callback)

		mutedObjects[object] -= 1
		if mutedObjects[object] <= 0 then
			mutedObjects[object] = nil
		end

		if not ok then
			error(result)
		end

		return result
	end

	-- ═══ REMOTE EVENT HOOKS ═══
	-- Injects FireServer into RemoteEvent instances on the client.

	local function injectRemoteEventHook(object)
		if object.ClassName == "RemoteEvent" then
			object:SetProperties({
				FireServer = function(self, ...)
					networkService:SendToServer(Protocol.Channels.Message, Protocol.Kinds.RemoteEvent, {
						object = self.NetworkId,
						args = table.pack(...),
					}, true)
				end,
			})
		elseif object.ClassName == "UnreliableRemoteEvent" then
			object:SetProperties({
				FireServer = function(self, ...)
					networkService:SendToServer(Protocol.Channels.Message, Protocol.Kinds.UnreliableRemoteEvent, {
						object = self.NetworkId,
						args = table.pack(...),
					}, false)
				end,
			})
		end
	end

	-- ═══ OWNED PATCH QUEUING ═══
	-- Queues property patches for objects owned by the local player.

	local function queueOwnedPatch(object, prop, value)
		local localPlayer = game.Players.LocalPlayer
		if not localPlayer or object.NetworkId == nil then
			return
		end
		if not networkOwnership.IsOwnedByPlayer(object, localPlayer) then
			return
		end

		local _, controller = networkOwnership.GetControllerRoot(object)
		if controller ~= nil then
			return
		end

		if not networkOwnership.ShouldReplicateProperty(object, prop) then
			return
		end

		local encoded = Shared.EncodePropertyValue(userdata, value)
		if encoded == nil then
			return
		end

		outboundOwnedPatchEntries[object.NetworkId] = outboundOwnedPatchEntries[object.NetworkId] or {}
		outboundOwnedPatchEntries[object.NetworkId][prop] = encoded
	end

	-- ═══ CLIENT-SIDE MONITOR ═══
	-- Tracks Changed signals for owned property patch queuing.

	local function monitorObject(object)
		if monitors[object] then
			return
		end

		monitors[object] = object.Changed:Connect(function(prop, value)
			if mutedObjects[object] then
				return
			end

			queueOwnedPatch(object, prop, value)
		end)
	end

	-- ═══ REMOTE DATA HOOK ═══
	-- Sends RemoteData.Data changes to the server.

	local function injectRemoteDataHook(object)
		if object.ClassName ~= "RemoteData" then
			return
		end

		object:GetPropertyChangedSignal("Data"):Connect(function(value)
			if mutedObjects[object] then
				return
			end
			if object.NetworkId == nil then
				return
			end

			local encoded = Shared.EncodePropertyValue(userdata, value)
			if encoded == nil then
				return
			end

			networkService:SendToServer(Protocol.Channels.Message, Protocol.Kinds.RemoteDataUpdate, {
				object = object.NetworkId,
				data = encoded,
			}, true)
		end)
	end

	-- ═══ MONITOR CLEANUP ═══

	local function unmonitorObject(object)
		local connection = monitors[object]
		if connection then
			connection:Disconnect()
			monitors[object] = nil
		end
	end

	-- ═══ REMOTE FUNCTION HELPERS ═══

	local function completeRemoteFunctionInvocation(requestId, payload)
		local pending = pendingRemoteFunctionInvocations[requestId]
		if not pending then
			return
		end

		pending.done = true
		pending.payload = payload
	end

	local function waitForRemoteFunctionResponse(requestId, timeout)
		local startedAt = os.clock()
		while true do
			local pending = pendingRemoteFunctionInvocations[requestId]
			if not pending then
				return nil
			end

			if pending.done then
				pendingRemoteFunctionInvocations[requestId] = nil
				return pending.payload
			end

			if os.clock() - startedAt >= timeout then
				pendingRemoteFunctionInvocations[requestId] = nil
				return {
					success = false,
					error = `RemoteFunction timed out after {string.format("%.2f", timeout)}s`,
				}
			end

			task.wait()
		end
	end

	-- ═══ REMOTE FUNCTION HOOK ═══
	-- Injects InvokeServer into RemoteFunction instances.

	local function injectRemoteFunctionHook(object)
		if object.ClassName ~= "RemoteFunction" then
			return
		end

		object:SetProperties({
			InvokeServer = function(self, ...)
				remoteFunctionRequestId += 1
				local requestId = remoteFunctionRequestId
				pendingRemoteFunctionInvocations[requestId] = {
					done = false,
					payload = nil,
				}

				local timeout = math.max(0.1, tonumber(self.InvokeTimeout) or 10)
				networkService:SendToServer(Protocol.Channels.Message, Protocol.Kinds.RemoteFunctionRequest, {
					object = self.NetworkId,
					requestId = requestId,
					args = packArgs(...),
				}, true)

				local response = waitForRemoteFunctionResponse(requestId, timeout)
				if not response then
					error("RemoteFunction invocation failed unexpectedly")
				end

				if response.success ~= true then
					error(response.error or "RemoteFunction invocation failed")
				end

				local results = response.result or {}
				return table.unpack(results, 1, results.n or #results)
			end,
		})
	end

	-- ═══ DEFERRED REFERENCE PATCHES ═══
	-- Patches that reference instances not yet in lookup are queued and retried.

	local function flushDeferredReferencePatches()
		if #deferredReferencePatches == 0 then
			return
		end

		local now = os.clock()
		local retry = {}

		for _, entry in ipairs(deferredReferencePatches) do
			if entry.addedAt and now - entry.addedAt > DEFERRED_PATCH_TTL then
				continue
			end
			if #retry >= MAX_DEFERRED_PATCHES then
				break
			end

			local object = lookup[entry.object]
			if not object then
				table.insert(retry, entry)
				continue
			end

			local decoded, ok = Shared.DecodePropertyValue(userdata, lookup, entry.value)
			if not ok then
				table.insert(retry, entry)
			else
				if object.ClassName == "Player" and entry.prop == "Character" then
					continue
				end
				withMutedObject(object, function()
					object[entry.prop] = decoded
				end)
			end
		end

		deferredReferencePatches = retry
	end

	-- ═══ TREE TRAVERSAL HELPERS ═══

	local function collectTreeEntries(rootObject)
		local entries = {}
		local stack = { rootObject }

		while #stack > 0 do
			local object = table.remove(stack)
			local netId = object._props and object._props.NetworkId or object.NetworkId

			if netId ~= nil then
				if lookup[netId] and lookup[netId] ~= object then
					return nil, netId
				end

				table.insert(entries, {
					object = object,
					netId = netId,
				})
			end

			for _, child in ipairs(object:GetChildren()) do
				table.insert(stack, child)
			end
		end

		return entries
	end

	local function visitTree(rootObject, callback)
		local stack = { rootObject }
		while #stack > 0 do
			local object = table.remove(stack)
			callback(object)
			for _, child in ipairs(object:GetChildren()) do
				table.insert(stack, child)
			end
		end
	end

	-- Reserve NetworkIds for a tree of newly-created objects.
	local function reserveTreeEntries(entries)
		for _, entry in ipairs(entries) do
			if entry.object._props then
				entry.object._props.NetworkId = nil
				entry.object._props._parentID = nil
			end

			entry.object.NetworkId = entry.netId
			lookup[entry.netId] = entry.object
			injectRemoteEventHook(entry.object)
			injectRemoteFunctionHook(entry.object)
			injectRemoteDataHook(entry.object)
		end
	end

	-- Destroy an object and all its descendants.
	local function destroyInstanceTree(rootObject)
		if not rootObject then
			return
		end

		local stack = { rootObject }
		while #stack > 0 do
			local object = table.remove(stack)
			for _, child in ipairs(object:GetChildren()) do
				table.insert(stack, child)
			end
			if object.Destroy then
				object:Destroy()
			end
		end
	end

	-- ═══ WORKSPACE TREE ADOPTION ═══
	-- If an object already exists locally in Workspace (e.g. from a blob load),
	-- adopt it by mapping NetworkIds instead of destroying and recreating.

	local function adoptReplicatedWorkspaceTree(localRoot, replicatedRoot)
		local function adoptPair(localNode, replicatedNode)
			local netId = replicatedNode._props and replicatedNode._props.NetworkId or replicatedNode.NetworkId
			if netId ~= nil then
				if localNode.NetworkId == nil then
					localNode.NetworkId = netId
				end
				lookup[netId] = localNode
				processedCreateNetIds[netId] = true
			end

			local localByName = {}
			for _, child in ipairs(localNode:GetChildren()) do
				localByName[child.Name] = child
			end

			for _, replicatedChild in ipairs(replicatedNode:GetChildren()) do
				local match = localByName[replicatedChild.Name]
				if match and match.ClassName == replicatedChild.ClassName then
					adoptPair(match, replicatedChild)
				end
			end
		end

		adoptPair(localRoot, replicatedRoot)
		destroyInstanceTree(replicatedRoot)
		return localRoot
	end

	-- Try to adopt a Workspace child server-replicated tree into the local tree.
	local function tryAdoptLocalWorkspaceRoot(object, parentNetId)
		if parentNetId ~= 1 then
			return nil
		end

		local localRoot = workspace:FindFirstChild(object.Name)
		if not localRoot or localRoot.ClassName ~= object.ClassName or localRoot.NetworkId ~= nil then
			return nil
		end

		if object.ClassName == "Model" and object.FindFirstChildOfClass and object:FindFirstChildOfClass("Humanoid") then
			if not localRoot.FindFirstChildOfClass or not localRoot:FindFirstChildOfClass("Humanoid") then
				return nil
			end
		end

		return adoptReplicatedWorkspaceTree(localRoot, object)
	end

	-- ═══ CHARACTER BINDING ═══
	-- Binds character Models to Player objects.

	local function assignCharacterToPlayer(player, character)
		if DEBUG_CREATE_TRACE then
			print(
				`[Replicator][Client] assignCharacterToPlayer: player=${player and player.Name or "nil"}, character=${character and character.Name or "nil"}`
			)
		end
		if not player or not character or player.Character == character then
			print(`[Replicator][Client]   -> skipped`)
			return
		end

		local previous = player.Character
		if previous and previous ~= character and player.CharacterRemoving then
			player.CharacterRemoving:Fire(previous)
		end

		player.Character = character
		print(`[Replicator][Client]   -> player.Character SET`)
		if player.CharacterAdded then
			player.CharacterAdded:Fire(character)
			print(`[Replicator][Client]   -> CharacterAdded fired`)
		end
	end

	local function isValidCharacterModelForPlayer(model, player)
		if not model or not player or model.ClassName ~= "Model" or model.Parent == nil then
			return false
		end

		if not model.FindFirstChildOfClass or not model:FindFirstChildOfClass("Humanoid") then
			return false
		end

		local uid = model.GetAttribute and model:GetAttribute("__characterUserId")
		if type(uid) == "number" and uid == player.UserId then
			return true
		end

		return model.Name == player.Name
	end

	local function findCharacterModelForPlayer(workspace, player)
		if not workspace or not player then
			return nil
		end

		for _, child in ipairs(workspace:GetChildren()) do
			if child.ClassName == "Model" and child.FindFirstChildOfClass then
				local humanoid = child:FindFirstChildOfClass("Humanoid")
				if humanoid then
					local uid = child.GetAttribute and child:GetAttribute("__characterUserId")
					if type(uid) == "number" and uid == player.UserId then
						return child
					end
				end
			end
		end

		local byName = workspace:FindFirstChild(player.Name)
		if byName and byName.ClassName == "Model" and byName.FindFirstChildOfClass then
			local humanoid = byName:FindFirstChildOfClass("Humanoid")
			if humanoid then
				return byName
			end
		end

		local cached = characterModelsByUserId[player.UserId] or characterModelsByName[player.Name]
		if cached and cached.Parent ~= nil and cached.FindFirstChildOfClass and cached:FindFirstChildOfClass("Humanoid") then
			return cached
		end

		return nil
	end

	local function rememberCharacterModel(model)
		if not model or model.ClassName ~= "Model" or not model.FindFirstChildOfClass then
			return
		end
		if not model:FindFirstChildOfClass("Humanoid") then
			return
		end

		local uid = model.GetAttribute and model:GetAttribute("__characterUserId")
		if type(uid) == "number" then
			characterModelsByUserId[uid] = model
		end
		characterModelsByName[model.Name] = model
	end

	local function forgetCharacterModel(model)
		if not model or model.ClassName ~= "Model" then
			return
		end

		local uid = model.GetAttribute and model:GetAttribute("__characterUserId")
		if type(uid) == "number" and characterModelsByUserId[uid] == model then
			characterModelsByUserId[uid] = nil
		end
		if characterModelsByName[model.Name] == model then
			characterModelsByName[model.Name] = nil
		end
	end

	local function detachCharacterModel(model, reason)
		if not model or model.ClassName ~= "Model" then
			return
		end

		local playersService = game:GetService("Players")
		local uid = model.GetAttribute and model:GetAttribute("__characterUserId")
		local player = nil
		if type(uid) == "number" then
			player = playersService:GetPlayerByUserId(uid)
		end
		if not player then
			player = playersService:GetPlayerByName(model.Name)
		end

		if player and player.Character == model then
			if reason ~= "server_remove" and model.NetworkId ~= nil and model.Destroyed ~= true then
				print(
					`[Replicator][Client] Preserving replicated character during local removal reason={reason or "unknown"} model={model.Name}#{model.NetworkId}`
				)
				task.defer(function()
					if player.Character == model and model.Parent == nil and model.Destroyed ~= true then
						model.Parent = game:GetService("Workspace")
						rememberCharacterModel(model)
					end
				end)
				return
			end

			print(
				`[Replicator][Client] Clearing player.Character reason={reason or "unknown"} model={model.Name}#{model.NetworkId or "?"}`
			)
			if player.CharacterRemoving then
				player.CharacterRemoving:Fire(model)
			end
			player.Character = nil
		end
		forgetCharacterModel(model)
	end

	local function destroyCharacterModelsForPlayer(player)
		local workspace = game:GetService("Workspace")
		if not workspace or not player then
			return
		end

		for _, child in ipairs(workspace:GetChildren()) do
			if child.ClassName == "Model" and child.FindFirstChildOfClass then
				local humanoid = child:FindFirstChildOfClass("Humanoid")
				if humanoid then
					local uid = child.GetAttribute and child:GetAttribute("__characterUserId")
					if (type(uid) == "number" and uid == player.UserId) or child.Name == player.Name then
						detachCharacterModel(child, "server_remove")
						child:Destroy()
					end
				end
			end
		end
	end

	local isSyncingCharacter = false

	local function ensureCharacterModelMetadata(model, player)
		if not model or model.ClassName ~= "Model" or not player then
			return
		end

		if model.SetAttribute and type(model:GetAttribute("__characterUserId")) ~= "number" then
			model:SetAttribute("__characterUserId", player.UserId)
		end
	end

	-- Sync a character model to its owning Player object.
	local function syncPlayerCharacterBindingForModel(model)
		if isSyncingCharacter then
			return
		end
		isSyncingCharacter = true
		local function finish()
			isSyncingCharacter = false
		end

		if not model or model.ClassName ~= "Model" then
			finish()
			return
		end

		local playersService = game:GetService("Players")
		local uid = model.GetAttribute and model:GetAttribute("__characterUserId")
		local player = nil

		if type(uid) == "number" then
			player = playersService:GetPlayerByUserId(uid)
		end
		if not player then
			player = playersService:GetPlayerByName(model.Name)
		end
		-- Fallback: search lookup for a Player object matching by name/userId
		if not player then
			for _, obj in pairs(lookup) do
				if obj and obj.ClassName == "Player" then
					if (type(uid) == "number" and obj.UserId == uid) or obj.Name == model.Name then
						player = obj
						break
					end
				end
			end
		end
		if not player then
			finish()
			return
		end

		if not model.FindFirstChildOfClass or not model:FindFirstChildOfClass("Humanoid") then
			finish()
			return
		end

		ensureCharacterModelMetadata(model, player)
		rememberCharacterModel(model)
		assignCharacterToPlayer(player, model)
		finish()
	end

	local function restoreHumanoidRigForModel(model)
		if not model or model.ClassName ~= "Model" or not model.FindFirstChildOfClass then
			return
		end

		local humanoid = model:FindFirstChildOfClass("Humanoid")
		if not humanoid then
			return
		end

		if humanoid.Character ~= model then
			humanoid.Character = model
		end

		if (humanoid.RootPart == nil or humanoid.RootPart.Parent ~= model) and model.FindFirstChild then
			local root = model:FindFirstChild("HumanoidRootPart")
			if root then
				humanoid.RootPart = root
			end
		end

		if humanoid.RootPart and model.PrimaryPart ~= humanoid.RootPart then
			model.PrimaryPart = humanoid.RootPart
		end

		if humanoid.RestoreRig then
			humanoid:RestoreRig()
		end
	end

	-- Find and sync a character for a Player.
	local function syncPlayerCharacterBindingForPlayer(player)
		print(`[Replicator][Client] syncCharBindingForPlayer: ${player and player.Name or "nil"}`)
		if not player then
			return
		end

		if isValidCharacterModelForPlayer(player.Character, player) then
			return
		end

		local workspace = game:GetService("Workspace")
		local character = findCharacterModelForPlayer(workspace, player)
		print(`[Replicator][Client]   findCharacterModelForPlayer = ${character and character.Name or "nil"}`)
		if character then
			ensureCharacterModelMetadata(character, player)
			rememberCharacterModel(character)
			assignCharacterToPlayer(player, character)
		end
	end

	-- ═══ PENDING PARENT QUEUE FLUSH ═══

	local function flushPendingParentQueue()
		if #pendingParentQueue == 0 then
			return
		end

		local remaining = {}
		for _, entry in ipairs(pendingParentQueue) do
			local parent = lookup[entry.parentNetId]
			if parent then
				entry.object.Parent = parent
				if entry.object.ClassName == "Model" then
					syncPlayerCharacterBindingForModel(entry.object)
					restoreHumanoidRigForModel(entry.object)
				end
			else
				table.insert(remaining, entry)
			end
		end
		pendingParentQueue = remaining
	end

	-- ═══ HANDLE CREATE ═══
	-- Deserializes server-sent object trees and integrates them into the local object tree.
	-- Handles singletons, Player matching, duplicate detection, adoption, and parenting.

	local function handleCreate(serializedBuffer)
		flushPendingParentQueue()

		if DEBUG_CREATE_TRACE then
			print(`[Replicator][Client] handleCreate: deserializing {buffer.len(serializedBuffer)} bytes...`)
		end
		local deserStart = os.clock()
		local ok, deserialized = pcall(serializationService.Deserialize, serializedBuffer)
		local deserTime = os.clock() - deserStart
		if not ok or not deserialized then
			warn(`[Replicator][Client] handleCreate: failed to deserialize batch  {deserialized}`)
			return
		end
		if DEBUG_CREATE_TRACE then
			print(
				`[Replicator][Client] handleCreate: deserialized {#deserialized} objects in {string.format(
					"%.1f",
					deserTime * 1000
				)}ms`
			)
		end

		-- Check for duplicate Create messages
		local duplicateCount = 0
		for _, object in ipairs(deserialized) do
			local netId = object._props and object._props.NetworkId
			if netId and processedCreateNetIds[netId] then
				duplicateCount += 1
			end
		end

		if duplicateCount > 0 then
			warn(
				`[Replicator][Client] Received duplicate Create message with {duplicateCount}/{#deserialized} already-created objects  rejecting duplicates`
			)
		end

		local modelNames = {}
		for _, object in ipairs(deserialized) do
			if object.ClassName == "Model" then
				table.insert(modelNames, object.Name)
			end
		end

		if DEBUG_CREATE_TRACE then
			print(
				`[Replicator][Client] Received create batch: objects={#deserialized}, bytes={buffer.len(
					serializedBuffer
				)}, models=[{table.concat(modelNames, ", ")}]`
			)
		end

		if DEBUG_CREATE_TRACE then
			print(`[Replicator][Client] handleCreate: processing {#deserialized} objects...`)
		end
		local processStart = os.clock()
		local deferred = {}
		local skippedCount = 0
		local playerCount = 0
		local singletonCount = 0
		local treeCount = 0

		for i, object in ipairs(deserialized) do
			local netId = object._props.NetworkId
			local parentNetId = object._props._parentID

			if netId == nil then
				skippedCount += 1
				continue
			end

			if ignoredCreateNetIds[netId] then
				skippedCount += 1
				continue
			end

			-- Reject duplicate Create for already-existing NetworkId
			if lookup[netId] then
				skippedCount += 1
				print(
					`[Replicator][Client] Rejecting duplicate Create for {object.ClassName}:{object.Name} with NetworkId={netId} (already exists)`
				)
				continue
			end

			-- Protected singletons (Camera, Terrain) are never replaced
			if protectedWorkspaceSingletonClasses[object.ClassName] then
				local existingSingleton = singletonByClass[object.ClassName]
					or (parentNetId == 1 and workspace:FindFirstChild(object.Name))
				if existingSingleton and existingSingleton.ClassName == object.ClassName then
					singletonByClass[object.ClassName] = existingSingleton
					if existingSingleton.NetworkId == nil then
						singletonCount += 1
						existingSingleton.NetworkId = netId
						lookup[netId] = existingSingleton
					else
						ignoredCreateNetIds[netId] = true
						skippedCount += 1
						print(
							`[Replicator][Client] Ignoring duplicate {object.ClassName} create for netId={netId}; preserving local singleton`
						)
					end
					continue
				end
			end

			-- Player matching: find existing Player by UserId or name
			if object.ClassName == "Player" then
				playerCount += 1
				print(`[Replicator][Client]   Processing Player: {object.Name} (netId={netId})`)
				local playersService = game:GetService("Players")
				local localPlayer = playersService.LocalPlayer
				if localPlayer and localPlayer.NetworkId == nil and localPlayer.Name == object.Name then
					print(`[Replicator][Client]   -> Matched LocalPlayer by name: {localPlayer.Name}`)
					localPlayer.NetworkId = netId
					localPlayer.UserId = object.UserId
					localPlayer.Parent = playersService
					lookup[netId] = localPlayer
					playersService.LocalPlayer = localPlayer
					syncPlayerCharacterBindingForPlayer(localPlayer)
					continue
				end

				local existingPlayer = playersService:GetPlayerByUserId(object.UserId)
					or playersService:GetPlayerByName(object.Name)
				if existingPlayer then
					print(
						`[Replicator][Client]   -> Matched existing player: {existingPlayer.Name} (UserId={existingPlayer.UserId})`
					)
					existingPlayer.NetworkId = existingPlayer.NetworkId or netId
					existingPlayer.UserId = object.UserId
					existingPlayer.Name = object.Name
					existingPlayer.Parent = playersService
					lookup[netId] = existingPlayer
					if playersService.LocalPlayer == nil then
						playersService.LocalPlayer = existingPlayer
					end
					continue
				else
					print(
						`[Replicator][Client]   -> No matching player found for {object.Name} (UserId={object.UserId}), LocalPlayer={localPlayer and localPlayer.Name or "nil"}`
					)
				end
			end

			-- Match other singletons by class name
			local existing = singletonByClass[object.ClassName]
			if existing and existing.NetworkId == nil then
				singletonCount += 1
				existing.NetworkId = netId
				lookup[netId] = existing
				continue
			end

			-- Try adopting a locally-existing Workspace root
			local adoptedRoot = tryAdoptLocalWorkspaceRoot(object, parentNetId)
			if adoptedRoot then
				singletonCount += 1
				if adoptedRoot.ClassName == "Model" then
					syncPlayerCharacterBindingForModel(adoptedRoot)
					restoreHumanoidRigForModel(adoptedRoot)
				end
				continue
			end

			-- New tree: reserve NetworkIds for all objects
			local treeEntries, conflictingNetId = collectTreeEntries(object)
			if not treeEntries then
				warn(
					`[Replicator][Client] Skipping duplicate create tree for {object.ClassName}:{object.Name} because NetworkId {conflictingNetId} is already mapped`
				)
				continue
			end

			reserveTreeEntries(treeEntries)
			treeCount += 1

			table.insert(deferred, {
				object = object,
				netId = netId,
				parentNetId = parentNetId,
			})

			-- Progress report and yield every 50 objects to keep network alive
			if i % 50 == 0 then
				if DEBUG_CREATE_TRACE then
					print(`[Replicator][Client]   Progress: {i}/{#deserialized} objects processed...`)
				end
				task.wait()
			end
		end

		if DEBUG_CREATE_TRACE then
			print(
				`[Replicator][Client] handleCreate: classification done  deferred={#deferred}, skipped={skippedCount}, players={playerCount}, singletons={singletonCount}, trees={treeCount}`
			)
		end

		-- ═══ PARENTING ═══

		local function tryParent(entry)
			local parent = lookup[entry.parentNetId]
			if not parent then
				return false
			end

			entry.object.Parent = parent
			if entry.object.ClassName == "Player" then
				print(`[Replicator][Client]   Parented Player: {entry.object.Name}`)
				local registry = game:GetService("Players").Players
				if not table.find(registry, entry.object) then
					table.insert(registry, entry.object)
				end
				syncPlayerCharacterBindingForPlayer(entry.object)
			elseif entry.object.ClassName == "Model" then
				print(`[Replicator][Client]   Parented Model: {entry.object.Name} to {parent.Name or parent.ClassName}`)
				syncPlayerCharacterBindingForModel(entry.object)
				restoreHumanoidRigForModel(entry.object)
			end
			return true
		end

		if DEBUG_CREATE_TRACE then
			print(`[Replicator][Client] handleCreate: parenting {#deferred} deferred objects...`)
		end
		local retryQueue = {}
		for i, entry in ipairs(deferred) do
			if not tryParent(entry) then
				table.insert(retryQueue, entry)
			end
			if i % 50 == 0 then
				task.wait()
			end
		end

		if DEBUG_CREATE_TRACE and #retryQueue > 0 then
			print(`[Replicator][Client] handleCreate: {#retryQueue} objects need retry parenting...`)
		end

		local attempts = 0
		local maxAttempts = math.max(1, #retryQueue * 2)
		local retryYieldCount = 0
		while #retryQueue > 0 and attempts < maxAttempts do
			attempts += 1
			local entry = table.remove(retryQueue, 1)
			if not tryParent(entry) then
				table.insert(retryQueue, entry)
			end
			retryYieldCount += 1
			if retryYieldCount % 50 == 0 then
				task.wait()
			end
		end

		-- Fallback parenting for objects whose parent never arrived
		for _, entry in ipairs(retryQueue) do
			if entry.parentNetId == 1 or entry.parentNetId == nil then
				if DEBUG_CREATE_TRACE then
					print(
						`[Replicator][Client]   Fallback parenting {entry.object.ClassName}:{entry.object.Name} to Workspace`
					)
				end
				entry.object.Parent = game.Workspace
				if entry.object.ClassName == "Model" then
					syncPlayerCharacterBindingForModel(entry.object)
					restoreHumanoidRigForModel(entry.object)
				end
			else
				table.insert(pendingParentQueue, entry)
				if DEBUG_CREATE_TRACE then
					print(
						`[Replicator][Client]   Deferring orphan {entry.object.ClassName}:{entry.object.Name} until parent netId={entry.parentNetId} arrives`
					)
				end
			end
		end

		flushPendingParentQueue()

		-- Final sync pass: Player objects and character Models may both arrive in the
		-- same Create batch in unpredictable order. After all objects are parented
		-- we retry bindings so neither side misses the other.
		if DEBUG_CREATE_TRACE then
			print(`[Replicator][Client] handleCreate: final sync pass...`)
		end
		for i, entry in ipairs(deferred) do
			if entry.object.ClassName == "Player" then
				syncPlayerCharacterBindingForPlayer(entry.object)
			elseif entry.object.ClassName == "Model" then
				syncPlayerCharacterBindingForModel(entry.object)
				restoreHumanoidRigForModel(entry.object)
			end
			-- Apply any snapshot state that arrived before this object was in lookup
			flushPendingSnapshot(entry.object)

			if i % 50 == 0 then
				task.wait()
			end
		end

		flushDeferredReferencePatches()

		-- Mark all successfully created NetworkIds to reject future duplicate Creates
		for _, entry in ipairs(deferred) do
			if entry.netId then
				processedCreateNetIds[entry.netId] = true
			end
		end

		local totalTime = os.clock() - processStart
		if DEBUG_CREATE_TRACE or totalTime > 0.1 or deserTime > 0.1 then
			print(
				`[Replicator][Client] handleCreate: COMPLETE in {string.format("%.1f", totalTime * 1000)}ms  {#deferred} objects parented`
			)
		end
	end

	-- ═══ APPLY PATCH ENTRY ═══
	-- Apply a single property patch, deferring reference patches if needed.

	local function applyPatchEntry(entry)
		local object = lookup[entry.object]
		if not object then
			for prop, encoded in pairs(entry.updates or {}) do
				table.insert(deferredReferencePatches, {
					object = entry.object,
					prop = prop,
					value = encoded,
					addedAt = os.clock(),
				})
			end
			return
		end

		for prop, encoded in pairs(entry.updates or {}) do
			if object.ClassName == "Player" and prop == "Character" then
				continue
			end
			local decoded, ok = Shared.DecodePropertyValue(userdata, lookup, encoded)
			if not ok then
				table.insert(deferredReferencePatches, {
					object = entry.object,
					prop = prop,
					value = encoded,
					addedAt = os.clock(),
				})
			else
				withMutedObject(object, function()
					object[prop] = decoded
				end)
				if
					object.ClassName == "Humanoid"
					and (prop == "Character" or prop == "RootPart" or prop == "RigDescriptor")
					and object.RestoreRig
				then
					object:RestoreRig()
				end
			end
		end
	end

	-- ═══ RECONCILE LOCAL STATE ═══
	-- Compares server-authoritative snapshot state with client prediction.
	-- If the client's prediction is close enough, keep it. Otherwise reconcile.

	local function reconcileLocalState(object, state, ackPredictedState)
		if object.Parent == nil or object.CFrame == nil or state.cframe == nil then
			return
		end

		local target = CFrame.FromTable(state.cframe)

		if ackPredictedState and ackPredictedState.cframe then
			local ok, predicted = pcall(CFrame.FromTable, ackPredictedState.cframe)
			if ok and predicted then
				local deltaFromPrediction = (target.Position - predicted.Position):Magnitude()
				if deltaFromPrediction < 0.2 then
					return
				end
			end
		end

		local liveDelta = (target.Position - object.CFrame.Position):Magnitude()

		if liveDelta > 0.05 then
			withMutedObject(object, function()
				stateRegistry.Apply(object, state)
			end)
		end
	end

	-- ═══ APPLY OWNERSHIP STATE ═══
	-- Sets the NetworkOwner on an object based on snapshot data.

	local function applyOwnershipState(object, state)
		if state.type ~= "BasePart" and state.type ~= "NetworkAuthorityRoot" then
			return
		end

		local owner = state.ownerNetId and lookup[state.ownerNetId] or nil
		withMutedObject(object, function()
			object.NetworkOwner = owner
			object.NetworkOwnerType = owner and Enum.MachineNetworkOwner.Client or Enum.MachineNetworkOwner.Server
		end)
	end

	-- ═══ APPLY BUFFERED SNAPSHOT ═══
	-- Applies a snapshot to an object that just arrived in lookup.

	-- Assign the forward-declared flushPendingSnapshot now that all its runtime
	-- dependencies (reconcileLocalState, applyOwnershipState) are in scope.
	local function applyBufferedSnapshot(object, state, ackPredictedState)
		-- Object may have been destroyed between the snapshot arriving and
		-- the Create packet being processed.
		if object.Parent == nil then
			return
		end
		local localPlayer = game.Players.LocalPlayer
		applyOwnershipState(object, state)
		if state.type == "BasePart" then
			if localPlayer and networkOwnership.IsOwnedReplicatedPhysicsPart(object, localPlayer) then
				reconcileLocalState(object, state, ackPredictedState)
			elseif not (localPlayer and networkOwnership.IsOwnedByPlayer(object, localPlayer)) then
				remoteTargets[state.id] = state
				withMutedObject(object, function()
					if state.linear then
						local linear = Vector3.FromTable(state.linear)
						object.AssemblyLinearVelocity = linear
						object.Velocity = linear
					end
					if state.angular then
						object.AssemblyAngularVelocity = Vector3.FromTable(state.angular)
					end
				end)
			end
		elseif state.type ~= "NetworkAuthorityRoot" then
			withMutedObject(object, function()
				stateRegistry.Apply(object, state)
			end)
		end
	end

	flushPendingSnapshot = function(object)
		if object.NetworkId == nil then
			return
		end
		local buffered = pendingSnapshots[object.NetworkId]
		if not buffered then
			return
		end
		pendingSnapshotsCount = math.max(0, pendingSnapshotsCount - 1)
		pendingSnapshots[object.NetworkId] = nil
		applyBufferedSnapshot(object, buffered.state, buffered.ackPredictedState)
	end

	-- ═══ HANDLE SNAPSHOT ═══
	-- Receives delta-compressed state snapshots, decompresses against cached baselines,
	-- and applies state to objects. Handles ack-based prediction buffer reconciliation.

	local function handleSnapshot(payload)
		local ackSequence = payload.lastProcessedOwnedStateSequence or 0
		local ackBatch = predictionBuffer.entries[ackSequence]
		local ackPredictedStates = {}
		if ackBatch then
			for _, predictedState in ipairs(ackBatch.states or {}) do
				ackPredictedStates[predictedState.id] = predictedState
			end
		end

		predictionBuffer:Acknowledge(ackSequence)

		local baseTick = payload.baseTick or 0
		local baselineMap, resolvedBaseTick = getBestBaselineMap(baseTick)
		local newBaselineMap = clientBaselineCache[payload.tick]
		if not newBaselineMap then
			newBaselineMap = {}
			for netId, baseline in pairs(baselineMap) do
				newBaselineMap[netId] = baseline
			end
		end
		local statesToApply = {}

		-- Decompress delta states against baseline map
		for _, stateOrDelta in ipairs(payload.states or {}) do
			local netId = stateOrDelta.id
			if netId == nil then
				warn(`[Replicator][Client] Dropping snapshot state without id at tick {payload.tick}`)
				continue
			end
			local baseline = newBaselineMap[netId] or baselineMap[netId]
			local fullState = stateRegistry.ApplyDelta(baseline, stateOrDelta)
			if fullState ~= nil then
				if fullState.id == nil then
					fullState.id = netId
				end
				newBaselineMap[netId] = fullState
				table.insert(statesToApply, fullState)
			elseif stateOrDelta.__isDelta then
				local fallbackSuffix = ""
				if resolvedBaseTick ~= nil then
					fallbackSuffix = ` (using fallback tick {resolvedBaseTick})`
				end
				warn(
					`[Replicator][Client] Dropping delta for object {tostring(netId)} at tick {payload.tick} because object baseline was unavailable for base tick {baseTick}`
						.. fallbackSuffix
				)
			end
		end

		clientBaselineCache[payload.tick] = newBaselineMap

		-- Clean up old entries and enforce maximum cache size
		local cacheEntries = {}
		for t in pairs(clientBaselineCache) do
			if t < payload.tick - 120 then
				clientBaselineCache[t] = nil
			else
				table.insert(cacheEntries, t)
			end
		end

		-- If cache exceeds maximum size, remove oldest entries
		if #cacheEntries > MAX_BASELINE_CACHE_SIZE then
			table.sort(cacheEntries)
			for i = 1, #cacheEntries - MAX_BASELINE_CACHE_SIZE do
				clientBaselineCache[cacheEntries[i]] = nil
			end
		end

		-- First pass: apply ownership
		for _, state in ipairs(statesToApply) do
			local object = lookup[state.id]
			if object then
				applyOwnershipState(object, state)
			end
		end

		-- Second pass: apply physics state with reconciliation
		local localPlayer = game.Players.LocalPlayer
		for _, state in ipairs(statesToApply) do
			local object = lookup[state.id]
			local ackPredictedState = ackPredictedStates[state.id]
			if not object then
				if not pendingSnapshots[state.id] then
					if pendingSnapshotsCount < MAX_PENDING_SNAPSHOTS then
						pendingSnapshots[state.id] = { state = state, ackPredictedState = ackPredictedState }
						pendingSnapshotsCount += 1
					end
				else
					pendingSnapshots[state.id] = { state = state, ackPredictedState = ackPredictedState }
				end
				continue
			end

			logHumanoidRootState("snapshot-received", object, state, `ack={ackSequence}`)

			if state.type == "BasePart" then
				if localPlayer and networkOwnership.IsOwnedReplicatedPhysicsPart(object, localPlayer) then
					reconcileLocalState(object, state, ackPredictedState)
				elseif not (localPlayer and networkOwnership.IsOwnedByPlayer(object, localPlayer)) then
					remoteTargets[state.id] = state
					withMutedObject(object, function()
						if state.linear then
							local linear = Vector3.FromTable(state.linear)
							object.AssemblyLinearVelocity = linear
							object.Velocity = linear
						end
						if state.angular then
							object.AssemblyAngularVelocity = Vector3.FromTable(state.angular)
						end
					end)
					logHumanoidRootState("remote-target-set", object, state, "")
				end
			elseif state.type ~= "NetworkAuthorityRoot" then
				withMutedObject(object, function()
					stateRegistry.Apply(object, state)
				end)
			end
		end
	end

	-- ═══ COLLECT OWNED STATES ═══
	-- Gathers current state of all objects owned by the local player for unreliably sent snapshots.

	local function collectOwnedStates(localPlayer)
		local states = {}

		for _, object in pairs(lookup) do
			if
				object
				and object.Parent ~= nil
				and stateRegistry.ResolveAdapter(object)
				and not (object.GetAttribute and object:GetAttribute("__humanoidRigSkipOwnedState") == true)
				and networkOwnership.IsOwnedReplicatedPhysicsPart(object, localPlayer)
			then
				local state = stateRegistry.Capture(object)
				if state then
					table.insert(states, state)
					logHumanoidRootState("capture-owned", object, state, `player={localPlayer.Name}`)
				end
			end
		end

		return states
	end

	-- ═══ SHOULD SEND OWNED STATES ═══
	-- Rate-limits owned state sends and avoids sending when state hasn't changed.

	local function shouldSendOwnedStates(tick, states)
		local tickRate = tonumber(networkService.TickRate) or 30
		local minTicksBetweenSends = math.max(1, math.ceil(tickRate / OWNED_STATE_SEND_RATE))
		if tick - lastOwnedStateSendTick < minTicksBetweenSends then
			return false
		end

		local changed = false
		local seen = {}
		for _, state in ipairs(states) do
			seen[state.id] = true
			local previous = lastOwnedStatesById[state.id]
			if not previous or not stateRegistry.StatesEqual(previous, state) then
				changed = true
			end
		end

		if not changed then
			for id in pairs(lastOwnedStatesById) do
				if not seen[id] then
					changed = true
					break
				end
			end
		end

		if not changed then
			return false
		end

		lastOwnedStatesById = {}
		for _, state in ipairs(states) do
			lastOwnedStatesById[state.id] = stateRegistry.CloneState(state)
		end
		lastOwnedStateSendTick = tick
		return true
	end

	-- ═══ FLUSH OWNED PATCH ENTRIES ═══
	-- Sends queued owned property patches to the server.

	local function flushOwnedPatchEntries()
		if next(outboundOwnedPatchEntries) == nil then
			return
		end

		local entries = {}
		for netId, updates in pairs(outboundOwnedPatchEntries) do
			table.insert(entries, {
				object = netId,
				updates = updates,
			})
		end

		outboundOwnedPatchEntries = {}
		networkService:SendToServer(Protocol.Channels.Input, Protocol.Kinds.OwnedPatchBatch, {
			entries = entries,
		}, true)
	end

	-- ═══ DESCENDANT TRACKING ═══
	-- Client-side tracking for locally-created objects that already have NetworkIds.

	game.DescendantAdded:Connect(function(object)
		visitTree(object, function(descendant)
			if descendant.NetworkId ~= nil then
				lookup[descendant.NetworkId] = descendant
			end
			flushPendingSnapshot(descendant)
			injectRemoteEventHook(descendant)
			injectRemoteFunctionHook(descendant)
			injectRemoteDataHook(descendant)
			monitorObject(descendant)
		end)
		flushDeferredReferencePatches()
	end)

	game.DescendantRemoving:Connect(function(object)
		visitTree(object, function(descendant)
			if descendant.ClassName == "Model" then
				detachCharacterModel(descendant, "local_descendant_removing")
			end
			if descendant.NetworkId ~= nil then
				lookup[descendant.NetworkId] = nil
				remoteTargets[descendant.NetworkId] = nil
				outboundOwnedPatchEntries[descendant.NetworkId] = nil
				processedCreateNetIds[descendant.NetworkId] = nil
				if pendingSnapshots[descendant.NetworkId] then
					pendingSnapshotsCount = math.max(0, pendingSnapshotsCount - 1)
					pendingSnapshots[descendant.NetworkId] = nil
				end
			end
			unmonitorObject(descendant)
		end)
	end)

	-- Inject hooks into all existing objects
	for _, object in ipairs(game:GetDescendants()) do
		injectRemoteEventHook(object)
		injectRemoteFunctionHook(object)
		injectRemoteDataHook(object)
		monitorObject(object)
	end

	-- ═══ CREATE QUEUE ═══
	-- Pending Create buffers are processed asynchronously to avoid blocking the network loop.

	local pendingCreateBuffers = {}
	local drainingCreateQueue = false

	local function drainCreateQueue()
		if drainingCreateQueue then
			return
		end

		drainingCreateQueue = true
		task.spawn(function()
			while #pendingCreateBuffers > 0 do
				local serializedBuffer = table.remove(pendingCreateBuffers, 1)
				local ok, err = pcall(handleCreate, serializedBuffer)
				if not ok then
					warn(`[Replicator][Client] handleCreate failed: {err}`)
				end
			end
			drainingCreateQueue = false
		end)
	end

	local function enqueueCreate(serializedBuffer)
		table.insert(pendingCreateBuffers, serializedBuffer)
		drainCreateQueue()
	end

	-- ═══ MESSAGE HANDLER: Create ═══

	networkService:RegisterMessageHandler(Protocol.Channels.Replication, Protocol.Kinds.Create, function(_, payload)
		enqueueCreate(payload.objects)
	end)

	-- ═══ MESSAGE HANDLER: Remove ═══

	networkService:RegisterMessageHandler(Protocol.Channels.Replication, Protocol.Kinds.Remove, function(_, payload)
		if ignoredCreateNetIds[payload.object] then
			ignoredCreateNetIds[payload.object] = nil
			return
		end

		local object = lookup[payload.object]
		if object then
			if object.ClassName == "Player" then
				local playersService = game:GetService("Players")
				if object == playersService.LocalPlayer then
					lookup[payload.object] = nil
					remoteTargets[payload.object] = nil
					outboundOwnedPatchEntries[payload.object] = nil
					processedCreateNetIds[payload.object] = nil
					if pendingSnapshots[payload.object] then
						pendingSnapshotsCount = math.max(0, pendingSnapshotsCount - 1)
						pendingSnapshots[payload.object] = nil
					end
					unmonitorObject(object)
					return
				end
				destroyCharacterModelsForPlayer(object)
			elseif object.ClassName == "Model" then
				detachCharacterModel(object, "server_remove")
			end
			lookup[payload.object] = nil
			remoteTargets[payload.object] = nil
			outboundOwnedPatchEntries[payload.object] = nil
			unmonitorObject(object)
			object:Destroy()
		end
	end)

	-- ═══ MESSAGE HANDLER: PatchBatch ═══

	networkService:RegisterMessageHandler(Protocol.Channels.Replication, Protocol.Kinds.PatchBatch, function(_, payload)
		for _, entry in ipairs(payload.entries or {}) do
			applyPatchEntry(entry)
		end
		flushDeferredReferencePatches()
	end)

	-- ═══ MESSAGE HANDLER: Snapshot ═══

	networkService:RegisterMessageHandler(Protocol.Channels.Replication, Protocol.Kinds.Snapshot, function(_, payload)
		handleSnapshot(payload)
		networkService:SendToServer(Protocol.Channels.Replication, Protocol.Kinds.SnapshotAck, {
			tick = payload.tick,
		}, false)
	end)

	-- ═══ MESSAGE HANDLER: TerrainSnapshot ═══

	networkService:RegisterMessageHandler(
		Protocol.Channels.Replication,
		Protocol.Kinds.TerrainSnapshot,
		function(_, payload)
			local terrainObject = getTerrain()
			if terrainObject and type(terrainObject.ApplyReplicationSnapshot) == "function" then
				terrainObject:ApplyReplicationSnapshot(payload)
			end
		end
	)

	-- ═══ MESSAGE HANDLER: TerrainChunkBatch ═══

	networkService:RegisterMessageHandler(
		Protocol.Channels.Replication,
		Protocol.Kinds.TerrainChunkBatch,
		function(_, payload)
			local terrainObject = getTerrain()
			if terrainObject and type(terrainObject.ApplyReplicationChunkBatch) == "function" then
				terrainObject:ApplyReplicationChunkBatch(payload)
			end
		end
	)

	-- ═══ MESSAGE HANDLER: RemoteEvent (client receiving) ═══

	networkService:RegisterMessageHandler(Protocol.Channels.Message, Protocol.Kinds.RemoteEvent, function(_, payload)
		local object = lookup[payload.object]
		if not object or object.ClassName ~= "RemoteEvent" then
			return
		end

		local args = payload.args or {}
		if type(object.OnClientEvent.Fire) == "function" then
			object.OnClientEvent:Fire(table.unpack(args, 1, args.n or #args))
		end
	end)

	-- ═══ MESSAGE HANDLER: UnreliableRemoteEvent (client receiving) ═══

	networkService:RegisterMessageHandler(
		Protocol.Channels.Message,
		Protocol.Kinds.UnreliableRemoteEvent,
		function(_, payload)
			local object = lookup[payload.object]
			if not object or object.ClassName ~= "UnreliableRemoteEvent" then
				return
			end

			local args = payload.args or {}
			if type(object.OnClientEvent.Fire) == "function" then
				object.OnClientEvent:Fire(table.unpack(args, 1, args.n or #args))
			end
		end
	)

	-- ═══ MESSAGE HANDLER: RemoteFunctionRequest (server → client) ═══

	networkService:RegisterMessageHandler(
		Protocol.Channels.Message,
		Protocol.Kinds.RemoteFunctionRequest,
		function(_, payload)
			local object = lookup[payload.object]
			if not object or object.ClassName ~= "RemoteFunction" then
				return
			end

			local invokeHandler = object.OnClientInvoke
			local args = payload.args or {}
			local ok, resultsOrError = pcall(function()
				if type(invokeHandler) ~= "function" then
					error(`RemoteFunction {object.Name} is missing OnClientInvoke`)
				end

				return packArgs(invokeHandler(table.unpack(args, 1, args.n or #args)))
			end)

			if ok then
				networkService:SendToServer(Protocol.Channels.Message, Protocol.Kinds.RemoteFunctionResponse, {
					object = payload.object,
					requestId = payload.requestId,
					success = true,
					result = resultsOrError,
				}, true)
			else
				networkService:SendToServer(Protocol.Channels.Message, Protocol.Kinds.RemoteFunctionResponse, {
					object = payload.object,
					requestId = payload.requestId,
					success = false,
					error = tostring(resultsOrError),
				}, true)
			end
		end
	)

	-- ═══ MESSAGE HANDLER: RemoteFunctionResponse (client receiving) ═══

	networkService:RegisterMessageHandler(
		Protocol.Channels.Message,
		Protocol.Kinds.RemoteFunctionResponse,
		function(_, payload)
			completeRemoteFunctionInvocation(payload.requestId, payload)
		end
	)

	-- ═══ MESSAGE HANDLER: RemoteDataUpdate (client receiving) ═══

	networkService:RegisterMessageHandler(
		Protocol.Channels.Message,
		Protocol.Kinds.RemoteDataUpdate,
		function(_, payload)
			local object = lookup[payload.object]
			if not object or object.ClassName ~= "RemoteData" then
				return
			end

			local decoded, ok = Shared.DecodePropertyValue(userdata, lookup, payload.data)
			if not ok then
				return
			end

			withMutedObject(object, function()
				object.Data = decoded
			end)
		end
	)

	-- ═══ MESSAGE HANDLER: WorldLoaded ═══
	-- Server signals that initial sync is complete.

	networkService:RegisterMessageHandler(Protocol.Channels.Control, Protocol.Kinds.WorldLoaded, function(_, payload)
		if worldLoadedHandled then
			return
		end
		worldLoadedHandled = true
		task.spawn(function()
			task.wait(0.5)
			networkService:SendToServer(
				Protocol.Channels.Control,
				Protocol.Kinds.ClientReady,
				{ tick = networkService:GetCurrentTick() },
				true
			)
			-- Start character binding retry here, not at module load time
			task.spawn(function()
				local MAX_RETRIES = 30
				for attempt = 1, MAX_RETRIES do
					local localPlayer = game:GetService("Players").LocalPlayer
					if localPlayer and localPlayer.Character ~= nil then
						break
					end
					if localPlayer then
						syncPlayerCharacterBindingForPlayer(localPlayer)
						if localPlayer.Character ~= nil then
							break
						end
					end
					task.wait(1)
				end
			end)
		end)
	end)

	-- ═══ MESSAGE HANDLER: ClientObjectInventoryRequest ═══
	-- Server requests the client's known object list for delta sync.

	networkService:RegisterMessageHandler(
		Protocol.Channels.Control,
		Protocol.Kinds.ClientObjectInventoryRequest,
		function(_, _payload)
			sendObjectInventoryToServer()
		end
	)

	-- Proactively send inventory in case the request arrives before this
	-- handler is fully active or gets dropped.
	task.spawn(function()
		task.wait(0.5)
		if networkService.IsClientConnected and not worldLoadedHandled then
			sendObjectInventoryToServer()
		end
	end)

	-- Fallback: periodically retry character binding for the local player.
	-- If the initial Create message was dropped or arrived before the Player
	-- object existed, the character model sits in Workspace without being
	-- bound to player.Character.  This background loop catches that case.
	task.spawn(function()
		task.wait(2) -- give initial sync time to complete
		local MAX_RETRIES = 30
		local RETRY_INTERVAL = 1
		for attempt = 1, MAX_RETRIES do
			local playersService = game:GetService("Players")
			local localPlayer = playersService and playersService.LocalPlayer
			if localPlayer and localPlayer.Character ~= nil then
				break -- character already bound
			end

			if localPlayer then
				syncPlayerCharacterBindingForPlayer(localPlayer)
				if localPlayer.Character ~= nil then
					print(`[Replicator][Client] Fallback character binding succeeded on attempt {attempt}`)
					break
				end
			end

			task.wait(RETRY_INTERVAL)
		end
	end)

	-- ═══ INPUT → SERVER ═══
	-- In server-authoritative mode, sample inputs and send to server each simulation step.

	runService:BindToSimulation(function(dt)
		if workspace.ServerAuthority and workspace.ServerAuthority.AuthorityMode == Enum.AuthorityMode.Server then
			local inputs = InputActionService:SampleLocalInputs()
			networkService:SendToServer(Protocol.Channels.Input, Protocol.Kinds.ControllerInput, {
				tick = runService:GetSimulationTick(),
				inputs = inputs,
			}, false)
		end
	end)

	-- ═══ TICK HOOK: Send Owned States ═══

	networkService.Tick:Connect(function(tick)
		if not networkService.IsClientConnected then
			return
		end

		local localPlayer = game.Players.LocalPlayer
		if not localPlayer then
			return
		end

		local states = collectOwnedStates(localPlayer)
		if #states > 0 and shouldSendOwnedStates(tick, states) then
			ownedStateSequence += 1

			local payload = {
				sequence = ownedStateSequence,
				tick = tick,
				states = states,
			}

			predictionBuffer:Push(ownedStateSequence, payload)
			networkService:SendToServer(Protocol.Channels.Input, Protocol.Kinds.OwnedStateBatch, payload, false)
			if ownedStateSequence == 1 or ownedStateSequence % 30 == 0 then
				print(`[Replicator][Client] Sending owned state batch: sequence={ownedStateSequence}, count={#states}`)
			end
		elseif
			tick - lastNoOwnedStateLogTick >= (networkService.TickRate or 30) * NO_OWNED_STATE_LOG_INTERVAL_SECONDS
		then
			lastNoOwnedStateLogTick = tick
			print(`[Replicator][Client] No owned state objects for {localPlayer.Name} at tick {tick}`)
		end

		flushOwnedPatchEntries()
	end)

	-- ═══ RENDER STEP: Remote State Interpolation ═══
	-- Lerps remote objects toward their latest snapshot target each render frame.

	runService.RenderStepped:Connect(function(dt)
		local localPlayer = game.Players.LocalPlayer
		for netId, state in pairs(remoteTargets) do
			local object = lookup[netId]
			if not object or object.Parent == nil or object.CFrame == nil or state == nil or state.cframe == nil then
				remoteTargets[netId] = nil
				continue
			end

			if state.type ~= "BasePart" then
				remoteTargets[netId] = nil
				withMutedObject(object, function()
					stateRegistry.Apply(object, state)
				end)
				continue
			end

			if localPlayer and networkOwnership.IsOwnedByPlayer(object, localPlayer) then
				continue
			end

			withMutedObject(object, function()
				if object.Parent == nil or object.CFrame == nil then
					remoteTargets[netId] = nil
					return
				end

				local target = CFrame.FromTable(state.cframe)
				logHumanoidRootState("remote-target-step", object, state, `dt={string.format("%.3f", dt)}`)
				applyInterpolatedBasePartTransform(object, object.CFrame:Lerp(target, math.clamp(dt * 12, 0, 1)))
			end)
		end
	end)

	return {}
end

return Client
