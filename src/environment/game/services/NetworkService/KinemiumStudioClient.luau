-- changed-method clientside networking implementation by devcell

local KinemiumClient = {}
local gns = require("@gns")
local Client = gns.Client
local ser_adapters = require("@GNS/SerializerAdapters")

local registry = require("@InstanceRegistry")

_G.task = zune.task

ser_adapters.EnsureRegistered()

export type KinemiumClientArgs = {
	name: string,
	engine_version: string,
}

local isConnected = false
local object_map = {}
local id_map = {} -- id → object
local events = {}

function KinemiumClient:Init(Address, Port, Datamodel, Renderer)
	local SerializationService = Datamodel:GetService("SerializationService")
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
		CHANGE = "change_batch",
		EDIT = "edit_object",
		CREATE = "create_object",
		DELETE = "delete_object",
	}

	Client:Init(Address, Port)
	Client:Connect({ name = name, engine_version = version, mods = getActivatedMods() })

	local function PruneInstance(serverInstance, localInstance)
		for _, localChild in ipairs(localInstance:GetChildren()) do
			local serverChild = serverInstance:FindFirstChild(localChild.Name)

			if serverChild then
				PruneInstance(serverChild, localChild)
			else
				localChild:Destroy()
			end
		end
	end

	local function SyncInstance(networkInstance, parent)
		id_map[networkInstance.UniqueId] = networkInstance
		object_map[networkInstance] = networkInstance.UniqueId

		local localInstance

		if parent then
			localInstance = parent:FindFirstChild(networkInstance.Name)

			if not localInstance then
				localInstance = networkInstance
				localInstance.Parent = parent
			end
		else
			localInstance = Datamodel:GetService(networkInstance.Name)
		end

		if localInstance then
			localInstance.UniqueId = networkInstance.UniqueId

			id_map[networkInstance.UniqueId] = localInstance
			object_map[localInstance] = networkInstance.UniqueId
		end

		events[localInstance] = localInstance.Changed:Connect(function(property, value)
			print(`{localInstance.UniqueId}: {property}`, value)
			Client:Send({
				type = codes.EDIT,
				property = property,
				object = localInstance.UniqueId,
				value = value,
			}, true)
		end)

		for _, child in ipairs(networkInstance:GetChildren()) do
			SyncInstance(child, localInstance)
		end
	end

	local syncedWorldModel = false

	Client:OnRecieve(function(address, msg)
		if msg.type == codes.JOIN then
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
			local game_buf = msg.game
			local deserialized = SerializationService.Deserialize(game_buf)

			if deserialized then
				deserialized = deserialized[1]
				for _, service in ipairs(deserialized:GetChildren()) do
					SyncInstance(service)
				end

				for _, service in ipairs(deserialized:GetChildren()) do
					local reflection = Datamodel:GetService(service.Name)

					if reflection then
						PruneInstance(service, reflection)
					end
				end
				syncedWorldModel = true
			end
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
		elseif msg.type == codes.CHANGE then
			for i, changes in pairs(msg.changes) do
				local id = changes.id
				local prop = changes.prop
				local value = changes.value
				local target = id_map[id]

				if target then
					local success, result = pcall(function()
						target[prop] = value
					end)

					if success then
						continue
					else
						print(`Got error while applying new value to object {id}: {result}`)
					end
				end
			end
		end
	end)

	Datamodel.DescendantAdded:Connect(function(descendant)
		if syncedWorldModel then
			Client:Send({
				type = codes.CREATE,
				class = descendant.ClassName,
				parent = descendant.Parent.UniqueId,
				name = descendant.Name,
				id = descendant.UniqueId,
				props = descendant:GetProperties(),
			}, true)
		end
	end)

	Datamodel.DescendantRemoving:Connect(function(descendant)
		if syncedWorldModel then
			Client:Send({
				type = codes.DELETE,
				object = descendant.UniqueId,
			}, true)
		end
	end)

	return Client
end

return KinemiumClient
