local NetworkAttributes = require("../NetworkService/NetworkAttributes")
local Protocol = require("../NetworkService/Protocol")

local NetworkPropSync = {}
NetworkPropSync.__index = NetworkPropSync

local BATCH_INTERVAL = 0.050
local DEFAULT_UNRELIABLE_SYNC_INTERVAL = 1.0

function NetworkPropSync.new(context)
	local self = setmetatable({
		_context = context,
		_networkService = context.NetworkService,
		_batchBroadcasts = {},
		_lastSyncedValues = {},
		_unreliableTimestamps = {},
		_sequenceCounters = {},
		_syncVarRegistry = {},
		_processRunning = false,
		_lastFlush = 0,
	}, NetworkPropSync)

	return self
end

-- Register a property as SyncVar
function NetworkPropSync:RegisterSyncVar(objectNetId, propName, attribute)
	if not NetworkAttributes.IsSyncVar(attribute) then
		return false
	end

	local key = `{objectNetId}:{propName}`
	self._syncVarRegistry[key] = attribute
	return true
end

-- Get the SyncVar attribute for a property (nil if not registered)
function NetworkPropSync:GetSyncVar(objectNetId, propName)
	return self._syncVarRegistry[`{objectNetId}:{propName}`]
end

-- Get the next sequence number for a property
function NetworkPropSync:GetSequenceForProp(objectNetId, propName)
	local key = `{objectNetId}:{propName}`
	local seq = (self._sequenceCounters[key] or 0) + 1
	self._sequenceCounters[key] = seq
	return seq
end

function NetworkPropSync:CheckPropHasAuthority(objectNetId, propName, localPeerId, objectAuthorityPeerId)
	local syncVar = self:GetSyncVar(objectNetId, propName)

	-- No SyncVar -> always broadcast (server has full authority)
	if not syncVar then
		return localPeerId == 1
	end

	-- ServerOnly -> only server can write
	if syncVar.ServerOnly then
		return localPeerId == 1
	end

	-- AllowAuthorWrite + local peer is authority -> allow
	if syncVar.AllowAuthorWrite and localPeerId == objectAuthorityPeerId then
		return true
	end

	-- Server always has authority
	if localPeerId == 1 then
		return true
	end

	return false
end

-- Detect if a property value has changed (duplicate detection)
function NetworkPropSync:HasValueChanged(objectNetId, propName, newValue)
	local key = `{objectNetId}:{propName}`
	local lastValue = self._lastSyncedValues[key]

	if lastValue == nil and newValue == nil then
		return false
	end

	if lastValue == nil or newValue == nil then
		self._lastSyncedValues[key] = newValue
		return true
	end

	if type(lastValue) ~= type(newValue) then
		self._lastSyncedValues[key] = newValue
		return true
	end

	-- For tables, do a shallow comparison
	if type(newValue) == "table" then
		for k, v in pairs(newValue) do
			if lastValue[k] ~= v then
				self._lastSyncedValues[key] = newValue
				return true
			end
		end
		for k in pairs(lastValue) do
			if newValue[k] == nil then
				self._lastSyncedValues[key] = newValue
				return true
			end
		end
		return false
	end

	if lastValue ~= newValue then
		self._lastSyncedValues[key] = newValue
		return true
	end

	return false
end

-- Check unreliable throttling
function NetworkPropSync:ShouldThrottleUnreliable(objectNetId, propName)
	local syncVar = self:GetSyncVar(objectNetId, propName)
	if not syncVar or not syncVar.Unreliable then
		return false
	end

	local key = `{objectNetId}:{propName}`
	local now = os.clock()
	local lastSend = self._unreliableTimestamps[key] or 0

	if now - lastSend < DEFAULT_UNRELIABLE_SYNC_INTERVAL then
		return true
	end

	self._unreliableTimestamps[key] = now
	return false
end

