local Protocol = require("../NetworkService/Protocol")

local NetworkReplicateSync = {}
NetworkReplicateSync.__index = NetworkReplicateSync

local CHUNK_SIZE = 300
local PENDING_CHECK_INTERVAL = 0.1
local MAX_PENDING_AGE = 30

function NetworkReplicateSync.new(context)
	local self = setmetatable({
		_context = context,
		_networkService = context.NetworkService,
		_serializationService = context.SerializationService,
		_pendingReplicates = {},
		_removedRef = {},
		_processRunning = false,
		_sequence = 0,
	}, NetworkReplicateSync)

	return self
end

function NetworkReplicateSync:NextSequence()
	self._sequence += 1
	return self._sequence
end

-- Gather all replicable descendants from a root object
function NetworkReplicateSync:GetReplicateDescendants(root)
	local result = {}
	if not root then
		return result
	end

	local function gather(parent)
		local children = parent.GetChildren and parent:GetChildren()
		if not children then
			return
		end

		for _, child in ipairs(children) do
			if child.NetworkId or child.ShouldReplicate then
				table.insert(result, child)
			end
			gather(child)
		end
	end

	gather(root)
	return result
end

-- Chunk an array into groups of CHUNK_SIZE
local function chunkArray(arr, size)
	local chunks = {}
	local current = {}
	for i, item in ipairs(arr) do
		table.insert(current, item)
		if #current >= size then
			table.insert(chunks, current)
			current = {}
		end
	end
	if #current > 0 then
		table.insert(chunks, current)
	end
	return chunks
end

-- Serialize an object into a replication data packet
function NetworkReplicateSync:SerializeObject(object)
	local data = {
		NetworkId = object.NetworkId,
		ClassName = object.ClassName,
		Name = object.Name,
		Sequence = self:NextSequence(),
	}

	if object.Parent then
		data.ParentId = object.Parent.NetworkId
		data.ParentPath = object.Parent.GetFullName and object.Parent:GetFullName()
	end

	if object.Authority then
		data.Authority = object.Authority
	end

	local props = {}
	if object.GetProperties then
		local allProps = object:GetProperties()
		if type(allProps) == "table" then
			for propName, propValue in pairs(allProps) do
				if propName ~= "Parent" and propName ~= "ClassName" then
					props[propName] = propValue
				end
			end
		end
	end
	data.Properties = props

	return data
end

-- SyncPlaceToPlayer: send all replicated objects to a newly connected player
function NetworkReplicateSync:SyncPlaceToPlayer(session, root)
	if not session or not root then
		return
	end

	local objects = self:GetReplicateDescendants(root)
	local chunks = chunkArray(objects, CHUNK_SIZE)

	for chunkIndex, chunk in ipairs(chunks) do
		local entries = {}
		for _, object in ipairs(chunk) do
			table.insert(entries, self:SerializeObject(object))
		end

		self._networkService:SendToClient(session, Protocol.Channels.Replication, "replicate_chunk", {
			chunkIndex = chunkIndex,
			totalChunks = #chunks,
			entries = entries,
		}, true)
	end
end

-- Handle incoming chunk on the client side
function NetworkReplicateSync:RecvChunk(chunkData, networkObjects, createObject)
	if type(chunkData) ~= "table" or not chunkData.entries then
		return
	end

	for _, entry in ipairs(chunkData.entries) do
		local netId = entry.NetworkId
		if not netId then
			continue
		end

		-- Deduplication: skip objects that already exist
		if networkObjects[netId] then
			continue
		end

		-- Check if the parent has been deleted during place replication
		if entry.ParentPath and self._removedRef[entry.ParentPath] then
			continue
		end

		-- Try to resolve parent: ID first, fallback to path
		local parent = nil
		if entry.ParentId then
			parent = networkObjects[entry.ParentId]
		end
		if not parent and entry.ParentPath then
			local root = self._context.game and self._context.game:GetService("Workspace")
			if root and root.FindFirstChild then
				parent = root:FindFirstChild(entry.ParentPath)
			end
		end

		if not parent then
			-- Queue in pending replicates
			if not self._pendingReplicates[netId] then
				self._pendingReplicates[netId] = {
					entry = entry,
					createObject = createObject,
					networkObjects = networkObjects,
					createdAt = os.clock(),
				}
			end
			continue
		end

		-- Create the object
		if createObject then
			createObject(entry, parent, networkObjects)
		end
	end
end

-- Process pending replicates: check every frame for parents that have now spawned
function NetworkReplicateSync:StartProcessLoop()
	if self._processRunning then
		return
	end
	self._processRunning = true

	local task = zune.task
	task.spawn(function()
		while self._processRunning do
			task.wait(PENDING_CHECK_INTERVAL)
			self:ProcessPending()
		end
	end)
end

function NetworkReplicateSync:StopProcessLoop()
	self._processRunning = false
end

function NetworkReplicateSync:ProcessPending()
	local now = os.clock()
	local resolved = {}

	for netId, pending in pairs(self._pendingReplicates) do
		if now - pending.createdAt > MAX_PENDING_AGE then
			table.insert(resolved, netId)
			continue
		end

		local entry = pending.entry
		local networkObjects = pending.networkObjects

		-- Try to resolve parent
		local parent = nil
		if entry.ParentId then
			parent = networkObjects[entry.ParentId]
		end

		if parent and pending.createObject then
			pending.createObject(entry, parent, networkObjects)
			table.insert(resolved, netId)
		end
	end

	for _, netId in ipairs(resolved) do
		self._pendingReplicates[netId] = nil
	end
end

-- Handle runtime replication (object created during gameplay)
-- Client -> Server: SendNetReplicate
function NetworkReplicateSync:SendNetReplicate(object)
	if not object or not object.ShouldReplicate then
		return
	end

	if not self._networkService.IsClientConnected then
		return
	end

	local data = self:SerializeObject(object)
	self._networkService:SendToServer(Protocol.Channels.Replication, "runtime_replicate", data, true)
end

-- Handle deletion replication
function NetworkReplicateSync:RecvReplicateRemove(netId, networkObjects, isPlaceReplication)
	if isPlaceReplication then
		-- During place replication, record the removed path to prevent children from spawning
		local object = networkObjects[netId]
		if object and object.GetFullName then
			self._removedRef[object:GetFullName()] = true
		end
	end

	local object = networkObjects[netId]
	if object then
		if object.ForceDelete then
			object:ForceDelete()
		elseif object.Destroy then
			object:Destroy()
		end
		networkObjects[netId] = nil
	end

	-- Also remove from pending
	self._pendingReplicates[netId] = nil
end

-- Clear all pending replicates and removed references
function NetworkReplicateSync:Clear()
	self._pendingReplicates = {}
	self._removedRef = {}
	self._sequence = 0
end

function NetworkReplicateSync:GetPendingCount()
	local count = 0
	for _ in pairs(self._pendingReplicates) do
		count += 1
	end
	return count
end

return NetworkReplicateSync
