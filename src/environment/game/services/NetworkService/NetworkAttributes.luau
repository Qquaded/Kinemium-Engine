-- NetworkAttributes: NetRpc and SyncVar attribute definitions for Kinemium networking
-- Based on Polytoria's NetworkAttributes.cs:14-63

local NetworkAttributes = {}

-- Authority modes for RPC calls (Polytoria's AuthorMode)
NetworkAttributes.AuthorMode = {
	Server = "Server",
	Authority = "Authority",
	Any = "Any",
}

-- Transfer modes for RPC calls
NetworkAttributes.TransferMode = {
	Reliable = "Reliable",
	Unreliable = "Unreliable",
}

-- Transfer channels (ENet-style channels mapped to GNS message flags)
NetworkAttributes.TransferChannel = {
	Default = 0,
	Replication = 1,
	State = 2,
	Input = 3,
}

-- [NetRpc] attribute: configures RPC behavior
-- AuthorMode: Server, Authority, or Any
-- TransferMode: Reliable or Unreliable
-- TransferChannel: Which channel to use (0-3)
-- CallLocal: Whether to execute locally when called
-- AllowToServerOnly: For Any mode, restrict to server-only broadcasts
function NetworkAttributes.NetRpc(config)
	config = config or {}
	return {
		__attribute = "NetRpc",
		AuthorMode = config.AuthorMode or NetworkAttributes.AuthorMode.Server,
		TransferMode = config.TransferMode or NetworkAttributes.TransferMode.Reliable,
		TransferChannel = config.TransferChannel or NetworkAttributes.TransferChannel.Default,
		CallLocal = config.CallLocal == true,
		AllowToServerOnly = config.AllowToServerOnly == true,
	}
end

-- [SyncVar] attribute: marks a property for automatic synchronization
-- AllowAuthorWrite: Authority peer can write without checking NetPropAuthority
-- ServerOnly: Only server can write
-- Unreliable: Use unreliable transport (client->server only), skips duplicate checks
function NetworkAttributes.SyncVar(config)
	config = config or {}
	return {
		__attribute = "SyncVar",
		AllowAuthorWrite = config.AllowAuthorWrite == true,
		ServerOnly = config.ServerOnly == true,
		Unreliable = config.Unreliable == true,
	}
end

function NetworkAttributes.IsNetRpc(attr)
	return type(attr) == "table" and attr.__attribute == "NetRpc"
end

function NetworkAttributes.IsSyncVar(attr)
	return type(attr) == "table" and attr.__attribute == "SyncVar"
end

return NetworkAttributes
