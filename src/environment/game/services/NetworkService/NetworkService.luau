local Instance = require("@Instance")
local signal = require("@Kinemium.signal")
local Enum = require("@EnumMap")

local GNS
local defaultNetworkStack
local gnsOk, gnsResult = pcall(require, "@gns")
if gnsOk then
	defaultNetworkStack = gnsResult
else
	print("[NetworkService] GNS failed to load, falling back to KiNet: " .. tostring(gnsResult))
	defaultNetworkStack = require("@KiNet")
end

local Protocol = require("./Protocol")
local ServerPreview = require("./ServerPreview")
local GuiMirror = require("../../runtime/GuiMirror")
local RateLimiter = require("./RateLimiter")
local RpcService = require("./RpcService")
local NetworkAttributes = require("./NetworkAttributes")

local NetworkService = Instance.new("NetworkService")
NetworkService.ExplorerHidden = true
NetworkService._Intents = Enum.PluginIntents.Network

local task = zune.task

local function makeNoNetworkStack()
	local server = {}
	local client = {}

	function server:Init(address, port)
		self.Address = address or "0.0.0.0"
		self.Port = port or 0
		self.Socket = nil
		return nil
	end

	function server:Listen() end
	function server:Send()
		return false
	end
	function server:SendAll()
		return false
	end
	function server:SendFiltered()
		return false
	end
	function server:IsClientConnected()
		return false
	end
	function server:GetClientStats()
		return nil
	end
	function server:Shutdown() end
	function server:OnClientConnectionRequest(callback)
		self._onClientConnectionRequest = callback
	end
	function server:OnRecieve(callback)
		self._onRecieve = callback
	end
	function server:OnClientRemoved(callback)
		self._onClientRemoved = callback
	end
	function server:OnPreAuthMessage(callback)
		self._onPreAuthMessage = callback
	end

	function client:Init(address, port, authToken)
		self.ServerAddress = address or "127.0.0.1"
		self.ServerPort = port or 0
		self.AuthToken = authToken
		self.Socket = nil
		return nil
	end

	function client:Listen() end
	function client:Connect() end
	function client:StartHeartbeat() end
	function client:Send()
		return false
	end
	function client:Disconnect() end
	function client:OnRecieve(callback)
		self._onRecieve = callback
	end
	function client:OnShutdown(callback)
		self._onShutdown = callback
	end

	return {
		Name = "None",
		MultiplayerEnabled = false,
		Replicate = false,
		Server = server,
		Client = client,
	}
end

local networkStacks = {}
local activeNetworkStackName = nil
local activeNetworkStack = nil
local rebindActiveNetworkStack = nil
local mappedNetworkStackFunctionNames = {}
local overriddenNetworkStackFunctions = {}
local protectedNetworkStackFunctionNames = {
	GetPrimaryNetworkName = true,
	GetPrimaryNetworkStack = true,
	GetPrimaryNetworkStackName = true,
	GetRegisteredNetworkStacks = true,
	RegisterNetwork = true,
	RegisterNetworkStack = true,
	RegisterStack = true,
	SetNetworkStack = true,
	SetPrimaryNetwork = true,
	SetPrimaryNetworkStack = true,
	DisableMultiplayer = true,
}

local function callOptional(target, methodName, ...)
	if target and type(target[methodName]) == "function" then
		return pcall(target[methodName], target, ...)
	end
	return true, nil
end

local function copyNetworkStackMap(source)
	local copy = {}
	for key, value in pairs(source or {}) do
		copy[key] = value
	end
	return copy
end

local function setNetworkStackProperties()
	NetworkService._props.GNS = activeNetworkStack
	NetworkService._props.NetworkStack = activeNetworkStack
	NetworkService._props.ActiveNetworkStackName = activeNetworkStackName
	NetworkService._props.Replicate = activeNetworkStack and activeNetworkStack.Replicate ~= false
end

local function unmapNetworkStackFunctions()
	for name in pairs(mappedNetworkStackFunctionNames) do
		NetworkService._props[name] = overriddenNetworkStackFunctions[name]
	end
	mappedNetworkStackFunctionNames = {}
	overriddenNetworkStackFunctions = {}
end

local function mapNetworkStackFunctions(stack)
	for name, value in pairs(stack or {}) do
		if type(value) == "function" and not protectedNetworkStackFunctionNames[name] then
			overriddenNetworkStackFunctions[name] = NetworkService._props[name]
			NetworkService._props[name] = value
			mappedNetworkStackFunctionNames[name] = true
		end
	end
end

function NetworkService:RegisterNetworkStack(name, stack)
	if type(name) == "table" and stack == nil then
		stack = name
		name = stack.Name or stack.name
	end

	if type(name) ~= "string" or name == "" then
		warn("[NetworkService] RegisterNetworkStack requires a non-empty stack name")
		return false
	end
	if type(stack) ~= "table" then
		warn(`[NetworkService] RegisterNetworkStack({name}) requires a table`)
		return false
	end

	networkStacks[name] = stack
	stack.Name = stack.Name or name
	return true
end

NetworkService.RegisterNetwork = NetworkService.RegisterNetworkStack
NetworkService.RegisterStack = NetworkService.RegisterNetworkStack

