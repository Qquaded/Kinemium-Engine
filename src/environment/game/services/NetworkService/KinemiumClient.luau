-- clientside networking implementation by devcell

local KinemiumClient = {}
local gns = require("@gns")
local Client = gns.Client
local ser_adapters = require("@GNS/SerializerAdapters")

local registry = require("@InstanceRegistry")

local TICK_RATE = 20
local TICK_INTERVAL = 1 / TICK_RATE

local Vector3 = require("@Vector3")
local CFrame = require("@CFrame")
local Color3 = require("@Color3")

local function resolveValue(val)
	if type(val) == "table" then
		local type = val.__type or val.type
		if type == "Color3" then
			return Color3.FromTable(val)
		elseif type == "CFrame" then
			return CFrame.FromTable(val)
		elseif type == "Vector3" then
			return Vector3.FromTable(val)
		end
		return val
	else
		return val
	end
end

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
	local KinemiumModService = Datamodel:GetService("KinemiumModService")

	local function getActivatedMods()
		local enabled = {}
		for name, mod_data in pairs(KinemiumModService:GetEnabledMods()) do
			local manifest = mod_data.manifest
			local id = `{manifest.author}.{manifest.name}.{manifest.version}`
			enabled[id] = {
				name = manifest.name,
				version = manifest.version,
			}
		end
		return enabled
	end

	local name = GetFlagValue("username") or "User"
	local version = ENGINE_VERSION

	for _, object in pairs(Datamodel:GetDescendants()) do
		if object == Players.LocalPlayer then
			continue
		end
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
			new.UniqueId = repData.id
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

	-- wait a bit for game scripts to run
	task.wait(2.5)
	Client:Connect({ name = name, engine_version = version, mods = getActivatedMods() })

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
			if not isConnected then
				return
			end
			local workspace_buf = msg.workspace
			local replicated_buf = msg.replicated

			print("Got join batch from server")
			local workspace_deserialized = SerializationService.Deserialize(workspace_buf)
			local replicated_deserialized = SerializationService.Deserialize(replicated_buf)

			unwrap(workspace_deserialized[1], Datamodel:GetService("Workspace"))
			unwrap(replicated_deserialized[1], Datamodel:GetService("ReplicatedStorage"))
			print("Deserialized join batch successfully")
			print("Remapping ids from server authority.")

			for name, id in pairs(msg.ids) do
				local service = Datamodel:GetService(name)
				if service then
					service.UniqueId = id
					object_map[service] = id
					id_map[id] = service
					print(`Remapped service {name}'s id to {id}`)
				end
			end

			print("Successfully remapped ids")
		elseif msg.type == codes.DELETE then
			if not isConnected then
				return
			end
			local target = id_map[msg.object]
			if target then
				object_map[target] = nil
				id_map[msg.object] = nil
				target:Destroy()
			end
		elseif msg.type == codes.CREATEBATCH then
			if not isConnected then
				return
			end
			if msg.tick <= currentTick then
				return
			end -- discard stale

			--[[
				<table: 0x20020e14610> {
					type = "patch_batch",
					changes = <table: 0x20020e145e0> {
						[66] = <table: 0x20020e145b0> {
							Transparency = 0,
						},
					},
					tick = 1788,
				}
				<table: 0x2002250f820> {
					type = "patch_batch",
					changes = <table: 0x2002250f7f0> {
						[66] = <table: 0x2002250f7c0> {
							Size = <table: 0x2002250f790> {
								Y = 5,
								type = "Vector3",
								Z = 5,
								X = 5,
								__type = "Vector3",
							},
						},
					},
					tick = 2171,
				}
			--]]

			currentTick = msg.tick

			for id, changes in pairs(msg.changes) do
				local object = id_map[id]
				if object then
					for prop, val in pairs(changes) do
						print(prop, val)
						object[prop] = resolveValue(val)
					end
				else
					print(`Did not find object id {id}`)
				end
			end
		end
	end)

	return Client
end

return KinemiumClient
