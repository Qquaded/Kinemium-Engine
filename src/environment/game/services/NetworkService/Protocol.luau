local Protocol = {}

Protocol.MAGIC = "KEN (Kinemium Engine Network)"

Protocol.Channels = {
	Control = "control",
	Replication = "replication",
	Input = "input",
	Message = "message",
}

Protocol.Kinds = {
	PlayerProfile = "player_profile",
	PlayerJoined = "player_joined",
	PlayerLeft = "player_left",
	WorldLoaded = "world_loaded",
	ClientReady = "client_ready",
	ClientObjectInventoryRequest = "client_object_inventory_request",
	ClientObjectInventoryResponse = "client_object_inventory_response",
	Create = "create",
	Remove = "remove",
	PatchBatch = "patch_batch",
	Snapshot = "snapshot",
	TerrainSnapshot = "terrain_snapshot",
	TerrainChunkBatch = "terrain_chunk_batch",
	RemoteEvent = "remote_event",
	UnreliableRemoteEvent = "unreliable_remote_event",
	RemoteFunctionRequest = "remote_function_request",
	RemoteFunctionResponse = "remote_function_response",
	RemoteDataUpdate = "remote_data_update",
	ControllerInput = "controller_input",
	OwnedStateBatch = "owned_state_batch",
	OwnedPatchBatch = "owned_patch_batch",
	OwnershipImpact = "ownership_impact",
	SnapshotAck = "snapshot_ack",

	Rpc = "rpc",
	ReplicateChunk = "replicate_chunk",
	RuntimeReplicate = "runtime_replicate",
	ReplicateRemove = "replicate_remove",
	PropBatch = "prop_batch",
	PropUpdateToServer = "prop_update_to_server",
	PropUpdateToServerUnreliable = "prop_update_to_server_unreliable",
}

function Protocol.MakeEnvelope(channel, kind, payload, tick)
	return {
		__network = Protocol.MAGIC,
		channel = channel,
		kind = kind,
		tick = tick,
		payload = payload,
	}
end

function Protocol.IsEnvelope(packet)
	return type(packet) == "table"
		and packet.__network == Protocol.MAGIC
		and packet.channel ~= nil
		and packet.kind ~= nil
end

return Protocol
