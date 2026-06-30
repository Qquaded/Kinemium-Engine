-- clientside networking implementation by devcell

local KinemiumClient = {}
local gns = require("@gns")
local Client = gns.Client
local ser_adapters = require("@GNS/SerializerAdapters")

local registry = require("@InstanceRegistry")

local TICK_RATE = 20
local TICK_INTERVAL = 1 / TICK_RATE

local currentTick = 0

_G.task = zune.task

ser_adapters.EnsureRegistered()

export type KinemiumClientArgs = {
	name: string,
	engine_version: string,
}

local isConnected = false
local playerId = ""
local object_map = {}
local id_map = {} -- id → object

function KinemiumClient:Init(Address, Port, Datamodel, Renderer)
	local SerializationService = Datamodel:GetService("SerializationService")
	local Players = Datamodel:GetService("Players")

	local name = GetFlagValue("username") or "User"
	local version = ENGINE_VERSION

	for _, object in pairs(Datamodel:GetDescendants()) do
		object_map[object] = object.UniqueId
		print(`Mapped id {object.UniqueId}:{object.ClassName}`)
	end

	local function unwrap(object, parent)
		local children = object:GetChildren()
		for _, child in pairs(children) do
			child.Parent = parent
			id_map[child.UniqueId] = child
			object_map[child] = child.UniqueId
		end
		object:Destroy()
	end

	local function createObject(repData)
		local class = repData.class
		local parent

		for obj, id in pairs(object_map) do
			if id == repData.parent then
				parent = obj
				continue
			end
		end

		if parent then
			print("Found parent: " .. repData.parent .. " as " .. parent.Name)
			local new = registry.new(class, Renderer, Datamodel, true)
			new.Name = repData.name
			new.Parent = parent

			object_map[new] = new.UniqueId
			id_map[new.UniqueId] = new

			for key, value in pairs(repData.props) do
				if key == "Parent" then
					continue
				end
				new[key] = value
			end

			return new
		end
		return
	end

	local codes = {
		JOIN = "join_ack",
		JOINBATCH = "join_batch",
		ERROR = "error",
		CREATE = "create_object",
		CREATEBATCH = "patch_batch",
		DELETE = "delete_object",
	}

	Client:Init(Address, Port)

	Client:Connect({ name = name, engine_version = version })

	Client:OnRecieve(function(address, msg)
		if msg.type == codes.JOIN then
			if msg.id then
				playerId = msg.id
			end
			isConnected = msg.isConnected
			print(`Successfully connected to server {address}`)
		elseif msg.type == codes.ERROR then
			print(`Got error from server: {msg.error}`)
		elseif msg.type == codes.CREATE then
			print("Got create object request")
			print(`Class: {msg.class}\nParent unique id: {msg.parent}`)
			createObject(msg)
		elseif msg.type == codes.JOINBATCH then
			local workspace_buf = msg.workspace
			local replicated_buf = msg.replicated

			print("Got join batch from server")
			local workspace_deserialized = SerializationService.Deserialize(workspace_buf)
			local replicated_deserialized = SerializationService.Deserialize(replicated_buf)

			unwrap(workspace_deserialized[1], Datamodel:GetService("Workspace"))
			unwrap(replicated_deserialized[1], Datamodel:GetService("ReplicatedStorage"))
			print("Deserialized join batch successfully")
		elseif msg.type == codes.DELETE then
			local target = id_map[msg.object]
			if target then
				object_map[target] = nil
				id_map[msg.object] = nil
				target:Destroy()
			end
		elseif msg.type == codes.CREATEBATCH then
			if msg.tick <= currentTick then
				return
			end -- discard stale
			currentTick = msg.tick

			for id, diff in pairs(msg.diffs) do
				if diff.full then
					-- new object, deserialize and add
					local deserialized = SerializationService.Deserialize(diff.data)
					local object = deserialized[1]
					if object and not object_map[object] then
						object_map[object] = object.UniqueId
					end
				else
					-- find existing object and apply changed properties
					local target
					for obj, oid in pairs(object_map) do
						if oid == id then
							target = obj
							break
						end
					end
					if target then
						for property, value in pairs(diff.changed) do
							target[property] = value
						end
					end
				end
			end
		end
	end)

	return Client
end

return KinemiumClient
