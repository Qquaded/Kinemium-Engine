-- tick-based serverside networking implementation by devcell

local KinemiumServer = {}
local gns = require("@gns")
local server = gns.Server
local ser_adapters = require("@GNS/SerializerAdapters")
local Player = require("@Player")
local Instance = require("@Instance")
local signal = require("@Kinemium.signal")

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
	mods: { [string]: { name: string, version: string } },
}

local function hashString(str)
	local hash = 2166136261 -- FNV-1a 32-bit offset basis
	for i = 1, #str do
		hash = bit32.bxor(hash, string.byte(str, i))
		hash = (hash * 16777619) % 4294967296 -- FNV prime, keep 32-bit
	end
	return hash
end

KinemiumServer.KickForMissingMods = true
KinemiumServer.KickForWrongEngineVer = true

function KinemiumServer:Init(Address, Port, Datamodel)
	local SerializationService = Datamodel:GetService("SerializationService")
	local KinemiumModService = Datamodel:GetService("KinemiumModService")

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
				end
			else
				res[key] = value
				continue
			end
		end
		return res
	end

	local function sendAll(data, reliable, blacklisted: { client: any })
		for _, obj in pairs(connected) do
			local client = obj.client
			if blacklisted then
				if table.find(blacklisted, client) then
					continue
				end
			end
			local s, r = pcall(function(...)
				return server:Send(client, data, reliable)
			end)
		end
	end

	local function replicateObject(object, blacklisted, reliable)
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
			id = object.UniqueId,
			name = object.Name,
			parent = object.Parent and object.Parent.UniqueId,
		}, reliable, blacklisted)
		print("Sent")
	end

	local function SendDeletePacket(object)
		sendAll({
			type = "delete_object",
			object = object.UniqueId,
		}, false)
	end

	local function buildIdMap()
		local idMap = {}

		for _, service in pairs(Datamodel:GetChildren()) do
			idMap[service.Name] = service.UniqueId
		end

		return idMap
	end

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

	server:OnClientConnectionRequest(function(client, arguments: KinemiumClientArgs)
		print("Client connected:", client.address, client.port)
		print("Args:", arguments)

		if KinemiumServer.KickForWrongEngineVer then
			if arguments.engine_version ~= ENGINE_VERSION then
				local message = "Client version does not match server version, Expected version to be "
					.. ENGINE_VERSION
				server:Send(client, {
					type = "error",
					error = message,
				}, true)
				server:DisconnectClient(client, message)
			end
		end

		if KinemiumServer.KickForMissingMods then
			local server_mods = getActivatedMods()
			local client_mods = arguments.mods or {}
			local missing = {}
			local mismatched = {}

			for id, server_data in pairs(server_mods) do
				local client_data = client_mods[id]
				if not client_data then
					table.insert(missing, id)
				elseif client_data.version ~= server_data.version then
					table.insert(mismatched, `{id} (server: {server_data.version}, client: {client_data.version})`)
				end
			end

			if #missing > 0 or #mismatched > 0 then
				local lines = {}
				if #missing > 0 then
					table.insert(lines, "Missing mods: " .. table.concat(missing, ", "))
				end
				if #mismatched > 0 then
					table.insert(lines, "Version mismatch: " .. table.concat(mismatched, ", "))
				end

				local message = table.concat(lines, "\n")
				print(message)
				server:Send(client, { type = "error", error = message }, true)
				server:DisconnectClient(client, message)
				return
			end
		end

		if not connected[arguments.name] then
			connected[arguments.name] = { client = client, id = hashString(arguments.name), loaded = false }

			server:Send(client, { type = "join_ack", id = connected[arguments.name].id, isConnected = true }, true)
			server:Send(client, {
				type = "join_batch",
				workspace = getWorkspaceBuf(),
				replicated = getRepStorageBuf(),
				ids = buildIdMap(),
			}, true)

			-- create player object
			local new = Instance.new("Player")
			Player.callback(new, Datamodel.StarterGui)
			new.Name = arguments.name
			new.Parent = Datamodel.Players
			replicateObject(new, { client })
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

	task.spawn(function()
		while true do
			task.wait(TICK_INTERVAL)
			currentTick += 1

			local changes = {}

			for _, object in pairs(workspace:GetDescendants()) do
				if object:IsA("BasePart") then
					local current = {
						cf = object.CFrame,
						color = object.Color,
						transparency = object.Transparency,
						size = object.Size,
					}
					local last = lastSentState[object.UniqueId]

					if not last then
						replicateObject(object, {}, true)
						lastSentState[object.UniqueId] = current -- track it, but don't add to changes
					else
						local newChanges = {}

						if current.cf ~= last.cf then
							newChanges.CFrame = current.cf
						end
						if current.color ~= last.color then
							newChanges.Color = current.color
						end
						if current.transparency ~= last.transparency then
							newChanges.Transparency = current.transparency
						end
						if current.size ~= last.size then
							newChanges.Size = current.size
						end

						if next(newChanges) then
							changes[object.UniqueId] = newChanges
						end
					end

					lastSentState[object.UniqueId] = current
				end
			end

			if next(changes) and next(connected) then
				print(changes)
				sendAll({ type = "patch_batch", tick = currentTick, changes = changes }, false)
			end
		end
	end)

	return server
end

return KinemiumServer