-- Queue a property update for batched broadcasting (server -> clients)
function NetworkPropSync:BroadcastPropUpdate(objectNetId, propName, propValue, excludeSession)
	local syncVar = self:GetSyncVar(objectNetId, propName)

	-- Check duplicate (skip for unreliable)
	if syncVar and not syncVar.Unreliable then
		if not self:HasValueChanged(objectNetId, propName, propValue) then
			return
		end
	end

	-- Unreliable throttling
	if self:ShouldThrottleUnreliable(objectNetId, propName) then
		return
	end

	local sequence = self:GetSequenceForProp(objectNetId, propName)

	table.insert(self._batchBroadcasts, {
		netId = objectNetId,
		prop = propName,
		value = propValue,
		sequence = sequence,
		excludeSession = excludeSession,
		reliable = not (syncVar and syncVar.Unreliable),
	})
end

-- Flush batched property updates
function NetworkPropSync:FlushBatch()
	if #self._batchBroadcasts == 0 then
		return
	end

	-- Group by reliable/unreliable and exclude session
	local reliableBatch = {}
	local unreliableBatch = {}
	local excludedReliable = {}
	local excludedUnreliable = {}

	for _, entry in ipairs(self._batchBroadcasts) do
		if entry.excludeSession then
			local key = tostring(entry.excludeSession)
			if entry.reliable then
				excludedReliable[key] = excludedReliable[key] or { exclude = entry.excludeSession, entries = {} }
				table.insert(excludedReliable[key].entries, entry)
			else
				excludedUnreliable[key] = excludedUnreliable[key] or { exclude = entry.excludeSession, entries = {} }
				table.insert(excludedUnreliable[key].entries, entry)
			end
		else
			if entry.reliable then
				table.insert(reliableBatch, entry)
			else
				table.insert(unreliableBatch, entry)
			end
		end
	end

	-- Send reliable batch
	if #reliableBatch > 0 then
		self._networkService:Broadcast(Protocol.Channels.Replication, "prop_batch", { updates = reliableBatch }, true)
	end

	-- Send unreliable batch
	if #unreliableBatch > 0 then
		self._networkService:Broadcast(
			Protocol.Channels.Replication,
			"prop_batch",
			{ updates = unreliableBatch },
			false
		)
	end

	-- Send filtered batches (excluding specific sessions)
	for _, group in pairs(excludedReliable) do
		self._networkService:BroadcastFiltered(
			Protocol.Channels.Replication,
			"prop_batch",
			{ updates = group.entries },
			true,
			function(client)
				return client ~= group.exclude
			end
		)
	end

	for _, group in pairs(excludedUnreliable) do
		self._networkService:BroadcastFiltered(
			Protocol.Channels.Replication,
			"prop_batch",
			{ updates = group.entries },
			false,
			function(client)
				return client ~= group.exclude
			end
		)
	end

	self._batchBroadcasts = {}
end

-- Client -> Server property update
function NetworkPropSync:BroadcastPropUpdateToServer(objectNetId, propName, propValue, objectAuthorityPeerId)
	local localPeerId = self._networkService.LocalPeerID or 0

	if not self:CheckPropHasAuthority(objectNetId, propName, localPeerId, objectAuthorityPeerId) then
		return false
	end

	local syncVar = self:GetSyncVar(objectNetId, propName)
	local reliable = not (syncVar and syncVar.Unreliable)

	local channel = if reliable then "prop_update_to_server" else "prop_update_to_server_unreliable"

	self._networkService:SendToServer(Protocol.Channels.Replication, channel, {
		netId = objectNetId,
		prop = propName,
		value = propValue,
	}, reliable)

	return true
end

-- Start the batch processing loop (server-side)
function NetworkPropSync:StartProcessLoop()
	if self._processRunning then
		return
	end
	self._processRunning = true

	local task = zune.task
	task.spawn(function()
		while self._processRunning do
			task.wait(BATCH_INTERVAL)
			self:FlushBatch()
		end
	end)
end

function NetworkPropSync:StopProcessLoop()
	self._processRunning = false
end

-- Clear all state
function NetworkPropSync:Clear()
	self._batchBroadcasts = {}
	self._lastSyncedValues = {}
	self._unreliableTimestamps = {}
	self._sequenceCounters = {}
	self._syncVarRegistry = {}
end

return NetworkPropSync