function NetworkService:SetPrimaryNetworkStack(nameOrStack, optionalName)
	local name = nameOrStack
	local stack = nil

	if type(nameOrStack) == "table" then
		stack = nameOrStack
		name = optionalName or stack.Name or stack.name or "Custom"
		self:RegisterNetworkStack(name, stack)
	else
		stack = networkStacks[name]
	end

	if not stack then
		warn("[NetworkService] Attempted to set unknown network stack: " .. tostring(name))
		return false
	end

	if activeNetworkStack == stack and activeNetworkStackName == name then
		return true
	end

	local oldStack = activeNetworkStack
	if oldStack then
		unmapNetworkStackFunctions()
		callOptional(oldStack, "Unload")
		callOptional(oldStack.Client, "Disconnect")
		callOptional(oldStack.Server, "Shutdown")
	end

	activeNetworkStackName = name
	activeNetworkStack = stack
	GNS = stack
	setNetworkStackProperties()
	mapNetworkStackFunctions(stack)

	if stack.Load then
		local ok, err = pcall(stack.Load, stack, NetworkService)
		if not ok then
			warn(`[NetworkService] Network stack {name} Load failed: {tostring(err)}`)
		end
	end

	if rebindActiveNetworkStack then
		rebindActiveNetworkStack()
	end

	NetworkService.IsClientConnected = false
	print("[NetworkService] Active network stack set to: " .. tostring(name))
	return true
end

NetworkService.SetPrimaryNetwork = NetworkService.SetPrimaryNetworkStack
NetworkService.SetNetworkStack = function(self, stack, name)
	return self:SetPrimaryNetworkStack(stack, name)
end

function NetworkService:GetPrimaryNetworkStackName()
	return activeNetworkStackName
end

NetworkService.GetPrimaryNetworkName = NetworkService.GetPrimaryNetworkStackName

function NetworkService:GetPrimaryNetworkStack()
	return activeNetworkStack
end

function NetworkService:GetRegisteredNetworkStacks()
	return copyNetworkStackMap(networkStacks)
end

function NetworkService:DisableMultiplayer()
	return self:SetPrimaryNetworkStack("None")
end

NetworkService:RegisterNetworkStack("Default", defaultNetworkStack)
local noNetworkStack = makeNoNetworkStack()
NetworkService:RegisterNetworkStack("None", noNetworkStack)
NetworkService:RegisterNetworkStack("Disabled", noNetworkStack)
NetworkService:SetPrimaryNetworkStack("Default")

local tickSignal = signal.new()
local clientConnectedSignal = signal.new()
local clientRemovedSignal = signal.new()
local disconnectedSignal = signal.new()
local packetSignal = signal.new()

local packetHandlers = {}
local pendingPackets = {}
local sessionsByKey = {}
local sessionsByUserId = {}
local trafficStats = {
	sent = {
		total = 0,
		reliable = 0,
		unreliable = 0,
		byMessage = {},
	},
	received = {
		total = 0,
		reliable = 0,
		unreliable = 0,
		byMessage = {},
	},
}

local currentTick = 0
local tickRate = 30
local tickInterval = 1 / tickRate
local tickAccumulator = 0
local tickLoopBound = false
local networkSimulation = {
	enabled = false,
	lagMs = 0,
	jitterMs = 0,
	lossPercent = 0,
	dropReliable = false,
}

local previewStartedAt = os.time()
local previewMetadata = {
	name = "Kinemium Server",
	motd = "A Kinemium server is online.",
	maxPlayers = 16,
	tags = {},
	extra = {},
}

local datamodelRef = nil
local connectedTo = {}
local localPlayerUserId = nil

local function cloneTable(source)
	local copy = {}
	for key, value in pairs(source or {}) do
		copy[key] = value
	end
	return copy
end

local function updatePreviewMetadata(data)
	if type(data) ~= "table" then
		return cloneTable(previewMetadata)
	end

	for key, value in pairs(data) do
		previewMetadata[key] = value
	end

	return cloneTable(previewMetadata)
end

local function clonePublicSession(session)
	if type(session) ~= "table" then
		return nil
	end

	return {
		key = if session.userId ~= nil then `user_{session.userId}` else session.name,
		name = session.name,
		userId = session.userId,
		connectedAt = session.connectedAt,
		lastInputSequence = session.lastInputSequence,
		lastAppliedInputSequence = session.lastAppliedInputSequence,
		lastAcknowledgedInputSequence = session.lastAcknowledgedInputSequence,
		player = session.player,
	}
end

local function getTrafficBucket(direction, channel, kind)
	local key = `{channel}:{kind}`
	local bucket = trafficStats[direction].byMessage[key]
	if not bucket then
		bucket = {
			channel = channel,
			kind = kind,
			total = 0,
			reliable = 0,
			unreliable = 0,
		}
		trafficStats[direction].byMessage[key] = bucket
	end

	return bucket
end

local function recordTraffic(direction, envelope, reliable)
	local stats = trafficStats[direction]
	stats.total += 1
	if reliable then
		stats.reliable += 1
	else
		stats.unreliable += 1
	end

	local bucket = getTrafficBucket(direction, envelope.channel, envelope.kind)
	bucket.total += 1
	if reliable then
		bucket.reliable += 1
	else
		bucket.unreliable += 1
	end
