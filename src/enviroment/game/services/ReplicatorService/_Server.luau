local Server = {}

local KiNet = require("@kinet")
export type Server = typeof(KiNet.Server)

local OPCODES = {
	CREATE = 1,
	REMOVE = 2,
	EDIT = 3,
	PHYSICS = 4,
}

function Server.init(context)
	local game = context.game
	local serializationService = context.SerializationService
	local networkService = context.NetworkService
	local server = networkService.KiNet.Server :: Server

	local lookup = {}
	local values = {}
	local userdata = serializationService.userdata

	local nextNetId = 1
	local function assignNetworkId(object)
		if object.NetworkId == nil then
			object.NetworkId = nextNetId
			nextNetId += 1
		end
	end

	local function send_create(buffer)
		server:SendAll({
			opcode = OPCODES.CREATE,
			objects = buffer,
		})
	end

	local function send_edit(object, prop, newval)
		server:SendAll({
			opcode = OPCODES.EDIT,
			object = object.NetworkId,
			prop = prop,
			newval = newval,
		})
	end

	local function send_remove(netId)
		server:SendAll({
			opcode = OPCODES.REMOVE,
			object = netId,
		})
	end

	local function monitor(object)
		return object.Changed:Connect(function(prop, val)
			if object.NetworkId == nil then
				return
			end
			if prop == "_parentID" then
				return
			end
			if prop == "Parent" then
				return
			end
			if prop == "IsPlaytesting" then
				return
			end
			if prop == "NetworkId" then
				return
			end
			if prop == "CanReplicate" then
				return
			end

			local netId = object.NetworkId
			values[netId] = values[netId] or {}

			if values[netId][prop] == val then
				return
			end
			values[netId][prop] = val

			task.spawn(function()
				send_edit(object, prop, userdata.Encode(val))
			end)
		end)
	end

	for _, v in pairs(game:GetDescendants()) do
		assignNetworkId(v)
		lookup[v.NetworkId] = v
		log("[Replicator] Created lookup pointer: " .. v.NetworkId .. " to " .. v.Name)
		monitor(v)
	end

	game.DescendantAdded:Connect(function(object)
		assignNetworkId(object)
		lookup[object.NetworkId] = object
		log("[Replicator] Created lookup pointer: " .. object.NetworkId .. " to " .. object.Name)
		monitor(object)

		task.spawn(function()
			if object.CanReplicate == false then
				return
			end

			-- Inject NetworkId and parent reference into _props for serialization
			object._props.NetworkId = object.NetworkId
			object._props._parentID = object.Parent and object.Parent.NetworkId

			local serialized = serializationService.SerializeInstancesAsync({ object })

			object._props.NetworkId = nil
			object._props._parentID = nil

			send_create(serialized)
		end)
	end)

	game.DescendantRemoving:Connect(function(object)
		if object.NetworkId == nil then
			return
		end
		lookup[object.NetworkId] = nil
		values[object.NetworkId] = nil
		send_remove(object.NetworkId)
	end)

	server:OnNewClient(function(addr)
		log("[Replicator] New client connected, sending initial state")

		local batch = {}
		for _, obj in pairs(game:GetDescendants()) do
			if obj.CanReplicate == false then
				continue
			end
			assignNetworkId(obj)
			lookup[obj.NetworkId] = obj
			obj._props.NetworkId = obj.NetworkId
			obj._props._parentID = obj.Parent and obj.Parent.NetworkId
			table.insert(batch, obj)
		end

		local serialized = serializationService.SerializeInstancesAsync(batch)

		-- Clean up injected props
		for _, obj in pairs(batch) do
			obj._props.NetworkId = nil
			obj._props._parentID = nil
		end
		table.clear(batch)

		send_create(serialized)
	end)

	return {}
end

return Server
