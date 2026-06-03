local Server = {}

local GNS = require("@GNS")
local Protocol = require("../NetworkService/Protocol")
local Shared = require("./Shared")
local OwnedStateAntiCheat = require("./OwnedStateAntiCheat")
local PredictionBuffer = require("./PredictionBuffer")
local CFrame = require("@CFrame")
local Vector3 = require("@Vector3")
local InputActionService = require("../InputActionService/InputActionService")
local AreaOfInterest = require("./AreaOfInterest")
local Enum = require("@EnumMap")

local MAX_TERRAIN_RELIABLE_MESSAGES_PER_TICK = 10
local OWNERSHIP_REBALANCE_INTERVAL = 0.2
local REPLICATION_TARGET_BYTES = 384 * 1024 -- keep reliable Create messages small so gameplay remotes are not starved
local MAX_PATCH_ENTRIES_PER_MESSAGE = 96
local MAX_SNAPSHOT_STATES_PER_MESSAGE = 16
local INITIAL_INVENTORY_HANDSHAKE_TIMEOUT = 8
local SNAPSHOT_MIN_SEND_INTERVAL_TICKS = 6
local _SNAPSHOT_IDLE_KEEPALIVE_TICKS = 0
local SNAPSHOT_MAX_UNACKED_TICKS = 2
local SNAPSHOT_BACKPRESSURE_RETRY_TICKS = 12
local MAX_CREATE_PAYLOAD_BYTES = REPLICATION_TARGET_BYTES
local CREATE_PRE_SERIALIZE_TREE_SPLIT_COUNT = 192
local CREATE_PRE_SERIALIZE_ROOT_SPLIT_COUNT = 96
local CREATE_PRE_SERIALIZE_MAX_ROOTS_PER_BATCH = 8
local CREATE_INTER_BATCH_YIELD_SECONDS = 0.03
local CREATE_BACKPRESSURE_PENDING_LIMIT = 8
local CREATE_BACKPRESSURE_FRAGMENT_LIMIT = 128
local CREATE_BACKPRESSURE_LOG_INTERVAL_SECONDS = 10
local DEBUG_REPLICATION_TRACE = false
local REPLICATION_DIAGNOSTICS = true
local SLOW_TICK_DIAGNOSTIC_SECONDS = 0.05
local INITIAL_ROOT_DETAIL_LIMIT = 40
local STREAM_CHUNK_SIZE_DEFAULT = 192
local STREAM_RECONCILE_INTERVAL_TICKS = 3

local function packArgs(...)
	return table.pack(...)
end