end

local function cloneTrafficSnapshot(snapshot)
	local copy = {
		total = snapshot.total,
		reliable = snapshot.reliable,
		unreliable = snapshot.unreliable,
		byMessage = {},
	}

	for key, bucket in pairs(snapshot.byMessage) do
		copy.byMessage[key] = {
			channel = bucket.channel,
			kind = bucket.kind,
			total = bucket.total,
			reliable = bucket.reliable,
			unreliable = bucket.unreliable,
		}
	end

	return copy
end

local function resetTrafficStats()
	for _, direction in ipairs({ "sent", "received" }) do
		trafficStats[direction].total = 0
		trafficStats[direction].reliable = 0
		trafficStats[direction].unreliable = 0
		trafficStats[direction].byMessage = {}
	end
end

local function readNumberFlag(names, defaultValue)
	for _, name in ipairs(names) do
		local value = tonumber(GetFlagValue(name))
		if value ~= nil then
			return value
		end
	end
	return defaultValue
end

local function readNetworkSimulationConfig()
	local config = {
		enabled = false,
		lagMs = math.max(0, readNumberFlag({ "net_lag_ms", "lag_ms" }, 0)),
		jitterMs = math.max(0, readNumberFlag({ "net_jitter_ms", "jitter_ms" }, 0)),
		lossPercent = math.clamp(readNumberFlag({ "net_loss_percent", "packet_loss_percent" }, 0), 0, 100),
		dropReliable = FlagExists("net_drop_reliable") or FlagExists("drop_reliable_packets"),
	}

	config.enabled = config.lagMs > 0 or config.jitterMs > 0 or config.lossPercent > 0
	return config
end

local function shouldDropSimulatedPacket(reliable)
	if not networkSimulation.enabled or networkSimulation.lossPercent <= 0 then
		return false
	end
	if reliable and not networkSimulation.dropReliable then
		return false
	end
	return math.random() * 100 < networkSimulation.lossPercent
end

local function getSimulatedDelaySeconds()
	if not networkSimulation.enabled then
		return 0
	end

	local delayMs = networkSimulation.lagMs
	if networkSimulation.jitterMs > 0 then
		delayMs += (math.random() * 2 - 1) * networkSimulation.jitterMs
	end

	return math.max(0, delayMs) / 1000
end

local function clientKey(client)
	if client and client.hConn ~= nil then
		return `gns:{client.hConn}`
	end
	return `{client.address}:{client.port}`
end

local function normalizeRecipient(recipient)
	if recipient == nil then
		return nil
	end

	if recipient.client then
		return recipient.client
	end

	return recipient
end

local function queuePendingPacket(sender, envelope)
	local key = `{envelope.channel}:{envelope.kind}`
	local bucket = pendingPackets[key]
	if not bucket then
		bucket = {}
		pendingPackets[key] = bucket
	end

	table.insert(bucket, {
		sender = sender,
		envelope = envelope,
	})
end

local function dispatchPacket(sender, envelope)
	if not Protocol.IsEnvelope(envelope) then
		return false
	end

	local channelHandlers = packetHandlers[envelope.channel]
	local kindHandlers = channelHandlers and channelHandlers[envelope.kind]
	recordTraffic("received", envelope, envelope.reliable == true)
	if not kindHandlers or #kindHandlers == 0 then
		queuePendingPacket(sender, envelope)
		return true
	end

	packetSignal:Fire(sender, envelope)

	for _, callback in ipairs(kindHandlers) do
		task.spawn(function()
			callback(sender, envelope.payload, envelope)
		end)
	end

	return true
end

local function flushPendingPackets(channel, kind)
	local key = `{channel}:{kind}`
	local bucket = pendingPackets[key]
	if not bucket then
		return
	end

	pendingPackets[key] = nil
	for _, entry in ipairs(bucket) do
		dispatchPacket(entry.sender, entry.envelope)
	end
end

local function registerMessageHandler(channel, kind, callback)
	packetHandlers[channel] = packetHandlers[channel] or {}
	packetHandlers[channel][kind] = packetHandlers[channel][kind] or {}
	table.insert(packetHandlers[channel][kind], callback)
	flushPendingPackets(channel, kind)
	return function()
		local handlers = packetHandlers[channel] and packetHandlers[channel][kind]
		if not handlers then
			return
		end

		for index = #handlers, 1, -1 do
			if handlers[index] == callback then
				table.remove(handlers, index)
			end
		end

		if #handlers == 0 then
			packetHandlers[channel][kind] = nil
			if next(packetHandlers[channel]) == nil then
				packetHandlers[channel] = nil
			end
		end
	end
end

local function sendEnvelope(sendFn, recipient, channel, kind, payload, reliable)
	local envelope = Protocol.MakeEnvelope(channel, kind, payload, currentTick)
	envelope.reliable = reliable == true

	local actualReliable = reliable == true
	if shouldDropSimulatedPacket(actualReliable) then
		return true
	end

	local function sendNow()
		local sent
		if recipient then
			sent = sendFn(normalizeRecipient(recipient), envelope, actualReliable)
		else
			sent = sendFn(envelope, actualReliable)
		end

		if sent == false then
			return false
		end

		recordTraffic("sent", envelope, actualReliable)
		return true
	end

	local delaySeconds = getSimulatedDelaySeconds()
	if delaySeconds > 0 then
		task.delay(delaySeconds, sendNow)
		return true
	end

	local sent = sendNow()
	if sent == false then
		return false
	end
	return true
