-- tick-based serverside networking implementation by devcell

local KinemiumServer = {}
local gns = require("@gns")
local server = gns.Server
local ser_adapters = require("@GNS/SerializerAdapters")
local Player = require("@Player")
local Instance = require("@Instance")

local TICK_RATE = 20
local TICK_INTERVAL = 1 / TICK_RATE

local currentTick = 0

_G.task = zune.task

ser_adapters.EnsureRegistered()

local object_map = {}
local connected = {}

export type KinemiumClientArgs = {
	name: string,
	engine_version: string,
}

local function hashString(str)
	local hash = 2166136261 -- FNV-1a 32-bit offset basis
	for i = 1, #str do
		hash = bit32.bxor(hash, string.byte(str, i))
		hash = (hash * 16777619) % 4294967296 -- FNV prime, keep 32-bit
	end
	return hash
end

function KinemiumServer:Init(Address, Port, Datamodel)
	local SerializationService = Datamodel:GetService("SerializationService")

	for _, object in pairs(Datamodel:GetDescendants()) do
		object_map[object] = object.UniqueId
		print(`Mapped id {object.UniqueId}:{object.ClassName}`)
	end

	print(`Listening on {Address}:{Port}`)

	server:Init(Address, Port)

	local workspace = Datamodel:GetService("Workspace")
	local replicated = Datamodel:GetService("ReplicatedStorage")

	local function getWorkspaceBuf()
		return SerializationService.SerializeInstancesAsync({ workspace })
	end

	local function getRepStorageBuf()
		return SerializationService.SerializeInstancesAsync({ replicated })
	end

	local function clean(props)
		local res = {}
		for key, value in pairs(props) do
			if type(value) == "table" then
				if value.__type == "EnumItem" then
					res[key] = "Enum"
				elseif value.ClassName then
					res[key] = value.UniqueId
				elseif value["ToTable"] then
					res[key] = value:ToTable()
					continue
				end
			end
		end
		return res
	end

	local function sendAll(data, reliable)
		for _, obj in pairs(connected) do
			local client = obj.client
			local s, r = pcall(function(...)
				return server:Send(client, data, reliable)
			end)
		end
	end

	local function replicateObject(object)
		local props = {}

		for key, value in pairs(object:GetProperties()) do
			if key == "Parent" then
				continue
			end
			if key == "ClassName" then
				continue
			end

			props[key] = value
		end

		props = clean(props)

		print("Sending object..")
		sendAll({
			type = "create_object",
			props = props,
			class = object.ClassName,
			name = object.Name,
			parent = object.Parent and object.Parent.UniqueId,
		}, false)
		print("Sent")
	end

	local function SendDeletePacket(object)
		sendAll({
			type = "delete_object",
			object = object.UniqueId,
		}, false)
	end

	server:OnClientConnectionRequest(function(client, arguments: KinemiumClientArgs)
		print("Client connected:", client.address, client.port)
		print("Args:", arguments)

		if arguments.engine_version ~= ENGINE_VERSION then
			local message = "Client version does not match server version, Expected version to be " .. ENGINE_VERSION
			server:Send(client, {
				type = "error",
				error = message,
			}, true)
		end

		if not connected[arguments.name] then
			connected[arguments.name] = { client = client, id = hashString(arguments.name), loaded = false }
			server:Send(client, { type = "join_ack", id = connected[arguments.name].id, isConnected = true }, true)
			server:Send(
				client,
				{ type = "join_batch", workspace = getWorkspaceBuf(), replicated = getRepStorageBuf() },
				true
			)

			-- create player object
			local new = Instance.new("Player")
			Player.callback(new, Datamodel.StarterGui)
			new.Name = arguments.name
			new.Parent = Datamodel.Players
			replicateObject(new)
			print("Created new object")
		else
			server:Send(client, { type = "error", error = "Player already in-game" }, true)
			return
		end
	end)

	server:OnClientRemoved(function(client)
		-- might be a security risk.. eh ill fix it later
		print(`Client {client.address} left the server.`)

		local name

		for n, other in pairs(connected) do
			if other.client == client then
				name = n
				break
			end
		end

		if name then
			if Datamodel.Players[name] then
				local plr = Datamodel.Players[name]
				SendDeletePacket(plr)
				plr:Destroy()
			end
		end
	end)

	local lastSentState = {}

	local REPLICATED_SERVICES = {
		"Workspace",
		"ReplicatedStorage",
		"Lighting",
	}

	task.spawn(function()
		while true do
			task.wait(TICK_INTERVAL)
			currentTick += 1

			local diffs = {}

			local toTrack = {}

			for _, serviceName in pairs(REPLICATED_SERVICES) do
				local service = Datamodel:GetService(serviceName)
				if service then
					-- track the service itself
					table.insert(toTrack, service)
					-- track its children
					for _, obj in pairs(service:GetChildren()) do
						table.insert(toTrack, obj)
					end
				end
			end

			for _, object in pairs(toTrack) do
				local id = object.UniqueId
				local current = object:GetProperties()
				local last = lastSentState[id]

				if not last then
					diffs[id] = { full = true, data = current, obj = object }
				else
					local changed = {}
					for property, value in pairs(current) do
						if value ~= last[property] then
							changed[property] = value
						end
					end

					if next(changed) then
						diffs[id] = changed
					end
				end

				lastSentState[id] = current
			end

			if next(diffs) then
				local result = {}

				for _, obj in pairs(diffs) do
					table.insert(result, SerializationService.SerializeInstancesAsync(obj.obj))
				end

				print(result)

				sendAll({
					type = "patch_batch",
					tick = currentTick,
					diffs = result,
				}, false)
				print(`Sent batch on tick {currentTick}`)
				print(`Current clients connected:`, connected)
			end
		end
	end)

	return server
end

return KinemiumServer
