--[[
  Protocol — message envelope definitions                     
                                                              
  Every network packet is wrapped in an envelope tagged with   
  a magic string, a channel (routing category), and a kind     
  (message type within that channel).                          
                                                              
  Channels:                                                    
    Control     — lifecycle: join/leave/ready/world-loaded     
    Replication — world state: create/remove/patch/snapshot    
    Input       — player input + owned-state submission        
    Message     — user-level: RemoteEvent/Function/Data, RPC   
--]]

local Protocol = {}

Protocol.MAGIC = "KINECO"

-- Channels group message kinds by purpose.
-- Each channel has its own rate-limiting / priority semantics.
Protocol.Channels = {
	Control = "control", -- Session lifecycle: profile, join, leave, ready
	Replication = "replication", -- World sync: create/remove objects, patch props, snapshot state
	Input = "input", -- Player input & owned-physics submission
	Message = "message", -- User-facing: RemoteEvent/Function/Data, RPC
}

-- Specific message kinds within each channel.
Protocol.Kinds = {
	-- Control channel
	PlayerProfile = "player_profile", -- Sent to client on connect: "you are this player"
	PlayerJoined = "player_joined", -- Broadcast: new player connected
	PlayerLeft = "player_left", -- Broadcast: player disconnected
	WorldLoaded = "world_loaded", -- Sent after initial sync: "you can start gameplay"
	ClientReady = "client_ready", -- Client confirms world is loaded and character can spawn
	ClientObjectInventoryRequest = "client_object_inventory_request",
	ClientObjectInventoryResponse = "client_object_inventory_response",

	-- Replication channel
	Create = "create", -- Server → Client: serialised object tree(s)
	Remove = "remove", -- Server → Client: destroy object by NetworkId
	PatchBatch = "patch_batch", -- Server → Client: batched property updates
	Snapshot = "snapshot", -- Server → Client (unreliable): state deltas per tick
	TerrainSnapshot = "terrain_snapshot", -- Full terrain state for initial sync
	TerrainChunkBatch = "terrain_chunk_batch", -- Incremental terrain edits

	-- Message channel
	RemoteEvent = "remote_event", -- User-created RemoteEvent
	UnreliableRemoteEvent = "unreliable_remote_event",
	RemoteFunctionRequest = "remote_function_request",
	RemoteFunctionResponse = "remote_function_response",
	RemoteDataUpdate = "remote_data_update",

	-- Input channel
	ControllerInput = "controller_input", -- Client → Server: input actions
	OwnedStateBatch = "owned_state_batch", -- Client → Server (unreliable): owned physics state
	OwnedPatchBatch = "owned_patch_batch", -- Client → Server (reliable): owned property patches
	OwnershipImpact = "ownership_impact", -- Collision/impact events from owned objects
	SnapshotAck = "snapshot_ack", -- Client → Server: tick acknowledged

	-- RPC (Message channel sub-kind)
	Rpc = "rpc",

	-- Legacy / deprecated kinds kept for compatibility
	ReplicateChunk = "replicate_chunk",
	RuntimeReplicate = "runtime_replicate",
	ReplicateRemove = "replicate_remove",
	PropBatch = "prop_batch",
	PropUpdateToServer = "prop_update_to_server",
	PropUpdateToServerUnreliable = "prop_update_to_server_unreliable",
}

-- Create an envelope table tagged with the magic string.
-- The transport layer uses __network to distinguish our packets.
function Protocol.MakeEnvelope(channel, kind, payload, tick)
	return {
		__network = Protocol.MAGIC,
		channel = channel,
		kind = kind,
		tick = tick,
		payload = payload,
	}
end

-- Validate that a table is a properly-formed Kinemium envelope.
function Protocol.IsEnvelope(packet)
	return type(packet) == "table"
		and packet.__network == Protocol.MAGIC
		and packet.channel ~= nil
		and packet.kind ~= nil
end

return Protocol