end

local function withMouseInjection(player, renderer, datamodel)
	if player.GetMouse then
		return
	end

	player:SetProperties({
		GetMouse = function(self)
			if not self.MouseInstance then
				local Mouse = require("@Mouse")
				local mouseInstance = Instance.new("Mouse")
				self.MouseInstance = Mouse.callback(mouseInstance, renderer, datamodel)
			end
			return self.MouseInstance
		end,
	})
end

local function attachPlayerSession(datamodel, session)
	local players = datamodel.Players
	local player = players:AddPlayer(session.name, session.userId, datamodel, { noCharacter = true })
	if not player then
		return nil
	end

	player.client = session.client

	local playerGui = Instance.new("PlayerGui")
	GuiMirror.MarkTreeLocalOnly(playerGui)
	playerGui.Parent = player
	player.PlayerGui = playerGui

	local guiMirrorController = GuiMirror.new(playerGui)
	guiMirrorController:BindContainer(datamodel.StarterGui, "StarterGui")
	session.guiMirrorController = guiMirrorController

	session.player = player
	return player
end

local function isCharacterModelForSession(model, session)
	if not model or model.ClassName ~= "Model" or not session then
		return false
	end
	if model.FindFirstChildOfClass and not model:FindFirstChildOfClass("Humanoid") then
		return false
	end

	local uid = model.GetAttribute and model:GetAttribute("__characterUserId")
	if type(uid) == "number" and uid == session.userId then
		return true
	end

	return model.Name == session.name
end

local function destroyCharacterModelsForSession(datamodel, session)
	local workspace = datamodel and datamodel:GetService("Workspace")
	if not workspace then
		return
	end

	for _, child in ipairs(workspace:GetChildren()) do
		if isCharacterModelForSession(child, session) then
			child:Destroy()
		end
	end
end

local function cleanupPlayerSession(datamodel, session)
	local players = datamodel:GetService("Players")
	local player = session.player
	if not player then
		destroyCharacterModelsForSession(datamodel, session)
		return
	end

	if player.Character then
		player.Character:Destroy()
		player.Character = nil
	end
	destroyCharacterModelsForSession(datamodel, session)

	if session.guiMirrorController then
		session.guiMirrorController:Destroy()
		session.guiMirrorController = nil
	end

	players:RemovePlayer(player)
	player:Destroy()
	session.player = nil
end

local function bindTickLoop(runService)
	if tickLoopBound then
		return
	end

	tickLoopBound = true
	task.spawn(function()
		local lastClock = os.clock()

		while datamodelRef ~= nil do
			task.wait(tickInterval * 0.5)

			local now = os.clock()
			tickAccumulator += now - lastClock
			lastClock = now

			while tickAccumulator >= tickInterval do
				tickAccumulator -= tickInterval
				currentTick += 1
				tickSignal:Fire(currentTick, tickInterval)
			end
		end
	end)
end

