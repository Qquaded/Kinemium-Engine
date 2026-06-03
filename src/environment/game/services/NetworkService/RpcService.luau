local NetworkAttributes = require("./NetworkAttributes")

local RpcService = {}

local rpcDispatchCache = {}
local rpcRegistry = {}
local nextRpcId = 1

function RpcService.Register(target, methodName, attribute, handler)
	if not NetworkAttributes.IsNetRpc(attribute) then
		warn(`[RpcService] Cannot register '{methodName}': invalid NetRpc attribute`)
		return nil
	end

	local rpcId = nextRpcId
	nextRpcId += 1

	local entry = {
		id = rpcId,
		name = methodName,
		target = target,
		attribute = attribute,
		handler = handler,
	}

	rpcRegistry[rpcId] = entry
	rpcDispatchCache[methodName] = rpcDispatchCache[methodName] or {}
	table.insert(rpcDispatchCache[methodName], entry)

	return rpcId
end

-- Unregister an RPC by its id
function RpcService.Unregister(rpcId)
	local entry = rpcRegistry[rpcId]
	if not entry then
		return false
	end

	rpcRegistry[rpcId] = nil

	local cache = rpcDispatchCache[entry.name]
	if cache then
		for i = #cache, 1, -1 do
			if cache[i].id == rpcId then
				table.remove(cache, i)
			end
		end
		if #cache == 0 then
			rpcDispatchCache[entry.name] = nil
		end
	end

	return true
end

function RpcService.ValidateAuthority(localPeerId, senderPeerId, authorityPeerId, attribute)
	local mode = attribute.AuthorMode

	if mode == NetworkAttributes.AuthorMode.Server then
		return senderPeerId == 1
	end

	if mode == NetworkAttributes.AuthorMode.Authority then
		return senderPeerId == 1 or senderPeerId == authorityPeerId
	end

	if mode == NetworkAttributes.AuthorMode.Any then
		if attribute.AllowToServerOnly and localPeerId ~= 1 then
			return senderPeerId == 1
		end
		return true
	end

	return false
end

-- Invoke an RPC by name with argument validation
-- methodName: the name of the RPC to invoke
-- context: { localPeerId, senderPeerId, authorityPeerId, target }
-- args: array of arguments to pass to the handler
function RpcService.Invoke(methodName, context, args)
	local entries = rpcDispatchCache[methodName]
	if not entries or #entries == 0 then
		return false, `RPC '{methodName}' not registered`
	end

	local invoked = false
	for _, entry in ipairs(entries) do
		if context.target and entry.target ~= context.target then
			continue
		end

		if
			not RpcService.ValidateAuthority(
				context.localPeerId,
				context.senderPeerId,
				context.authorityPeerId or 0,
				entry.attribute
			)
		then
			continue
		end

		local ok, err = pcall(entry.handler, entry.target, table.unpack(args or {}))
		if not ok then
			warn(`[RpcService] RPC '{methodName}' handler error: {err}`)
		end
		invoked = true
	end

	return invoked
end

-- Build an RPC envelope for network transmission
function RpcService.MakeRpcEnvelope(methodName, args, rpcId, reliable)
	return {
		__rpc = true,
		method = methodName,
		rpcId = rpcId,
		args = args or {},
		reliable = reliable,
	}
end

-- Check if a packet is an RPC envelope
function RpcService.IsRpcEnvelope(packet)
	return type(packet) == "table" and packet.__rpc == true and type(packet.method) == "string"
end

-- Get the dispatch cache entry for a method
function RpcService.GetCachedEntries(methodName)
	return rpcDispatchCache[methodName]
end

-- Get all registered RPCs
function RpcService.GetRegistry()
	return rpcRegistry
end

-- Clear all registered RPCs
function RpcService.Clear()
	rpcDispatchCache = {}
	rpcRegistry = {}
	nextRpcId = 1
end

return RpcService
