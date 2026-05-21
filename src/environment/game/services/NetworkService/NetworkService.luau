local Instance = require("@Instance")
local signal = require("@Kinemium.signal")
local KiNet = require("@KiNet")
local Protocol = require("./Protocol")
local ServerPreview = require("./ServerPreview")
local GuiMirror = require("../../runtime/GuiMirror")

local NetworkService = Instance.new("NetworkService")
NetworkService.ExplorerHidden = true

local task = zune.task

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

local function clientKey(client)
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
	local sent
	if recipient then
		sent = sendFn(normalizeRecipient(recipient), envelope, reliable == true)
	else
		sent = sendFn(envelope, reliable == true)
	end

	if sent == false then
		return false
	end

	recordTraffic("sent", envelope, reliable == true)
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
	guiMirrorController:BindContainer(datamodel.CoreGui, "CoreGui")
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

		local function sendToClient(recipient, channel, kind, payload, reliable)
			-- Force Create messages to be unreliable to prevent blocking reliable traffic (chat, input, remotes)
			local actualReliable = reliable
			if channel == Protocol.Channels.Replication and kind == Protocol.Kinds.Create then
				actualReliable = false
			end

			sendEnvelope(function(client, envelope, shouldBeReliable)
				if KiNet.Server.IsClientConnected and not KiNet.Server:IsClientConnected(client) then
					return false
				end
				return KiNet.Server:Send(client, envelope, shouldBeReliable)
			end, recipient, channel, kind, payload, actualReliable)
		end

		local function broadcast(channel, kind, payload, reliable)
			sendEnvelope(function(envelope, shouldBeReliable)
				return KiNet.Server:SendAll(envelope, shouldBeReliable)
			end, nil, channel, kind, payload, reliable)
		end

		local function broadcastFiltered(channel, kind, payload, reliable, filterFn)
			local envelope = Protocol.MakeEnvelope(channel, kind, payload, currentTick)
			envelope.reliable = reliable == true
			local sent = KiNet.Server:SendFiltered(envelope, reliable == true, filterFn)
			if sent ~= false then
				recordTraffic("sent", envelope, reliable == true)
			end
		end

		local function sendToMultipleClients(sessions, channel, kind, payload, reliable)
			for _, session in ipairs(sessions) do
				sendToClient(session, channel, kind, payload, reliable)
			end
		end

		local function sendToServer(channel, kind, payload, reliable)
			-- Force Create messages to be unreliable to prevent blocking reliable traffic
			local actualReliable = reliable
			if channel == Protocol.Channels.Replication and kind == Protocol.Kinds.Create then
				actualReliable = false
			end

			if not NetworkService.IsClientConnected or not KiNet.Client.Socket then
				return
			end
			sendEnvelope(function(envelope, shouldBeReliable)
				return KiNet.Client:Send(envelope, shouldBeReliable)
			end, nil, channel, kind, payload, actualReliable)
		end

		function NetworkService:StartServer(address, port, allowedTokens)
			KiNet.Server:Init(address, port, allowedTokens)
			previewStartedAt = os.time()
			KiNet.Server:Listen()
		end

		function NetworkService:StartClient(address, port, authToken)
			KiNet.Client:Init(address, port, authToken)

			KiNet.Client:OnRecieve(function(addr, msg)
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

			KiNet.Client:OnShutdown(function()
				if NetworkService.IsClientConnected then
					NetworkService.IsClientConnected = false
					disconnectedSignal:Fire("Connection Lost")
				end
			end)

			KiNet.Client:Listen()
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

		KiNet.Server:OnClientConnectionRequest(function(client, clientData)
			local name = clientData and clientData.name
			local userId = clientData and clientData.id
			local clientAddr = `{client.address}:{client.port}`

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

			print(`[NetworkService] Connection accepted from {clientAddr}: name={name}, userId={userId}`)

			local session = {
				key = clientKey(client),
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

		KiNet.Server:OnRecieve(function(addr, msg)
			local session = sessionsByKey[clientKey(addr)]
			dispatchPacket(session, msg)
		end)

		KiNet.Server:OnClientRemoved(function(addr)
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

		KiNet.Server:OnPreAuthMessage(function(addr, msg)
			return ServerPreview.HandleRequest(KiNet.Server.Socket, addr, msg, {
				datamodel = datamodel,
				sessions = sessionsByKey,
				previewData = previewMetadata,
				address = KiNet.Server and KiNet.Server.Address,
				port = KiNet.Server and KiNet.Server.Port,
				tickRate = tickRate,
				currentTick = currentTick,
				startedAt = previewStartedAt,
				requiresAuth = KiNet.Server and KiNet.Server.AllowedTokens and #KiNet.Server.AllowedTokens > 0,
			})
		end)

		local authToken = GetFlagValue("auth_token")
		local allowedTokens = authToken and { authToken } or {}
		local data

		if IsClient then
			local userName = GetFlagValue("username") or "Player"
			local userId = math.random(1000, 999999)
			data = { name = userName, id = userId }
		end

		if IsServer then
			local port = tonumber(GetFlagValue("port"))
			local address = GetFlagValue("address")
			if port and address then
				connectedTo = { address, port }
				NetworkService:StartServer(address, port, allowedTokens)
			else
				connectedTo = { "0.0.0.0", 1234 }
				NetworkService:StartServer("0.0.0.0", 1234, allowedTokens)
			end
		elseif IsClient then
			local port = tonumber(GetFlagValue("port"))
			local address = GetFlagValue("address")
			if port and address then
				connectedTo = { address, port }
				NetworkService:StartClient(address, port, authToken)
				KiNet.Client:Connect(data)
				KiNet.Client:StartHeartbeat()
			else
				connectedTo = { "127.0.0.1", 1234 }
				NetworkService:StartClient("127.0.0.1", 1234, authToken)
				KiNet.Client:Connect(data)
				KiNet.Client:StartHeartbeat()
			end
		elseif FlagExists("live") then
			NetworkService:StartServer("0.0.0.0", 1234, allowedTokens)
			connectedTo = { "127.0.0.1", 1234 }
			NetworkService:StartClient("127.0.0.1", 1234, authToken)
			KiNet.Client:Connect(data)
			KiNet.Client:StartHeartbeat()
		end

		table.insert(datamodel.ShutdownCallbacks, function()
			if KiNet.Client then
				KiNet.Client:Disconnect()
			end
			if KiNet.Server then
				KiNet.Server:Shutdown()
			end
		end)

		NetworkService:SetProperties({
			Success = true,
			IsClientConnected = false,
			KiNet = KiNet,
			Protocol = Protocol,
			Replicate = true,
			Tick = tickSignal,
			ClientConnected = clientConnectedSignal,
			ClientRemoved = clientRemovedSignal,
			Disconnected = disconnectedSignal,
			PacketReceived = packetSignal,
			TickRate = tickRate,
			TickInterval = tickInterval,
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
		})
	end)
end

return NetworkService
