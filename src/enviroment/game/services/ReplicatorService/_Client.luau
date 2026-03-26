local Client = {}

local kinet = require("@kinet")
type Client = typeof(kinet.Client)

local OPCODES = {
	CREATE = 1,
	REMOVE = 2,
	EDIT = 3,
}

function Client.init(context)
	local game = context.game
	local serializationService = context.SerializationService
	local networkService = context.NetworkService
	local Enum = require("@Enum")
	local kinet_client = kinet.Client :: Client

	-- NetworkId -> local object
	local lookup = {}
	-- ClassName -> pre-existing local singleton
	local singletonByClass = {}
	local userdata = serializationService.userdata

	-- Seed singletons from all existing descendants
	for _, v in pairs(game:GetDescendants()) do
		singletonByClass[v.ClassName] = v
	end
	singletonByClass[game.ClassName] = game

	game.DescendantAdded:Connect(function(object)
		if object.NetworkId ~= nil then
			lookup[object.NetworkId] = object
			log("[ClientReplicator] Mapped NetworkId", object.NetworkId, "->", object.Name)
		end
	end)

	game.DescendantRemoving:Connect(function(object)
		if object.NetworkId ~= nil then
			lookup[object.NetworkId] = nil
			log("[ClientReplicator] Unmapped NetworkId", object.NetworkId, "for", object.Name)
		end
	end)

	local function handleCreate(buffer)
		-- Deserialize the whole batch at once
		local deserialized = serializationService.Deserialize(buffer)
		if not deserialized then
			return
		end

		-- Pass 1: stamp all singletons first so parent lookups resolve correctly
		local deferred = {}
		for _, object in ipairs(deserialized) do
			local netId = object._props.NetworkId
			local parentNetId = object._props._parentID

			-- Clear injected props from the live object
			object._props.NetworkId = nil
			object._props._parentID = nil

			if netId == nil then
				warn("[ClientReplicator] Received object with no NetworkId, skipping:", object.ClassName)
				continue
			end

			if lookup[netId] then
				log("[ClientReplicator] NetworkId", netId, "already mapped, skipping")
				continue
			end

			-- Singleton resolution before trying to parent
			local existing = singletonByClass[object.ClassName]
			if existing and existing.NetworkId == nil then
				existing.NetworkId = netId
				lookup[netId] = existing
				log("[ClientReplicator] Stamped singleton", object.ClassName, "with NetworkId", netId)
				continue
			end

			-- Not a singleton — defer for parenting pass
			table.insert(deferred, {
				object = object,
				netId = netId,
				parentNetId = parentNetId,
			})
		end

		-- Pass 2: parent deferred objects, retrying for ordering issues
		local function tryParent(entry)
			local parent = lookup[entry.parentNetId]
			if not parent then
				return false
			end

			entry.object.NetworkOwnerType = Enum.MachineNetworkOwner.Server.Value
			entry.object.Parent = parent
			lookup[entry.netId] = entry.object
			log("[ClientReplicator] Created", entry.object.Name, "with NetworkId", entry.netId)
			return true
		end

		local retryQueue = {}
		for _, entry in ipairs(deferred) do
			if not tryParent(entry) then
				table.insert(retryQueue, entry)
			end
		end

		-- Retry loop for out-of-order batches (child before parent)
		local maxRetries = #retryQueue * #retryQueue
		local retries = 0
		while #retryQueue > 0 and retries < maxRetries do
			retries += 1
			local entry = table.remove(retryQueue, 1)
			if not tryParent(entry) then
				table.insert(retryQueue, entry)
			end
		end

		-- Anything still unresolved falls back to Workspace
		for _, entry in ipairs(retryQueue) do
			warn(
				"[ClientReplicator] Unresolved parent NetworkId",
				entry.parentNetId,
				"for",
				entry.object.Name,
				"— falling back to Workspace"
			)
			entry.object.NetworkOwnerType = Enum.MachineNetworkOwner.Server.Value
			entry.object.Parent = game.Workspace
			lookup[entry.netId] = entry.object
		end
	end

	kinet_client:OnRecieve(function(addr, data)
		if data.opcode == OPCODES.CREATE then
			-- data.objects is a raw compressed buffer, pass straight through
			handleCreate(data.objects)
		elseif data.opcode == OPCODES.REMOVE then
			local object = lookup[data.object]
			if object then
				lookup[data.object] = nil
				object:Destroy()
				log("[ClientReplicator] Removed NetworkId", data.object)
			else
				warn("[ClientReplicator] REMOVE: no object for NetworkId", data.object)
			end
		elseif data.opcode == OPCODES.EDIT then
			local object = lookup[data.object]
			if object then
				object[data.prop] = userdata.Decode(data.newval)
			else
				warn("[ClientReplicator] EDIT: no object for NetworkId", data.object, "prop:", data.prop)
			end
		end
	end)

	repeat
		log("[Replicator Client] Waiting for authentication...")
		task.wait()
	until kinet_client.IsAuthenticated == true

	log("[Replicator Client] Authenticated")

	return {}
end

return Client