NetworkService.InitRenderer = function(renderer, renderer_signal, datamodel)
	task.spawn(function()
		repeat
			task.wait()
		until datamodel.Players and datamodel:GetService("RunService")

		datamodelRef = datamodel
		bindTickLoop(datamodel:GetService("RunService"))
		networkSimulation = readNetworkSimulationConfig()
		if networkSimulation.enabled then
			print(
				`[NetworkService] Network simulation enabled: lag={networkSimulation.lagMs}ms jitter={networkSimulation.jitterMs}ms loss={networkSimulation.lossPercent}% dropReliable={networkSimulation.dropReliable}`
			)
		end
		local requestedNetworkStack = GetFlagValue("network_stack") or GetFlagValue("networkStack")
		if requestedNetworkStack then
			NetworkService:SetPrimaryNetworkStack(requestedNetworkStack)
		end
		if FlagExists("disable_multiplayer") or FlagExists("disable_networking") or FlagExists("no_multiplayer") then
			NetworkService:SetPrimaryNetworkStack("None")
		end

		local function sendToClient(recipient, channel, kind, payload, reliable)
			sendEnvelope(function(client, envelope, shouldBeReliable)
				local server = GNS and GNS.Server
				if not server or type(server.Send) ~= "function" then
					return false
				end
				if server.IsClientConnected and not server:IsClientConnected(client) then
					return false
				end
				return server:Send(client, envelope, shouldBeReliable)
			end, recipient, channel, kind, payload, reliable)
		end

		local function broadcast(channel, kind, payload, reliable)
			sendEnvelope(function(envelope, shouldBeReliable)
				local server = GNS and GNS.Server
				if not server or type(server.SendAll) ~= "function" then
					return false
				end
				return server:SendAll(envelope, shouldBeReliable)
			end, nil, channel, kind, payload, reliable)
		end

		local function broadcastFiltered(channel, kind, payload, reliable, filterFn)
			local server = GNS and GNS.Server
			if not server or type(server.SendFiltered) ~= "function" then
				return false
			end

			local envelope = Protocol.MakeEnvelope(channel, kind, payload, currentTick)
			envelope.reliable = reliable == true
			local sent = server:SendFiltered(envelope, reliable == true, filterFn)
			if sent ~= false then
				recordTraffic("sent", envelope, reliable == true)
			end
			return sent
		end

		local function sendToMultipleClients(sessions, channel, kind, payload, reliable)
			for _, session in ipairs(sessions) do
				sendToClient(session, channel, kind, payload, reliable)
			end
		end

		local function sendToServer(channel, kind, payload, reliable)
			local client = GNS and GNS.Client
			if not client or type(client.Send) ~= "function" then
				return false
			end
			if not NetworkService.IsClientConnected and not client.Socket and client.IsConnected ~= true then
				return
			end
			sendEnvelope(function(envelope, shouldBeReliable)
				return client:Send(envelope, shouldBeReliable)
			end, nil, channel, kind, payload, reliable)
		end

		function NetworkService:StartServer(address, port, allowedTokens)
			local server = GNS and GNS.Server
			if activeNetworkStack and activeNetworkStack.MultiplayerEnabled == false then
				return false
			end
			if not server or type(server.Init) ~= "function" or type(server.Listen) ~= "function" then
				warn("[NetworkService] Active network stack does not provide Server:Init and Server:Listen")
				return false
			end
			server:Init(address, port, allowedTokens)
			previewStartedAt = os.time()
			server:Listen()
			return true
		end

		function NetworkService:StartClient(address, port, authToken)
			local client = GNS and GNS.Client
			if activeNetworkStack and activeNetworkStack.MultiplayerEnabled == false then
				return false
			end
			if not client or type(client.Init) ~= "function" or type(client.Listen) ~= "function" then
				warn("[NetworkService] Active network stack does not provide Client:Init and Client:Listen")
				return false
			end
			client:Init(address, port, authToken)

			if type(client.OnRecieve) == "function" then
				client:OnRecieve(function(addr, msg)
					if msg.type == "AUTH_SUCCESS" then
						NetworkService.IsClientConnected = true
						return
					end

					if msg.type == "AUTH_FAILED" or msg.type == "DISCONNECT" or msg.type == "SHUTDOWN" then
						NetworkService.IsClientConnected = false
						disconnectedSignal:Fire(msg.reason or msg.type)
						return
					end

					dispatchPacket(nil, msg)
				end)
			end

			if type(client.OnShutdown) == "function" then
				client:OnShutdown(function()
					if NetworkService.IsClientConnected then
						NetworkService.IsClientConnected = false
						disconnectedSignal:Fire("Connection Lost")
					end
				end)
			end

			client:Listen()
			return true
		end

		local function isCharacterModelForPlayer(model, payload)
			if not model or model.ClassName ~= "Model" or not payload then
				return false
			end
			if model.FindFirstChildOfClass and not model:FindFirstChildOfClass("Humanoid") then
				return false
			end

			local uid = model.GetAttribute and model:GetAttribute("__characterUserId")
			if type(uid) == "number" and uid == payload.id then
				return true
			end

			return model.Name == payload.name
		end

		local function findClientCharacterModel(payload)
			local workspace = datamodel:GetService("Workspace")
			if not workspace or type(payload) ~= "table" then
				return nil
			end

			for _, child in ipairs(workspace:GetChildren()) do
				if isCharacterModelForPlayer(child, payload) then
					return child
				end
			end

			return nil
		end

		local function bindClientPlayerCharacter(player, payload)
			if not player then
				return
			end

			local character = findClientCharacterModel(payload)
			if not character or player.Character == character then
				return
			end

			local previous = player.Character
			if previous and previous ~= character and player.CharacterRemoving then
				player.CharacterRemoving:Fire(previous)
			end

			player.Character = character
			if player.CharacterAdded then
				player.CharacterAdded:Fire(character)
			end
		end

		local function destroyClientCharacterModels(payload)
			local workspace = datamodel:GetService("Workspace")
			if not workspace or type(payload) ~= "table" then
				return
			end

			for _, child in ipairs(workspace:GetChildren()) do
				if isCharacterModelForPlayer(child, payload) then
					child:Destroy()
				end
			end
		end

		local function ensureClientPlayerInstance(payload)
			if type(payload) ~= "table" then
				return nil
			end

			local players = datamodel:GetService("Players")
			if not players or not payload.name or not payload.id then
				return nil
			end

			local player = players:GetPlayerByUserId(payload.id) or players:GetPlayerByName(payload.name)
			if player then
				player.Name = payload.name
				player.UserId = payload.id
				if player.Parent ~= players then
					player.Parent = players
				end
				bindClientPlayerCharacter(player, payload)
				return player
			end

			if players.AddPlayer then
				player = players:AddPlayer(payload.name, payload.id, datamodel)
				bindClientPlayerCharacter(player, payload)
				return player
			end

			return nil
		end

		registerMessageHandler(Protocol.Channels.Control, Protocol.Kinds.PlayerProfile, function(_, payload)
			localPlayerUserId = payload.id

			task.spawn(function()
				local player = datamodel.Players.LocalPlayer
				if player and player.UserId == 1 and player.Name == payload.name then
					player.UserId = payload.id
					datamodel.Players.LocalPlayer = player
					withMouseInjection(player, renderer, datamodel)
					NetworkService.IsClientConnected = true
					return
				end

				local player
				repeat
					task.wait()
					player = datamodel.Players:GetPlayerByUserId(payload.id)
					if not player then
						for _, child in ipairs(datamodel.Players:GetChildren()) do
							if child.ClassName == "Player" and child.Name == payload.name then
								player = child
								break
							end
						end
					end
				until player

				datamodel.Players.LocalPlayer = player
				withMouseInjection(player, renderer, datamodel)
				NetworkService.IsClientConnected = true
			end)

			for _, existingPlayer in ipairs(payload.existingPlayers or {}) do
				ensureClientPlayerInstance(existingPlayer)
			end
		end)

		registerMessageHandler(Protocol.Channels.Control, Protocol.Kinds.PlayerJoined, function(_, payload)
			ensureClientPlayerInstance(payload)
		end)

		registerMessageHandler(Protocol.Channels.Control, Protocol.Kinds.PlayerLeft, function(_, payload)
			if type(payload) ~= "table" then
				return
			end

			local players = datamodel:GetService("Players")
			local player = players:GetPlayerByUserId(payload.id)
			if player then
				if player.Character then
					player.Character:Destroy()
					player.Character = nil
				end
				players:RemovePlayer(player)
				player:Destroy()
			end
			destroyClientCharacterModels(payload)
		end)

		registerMessageHandler(Protocol.Channels.Control, Protocol.Kinds.ClientReady, function(session, payload)
			print(`[NetworkService] ClientReady handler fired`)
			if not session or not session.player then
				warn("[NetworkService] ClientReady received but session or player is missing")
				warn(
					`[NetworkService]   session={tostring(session)}, session.player={session and tostring(
						session.player
					) or "nil"}`
				)
				return
			end
			print(`[NetworkService] Client {session.key} is ready  loading character for {session.player.Name}`)
			task.spawn(function()
				local players = datamodel:GetService("Players")
				print(
					`[NetworkService] Players service: {tostring(players)}, LoadCharacter type: {type(
						players and players.LoadCharacter
					)}`
				)
				if players and type(players.LoadCharacter) == "function" then
					print(`[NetworkService] Calling Players:LoadCharacter for {session.player.Name}...`)
					local ok, err = pcall(function()
						players:LoadCharacter(session.player, datamodel)
					end)
					if ok then
						print(`[NetworkService] LoadCharacter completed for {session.player.Name}`)
						print(`[NetworkService]   Character = {tostring(session.player.Character)}`)
					else
						warn(`[NetworkService] LoadCharacter FAILED for {session.player.Name}: {tostring(err)}`)
					end
				else
					warn(`[NetworkService] LoadCharacter not available on Players service`)
				end
			end)
		end)

		rebindActiveNetworkStack = function()
			local server = GNS and GNS.Server
			if not server then
				return
			end

			if type(server.OnClientConnectionRequest) == "function" then
				server:OnClientConnectionRequest(function(client, clientData)
					local name = clientData and clientData.name
					local userId = clientData and clientData.id
					local clientAddr = `{client.address}:{client.port}`
					local key = clientKey(client)

					if not clientData then
						warn(
							`[NetworkService] Connection from {clientAddr} rejected: no clientData payload (client may not have called Connect() with auth data)`
						)
						return
					end
					if not name then
						warn(`[NetworkService] Connection from {clientAddr} rejected: missing 'name' in clientData`)
						return
					end
					if not userId then
						warn(`[NetworkService] Connection from {clientAddr} rejected: missing 'id' in clientData`)
						return
					end
					if sessionsByUserId[userId] then
						warn(
							`[NetworkService] Connection from {clientAddr} rejected: userId {userId} ({name}) is already connected`
						)
						return
					end

					print(
						`[NetworkService] Connection accepted from {clientAddr} ({key}): name={name}, userId={userId}`
					)

					local session = {
						key = key,
						client = client,
						address = client.address,
						port = client.port,
						name = name,
						userId = userId,
						connectedAt = os.time(),
						lastInputSequence = 0,
						lastAppliedInputSequence = 0,
						lastAcknowledgedInputSequence = -1,
					}

					sessionsByKey[session.key] = session
					sessionsByUserId[userId] = session

					attachPlayerSession(datamodel, session)

					local existingPlayers = {}
					for _, otherSession in pairs(sessionsByKey) do
						if otherSession.userId ~= session.userId then
							table.insert(existingPlayers, {
								name = otherSession.name,
								id = otherSession.userId,
							})
						end
					end

					sendToClient(session, Protocol.Channels.Control, Protocol.Kinds.PlayerProfile, {
						name = session.name,
						id = session.userId,
						existingPlayers = existingPlayers,
					}, true)

					for _, otherSession in pairs(sessionsByKey) do
						if otherSession.userId ~= session.userId then
							sendToClient(otherSession, Protocol.Channels.Control, Protocol.Kinds.PlayerJoined, {
								name = session.name,
								id = session.userId,
							}, true)
						end
					end

					clientConnectedSignal:Fire(session, session.player)
				end)
			end

			if type(server.OnRecieve) == "function" then
				server:OnRecieve(function(addr, msg)
					local key = clientKey(addr)
					local session = sessionsByKey[key]

					if session and not RateLimiter.Allow(key) then
						return
					end

					dispatchPacket(session, msg)
				end)
			end

			if type(server.OnClientRemoved) == "function" then
				server:OnClientRemoved(function(addr)
					local key = clientKey(addr)
					local session = sessionsByKey[key]
					if not session then
						return
					end

					sessionsByKey[key] = nil
					sessionsByUserId[session.userId] = nil
					cleanupPlayerSession(datamodel, session)

					broadcast(Protocol.Channels.Control, Protocol.Kinds.PlayerLeft, {
						name = session.name,
						id = session.userId,
					}, true)

					clientRemovedSignal:Fire(session)
				end)
			end

			if type(server.OnPreAuthMessage) == "function" then
				server:OnPreAuthMessage(function(addr, msg)
					return ServerPreview.HandleRequest(server.Socket, addr, msg, {
						datamodel = datamodel,
						sessions = sessionsByKey,
						previewData = previewMetadata,
						address = server.Address,
						port = server.Port,
						tickRate = tickRate,
						currentTick = currentTick,
						startedAt = previewStartedAt,
						requiresAuth = false,
					})
				end)
			end
		end

		rebindActiveNetworkStack()

		local authToken = GetFlagValue("auth_token")
		local allowedTokens = authToken and { authToken } or {}
		local data

		if IsClient then
			local userName = GetFlagValue("username") or "Player"
			local userId = tonumber(GetFlagValue("userid") or GetFlagValue("userId")) or math.random(1000, 999999)
			data = { name = userName, id = userId }
		end

		local multiplayerEnabled = not (activeNetworkStack and activeNetworkStack.MultiplayerEnabled == false)
		local autoStartEnabled = multiplayerEnabled
			and not (activeNetworkStack and activeNetworkStack.AutoStart == false)
		local function connectClient(data)
			local client = GNS and GNS.Client
			if not client then
				return
			end
			if type(client.Connect) == "function" then
				client:Connect(data)
			end
			if type(client.StartHeartbeat) == "function" then
				client:StartHeartbeat()
			end
		end

		if autoStartEnabled and IsServer then
			local port = tonumber(GetFlagValue("port"))
			local address = GetFlagValue("address")
			if port and address then
				connectedTo = { address, port }
				NetworkService:StartServer(address, port, allowedTokens)
			else
				connectedTo = { "0.0.0.0", 1234 }
				NetworkService:StartServer("0.0.0.0", 1234, allowedTokens)
			end
		elseif autoStartEnabled and IsClient then
			local port = tonumber(GetFlagValue("port"))
			local address = GetFlagValue("address")
			if port and address then
				connectedTo = { address, port }
				NetworkService:StartClient(address, port, authToken)
				connectClient(data)
			else
				connectedTo = { "127.0.0.1", 1234 }
				NetworkService:StartClient("127.0.0.1", 1234, authToken)
				connectClient(data)
			end
		elseif autoStartEnabled and FlagExists("live") then
			NetworkService:StartServer("0.0.0.0", 1234, allowedTokens)
			connectedTo = { "127.0.0.1", 1234 }
			NetworkService:StartClient("127.0.0.1", 1234, authToken)
			connectClient(data)
		end

		table.insert(datamodel.ShutdownCallbacks, function()
			callOptional(GNS and GNS.Client, "Disconnect")
			callOptional(GNS and GNS.Server, "Shutdown")
			RpcService.Clear()
		end)

		local HEARTBEAT_INTERVAL = 10
		task.spawn(function()
			while datamodelRef ~= nil do
				task.wait(HEARTBEAT_INTERVAL)
				if IsServer then
					for key, session in pairs(sessionsByKey) do
						local server = GNS and GNS.Server
						if session.client and server and type(server.GetClientStats) == "function" then
							local stats = server:GetClientStats(session.client)
							if stats and stats.pendingReliable and stats.pendingReliable > 256 then
								warn(
									`[NetworkService] Heartbeat: peer {key} has {stats.pendingReliable} pending reliable messages`
								)
							end
						end
					end
				end
			end
		end)

		-- RPC dispatch handler: route incoming RPC packets to registered handlers
		registerMessageHandler(Protocol.Channels.Message, Protocol.Kinds.Rpc, function(sender, payload)
			if not RpcService.IsRpcEnvelope(payload) then
				return
			end

			local localPeerId = if IsServer then 1 else 0
			local senderPeerId = if sender and sender.client then 0 else 1
			local authorityPeerId = payload.authorityPeerId or 0

			RpcService.Invoke(payload.method, {
				localPeerId = localPeerId,
				senderPeerId = senderPeerId,
				authorityPeerId = authorityPeerId,
				target = nil,
			}, payload.args)
		end)

		-- Peer rate limiter cleanup on client disconnect
		clientRemovedSignal:Connect(function(session)
			if session and session.key then
				RateLimiter.Reset(session.key)
			end
		end)

		NetworkService:SetProperties({
			Success = true,
			IsClientConnected = false,
			GNS = GNS,
			NetworkStack = activeNetworkStack,
			ActiveNetworkStackName = activeNetworkStackName,
			Protocol = Protocol,
			Replicate = activeNetworkStack and activeNetworkStack.Replicate ~= false,
			Tick = tickSignal,
			ClientConnected = clientConnectedSignal,
			ClientRemoved = clientRemovedSignal,
			Disconnected = disconnectedSignal,
			PacketReceived = packetSignal,
			TickRate = tickRate,
			TickInterval = tickInterval,
			LocalPeerID = if IsServer then 1 else 0,
			ActivePeerIDs = {},
			RpcService = RpcService,
			NetworkAttributes = NetworkAttributes,
			RateLimiter = RateLimiter,
			RegisterNetworkStack = NetworkService.RegisterNetworkStack,
			RegisterNetwork = NetworkService.RegisterNetworkStack,
			RegisterStack = NetworkService.RegisterNetworkStack,
			SetPrimaryNetworkStack = NetworkService.SetPrimaryNetworkStack,
			SetPrimaryNetwork = NetworkService.SetPrimaryNetworkStack,
			SetNetworkStack = NetworkService.SetNetworkStack,
			GetPrimaryNetworkStackName = NetworkService.GetPrimaryNetworkStackName,
			GetPrimaryNetworkName = NetworkService.GetPrimaryNetworkStackName,
			GetPrimaryNetworkStack = NetworkService.GetPrimaryNetworkStack,
			GetRegisteredNetworkStacks = NetworkService.GetRegisteredNetworkStacks,
			DisableMultiplayer = NetworkService.DisableMultiplayer,
			RegisterMessageHandler = function(self, channel, kind, callback)
				return registerMessageHandler(channel, kind, callback)
			end,
			UnregisterMessageHandler = function(self, channel, kind, callback)
				local handlers = packetHandlers[channel] and packetHandlers[channel][kind]
				if not handlers then
					return false
				end

				local removed = false
				for index = #handlers, 1, -1 do
					if handlers[index] == callback then
						table.remove(handlers, index)
						removed = true
					end
				end

				if #handlers == 0 then
					packetHandlers[channel][kind] = nil
					if next(packetHandlers[channel]) == nil then
						packetHandlers[channel] = nil
					end
				end

				return removed
			end,
			SendToServer = function(self, channel, kind, payload, reliable)
				sendToServer(channel, kind, payload, reliable)
			end,
			SendToClient = function(self, recipient, channel, kind, payload, reliable)
				sendToClient(recipient, channel, kind, payload, reliable)
			end,
			Broadcast = function(self, channel, kind, payload, reliable)
				broadcast(channel, kind, payload, reliable)
			end,
			BroadcastFiltered = function(self, channel, kind, payload, reliable, filterFn)
				broadcastFiltered(channel, kind, payload, reliable, filterFn)
			end,
			SendToMultipleClients = function(self, sessions, channel, kind, payload, reliable)
				sendToMultipleClients(sessions, channel, kind, payload, reliable)
			end,
			GetCurrentTick = function()
				return currentTick
			end,
			GetServerDataAsync = function()
				return table.unpack(connectedTo)
			end,
			GetLocalPlayerUserId = function()
				return localPlayerUserId
			end,
			GetSessionByUserId = function(self, userId)
				local session = sessionsByUserId[userId]
				if IsClient then
					return clonePublicSession(session)
				end
				return session
			end,
			GetSessions = function()
				local list = {}
				for _, session in pairs(sessionsByKey) do
					if IsClient then
						table.insert(list, clonePublicSession(session))
					else
						table.insert(list, session)
					end
				end
				return list
			end,
			GetStatsSnapshot = function()
				return {
					tick = currentTick,
					sent = cloneTrafficSnapshot(trafficStats.sent),
					received = cloneTrafficSnapshot(trafficStats.received),
				}
			end,
			Ping = function(self, address, port, options)
				return ServerPreview.Ping(address, port, options)
			end,
			SetPreviewData = function(self, data)
				return updatePreviewMetadata(data)
			end,
			GetPreviewData = function()
				return cloneTable(previewMetadata)
			end,
			ResetStats = function()
				resetTrafficStats()
			end,
			RegisterRpc = function(self, target, methodName, attribute, handler)
				return RpcService.Register(target, methodName, attribute, handler)
			end,
			UnregisterRpc = function(self, rpcId)
				return RpcService.Unregister(rpcId)
			end,
			InvokeRpc = function(self, methodName, args, reliable)
				local envelope = RpcService.MakeRpcEnvelope(methodName, args, nil, reliable ~= false)
				if IsServer then
					broadcast(Protocol.Channels.Message, Protocol.Kinds.Rpc, envelope, reliable ~= false)
				else
					sendToServer(Protocol.Channels.Message, Protocol.Kinds.Rpc, envelope, reliable ~= false)
				end
			end,
			InvokeRpcOnClient = function(self, recipient, methodName, args, reliable)
				local envelope = RpcService.MakeRpcEnvelope(methodName, args, nil, reliable ~= false)
				sendToClient(recipient, Protocol.Channels.Message, Protocol.Kinds.Rpc, envelope, reliable ~= false)
			end,
		})
		setNetworkStackProperties()
	end)
end

return NetworkService