function Server.init(context)
	local game = context.game
	local serializationService = context.SerializationService
	local networkService = context.NetworkService
	local _transportSerializer = GNS.Serializer
	local stateRegistry = context.StateRegistry
	local networkOwnership = context.NetworkOwnership
	local userdata = serializationService.userdata
	local runService = game:GetService("RunService")

	-- Register custom serializer adapters with error handling
	local ok, SerializerAdapters = pcall(function()
		return GNS.SerializerAdapters
	end)
	if ok and SerializerAdapters and SerializerAdapters.EnsureRegistered then
		SerializerAdapters.EnsureRegistered()
	elseif not ok then
		print("[Replicator][Server] SerializerAdapters not available, using default serializers")
	end

	local lookup = {}
	local monitors = {}
	local mutedObjects = setmetatable({}, { __mode = "k" })

	local function withMutedObject(object, callback)
		mutedObjects[object] = (mutedObjects[object] or 0) + 1
		local ok, result = pcall(callback)
		mutedObjects[object] -= 1
		if mutedObjects[object] <= 0 then
			mutedObjects[object] = nil
		end
		if not ok then
			warn(`[Replicator][Server] withMutedObject error: {result}`)
		end
	end

	local function sendRemoveToSession(session, netId)
		if not session or netId == nil then
			return
		end

		networkService:SendToClient(session, Protocol.Channels.Replication, Protocol.Kinds.Remove, { object = netId }, true)
	end

	local trackedStateObjects = {}
	local dirtyPatches = {}
	local objectStateHistory = {}
	local terrainQueueByClient = {}
	local ownershipRoots = {}
	local ownershipStateByRoot = setmetatable({}, { __mode = "k" })
	local workspace = game.Workspace or game:GetService("Workspace")
	local configuredChunkSize = tonumber(workspace and workspace.StreamingChunkSize) or STREAM_CHUNK_SIZE_DEFAULT
	local streamChunkSize = math.max(32, math.floor(configuredChunkSize))
	local streamChunkSizeInv = 1 / streamChunkSize
	local streamChunks = {}
	local streamRoots = setmetatable({}, { __mode = "k" })
	local streamRootChunkKey = setmetatable({}, { __mode = "k" })
	local streamRootsWithoutChunk = setmetatable({}, { __mode = "k" })
	local sessionStreamingState = {}
	local terrain = workspace and workspace:FindFirstChild("Terrain")
	local configuredTargetRadius = tonumber(
		workspace and (workspace.StreamingTargetRadius or workspace.StreamingMinRadius)
	)
	if configuredTargetRadius and configuredTargetRadius > 0 then
		AreaOfInterest.SetDefaultRadius(configuredTargetRadius)
	end
	local humanoidRootDebugAt = {}
	local remoteFunctionRequestId = 0
	local pendingRemoteFunctionInvocations = {}
	local pendingInitialInventorySync = {}
	local initialSyncCompleted = {}

	local readySessions = {}
	local replicatedWorkspaceBaseplate = nil
	local RUNTIME_MUTATION_SUPPRESS_KEY = "__replicatorSuppressRuntimeMutation"

	local function isRuntimeCreateSuppressed()
		if game.GetMetadata == nil then
			return false
		end

		return (game:GetMetadata("__replicatorSuppressRuntimeCreate") or 0) > 0
	end

	local function isRuntimeMutationSuppressed()
		if game.GetMetadata == nil then
			return false
		end

		return (game:GetMetadata(RUNTIME_MUTATION_SUPPRESS_KEY) or 0) > 0
	end

	local function beginRuntimeMutationSuppression()
		if game.GetMetadata == nil or game.SetMetadata == nil then
			return false
		end

		local count = game:GetMetadata(RUNTIME_MUTATION_SUPPRESS_KEY) or 0
		game:SetMetadata(RUNTIME_MUTATION_SUPPRESS_KEY, count + 1)
		return true
	end

	local function endRuntimeMutationSuppression(applied)
		if not applied or game.GetMetadata == nil or game.SetMetadata == nil then
			return
		end

		local count = math.max((game:GetMetadata(RUNTIME_MUTATION_SUPPRESS_KEY) or 0) - 1, 0)
		game:SetMetadata(RUNTIME_MUTATION_SUPPRESS_KEY, count)
	end

	local function isSessionEligibleForLiveCreate(session)
		if not session or not session.key then
			return false
		end

		return initialSyncCompleted[session.key] == true
	end

	local function hasLiveCreateRecipients()
		for _, session in ipairs(networkService:GetSessions()) do
			if isSessionEligibleForLiveCreate(session) then
				return true
			end
		end

		return false
	end

	local function isHumanoidRootObject(object)
		if type(object) ~= "table" then
			return false
		end

		if type(object.GetAttribute) == "function" and object:GetAttribute("__humanoidRigRoot") == true then
			return true
		end

		return object.Name == "HumanoidRootPart"
	end

	local function shouldLogHumanoidRoot(stage, sessionKey, object, interval)
		if not isHumanoidRootObject(object) then
			return false
		end

		local key = `{stage}:{sessionKey or "global"}:{object.NetworkId or "?"}`
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

	local function logHumanoidRootState(stage, sessionKey, object, state, extra)
		if not shouldLogHumanoidRoot(stage, sessionKey, object) then
			return
		end

		--[[
		local statePos = decodeStatePosition(state)
		print(
			`[HumanoidDebug][Server][{stage}] session={sessionKey or "global"} object={object.Name}#{object.NetworkId or "?"} owner={owner} live={formatVector3(
				livePos
			)} state={formatVector3(statePos)} {extra or ""}`
		)
			--]]
	end

	local function getOwnershipState(root)
		local state = ownershipStateByRoot[root]
		if not state then
			state = {}
			ownershipStateByRoot[root] = state
		end

		return state
	end

	local function copyArray(source)
		local copy = {}
		for index, value in ipairs(source or {}) do
			copy[index] = value
		end
		return copy
	end

	local function shallowCopy(source)
		local copy = {}
		for key, value in pairs(source or {}) do
			copy[key] = value
		end
		return copy
	end

	local function buildListPayloads(fieldName, items, basePayload, maxItems)
		if #items == 0 then
			return {}
		end

		local payloads = {}
		local current = {}

		local function flushCurrent()
			if #current == 0 then
				return
			end

			local payload = shallowCopy(basePayload)
			payload[fieldName] = copyArray(current)
			table.insert(payloads, payload)
			current = {}
		end

		for _, item in ipairs(items) do
			table.insert(current, item)

			local candidate = shallowCopy(basePayload)
			candidate[fieldName] = current
			local tooManyItems = #current > maxItems

			if #current > 1 and tooManyItems then
				local overflow = table.remove(current)
				flushCurrent()
				current = { overflow }
			end
		end

		flushCurrent()
		return payloads
	end

	local function markOwnershipCooldown(root, duration, blockedUserId)
		if not root then
			return
		end

		local now = os.clock()
		local state = getOwnershipState(root)
		local lockDuration = math.max(duration or 0, 0)
		state.cooldownUntil = math.max(state.cooldownUntil or 0, now + lockDuration)
		if blockedUserId ~= nil then
			state.blockedUserId = blockedUserId
			state.blockedUntil = math.max(state.blockedUntil or 0, now + math.max(lockDuration, 3))
		end
	end

	local antiCheat = OwnedStateAntiCheat.new({
		NetworkService = networkService,
		NetworkOwnership = networkOwnership,
		OnOwnershipRevoked = function(session, root)
			markOwnershipCooldown(root, 3, session and session.userId or nil)
		end,
	})

	local function getTerrain()
		if not terrain or terrain.Parent == nil then
			terrain = game:GetService("Workspace"):FindFirstChild("Terrain")
		end

		return terrain
	end

	local function getTerrainQueue(session)
		if not session or not session.key then
			return nil
		end

		local queue = terrainQueueByClient[session.key]
		if not queue then
			queue = {
				items = {},
				head = 1,
				tail = 0,
			}
			terrainQueueByClient[session.key] = queue
		end

		return queue
	end

	local function clearTerrainQueue(session)
		if session and session.key then
			terrainQueueByClient[session.key] = nil
		end
	end

	local function enqueueTerrainPayload(session, kind, payload)
		if payload == nil then
			return
		end
		if type(payload) == "table" and next(payload) == nil then
			return
		end
		if type(payload) == "string" and #payload == 0 then
			return
		end
		if type(payload) == "buffer" and buffer.len(payload) == 0 then
			return
		end

		local queue = getTerrainQueue(session)
		if not queue then
			return
		end

		queue.tail += 1
		queue.items[queue.tail] = {
			kind = kind,
			payload = payload,
		}
	end

	local function enqueueTerrainPayloadForSessions(kind, payload)
		for _, session in ipairs(networkService:GetSessions()) do
			enqueueTerrainPayload(session, kind, payload)
		end
	end

	local function flushTerrainQueues()
		for _, session in ipairs(networkService:GetSessions()) do
			local queue = terrainQueueByClient[session.key]
			if not queue then
				continue
			end

			local sent = 0
			while sent < MAX_TERRAIN_RELIABLE_MESSAGES_PER_TICK and queue.head <= queue.tail do
				local item = queue.items[queue.head]
				queue.items[queue.head] = nil
				queue.head += 1
				sent += 1

				if item then
					networkService:SendToClient(session, Protocol.Channels.Replication, item.kind, item.payload, true)
				end
			end

			if queue.head > queue.tail then
				terrainQueueByClient[session.key] = nil
			end
		end
	end

	local nextNetId = 100

	local function assignNetworkId(object)
		if object.NetworkId ~= nil then
			if type(object.NetworkId) == "number" then
				local occupied = lookup[object.NetworkId]
				if occupied ~= nil and occupied ~= object then
					while lookup[nextNetId] ~= nil do
						nextNetId += 1
					end
					warn(
						`[Replicator][Server] NetworkId collision for {object.ClassName}:{object.Name} requested={object.NetworkId} occupiedBy={occupied.ClassName}:{occupied.Name} reassigned={nextNetId}`
					)
					object.NetworkId = nextNetId
					nextNetId += 1
					return
				end

				if object.NetworkId >= nextNetId then
					nextNetId = object.NetworkId + 1
				end
			end
			return
		end

		if object.ClassName == "DataModel" then
			object.NetworkId = 0
		elseif object.ClassName == "Workspace" then
			object.NetworkId = 1
		elseif object.ClassName == "Players" then
			object.NetworkId = 2
		elseif object.ClassName == "ReplicatedStorage" then
			object.NetworkId = 3
		elseif object.ClassName == "InternalStorage" then
			object.NetworkId = 6
		elseif object.ClassName == "StarterGui" then
			object.NetworkId = 4
		elseif object.ClassName == "CoreGui" then
			object.NetworkId = 5
		else
			while lookup[nextNetId] ~= nil do
				nextNetId += 1
			end
			object.NetworkId = nextNetId
			nextNetId += 1
		end
	end

	local function visitTree(root, callback)
		callback(root)
		for _, descendant in ipairs(root:GetDescendants()) do
			callback(descendant)
		end
	end

	local function formatSeconds(seconds)
		return string.format("%.3f", seconds or 0)
	end

	local function describeObject(object)
		if not object then
			return "nil"
		end

		return `{object.ClassName or "?"}:{object.Name or "?"}#{object.NetworkId or "?"}`
	end

	local function countTreeObjects(root)
		if not root then
			return 0
		end

		local descendants = root:GetDescendants()
		return #descendants + 1
	end

	local function logReplicationDiagnostic(message)
		if REPLICATION_DIAGNOSTICS then
			print(`[Replicator][Server][Diag] {message}`)
		end
	end

	local function getSessionStreamState(session)
		if not session or not session.key then
			return nil
		end

		local state = sessionStreamingState[session.key]
		if not state then
			state = {
				roots = {},
				netIds = {},
			}
			sessionStreamingState[session.key] = state
		end

		return state
	end

	local function clearSessionStreamState(session)
		if session and session.key then
			sessionStreamingState[session.key] = nil
		end
	end

	local function unmarkNetIdFromAllSessions(netId)
		if netId == nil then
			return
		end

		for _, state in pairs(sessionStreamingState) do
			state.roots[netId] = nil
			state.netIds[netId] = nil
		end
	end

	local function chunkCoordFromValue(value)
		return math.floor((value or 0) * streamChunkSizeInv)
	end

	local function chunkKeyFromCoords(x, y, z)
		return `{x}|{y}|{z}`
	end

	local function chunkKeyFromPosition(position)
		if type(position) ~= "table" then
			return nil
		end

		return chunkKeyFromCoords(
			chunkCoordFromValue(position.X),
			chunkCoordFromValue(position.Y),
			chunkCoordFromValue(position.Z)
		)
	end

	local function removeRootFromChunk(root, chunkKey)
		if not root or not chunkKey then
			return
		end

		local bucket = streamChunks[chunkKey]
		if not bucket then
			return
		end

		bucket[root] = nil
		if next(bucket) == nil then
			streamChunks[chunkKey] = nil
		end
	end

	local function isStreamRoot(root)
		if not root then
			return false
		end

		if root.Parent ~= workspace or root.CanReplicate == false or root.NetworkId == nil then
			return false
		end

		if AreaOfInterest.IsGlobalEntity(root) then
			return false
		end

		return true
	end

	local function unregisterStreamRoot(root)
		if not root then
			return
		end

		streamRoots[root] = nil
		streamRootsWithoutChunk[root] = nil
		removeRootFromChunk(root, streamRootChunkKey[root])
		streamRootChunkKey[root] = nil
	end

	local function refreshStreamRootChunk(root)
		if not isStreamRoot(root) then
			unregisterStreamRoot(root)
			return
		end

		streamRoots[root] = true

		local previousChunkKey = streamRootChunkKey[root]
		local position = networkOwnership.GetWorldPosition(root)
		local nextChunkKey = chunkKeyFromPosition(position)

		if not nextChunkKey then
			if previousChunkKey then
				removeRootFromChunk(root, previousChunkKey)
				streamRootChunkKey[root] = nil
			end
			streamRootsWithoutChunk[root] = true
			return
		end

		streamRootsWithoutChunk[root] = nil
		if previousChunkKey == nextChunkKey then
			return
		end

		removeRootFromChunk(root, previousChunkKey)
		streamRootChunkKey[root] = nextChunkKey

		local nextBucket = streamChunks[nextChunkKey]
		if not nextBucket then
			nextBucket = {}
			streamChunks[nextChunkKey] = nextBucket
		end
		nextBucket[root] = true
	end

	local function registerStreamRoot(root)
		if not root then
			return
		end

		refreshStreamRootChunk(root)
	end

	local function refreshAllStreamRoots()
		for root in pairs(streamRoots) do
			refreshStreamRootChunk(root)
		end
	end

	local function markSessionRootStreamed(session, root, shallowOnly)
		if not session or not root then
			return
		end

		local state = getSessionStreamState(session)
		if not state then
			return
		end

		local rootNetId = root.NetworkId
		if rootNetId ~= nil then
			state.roots[rootNetId] = root
			state.netIds[rootNetId] = true
		end

		if shallowOnly == true then
			return
		end

		visitTree(root, function(object)
			local netId = object.NetworkId
			if netId ~= nil and object.CanReplicate ~= false then
				state.netIds[netId] = true
			end
		end)
	end

	local function unmarkSessionRootStreamed(session, root)
		if not session or not root then
			return
		end

		local state = getSessionStreamState(session)
		if not state then
			return
		end

		local rootNetId = root.NetworkId
		if rootNetId ~= nil then
			state.roots[rootNetId] = nil
			state.netIds[rootNetId] = nil
		end

		visitTree(root, function(object)
			local netId = object.NetworkId
			if netId ~= nil then
				state.netIds[netId] = nil
			end
		end)
	end

	local function markBatchStreamedForSession(session, batch)
		for _, root in ipairs(batch or {}) do
			markSessionRootStreamed(session, root, batch.__shallowRoot == true)
		end
	end

	local function shouldSuppressDuplicateWorkspaceBaseplate(object)
		if object == nil or object.CanReplicate == false then
			return false
		end
		if object.Parent ~= workspace or object.Name ~= "Baseplate" then
			return false
		end

		if
			replicatedWorkspaceBaseplate
			and replicatedWorkspaceBaseplate ~= object
			and replicatedWorkspaceBaseplate.Parent == workspace
			and replicatedWorkspaceBaseplate.CanReplicate ~= false
		then
			return true
		end

		replicatedWorkspaceBaseplate = object
		return false
	end

	local function trackObject(object)
		if shouldSuppressDuplicateWorkspaceBaseplate(object) then
			object.CanReplicate = false
			warn(
				`[Replicator][Server] Suppressing duplicate Workspace Baseplate from replication: {object.ClassName}:{object.Name}#{object.NetworkId or "?"}`
			)
			return
		end

		assignNetworkId(object)
		lookup[object.NetworkId] = object
		if stateRegistry.ResolveAdapter(object) then
			trackedStateObjects[object.NetworkId] = object
		end

		if object.Parent == workspace then
			registerStreamRoot(object)
		end
	end

	local function untrackObject(object)
		if streamRoots[object] or object.Parent == workspace then
			unregisterStreamRoot(object)
		end

		if object == replicatedWorkspaceBaseplate then
			replicatedWorkspaceBaseplate = nil
		end

		if object.NetworkId ~= nil then
			lookup[object.NetworkId] = nil
			trackedStateObjects[object.NetworkId] = nil
			objectStateHistory[object.NetworkId] = nil
			unmarkNetIdFromAllSessions(object.NetworkId)
		end
	end

	local function registerOwnershipRoot(object)
		local root, controller = networkOwnership.GetControllerRoot(object)
		if root ~= nil and controller ~= nil then
			ownershipRoots[root] = true
		elseif object.ClassName == "Part" or object.ClassName == "MeshPart" or object.BaseClass == "BasePart" then
			if object.Anchored == false then
				ownershipRoots[object] = true
			end
		end
	end

	local function unregisterOwnershipRoot(object)
		if object == nil then
			return
		end

		ownershipRoots[object] = nil
		ownershipStateByRoot[object] = nil

		local root = networkOwnership.GetAuthorityRoot(object)
		if root ~= nil and root ~= object and networkOwnership.GetController(root) == nil then
			ownershipRoots[root] = nil
			ownershipStateByRoot[root] = nil
		end
	end

	local function encodePropertyValue(value)
		return Shared.EncodePropertyValue(userdata, value)
	end

	local function queuePatch(object, prop, value)
		if object.NetworkId == nil or object.CanReplicate == false then
			return
		end
		if not Shared.ShouldReplicatePropertyForObject(object, prop) then
			return
		end
		if type(value) == "function" then
			return
		end

		local encoded = encodePropertyValue(value)
		if encoded == nil then
			return
		end

		dirtyPatches[object.NetworkId] = dirtyPatches[object.NetworkId] or {}
		dirtyPatches[object.NetworkId][prop] = encoded
	end

	local injectRemoteEventHooks
	local injectRemoteFunctionHooks
	local injectRemoteDataHooks

	local function monitor(object)
		if monitors[object] then
			return
		end

		monitors[object] = object.Changed:Connect(function(prop, value)
			if mutedObjects[object] then
				return
			end
			if prop == "Anchored" then
				if value == false then
					registerOwnershipRoot(object)
				else
					local root, controller = networkOwnership.GetControllerRoot(object)
					if root == nil or controller == nil then
						unregisterOwnershipRoot(object)
					end
				end
			elseif prop == "Parent" then
				if object.Parent == workspace then
					registerStreamRoot(object)
				elseif streamRoots[object] then
					unregisterStreamRoot(object)
				end
			end
			queuePatch(object, prop, value)
		end)
	end

	local function trackTree(root)
		visitTree(root, function(object)
			trackObject(object)
			registerOwnershipRoot(object)
			monitor(object)
			injectRemoteEventHooks(object)
			injectRemoteFunctionHooks(object)
			injectRemoteDataHooks(object)
		end)
	end

	local function untrackTree(root)
		visitTree(root, function(object)
			unregisterOwnershipRoot(object)
			untrackObject(object)
		end)
	end

	local function serializeObjects(objects)
		local startedAt = os.clock()
		local stampStartedAt = startedAt
		local stamped = {}
		local stampedCount = 0
		local rootSummary = {}

		for index, object in ipairs(objects) do
			if index <= 12 then
				table.insert(rootSummary, `{describeObject(object)} tree={countTreeObjects(object)}`)
			end
		end
		if #objects > 12 then
			table.insert(rootSummary, `...+{#objects - 12} more roots`)
		end
		logReplicationDiagnostic(`serializeObjects begin roots={#objects} [{table.concat(rootSummary, ", ")}]`)

		local function stamp(object)
			if stamped[object] then
				return
			end
			stamped[object] = {
				NetworkId = object._props.NetworkId,
				_parentID = object._props._parentID,
			}
			stampedCount += 1
			object._props.NetworkId = object.NetworkId
			object._props._parentID = object.Parent and object.Parent.NetworkId
		end

		for _, object in ipairs(objects) do
			visitTree(object, stamp)
		end
		local stampSeconds = os.clock() - stampStartedAt
		logReplicationDiagnostic(`serializeObjects stamped={stampedCount} stampSeconds={formatSeconds(stampSeconds)}`)

		-- Always restore _props even when serialization throws.
		local serializeStartedAt = os.clock()
		local ok, result = pcall(serializationService.SerializeInstancesAsync, objects)
		local serializeSeconds = os.clock() - serializeStartedAt

		for object, previous in pairs(stamped) do
			object._props.NetworkId = previous.NetworkId
			object._props._parentID = previous._parentID
		end

		if not ok then
			warn(`[Replicator][Server] serializeObjects failed after {formatSeconds(serializeSeconds)}s: {result}`)
			return nil
		end

		local payloadBytes = buffer.len(result)
		logReplicationDiagnostic(
			`serializeObjects done roots={#objects} stamped={stampedCount} bytes={payloadBytes} stampSeconds={formatSeconds(
				stampSeconds
			)} serializeSeconds={formatSeconds(serializeSeconds)} totalSeconds={formatSeconds(os.clock() - startedAt)}`
		)

		return result
	end

	local function collectSerializableRoots(roots)
		local serializable = {}
		local seen = {}

		for _, root in ipairs(roots) do
			if root and not seen[root] and root.CanReplicate ~= false then
				seen[root] = true
				table.insert(serializable, root)
			end
		end

		return serializable
	end

	local function collectReferencePatchEntries(roots)
		local entries = {}
		local seen = {}

		local function isCharacterModelObject(object)
			return object
				and object.ClassName == "Model"
				and object.GetAttribute ~= nil
				and type(object:GetAttribute("__characterUserId")) == "number"
		end

		local function isCharacterRigReference(object, prop)
			if prop == "PrimaryPart" and isCharacterModelObject(object) then
				return true
			end

			if object.ClassName ~= "Humanoid" or (prop ~= "Character" and prop ~= "RootPart") then
				return false
			end

			return isCharacterModelObject(object.Parent)
		end

		local function collect(object)
			if seen[object] then
				return
			end
			seen[object] = true

			if object.NetworkId == nil or object.CanReplicate == false then
				return
			end

			if type(object._props) ~= "table" then
				return
			end

			local updates = {}
			for prop, value in pairs(object._props) do
				if
					prop ~= "Parent"
					and Shared.ShouldReplicatePropertyForObject(object, prop)
					and not isCharacterRigReference(object, prop)
					and Shared.IsInstanceReference(value)
				then
					updates[prop] = encodePropertyValue(value)
				end
			end

			if next(updates) ~= nil then
				table.insert(entries, {
					object = object.NetworkId,
					updates = updates,
				})
			end
		end

		for _, root in ipairs(roots) do
			visitTree(root, collect)
		end

		return entries
	end

	local function isCharacterModel(object)
		return object ~= nil
			and object.ClassName == "Model"
			and object.GetAttribute ~= nil
			and type(object:GetAttribute("__characterUserId")) == "number"
	end

	local function shouldReplicateNetIdToSession(session, netId)
		if
			not AreaOfInterest.ShouldReplicateNetId(
				session,
				netId,
				lookup,
				networkOwnership.GetWorldPosition,
				networkOwnership
			)
		then
			return false
		end

		if not session or not session.key or initialSyncCompleted[session.key] ~= true then
			return true
		end

		local object = lookup[netId]
		if object and AreaOfInterest.IsGlobalEntity(object) then
			return true
		end

		local state = getSessionStreamState(session)
		return state and state.netIds[netId] == true or false
	end

	local function sendPatchEntries(recipient, entries)
		if #entries == 0 then
			return
		end

		if recipient then
			for _, payload in ipairs(buildListPayloads("entries", entries, {}, MAX_PATCH_ENTRIES_PER_MESSAGE)) do
				networkService:SendToClient(
					recipient,
					Protocol.Channels.Replication,
					Protocol.Kinds.PatchBatch,
					payload,
					true
				)
			end
			return
		end

		local sessions = networkService:GetSessions()
		local entriesBySession = {}
		for _, entry in ipairs(entries) do
			for _, session in ipairs(sessions) do
				if shouldReplicateNetIdToSession(session, entry.object) then
					local sessionEntries = entriesBySession[session]
					if not sessionEntries then
						sessionEntries = {}
						entriesBySession[session] = sessionEntries
					end
					table.insert(sessionEntries, entry)
				end
			end
		end

		for session, sessionEntries in pairs(entriesBySession) do
			for _, payload in ipairs(buildListPayloads("entries", sessionEntries, {}, MAX_PATCH_ENTRIES_PER_MESSAGE)) do
				networkService:SendToClient(
					session,
					Protocol.Channels.Replication,
					Protocol.Kinds.PatchBatch,
					payload,
					true
				)
			end
		end
	end

	local function debugTrace(message)
		if not DEBUG_REPLICATION_TRACE then
			return
		end
		print(`[Replicator][Server][Trace] {message}`)
	end

	local function sendCreate(recipient, roots, reason)
		local sendCreateStartedAt = os.clock()
		local reasonLabel = reason or "unspecified"
		logReplicationDiagnostic(
			`sendCreate begin reason={reasonLabel} recipient={recipient and recipient.key or "broadcast"} roots={roots and #roots or 0}`
		)
		debugTrace(
			`sendCreate reason={reason or "unspecified"} recipient={recipient and recipient.key or "broadcast"} roots={roots and #roots or 0}`
		)
		local serializable = collectSerializableRoots(roots)
		if #serializable == 0 then
			debugTrace(`sendCreate reason={reason or "unspecified"} -> 0 serializable roots`)
			return
		end

		local recipientLabel = recipient and (recipient.key or (recipient.address .. ":" .. recipient.port))
			or "broadcast"

		local batchesSent = 0
		local batchesQueued = 0
		local batchesSplit = 0
		local totalPayloadBytes = 0
		local totalBackpressureSeconds = 0
		local largestPayloadBytes = 0
		local largestPayloadRoots = ""
		local treeCountCache = setmetatable({}, { __mode = "k" })
		local pendingBatches = {}

		local function queueBatch(batch)
			if #batch == 0 then
				return
			end
			batchesQueued += 1
			table.insert(pendingBatches, batch)
		end

		local function queueShallowRoot(root)
			if not root then
				return
			end
			local batch = { root }
			batch.__shallowRoot = true
			queueBatch(batch)
		end

		local function getTreeCount(object)
			if not object then
				return 0
			end
			local cached = treeCountCache[object]
			if cached ~= nil then
				return cached
			end
			local count = countTreeObjects(object)
			treeCountCache[object] = count
			return count
		end

		local function collectReplicatedChildren(root)
			local children = {}
			for _, child in ipairs(root and root:GetChildren() or {}) do
				if child.CanReplicate ~= false and child.NetworkId ~= nil then
					table.insert(children, child)
				end
			end
			return children
		end

		local function serializeShallowRoot(root)
			if not root then
				return nil
			end

			local suppressionApplied = beginRuntimeMutationSuppression()
			local children = root:GetChildren()
			local detached = {}
			mutedObjects[root] = (mutedObjects[root] or 0) + 1

			for _, child in ipairs(children) do
				mutedObjects[child] = (mutedObjects[child] or 0) + 1
				table.insert(detached, child)
			end

			local ok, result = pcall(function()
				for _, child in ipairs(detached) do
					child.Parent = nil
				end
				return serializeObjects({ root })
			end)

			for _, child in ipairs(detached) do
				child.Parent = root
				mutedObjects[child] -= 1
				if mutedObjects[child] <= 0 then
					mutedObjects[child] = nil
				end
			end

			mutedObjects[root] -= 1
			if mutedObjects[root] <= 0 then
				mutedObjects[root] = nil
			end
			endRuntimeMutationSuppression(suppressionApplied)

			if not ok then
				warn(`[Replicator][Server] serializeShallowRoot failed for {describeObject(root)}: {result}`)
				return nil
			end

			return result
		end

		local function queueBalancedBatches(objects)
			local batch = {}
			local batchTreeCount = 0
			for _, object in ipairs(objects) do
				local treeCount = getTreeCount(object)
				if
					#batch > 0
					and (
						#batch >= CREATE_PRE_SERIALIZE_MAX_ROOTS_PER_BATCH
						or batchTreeCount + treeCount > CREATE_PRE_SERIALIZE_TREE_SPLIT_COUNT
					)
				then
					queueBatch(batch)
					batch = {}
					batchTreeCount = 0
				end
				table.insert(batch, object)
				batchTreeCount += treeCount
			end
			queueBatch(batch)
		end

		local function preSplitBatch(batch)
			if batch.__shallowRoot then
				return false
			end

			local totalTreeCount = 0
			local passthrough = {}
			local didSplit = false

			for _, object in ipairs(batch) do
				local treeCount = getTreeCount(object)
				totalTreeCount += treeCount

				if treeCount > CREATE_PRE_SERIALIZE_ROOT_SPLIT_COUNT and not isCharacterModel(object) then
					local children = collectReplicatedChildren(object)
					if #children > 0 then
						didSplit = true
						batchesSplit += 1
						logReplicationDiagnostic(
							`sendBatch pre-split-root reason={reasonLabel} root={describeObject(object)} tree={treeCount} children={#children}`
						)
						queueShallowRoot(object)
						queueBalancedBatches(children)
					else
						table.insert(passthrough, object)
					end
				else
					table.insert(passthrough, object)
				end
			end

			if didSplit then
				queueBalancedBatches(passthrough)
				return true
			end

			if #batch > 1 and totalTreeCount > CREATE_PRE_SERIALIZE_TREE_SPLIT_COUNT then
				batchesSplit += 1
				logReplicationDiagnostic(
					`sendBatch pre-split-batch reason={reasonLabel} roots={#batch} tree={totalTreeCount} limit={CREATE_PRE_SERIALIZE_TREE_SPLIT_COUNT}`
				)
				queueBalancedBatches(batch)
				return true
			end

			return false
		end

		local function waitForCreateBackpressure(sessions)
			local startedAt = os.clock()
			local lastWarningAt = startedAt

			while true do
				local highestPendingMessages = 0
				local highestPendingFragments = 0
				local anyConnected = false

				for _, session in ipairs(sessions or {}) do
					local client = session and session.client
					if client and GNS.Server:IsClientConnected(client) then
						anyConnected = true
						local stats = GNS.Server:GetClientStats(client)
						highestPendingMessages = math.max(highestPendingMessages, stats.pendingReliable or 0)
						highestPendingFragments = math.max(highestPendingFragments, stats.pendingReliableFragments or 0)
					end
				end

				if not anyConnected then
					totalBackpressureSeconds += os.clock() - startedAt
					return false
				end

				if
					highestPendingMessages < CREATE_BACKPRESSURE_PENDING_LIMIT
					and highestPendingFragments < CREATE_BACKPRESSURE_FRAGMENT_LIMIT
				then
					totalBackpressureSeconds += os.clock() - startedAt
					return true
				end

				local now = os.clock()
				if now - lastWarningAt > CREATE_BACKPRESSURE_LOG_INTERVAL_SECONDS then
					lastWarningAt = now
					warn(
						`[Replicator][Server] Create backpressure waiting {string.format("%.1f", now - startedAt)}s with {highestPendingMessages} unacked reliable messages ({highestPendingFragments} wire fragments)`
					)
				end

				task.wait(0.05)
			end
		end

		local function sendBatch(batch)
			if #batch == 0 then
				return
			end

			if preSplitBatch(batch) then
				return
			end

			local relevantSessions = nil
			if not recipient then
				-- Runtime broadcast: if no client has completed initial sync yet,
				-- this creation will be covered by that client's initial/inventory
				-- sync.  Avoid serializing huge blobs into a reliable queue that
				-- cannot help anyone yet.
				relevantSessions = {}
				for _, session in ipairs(networkService:GetSessions()) do
					if isSessionEligibleForLiveCreate(session) then
						local inRange = false
						for _, obj in ipairs(batch) do
							if
								AreaOfInterest.ShouldReplicateToSession(
									session,
									obj,
									networkOwnership.GetWorldPosition,
									networkOwnership
								)
							then
								inRange = true
								break
							end
						end
						if inRange then
							table.insert(relevantSessions, session)
						end
					end
				end

				if #relevantSessions == 0 then
					debugTrace(
						`sendBatch reason={reason or "unspecified"} broadcast skipped before serialize; no initial-sync-complete recipients`
					)
					return
				end
			end

			local batchStartedAt = os.clock()
			local batchNames = {}
			for index, object in ipairs(batch) do
				if index <= 12 then
					table.insert(batchNames, describeObject(object))
				end
			end
			if #batch > 12 then
				table.insert(batchNames, `...+{#batch - 12} more`)
			end
			logReplicationDiagnostic(
				`sendBatch begin reason={reasonLabel} recipient={recipientLabel} roots={#batch} pendingBefore={#pendingBatches} names=[{table.concat(
					batchNames,
					", "
				)}]`
			)
			debugTrace(`sendBatch reason={reason or "unspecified"} serializing size={#batch}`)
			local serializeStartedAt = os.clock()
			local serialized = batch.__shallowRoot and serializeShallowRoot(batch[1]) or serializeObjects(batch)
			local batchSerializeSeconds = os.clock() - serializeStartedAt
			logReplicationDiagnostic(
				`sendBatch serialized reason={reasonLabel} roots={#batch} ok={serialized ~= nil} serializeSeconds={formatSeconds(
					batchSerializeSeconds
				)}`
			)
			debugTrace(`sendBatch reason={reason or "unspecified"} serialized={serialized and "success" or "failed"}`)

			if not serialized then
				-- If the whole batch failed, try sending each root individually.
				if #batch > 1 then
					warn(
						`[Replicator][Server] sendCreate: batch serialization failed for {#batch} objects, retrying individually`
					)
					for _, root in ipairs(batch) do
						queueBatch({ root })
					end
					return
				else
					-- Single root failed  try its children.
					local root = batch[1]
					local children = root:GetChildren()
					if #children > 0 then
						warn(
							`[Replicator][Server] sendCreate: root {root.ClassName}:{root.Name} failed, splitting into {#children} children`
						)
						for _, child in ipairs(children) do
							if child.CanReplicate ~= false and child.NetworkId ~= nil then
								queueBatch({ child })
							end
						end
						return
					else
						warn(
							`[Replicator][Server] sendCreate: leaf object {root.ClassName}:{root.Name} failed to serialize, dropping`
						)
					end
				end
				return
			end

			-- Keep reliable Create payloads under a safe ceiling to avoid massive
			-- fragmentation storms that can starve ACK/control traffic.
			local payloadBytes = buffer.len(serialized)
			if payloadBytes <= 0 then
				debugTrace(`sendBatch reason={reason or "unspecified"} skipped empty serialized payload`)
				return
			end
			totalPayloadBytes += payloadBytes
			if payloadBytes > largestPayloadBytes then
				largestPayloadBytes = payloadBytes
				largestPayloadRoots = table.concat(batchNames, ", ")
			end
			if payloadBytes > MAX_CREATE_PAYLOAD_BYTES then
				debugTrace(
					`sendBatch reason={reason or "unspecified"} oversize bytes={payloadBytes} limit={MAX_CREATE_PAYLOAD_BYTES} batch={#batch}`
				)
				if batch.__shallowRoot then
					warn(
						`[Replicator][Server] sendCreate: shallow root {describeObject(batch[1])} serialized to {payloadBytes} bytes over limit {MAX_CREATE_PAYLOAD_BYTES}; sending intact`
					)
				elseif #batch == 1 and isCharacterModel(batch[1]) then
					debugTrace(
						`sendBatch reason={reason or "unspecified"} keeping oversized character model {batch[1].Name} intact`
					)
				elseif #batch > 1 then
					local midpoint = math.max(1, math.floor(#batch / 2))
					local left = {}
					local right = {}
					for i = 1, midpoint do
						table.insert(left, batch[i])
					end
					for i = midpoint + 1, #batch do
						table.insert(right, batch[i])
					end
					batchesSplit += 1
					logReplicationDiagnostic(
						`sendBatch split reason={reasonLabel} oversized bytes={payloadBytes} limit={MAX_CREATE_PAYLOAD_BYTES} roots={#batch} left={#left} right={#right}`
					)
					queueBatch(left)
					queueBatch(right)
					return
				else
					local root = batch[1]
					local children = root and root:GetChildren() or {}
					if #children > 0 then
						local splitChildren = {}
						for _, child in ipairs(children) do
							if child.CanReplicate ~= false and child.NetworkId ~= nil then
								table.insert(splitChildren, child)
							end
						end
						if #splitChildren > 0 then
							debugTrace(
								`sendBatch reason={reason or "unspecified"} split root {root.ClassName}:{root.Name} into {#splitChildren} children`
							)
							batchesSplit += 1
							logReplicationDiagnostic(
								`sendBatch split-root reason={reasonLabel} root={describeObject(root)} bytes={payloadBytes} children={#splitChildren}`
							)
							queueShallowRoot(root)
							queueBatch(splitChildren)
							return
						end
					end
				end
			end

			local rootNames = {}
			for _, object in ipairs(batch) do
				table.insert(rootNames, `{object.ClassName}:{object.Name}`)
			end

			print(
				`[Replicator][Server] Create -> {recipientLabel}: reason={reason or "unspecified"}, objects={#batch}, bytes={payloadBytes}, names=[{table.concat(
					rootNames,
					", "
				)}]`
			)

			local payload = { objects = serialized }
			if recipient then
				if not waitForCreateBackpressure({ recipient }) then
					return
				end
				networkService:SendToClient(
					recipient,
					Protocol.Channels.Replication,
					Protocol.Kinds.Create,
					payload,
					true
				)
				markBatchStreamedForSession(recipient, batch)
			else
				if not waitForCreateBackpressure(relevantSessions) then
					return
				end
				networkService:SendToMultipleClients(
					relevantSessions,
					Protocol.Channels.Replication,
					Protocol.Kinds.Create,
					payload,
					true
				)
				for _, session in ipairs(relevantSessions) do
					markBatchStreamedForSession(session, batch)
				end
			end

			batchesSent += 1
			logReplicationDiagnostic(
				`sendBatch sent reason={reasonLabel} recipient={recipientLabel} roots={#batch} bytes={payloadBytes} totalSeconds={formatSeconds(
					os.clock() - batchStartedAt
				)} batchesSent={batchesSent} queued={batchesQueued} pending={#pendingBatches}`
			)
			-- Pace every Create batch so reliable initial-sync traffic does not starve
			-- gameplay remotes, ACKs, and control messages.
			task.wait(CREATE_INTER_BATCH_YIELD_SECONDS)
		end

		if not recipient and not hasLiveCreateRecipients() then
			debugTrace(
				`sendCreate reason={reason or "unspecified"} broadcast skipped; no initial-sync-complete recipients`
			)
			return
		end

		local ROOTS_PER_BATCH = 2 -- keep initial root batches small; larger trees are pre-split below
		debugTrace(`sendCreate reason={reason or "unspecified"} queueing {#serializable} roots`)
		for i = 1, #serializable, ROOTS_PER_BATCH do
			local batch = {}
			for j = i, math.min(i + ROOTS_PER_BATCH - 1, #serializable) do
				table.insert(batch, serializable[j])
			end
			queueBatch(batch)
		end

		while #pendingBatches > 0 do
			local batch = table.remove(pendingBatches, 1)
			sendBatch(batch)
		end
		logReplicationDiagnostic(
			`sendCreate done reason={reasonLabel} recipient={recipientLabel} roots={#serializable} queued={batchesQueued} sent={batchesSent} split={batchesSplit} totalBytes={totalPayloadBytes} largestBytes={largestPayloadBytes} largestRoots=[{largestPayloadRoots}] backpressureSeconds={formatSeconds(
				totalBackpressureSeconds
			)} totalSeconds={formatSeconds(os.clock() - sendCreateStartedAt)}`
		)
		debugTrace(`sendCreate reason={reason or "unspecified"} batching done`)

		local patchStartedAt = os.clock()
		local referencePatches = collectReferencePatchEntries(serializable)
		logReplicationDiagnostic(
			`sendCreate referencePatches reason={reasonLabel} entries={#referencePatches} collectSeconds={formatSeconds(
				os.clock() - patchStartedAt
			)}`
		)
		sendPatchEntries(recipient, referencePatches)
	end

	local function collectInitialRoots()
		local startedAt = os.clock()
		local roots = {}
		local seen = {}
		local seenNetIds = {}
		local seenWorkspaceSingletons = {}
		local seenWorkspaceBaseplate = false
		local workspaceSingletonClasses = {
			Terrain = true,
		}
		local workspaceInst = game:GetService("Workspace")

		local function addRoot(object)
			if not object or object.CanReplicate == false or object.NetworkId == nil or seen[object] then
				return
			end
			if seenNetIds[object.NetworkId] then
				return
			end
			if object.Parent == workspaceInst and object.Name == "Baseplate" then
				if seenWorkspaceBaseplate then
					logReplicationDiagnostic(
						`collectInitialRoots: skipping duplicate Workspace Baseplate root {describeObject(object)}`
					)
					return
				end
				seenWorkspaceBaseplate = true
			end
			if object.Parent == workspaceInst and workspaceSingletonClasses[object.ClassName] then
				if seenWorkspaceSingletons[object.ClassName] then
					return
				end
				seenWorkspaceSingletons[object.ClassName] = true
			end
			seenNetIds[object.NetworkId] = true
			seen[object] = true
			table.insert(roots, object)
		end

		local function addWorkspaceRoot(object)
			if not object or object.CanReplicate == false or object.NetworkId == nil then
				return
			end

			local ancestor = object
			while ancestor.Parent and ancestor.Parent ~= workspaceInst do
				ancestor = ancestor.Parent
			end
			if ancestor.Parent == workspaceInst then
				addRoot(ancestor)
			end
		end

		-- Include every top-level Workspace instance that contains replicated descendants (nested rigs, synced folders).
		local trackedCount = 0
		for netId in pairs(lookup) do
			trackedCount += 1
		end
		print(`[Replicator][Server] collectInitialRoots: lookup has {trackedCount} tracked objects`)
		local workspaceDescendants = {}
		local workspaceScanStartedAt = os.clock()
		if workspaceInst then
			workspaceDescendants = workspaceInst:GetDescendants()
			for _, object in ipairs(workspaceDescendants) do
				addWorkspaceRoot(object)
			end
		end
		logReplicationDiagnostic(
			`collectInitialRoots workspaceScan descendants={#workspaceDescendants} rootsSoFar={#roots} seconds={formatSeconds(
				os.clock() - workspaceScanStartedAt
			)}`
		)

		local singletonIds = {
			[0] = true,
			[1] = true,
			[2] = true,
			[3] = true,
			[4] = true,
			[5] = true,
			[6] = true,
		}

		local gameDescendants = game:GetDescendants()
		local singletonScanStartedAt = os.clock()
		for _, object in ipairs(gameDescendants) do
			if object.CanReplicate == false or object.NetworkId == nil then
				continue
			end

			local parent = object.Parent
			if parent and singletonIds[parent.NetworkId] then
				addRoot(object)
			end
		end

		logReplicationDiagnostic(
			`collectInitialRoots singletonScan descendants={#gameDescendants} rootsSoFar={#roots} seconds={formatSeconds(
				os.clock() - singletonScanStartedAt
			)}`
		)

		table.sort(roots, function(a, b)
			local function parentPriority(object)
				local parent = object.Parent
				local parentNetId = parent and parent.NetworkId
				if parentNetId == 1 then
					if object.Name == "Baseplate" then
						return 0
					end
					return 1
				end
				if parentNetId == 2 then
					return 2
				end
				if parentNetId == 3 then
					return 4
				end
				return 3
			end

			local pa = parentPriority(a)
			local pb = parentPriority(b)
			if pa ~= pb then
				return pa < pb
			end
			return (a.Name or "") < (b.Name or "")
		end)

		print(`[Replicator][Server] collectInitialRoots: found {#roots} root(s) to replicate`)
		local rootDetails = {}
		for index, root in ipairs(roots) do
			if index > INITIAL_ROOT_DETAIL_LIMIT then
				table.insert(rootDetails, `...+{#roots - INITIAL_ROOT_DETAIL_LIMIT} more roots`)
				break
			end
			table.insert(
				rootDetails,
				`{describeObject(root)} parent={describeObject(root.Parent)} tree={countTreeObjects(root)}`
			)
		end
		logReplicationDiagnostic(`collectInitialRoots details [{table.concat(rootDetails, "; ")}]`)
		logReplicationDiagnostic(
			`collectInitialRoots done tracked={trackedCount} roots={#roots} seconds={formatSeconds(
				os.clock() - startedAt
			)}`
		)
		return roots
	end

	local function sendRemove(netId, object)
		local payload = { object = netId }

		if not object or AreaOfInterest.IsGlobalEntity(object) then
			networkService:Broadcast(Protocol.Channels.Replication, Protocol.Kinds.Remove, payload, true)
			return
		end

		local recipientSet = {}
		local recipients = {}

		for _, session in ipairs(networkService:GetSessions()) do
			local streamState = getSessionStreamState(session)
			if streamState and streamState.netIds[netId] == true then
				recipientSet[session] = true
			end
		end

		local relevantSessions = AreaOfInterest.GetRelevantSessions(
			object,
			networkService:GetSessions(),
			networkOwnership.GetWorldPosition,
			networkOwnership
		)
		for _, session in ipairs(relevantSessions) do
			recipientSet[session] = true
		end

		for session in pairs(recipientSet) do
			table.insert(recipients, session)
		end

		if #recipients == 0 then
			return
		end

		networkService:SendToMultipleClients(
			recipients,
			Protocol.Channels.Replication,
			Protocol.Kinds.Remove,
			payload,
			true
		)
	end

	local function sendTerrainSnapshot(recipient)
		local terrainObject = getTerrain()
		if not terrainObject then
			return
		end

		local batches
		if type(terrainObject.ExportReplicationSnapshotBatches) == "function" then
			batches = terrainObject:ExportReplicationSnapshotBatches()
		elseif type(terrainObject.ExportReplicationSnapshot) == "function" then
			batches = { terrainObject:ExportReplicationSnapshot() }
		end
		if not batches then
			return
		end

		for _, payload in ipairs(batches) do
			enqueueTerrainPayload(recipient, Protocol.Kinds.TerrainSnapshot, payload)
		end
	end

	local function sendWorldLoaded(session)
		networkService:SendToClient(
			session,
			Protocol.Channels.Control,
			Protocol.Kinds.WorldLoaded,
			{ tick = networkService:GetCurrentTick() },
			true
		)
	end

	local function buildClientNetIdSet(payload)
		local set = {}
		if type(payload) ~= "table" then
			return set
		end

		for _, netId in ipairs(payload.netIds or {}) do
			if type(netId) == "number" then
				set[netId] = true
			end
		end

		return set
	end

	local function rootHasMissingObjects(root, clientNetIds)
		local missing = false
		visitTree(root, function(object)
			if missing then
				return
			end
			local netId = object.NetworkId
			if netId ~= nil and object.CanReplicate ~= false and not clientNetIds[netId] then
				missing = true
			end
		end)
		return missing
	end

	local function rootCameFromBlob(root, fingerprint)
		if type(fingerprint) ~= "string" or fingerprint == "" or root == nil then
			return false
		end

		local hasReplicatedObject = false
		local allFromBlob = true
		visitTree(root, function(object)
			if object.NetworkId == nil or object.CanReplicate == false then
				return
			end

			hasReplicatedObject = true
			if object.GetMetadata == nil or object:GetMetadata("__blobFingerprint") ~= fingerprint then
				allFromBlob = false
			end
		end)

		return hasReplicatedObject and allFromBlob
	end

	local function sendInitialStateForSession(session, clientNetIds, clientBlobFingerprint)
		local initialSyncStartedAt = os.clock()
		if not session or not session.key or initialSyncCompleted[session.key] then
			return
		end

		local collectStartedAt = os.clock()
		local initialRoots = collectInitialRoots()
		local collectSeconds = os.clock() - collectStartedAt
		local rootsToReplicate = initialRoots
		logReplicationDiagnostic(
			`Initial sync {session.key}: collected roots={#initialRoots} seconds={formatSeconds(collectSeconds)}`
		)

		local filterStartedAt = os.clock()
		if clientNetIds ~= nil then
			rootsToReplicate = {}
			for _, root in ipairs(initialRoots) do
				if rootCameFromBlob(root, clientBlobFingerprint) then
					continue
				end
				if rootHasMissingObjects(root, clientNetIds) then
					table.insert(rootsToReplicate, root)
				end
			end
		end

		local aoiFilteredRoots = {}
		for _, root in ipairs(rootsToReplicate) do
			if
				AreaOfInterest.ShouldReplicateToSession(
					session,
					root,
					networkOwnership.GetWorldPosition,
					networkOwnership
				)
			then
				table.insert(aoiFilteredRoots, root)
			end
		end
		rootsToReplicate = aoiFilteredRoots
		logReplicationDiagnostic(
			`Initial sync {session.key}: filtered roots={#rootsToReplicate}/{#initialRoots} missingOnly={clientNetIds ~= nil} seconds={formatSeconds(
				os.clock() - filterStartedAt
			)}`
		)

		print(
			`[Replicator][Server] Initial sync {session.key}: sending {#rootsToReplicate}/{#initialRoots} roots (missing-only={clientNetIds ~= nil}, blobMatch={clientBlobFingerprint == (game.GetMetadata and game:GetMetadata(
				"__blobFingerprint"
			) or nil)})`
		)
		initialSyncCompleted[session.key] = true
		pendingInitialInventorySync[session.key] = nil
		local sendCreateStartedAt = os.clock()
		sendCreate(session, rootsToReplicate, "initial_sync")
		logReplicationDiagnostic(
			`Initial sync {session.key}: sendCreateSeconds={formatSeconds(os.clock() - sendCreateStartedAt)}`
		)
		if clientBlobFingerprint == nil then
			local terrainStartedAt = os.clock()
			sendTerrainSnapshot(session)
			logReplicationDiagnostic(
				`Initial sync {session.key}: terrainSnapshotSeconds={formatSeconds(os.clock() - terrainStartedAt)}`
			)
		else
			debugTrace(`Initial sync {session.key}: skipped terrain snapshot because blob fingerprints match`)
		end
		sendWorldLoaded(session)
		print(`[Replicator][Server] WorldLoaded sent to {session.key}`)
		logReplicationDiagnostic(
			`Initial sync {session.key}: totalSeconds={formatSeconds(os.clock() - initialSyncStartedAt)}`
		)
	end

	local function completeInitialSyncWithoutCreate(session)
		if not session or not session.key or initialSyncCompleted[session.key] then
			return
		end

		initialSyncCompleted[session.key] = true
		pendingInitialInventorySync[session.key] = nil
		clearTerrainQueue(session)
		sendWorldLoaded(session)
		warn(
			`[Replicator][Server] Initial inventory unavailable for {session.key}; skipping initial Create fallback and continuing with live replication`
		)
	end

	local function startInitialInventoryHandshake(session)
		if not session or not session.key or initialSyncCompleted[session.key] then
			return
		end

		pendingInitialInventorySync[session.key] = true
		networkService:SendToClient(
			session,
			Protocol.Channels.Control,
			Protocol.Kinds.ClientObjectInventoryRequest,
			{ tick = networkService:GetCurrentTick() },
			true
		)

		task.delay(INITIAL_INVENTORY_HANDSHAKE_TIMEOUT, function()
			if
				not session
				or not session.key
				or initialSyncCompleted[session.key]
				or not pendingInitialInventorySync[session.key]
			then
				return
			end
			warn(`[Replicator][Server] Initial inventory handshake timed out for {session.key}`)
			completeInitialSyncWithoutCreate(session)
		end)
	end

	injectRemoteEventHooks = function(object)
		if object.ClassName == "RemoteEvent" then
			object:SetProperties({
				FireClient = function(self, player, ...)
					local session = networkService:GetSessionByUserId(player.UserId)
					if not session then
						return
					end

					networkService:SendToClient(session, Protocol.Channels.Message, Protocol.Kinds.RemoteEvent, {
						object = self.NetworkId,
						args = packArgs(...),
					}, true)
				end,
				FireAllClients = function(self, ...)
					networkService:Broadcast(Protocol.Channels.Message, Protocol.Kinds.RemoteEvent, {
						object = self.NetworkId,
						args = packArgs(...),
					}, true)
				end,
				FireClients = function(self, players, ...)
					local args = packArgs(...)
					for _, player in ipairs(players or {}) do
						local session = networkService:GetSessionByUserId(player.UserId)
						if session then
							networkService:SendToClient(
								session,
								Protocol.Channels.Message,
								Protocol.Kinds.RemoteEvent,
								{ object = self.NetworkId, args = args },
								true
							)
						end
					end
				end,
			})
		elseif object.ClassName == "UnreliableRemoteEvent" then
			object:SetProperties({
				FireClient = function(self, player, ...)
					local session = networkService:GetSessionByUserId(player.UserId)
					if not session then
						return
					end

					networkService:SendToClient(
						session,
						Protocol.Channels.Message,
						Protocol.Kinds.UnreliableRemoteEvent,
						{
							object = self.NetworkId,
							args = packArgs(...),
						},
						false
					)
				end,
				FireAllClients = function(self, ...)
					networkService:Broadcast(Protocol.Channels.Message, Protocol.Kinds.UnreliableRemoteEvent, {
						object = self.NetworkId,
						args = packArgs(...),
					}, false)
				end,
				FireClients = function(self, players, ...)
					local args = packArgs(...)
					for _, player in ipairs(players or {}) do
						local session = networkService:GetSessionByUserId(player.UserId)
						if session then
							networkService:SendToClient(
								session,
								Protocol.Channels.Message,
								Protocol.Kinds.UnreliableRemoteEvent,
								{ object = self.NetworkId, args = args },
								false
							)
						end
					end
				end,
			})
		end
	end

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

	injectRemoteFunctionHooks = function(object)
		if object.ClassName ~= "RemoteFunction" then
			return
		end

		object:SetProperties({
			InvokeClient = function(self, player, ...)
				local session = networkService:GetSessionByUserId(player.UserId)
				if not session then
					error(`RemoteFunction target player {player.Name} is not connected`)
				end

				remoteFunctionRequestId += 1
				local requestId = remoteFunctionRequestId
				pendingRemoteFunctionInvocations[requestId] = {
					done = false,
					payload = nil,
				}

				local timeout = math.max(0.1, tonumber(self.InvokeTimeout) or 10)
				networkService:SendToClient(session, Protocol.Channels.Message, Protocol.Kinds.RemoteFunctionRequest, {
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

	injectRemoteDataHooks = function(object)
		if object.ClassName ~= "RemoteData" then
			return
		end

		object:GetPropertyChangedSignal("Data"):Connect(function(value)
			if object.NetworkId == nil then
				return
			end

			local encoded = Shared.EncodePropertyValue(userdata, value)
			if encoded == nil then
				return
			end

			networkService:Broadcast(Protocol.Channels.Message, Protocol.Kinds.RemoteDataUpdate, {
				object = object.NetworkId,
				data = encoded,
			}, true)
		end)
	end

	local function applyOwnedPatchBatch(session, payload)
		for _, entry in ipairs(payload.entries or {}) do
			local object = lookup[entry.object]
			if not object or object.Parent == nil then
				continue
			end

			local _, controller = networkOwnership.GetControllerRoot(object)
			if controller ~= nil then
				continue
			end

			if not networkOwnership.IsOwnedByPlayer(object, session.player) then
				continue
			end

			for prop, encoded in pairs(entry.updates or {}) do
				if not networkOwnership.ShouldReplicateProperty(object, prop) then
					continue
				end

				local decoded, ok = Shared.DecodePropertyValue(userdata, lookup, encoded)
				if ok then
					-- Mute so the server monitor does not re-queue the write as a
					-- server-originated dirty patch and broadcast it back to everyone.
					withMutedObject(object, function()
						object[prop] = decoded
					end)
				end
			end
		end
	end

	for _, object in ipairs(game:GetDescendants()) do
		if object.ClassName == "Camera" then
			continue
		end
		trackObject(object)
		registerOwnershipRoot(object)
		monitor(object)
		injectRemoteEventHooks(object)
		injectRemoteFunctionHooks(object)
		injectRemoteDataHooks(object)
	end

	game.DescendantAdded:Connect(function(object)
		if isRuntimeMutationSuppressed() then
			debugTrace(
				`DescendantAdded mutation-suppressed root={object.ClassName}:{object.Name} netId={tostring(object.NetworkId)}`
			)
			return
		end

		if object.ClassName == "Camera" then
			return
		end

		-- If this object was already in lookup it means a *parent's* DescendantAdded
		-- handler fired first, called trackTree on the parent (which tracked all
		-- descendants), and already scheduled sendCreate for the whole tree.
		-- Sending a second Create for the individual child would flood the network
		-- with duplicate objects.
		local alreadyTracked = object.NetworkId ~= nil and lookup[object.NetworkId] == object
		local suppressedAtAdd = isRuntimeCreateSuppressed()

		trackTree(object)
		if object.ClassName == "NetworkController" and object.Parent then
			trackObject(object.Parent)
		end

		if suppressedAtAdd then
			debugTrace(
				`DescendantAdded suppressed root={object.ClassName}:{object.Name} netId={tostring(object.NetworkId)}`
			)
		elseif not alreadyTracked then
			task.spawn(function()
				-- Guard: object may have been destroyed (e.g. Debris) before the
				-- deferred send executes.
				if object.Parent == nil then
					return
				end
				debugTrace(
					`DescendantAdded root={object.ClassName}:{object.Name} netId={tostring(object.NetworkId)} descendants={#object:GetDescendants()}`
				)
				sendCreate(nil, { object }, "runtime_descendant_added")
			end)
		end
	end)

	game.DescendantRemoving:Connect(function(object)
		if isRuntimeMutationSuppressed() then
			debugTrace(
				`DescendantRemoving mutation-suppressed root={object.ClassName}:{object.Name} netId={tostring(object.NetworkId)}`
			)
			return
		end

		if object.NetworkId == nil then
			return
		end

		-- Capture object reference before untracking so AoI can check its position
		local netId = object.NetworkId
		sendRemove(netId, object)
		untrackTree(object)
	end)

	networkService.ClientConnected:Connect(function(session)
		-- Run the initial world send in a separate coroutine so it does NOT
		-- block the GNS receive loop.  Without this, large maps cause the
		-- server to stop processing heartbeats during sendCreate, which
		-- triggers a heartbeat-timeout disconnect on the client.
		task.spawn(function()
			session.lastSnapshotAckTick = 0
			session.lastSentSnapshotTick = -1
			clearTerrainQueue(session)
			readySessions[session.key] = false -- not world-ready yet
			AreaOfInterest.RegisterSession(session)
			print(`[Replicator][Server] Client connected {session.key}, requesting client object inventory`)
			startInitialInventoryHandshake(session)
		end)
	end)

	networkService.ClientRemoved:Connect(function(session)
		readySessions[session.key] = nil
		pendingInitialInventorySync[session.key] = nil
		initialSyncCompleted[session.key] = nil
		clearSessionStreamState(session)
		clearTerrainQueue(session)
		antiCheat:ClearSession(session)
		AreaOfInterest.UnregisterSession(session)

		for root in pairs(ownershipRoots) do
			local owner = root and root.NetworkOwner or nil
			if owner and owner.UserId == session.userId then
				networkOwnership.ClearOwner(root)
				markOwnershipCooldown(root, 0.75, session.userId)
			end
		end
	end)

	-- Mark a session as world-ready when the client confirms it has loaded the
	-- initial world state.  Snapshots are held until this point.
	networkService:RegisterMessageHandler(
		Protocol.Channels.Control,
		Protocol.Kinds.ClientObjectInventoryResponse,
		function(session, payload)
			if not session or not session.key then
				return
			end
			if initialSyncCompleted[session.key] then
				return
			end

			local clientNetIds = buildClientNetIdSet(payload)
			local uniqueCount = 0
			for _ in pairs(clientNetIds) do
				uniqueCount += 1
			end
			debugTrace(
				`ClientObjectInventoryResponse session={session.key} payloadCount={#(payload and payload.netIds or {})} uniqueCount={uniqueCount}`
			)
			local clientBlobFingerprint = type(payload) == "table" and payload.blobFingerprint or nil
			local serverBlobFingerprint = game.GetMetadata and game:GetMetadata("__blobFingerprint") or nil
			if clientBlobFingerprint ~= serverBlobFingerprint then
				clientBlobFingerprint = nil
			end
			task.spawn(function()
				sendInitialStateForSession(session, clientNetIds, clientBlobFingerprint)
			end)
		end
	)

	networkService:RegisterMessageHandler(
		Protocol.Channels.Control,
		Protocol.Kinds.ClientReady,
		function(session, _payload)
			if not session or not session.key then
				return
			end
			readySessions[session.key] = true
			print(`[Replicator][Server] Session {session.key} confirmed world-ready`)
		end
	)

	networkService:RegisterMessageHandler(
		Protocol.Channels.Input,
		Protocol.Kinds.OwnedStateBatch,
		function(session, payload)
			if not session or not session.player then
				return
			end

			local sequence = payload.sequence or 0
			if sequence <= (session.lastOwnedStateSequence or 0) then
				return
			end

			if sequence == 1 or sequence % 30 == 0 then
				print(
					`[Replicator][Server] Received owned state batch from {session.player.Name}: sequence={sequence}, count={#(payload.states or {})}`
				)
			end

			session.lastOwnedStateSequence = sequence
			session.pendingOwnedStateBatch = payload
		end
	)

	networkService:RegisterMessageHandler(
		Protocol.Channels.Replication,
		Protocol.Kinds.SnapshotAck,
		function(session, payload)
			if session and payload.tick then
				local ackTick = tonumber(payload.tick) or 0
				session.lastSnapshotAckTick = math.max(session.lastSnapshotAckTick or 0, ackTick)
			end
		end
	)

	networkService:RegisterMessageHandler(
		Protocol.Channels.Input,
		Protocol.Kinds.OwnedPatchBatch,
		function(session, payload)
			if not session or not session.player then
				return
			end

			applyOwnedPatchBatch(session, payload)
		end
	)

	networkService:RegisterMessageHandler(
		Protocol.Channels.Message,
		Protocol.Kinds.RemoteEvent,
		function(session, payload)
			local object = lookup[payload.object]
			if not object or object.ClassName ~= "RemoteEvent" then
				return
			end

			local player = session and session.player or nil
			local args = payload.args or {}
			object.OnServerEvent:Fire(player, table.unpack(args, 1, args.n or #args))
		end
	)

	networkService:RegisterMessageHandler(
		Protocol.Channels.Message,
		Protocol.Kinds.UnreliableRemoteEvent,
		function(session, payload)
			local object = lookup[payload.object]
			if not object or object.ClassName ~= "UnreliableRemoteEvent" then
				return
			end

			local player = session and session.player or nil
			local args = payload.args or {}
			object.OnServerEvent:Fire(player, table.unpack(args, 1, args.n or #args))
		end
	)

	networkService:RegisterMessageHandler(
		Protocol.Channels.Message,
		Protocol.Kinds.RemoteFunctionRequest,
		function(session, payload)
			local object = lookup[payload.object]
			if not object or object.ClassName ~= "RemoteFunction" then
				return
			end

			local player = session and session.player or nil
			local invokeHandler = object.OnServerInvoke
			local args = payload.args or {}
			local ok, resultsOrError = pcall(function()
				if type(invokeHandler) ~= "function" then
					error(`RemoteFunction {object.Name} is missing OnServerInvoke`)
				end

				return packArgs(invokeHandler(player, table.unpack(args, 1, args.n or #args)))
			end)

			if ok then
				networkService:SendToClient(session, Protocol.Channels.Message, Protocol.Kinds.RemoteFunctionResponse, {
					object = payload.object,
					requestId = payload.requestId,
					success = true,
					result = resultsOrError,
				}, true)
			else
				networkService:SendToClient(session, Protocol.Channels.Message, Protocol.Kinds.RemoteFunctionResponse, {
					object = payload.object,
					requestId = payload.requestId,
					success = false,
					error = tostring(resultsOrError),
				}, true)
			end
		end
	)

	networkService:RegisterMessageHandler(
		Protocol.Channels.Message,
		Protocol.Kinds.RemoteFunctionResponse,
		function(_, payload)
			completeRemoteFunctionInvocation(payload.requestId, payload)
		end
	)

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

			object.Data = decoded
		end
	)

	networkService:RegisterMessageHandler(
		Protocol.Channels.Input,
		Protocol.Kinds.ControllerInput,
		function(session, payload)
			if not session then
				return
			end
			session.inputBuffer = session.inputBuffer or {}
			local tick = payload.tick
			if tick then
				session.inputBuffer[tick] = payload.inputs
			end

			local currentTick = runService:GetSimulationTick()
			for t in pairs(session.inputBuffer) do
				if t < currentTick - 120 then
					session.inputBuffer[t] = nil
				end
			end
		end
	)

	local SERVER_INPUT_ACTIONS = { "MoveX", "MoveZ", "Jump", "Sprint", "Crouch" }

	runService:BindToSimulation(function(dt)
		local currentTick = runService:GetSimulationTick()
		local workspace = game:GetService("Workspace")

		if not (workspace.ServerAuthority and workspace.ServerAuthority.AuthorityMode == Enum.AuthorityMode.Server) then
			return
		end

		for _, session in ipairs(networkService:GetSessions()) do
			local player = session.player
			if not player then
				continue
			end
			for _, actionName in ipairs(SERVER_INPUT_ACTIONS) do
				InputActionService:SetActionValue(actionName, player, 0)
			end
			if session.inputBuffer and session.inputBuffer[currentTick] then
				local inputs = session.inputBuffer[currentTick]
				for actionName, value in pairs(inputs) do
					InputActionService:SetActionValue(actionName, player, value)
				end
			end
		end
	end)

	local function flushDirtyPatches()
		if next(dirtyPatches) == nil then
			return
		end

		local entries = {}
		for netId, updates in pairs(dirtyPatches) do
			-- Skip objects that were destroyed between the patch being queued and now.
			local object = lookup[netId]
			if object and object.Parent ~= nil then
				table.insert(entries, {
					object = netId,
					updates = updates,
				})
			end
		end

		dirtyPatches = {}

		if #entries > 0 then
			sendPatchEntries(nil, entries)
		end
	end

	local function flushTerrainChunkUpdates()
		local terrainObject = getTerrain()
		if not terrainObject then
			return
		end

		local batches
		if type(terrainObject.ConsumeReplicationChunkUpdateBatches) == "function" then
			batches = terrainObject:ConsumeReplicationChunkUpdateBatches()
		elseif type(terrainObject.ConsumeReplicationChunkUpdates) == "function" then
			local payload = terrainObject:ConsumeReplicationChunkUpdates()
			if payload then
				batches = { payload }
			end
		end
		if not batches then
			return
		end

		for _, payload in ipairs(batches) do
			if #(payload.chunks or {}) > 0 or payload.reset == true then
				enqueueTerrainPayloadForSessions(Protocol.Kinds.TerrainChunkBatch, payload)
			end
		end
	end

	local function applyPendingOwnedStateBatches()
		local function applyOwnedBasePartStateSilently(object, state)
			local props = rawget(object, "_props")
			if type(props) ~= "table" then
				return false
			end

			if state.cframe then
				local ok, cframe = pcall(CFrame.FromTable, state.cframe)
				if ok and cframe then
					props.CFrame = cframe
					if cframe.Position then
						props.Position = cframe.Position
					end
					if cframe.ToOrientation then
						local rx, ry, rz = cframe:ToOrientation()
						local orientation = Vector3.new(rx, ry, rz)
						props.Orientation = orientation
						props.Rotation = orientation
					end
				end
			end

			if state.linear then
				local ok, linear = pcall(Vector3.FromTable, state.linear)
				if ok and linear then
					props.AssemblyLinearVelocity = linear
					props.Velocity = linear
				end
			end

			if state.angular then
				local ok, angular = pcall(Vector3.FromTable, state.angular)
				if ok and angular then
					props.AssemblyAngularVelocity = angular
				end
			end

			return true
		end

		for _, session in ipairs(networkService:GetSessions()) do
			local payload = session.pendingOwnedStateBatch
			if not session.player or not payload then
				continue
			end

			for _, state in ipairs(payload.states or {}) do
				local object = lookup[state.id]
				if not object or object.Parent == nil then
					continue
				end
				if not stateRegistry.ResolveAdapter(object) then
					continue
				end
				if not networkOwnership.IsOwnedByPlayer(object, session.player) then
					continue
				end
				if not antiCheat:ValidateOwnedState(session, payload, object, state) then
					continue
				end

				logHumanoidRootState(
					"apply-owned-before",
					session.key,
					object,
					state,
					`sequence={payload.sequence or 0}`
				)
				withMutedObject(object, function()
					if state.type ~= "BasePart" or not applyOwnedBasePartStateSilently(object, state) then
						stateRegistry.Apply(object, state)
					end
				end)
				logHumanoidRootState(
					"apply-owned-after",
					session.key,
					object,
					state,
					`sequence={payload.sequence or 0}`
				)
			end

			if payload.sequence == 1 or payload.sequence % 30 == 0 then
				print(
					`[Replicator][Server] Applied owned state batch from {session.player.Name}: sequence={payload.sequence}, count={#(payload.states or {})}`
				)
			end

			session.lastAppliedOwnedStateSequence = payload.sequence or session.lastAppliedOwnedStateSequence or 0
			session.pendingOwnedStateBatch = nil
		end
	end

	local function getPlayerDistanceToRoot(root, player)
		local rootPosition = networkOwnership.GetWorldPosition(root)
		local playerPosition = networkOwnership.GetPlayerFocusPosition(player)
		if not rootPosition or not playerPosition then
			return math.huge
		end

		return (rootPosition - playerPosition):Magnitude()
	end

	local function findBestOwnershipCandidate(root, now)
		local bestPlayer = nil
		local bestDistance = math.huge
		local state = getOwnershipState(root)

		for _, session in ipairs(networkService:GetSessions()) do
			local player = session.player
			if player and player.Parent ~= nil then
				if not (state.blockedUserId == player.UserId and now < (state.blockedUntil or 0)) then
					local distance = getPlayerDistanceToRoot(root, player)
					if distance < bestDistance then
						bestDistance = distance
						bestPlayer = player
					end
				end
			end
		end

		return bestPlayer, bestDistance
	end

	local function assignOwnership(root, newOwner, now)
		local state = getOwnershipState(root)
		local changed = root.NetworkOwner ~= newOwner
		if changed then
			networkOwnership.SetOwner(root, newOwner)
			state.lastTransferAt = now
			if newOwner then
				state.lastOwnerUserId = newOwner.UserId
			else
				state.lastOwnerUserId = nil
			end
		end
		state.cooldownUntil = math.max(state.cooldownUntil or 0, now)
		return changed
	end

	local function rebalanceOwnership(now)
		for root in pairs(ownershipRoots) do
			if root == nil or root.Parent == nil then
				unregisterOwnershipRoot(root)
				continue
			end

			local resolvedRoot, controller = networkOwnership.GetControllerRoot(root)
			resolvedRoot = resolvedRoot or root
			if resolvedRoot ~= root then
				unregisterOwnershipRoot(root)
				continue
			end

			local state = getOwnershipState(root)
			local currentOwner = root.NetworkOwner
			local currentSession = currentOwner and networkService:GetSessionByUserId(currentOwner.UserId) or nil
			local config = networkOwnership.GetAutoOwnershipConfig(root, controller)

			if not networkOwnership.CanAutoAssignOwnership(root, controller) then
				if currentOwner ~= nil then
					assignOwnership(root, nil, now)
				end
				continue
			end

			local speed = networkOwnership.GetLinearSpeed(root)
			local currentDistance = currentOwner and getPlayerDistanceToRoot(root, currentOwner) or math.huge
			local currentOwnerValid = currentOwner ~= nil
				and currentSession ~= nil
				and currentDistance <= config.releaseRadius

			if currentOwnerValid then
				continue
			end

			if now < (state.cooldownUntil or 0) then
				continue
			end

			local bestPlayer, bestDistance = findBestOwnershipCandidate(root, now)
			local canClaim = bestPlayer ~= nil and bestDistance <= config.ownershipRadius

			if currentOwner ~= nil and currentSession ~= nil then
				if canClaim and bestPlayer ~= currentOwner and bestDistance + config.stealMargin < currentDistance then
					assignOwnership(root, bestPlayer, now)
					state.cooldownUntil = now + config.transferCooldown
				elseif currentDistance > config.releaseRadius then
					if canClaim then
						assignOwnership(root, bestPlayer, now)
					else
						assignOwnership(root, nil, now)
					end
					state.cooldownUntil = now + config.transferCooldown
				end
				continue
			end

			if speed < config.velocityThreshold then
				if currentOwner ~= nil then
					if currentSession == nil then
						assignOwnership(root, nil, now)
						state.cooldownUntil = now + config.transferCooldown
					end
				elseif canClaim then
					-- Even if the object is stationary, if it has no owner,
					-- assign it to the nearest player so they can interact with it.
					assignOwnership(root, bestPlayer, now)
					state.cooldownUntil = now + config.transferCooldown
				end
				continue
			end

			if canClaim then
				assignOwnership(root, bestPlayer, now)
				state.cooldownUntil = now + config.transferCooldown
			elseif currentOwner ~= nil then
				assignOwnership(root, nil, now)
				state.cooldownUntil = now + config.transferCooldown
			end
		end
	end

	local function flushSnapshots(tick)
		for netId, object in pairs(trackedStateObjects) do
			if object.CanReplicate == false or object.Parent == nil or object.NetworkId == nil then
				continue
			end

			local state = stateRegistry.Capture(object)
			if not state or state.id == nil then
				continue
			end

			local history = objectStateHistory[netId]
			if not history then
				history = PredictionBuffer.new(64)
				objectStateHistory[netId] = history
			end

			local prev = history:GetLatest()
			if not prev or not stateRegistry.StatesEqual(prev, state) then
				local cloned = stateRegistry.CloneState(state)
				history:Push(tick, cloned)
			end
		end

		for _, session in ipairs(networkService:GetSessions()) do
			if not readySessions[session.key] then
				continue -- client is still loading the world; do not send snapshots yet
			end

			local clientAckTick = session.lastSnapshotAckTick or 0
			local lastSentTick = session.lastSentSnapshotTick or -1
			local ticksSinceLastSent = tick - lastSentTick
			if
				lastSentTick > clientAckTick + SNAPSHOT_MAX_UNACKED_TICKS
				and ticksSinceLastSent < SNAPSHOT_BACKPRESSURE_RETRY_TICKS
			then
				continue
			end
			local changedStates = {}
			local numStates = 0
			local maxStatesForSession = math.max(1, MAX_SNAPSHOT_STATES_PER_MESSAGE)

			for netId, history in pairs(objectStateHistory) do
				local latestTickSequence = history:GetLatestSequence()
				if not latestTickSequence then
					continue
				end

				if latestTickSequence > clientAckTick then
					-- AoI filter: skip snapshots for objects outside this session's range
					if
						not shouldReplicateNetIdToSession(session, netId)
					then
						continue
					end

					local baseline = history:GetAtOrBefore(clientAckTick)
					local currentState = history:GetLatest()

					local delta = stateRegistry.ComputeDelta(baseline, currentState)
					if delta then
						table.insert(changedStates, delta)
						numStates += 1
						if numStates >= maxStatesForSession then
							break
						end
					else
						-- if latestTickSequence > clientAckTick but delta is nil, it means
						-- this client already has this state effectively.
					end
				end
			end

			local lastOwnedSequence = session.lastAppliedOwnedStateSequence or 0
			if numStates == 0 then
				continue
			end

			if ticksSinceLastSent < SNAPSHOT_MIN_SEND_INTERVAL_TICKS then
				continue
			end

			session.lastSentSnapshotTick = tick
			-- Keep each snapshot tick as one logical message so client baseline
			-- assembly is atomic per tick and cannot lose states across chunks.
			networkService:SendToClient(session, Protocol.Channels.Replication, Protocol.Kinds.Snapshot, {
				tick = tick,
				baseTick = clientAckTick,
				lastProcessedOwnedStateSequence = lastOwnedSequence,
				states = changedStates,
			}, false)
		end
	end

	-- Update AoI positions for all sessions each tick from their character's position.
	local function updateAoIPositions()
		for _, session in ipairs(networkService:GetSessions()) do
			if session.player then
				local position = networkOwnership.GetPlayerFocusPosition(session.player)
				if position then
					AreaOfInterest.UpdateSessionPosition(session, position)
				end
			end
		end
	end

	local function gatherTargetStreamRootsForSession(session)
		local targetsByNetId = {}

		local sessionPosition = AreaOfInterest.GetSessionPosition(session)
		if sessionPosition then
			local radius = AreaOfInterest.GetSessionRadius(session)
			local chunkRadius = math.max(1, math.ceil(radius * streamChunkSizeInv) + 1)
			local chunkX = chunkCoordFromValue(sessionPosition.X)
			local chunkY = chunkCoordFromValue(sessionPosition.Y)
			local chunkZ = chunkCoordFromValue(sessionPosition.Z)

			for x = chunkX - chunkRadius, chunkX + chunkRadius do
				for y = chunkY - chunkRadius, chunkY + chunkRadius do
					for z = chunkZ - chunkRadius, chunkZ + chunkRadius do
						local bucket = streamChunks[chunkKeyFromCoords(x, y, z)]
						if bucket then
							for root in pairs(bucket) do
								if isStreamRoot(root) then
									targetsByNetId[root.NetworkId] = root
								end
							end
						end
					end
				end
			end
		else
			for root in pairs(streamRoots) do
				if isStreamRoot(root) then
					targetsByNetId[root.NetworkId] = root
				end
			end
		end

		for root in pairs(streamRootsWithoutChunk) do
			if isStreamRoot(root) then
				targetsByNetId[root.NetworkId] = root
			end
		end

		if session and session.player then
			for root in pairs(ownershipRoots) do
				local authorityRoot = networkOwnership.GetAuthorityRoot(root) or root
				if
					authorityRoot
					and authorityRoot.NetworkId ~= nil
					and isStreamRoot(authorityRoot)
					and networkOwnership.IsOwnedByPlayer(authorityRoot, session.player)
				then
					targetsByNetId[authorityRoot.NetworkId] = authorityRoot
				end
			end
		end

		for netId, root in pairs(targetsByNetId) do
			if
				not AreaOfInterest.ShouldReplicateToSession(
					session,
					root,
					networkOwnership.GetWorldPosition,
					networkOwnership
				)
			then
				targetsByNetId[netId] = nil
			end
		end

		return targetsByNetId
	end

	local function reconcileStreamingRegions()
		refreshAllStreamRoots()

		for _, session in ipairs(networkService:GetSessions()) do
			if not session or not session.key or not readySessions[session.key] or initialSyncCompleted[session.key] ~= true then
				continue
			end

			local streamState = getSessionStreamState(session)
			local targetRootsByNetId = gatherTargetStreamRootsForSession(session)
			local enteringRoots = {}
			local exitingRoots = {}

			for netId, root in pairs(targetRootsByNetId) do
				if streamState.roots[netId] == nil then
					table.insert(enteringRoots, root)
				end
			end

			for netId, root in pairs(streamState.roots) do
				if targetRootsByNetId[netId] == nil then
					table.insert(exitingRoots, root)
				end
			end

			if #enteringRoots > 0 then
				sendCreate(session, enteringRoots, "stream_enter")
			end

			for _, root in ipairs(exitingRoots) do
				if root and root.NetworkId ~= nil then
					sendRemoveToSession(session, root.NetworkId)
				end
				unmarkSessionRootStreamed(session, root)
			end
		end
	end

	networkService.Tick:Connect(function(tick)
		local tickOk, tickErr = pcall(function()
			local tickStartedAt = os.clock()
			local timings = {}
			local function measureTickStep(name, callback)
				local startedAt = os.clock()
				callback()
				timings[name] = os.clock() - startedAt
			end

			if tick % math.max(math.floor((networkService.TickRate or 30) * OWNERSHIP_REBALANCE_INTERVAL), 1) == 0 then
				measureTickStep("rebalanceOwnership", function()
					rebalanceOwnership(os.clock())
				end)
			end
			measureTickStep("updateAoIPositions", updateAoIPositions)
			if tick % STREAM_RECONCILE_INTERVAL_TICKS == 0 then
				measureTickStep("reconcileStreamingRegions", reconcileStreamingRegions)
			end
			measureTickStep("applyPendingOwnedStateBatches", applyPendingOwnedStateBatches)
			measureTickStep("flushDirtyPatches", flushDirtyPatches)
			measureTickStep("flushTerrainChunkUpdates", flushTerrainChunkUpdates)
			measureTickStep("flushTerrainQueues", flushTerrainQueues)
			measureTickStep("flushSnapshots", function()
				flushSnapshots(tick)
			end)

			local tickSeconds = os.clock() - tickStartedAt
			if REPLICATION_DIAGNOSTICS and tickSeconds >= SLOW_TICK_DIAGNOSTIC_SECONDS then
				warn(
					`[Replicator][Server][Diag] slow tick={tick} totalSeconds={formatSeconds(tickSeconds)} rebalance={formatSeconds(
						timings.rebalanceOwnership
					)} aoi={formatSeconds(timings.updateAoIPositions)} owned={formatSeconds(
						timings.applyPendingOwnedStateBatches
					)} patches={formatSeconds(timings.flushDirtyPatches)} terrainChunks={formatSeconds(
						timings.flushTerrainChunkUpdates
					)} terrainQueue={formatSeconds(timings.flushTerrainQueues)} snapshots={formatSeconds(
						timings.flushSnapshots
					)}`
				)
			end
		end)
		if not tickOk then
			warn("[SERVER] Tick handler error (recovered): " .. tostring(tickErr))
		end
	end)

	--  Race-condition catch-up
	-- The server socket begins accepting connections inside NetworkService.InitRenderer,
	-- which runs concurrently with ReplicatorService.InitRenderer.  A client can
	-- therefore complete the GNS handshake and fire ClientConnected *before* the
	-- handler above was registered, meaning those clients never received the initial
	-- world state or WorldLoaded packet.
	--
	-- After all handlers are wired up we do one synchronous pass over every session
	-- that NetworkService already knows about.  Any session not yet in readySessions
	-- is treated identically to a fresh ClientConnected event.
	task.spawn(function()
		local existingSessions = networkService:GetSessions()
		if not existingSessions or #existingSessions == 0 then
			return
		end

		for _, session in ipairs(existingSessions) do
			if readySessions[session.key] ~= nil then
				-- Already handled by the ClientConnected handler; skip.
				continue
			end

			print(`[Replicator][Server] Catch-up world send for early-connected session {session.key}`)

			-- Mirror exactly what ClientConnected does.
			session.lastSnapshotAckTick = 0
			session.lastSentSnapshotTick = -1
			clearTerrainQueue(session)
			readySessions[session.key] = false
			initialSyncCompleted[session.key] = nil
			startInitialInventoryHandshake(session)

			print(`[Replicator][Server] Catch-up inventory request sent to {session.key}`)
		end
	end)

	return {}
end

return Server
