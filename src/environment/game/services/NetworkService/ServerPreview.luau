local GNS
local gnsOk, gnsResult = pcall(require, "@gns")
if gnsOk then
	GNS = gnsResult
else
	GNS = require("@KiNet")
end
local Protocol = require("./Protocol")

local Serializer = GNS.Serializer
local net = zune.net
local task = zune.task

local ServerPreview = {}

ServerPreview.MAGIC = "kinemium_server_preview_v1"
ServerPreview.REQUEST_TYPE = "preview_request"
ServerPreview.RESPONSE_TYPE = "preview_response"
ServerPreview.VERSION = 1
ServerPreview.MAX_PACKET_SIZE = 262144
ServerPreview.DEFAULT_TIMEOUT = 3
ServerPreview.DEFAULT_PLAYER_SAMPLE_LIMIT = 16

local function cloneSerializable(value, depth, seen)
	depth = depth or 0
	seen = seen or {}

	local valueType = type(value)
	if valueType == "nil" or valueType == "boolean" or valueType == "number" or valueType == "string" then
		return value
	end

	if valueType == "buffer" then
		return value
	end

	if valueType == "userdata" then
		local ok = pcall(buffer.len, value)
		return if ok then value else nil
	end

	if valueType ~= "table" or depth >= 8 or seen[value] then
		return nil
	end

	seen[value] = true

	local copy = {}
	for key, nestedValue in pairs(value) do
		local clonedKey = cloneSerializable(key, depth + 1, seen)
		local clonedValue = cloneSerializable(nestedValue, depth + 1, seen)
		if clonedKey ~= nil and clonedValue ~= nil then
			copy[clonedKey] = clonedValue
		end
	end

	seen[value] = nil
	return copy
end

local function makeRequestId()
	return `preview_{os.time()}_{math.random(100000, 999999)}`
end

local function resolveServerEndpoint(address, port)
	local ok, addresses = pcall(net.getAddressList, address, port)
	if not ok or type(addresses) ~= "table" or #addresses == 0 then
		return address
	end

	for _, entry in ipairs(addresses) do
		if entry.family == net.ADDRF.INET then
			return entry.address
		end
	end

	return address
end

local function closeSocket(socket)
	if not socket then
		return
	end

	local ok, isOpen = pcall(function()
		return socket:isOpen()
	end)

	if ok and isOpen then
		pcall(function()
			socket:close()
		end)
	end
end

local function getPlayerSamples(sessions, limit)
	local list = {}
	local cap = math.max(0, math.floor(tonumber(limit) or ServerPreview.DEFAULT_PLAYER_SAMPLE_LIMIT))

	if cap == 0 then
		return list
	end

	for _, session in pairs(sessions or {}) do
		if #list >= cap then
			break
		end

		if type(session) == "table" then
			table.insert(list, {
				name = session.name or (session.player and session.player.Name) or "Player",
				id = session.userId or (session.player and session.player.UserId),
				connectedAt = session.connectedAt,
			})
		end
	end

	return list
end

local function countSessions(sessions)
	local total = 0
	for _ in pairs(sessions or {}) do
		total += 1
	end
	return total
end

local function coerceText(value, fallback)
	if type(value) == "string" and value ~= "" then
		return value
	end

	return fallback
end

function ServerPreview.IsRequest(packet)
	return type(packet) == "table"
		and packet.__preview == ServerPreview.MAGIC
		and packet.type == ServerPreview.REQUEST_TYPE
end

function ServerPreview.IsResponse(packet)
	return type(packet) == "table"
		and packet.__preview == ServerPreview.MAGIC
		and packet.type == ServerPreview.RESPONSE_TYPE
end

function ServerPreview.MakeRequest(options)
	options = options or {}

	return {
		__preview = ServerPreview.MAGIC,
		type = ServerPreview.REQUEST_TYPE,
		version = ServerPreview.VERSION,
		requestId = makeRequestId(),
		timestamp = os.time(),
		includePlayers = options.includePlayers ~= false,
		playerSampleLimit = options.playerSampleLimit or ServerPreview.DEFAULT_PLAYER_SAMPLE_LIMIT,
	}
end

function ServerPreview.BuildResponse(request, context)
	context = context or {}

	local previewData = context.previewData or {}
	local sessions = context.sessions or {}
	local playerCount = countSessions(sessions)
	local playerSampleLimit = request.playerSampleLimit or previewData.playerSampleLimit
	local maxPlayers = tonumber(previewData.maxPlayers)
	if maxPlayers == nil then
		maxPlayers = math.max(playerCount, ServerPreview.DEFAULT_PLAYER_SAMPLE_LIMIT)
	end

	local players = {
		online = playerCount,
		max = maxPlayers,
		sample = if request.includePlayers ~= false then getPlayerSamples(sessions, playerSampleLimit) else {},
	}

	local datamodel = context.datamodel
	local now = os.time()
	local defaultName = if datamodel
			and type(datamodel.Name) == "string"
			and datamodel.Name ~= ""
		then datamodel.Name
		else "Kinemium Server"

	return {
		__preview = ServerPreview.MAGIC,
		type = ServerPreview.RESPONSE_TYPE,
		version = ServerPreview.VERSION,
		requestId = request.requestId,
		timestamp = now,
		name = coerceText(previewData.name, defaultName),
		motd = coerceText(previewData.motd, "A Kinemium server is online."),
		icon = cloneSerializable(previewData.icon),
		banner = cloneSerializable(previewData.banner),
		description = coerceText(previewData.description, nil),
		map = coerceText(previewData.map, defaultName),
		mode = coerceText(previewData.mode, nil),
		tags = cloneSerializable(previewData.tags) or {},
		address = context.address,
		port = context.port,
		players = players,
		features = {
			preview = true,
			requiresAuth = context.requiresAuth == true,
			includePlayers = request.includePlayers ~= false,
		},
		server = {
			tickRate = context.tickRate,
			tick = context.currentTick,
			startedAt = context.startedAt,
			uptime = if context.startedAt then math.max(0, now - context.startedAt) else nil,
		},
		software = {
			name = "Kinemium",
			transport = "GNS/UDP",
			protocol = Protocol.MAGIC,
			preview = ServerPreview.MAGIC,
		},
		extra = cloneSerializable(previewData.extra) or {},
	}
end

function ServerPreview.HandleRequest(socket, addr, packet, context)
	if not socket or not ServerPreview.IsRequest(packet) then
		return false
	end

	local ok, encoded = pcall(Serializer.Serialize, ServerPreview.BuildResponse(packet, context))
	if not ok then
		warn(`[NetworkService][Preview] Failed to encode preview response: {encoded}`)
		return true
	end

	local sendOk, sendErr = pcall(function()
		socket:sendMsg(tonumber(addr.port), addr.address, encoded)
	end)

	if not sendOk then
		warn(`[NetworkService][Preview] Failed to send preview response: {sendErr}`)
	end

	return true
end

function ServerPreview.Ping(address, port, options)
	options = options or {}
	port = tonumber(port)
	if type(address) ~= "string" or address == "" then
		return nil, "Invalid address"
	end

	if not port or port < 1 or port > 65535 then
		return nil, "Invalid port"
	end

	local resolvedAddress = resolveServerEndpoint(address, port)
	local socketOk, socketOrErr = pcall(function()
		return net.createSocket(
			net.ADDRF.INET,
			bit32.bor(net.SOCKF.DGRAM, net.SOCKF.NONBLOCK, net.SOCKF.CLOEXEC),
			net.IPPROTO.UDP
		)
	end)
	if not socketOk then
		return nil, tostring(socketOrErr)
	end

	local socket = socketOrErr
	local bindOk, bindErr = pcall(function()
		socket:bindIp("0.0.0.0", 0)
	end)
	if not bindOk then
		closeSocket(socket)
		return nil, tostring(bindErr)
	end

	local request = ServerPreview.MakeRequest(options)
	local startedAt = os.clock()
	local sendOk, sendErr = pcall(function()
		socket:sendMsg(port, resolvedAddress, Serializer.Serialize(request))
	end)
	if not sendOk then
		closeSocket(socket)
		return nil, tostring(sendErr)
	end

	local response
	local responseError
	local done = false

	task.spawn(function()
		while true do
			local ok, addrOrErr, data = pcall(function()
				return socket:recvMsg(ServerPreview.MAX_PACKET_SIZE)
			end)

			if not ok then
				if not done then
					responseError = tostring(addrOrErr)
					done = true
				end
				return
			end

			local decodeOk, decoded = pcall(Serializer.Deserialize, data)
			if decodeOk and ServerPreview.IsResponse(decoded) and decoded.requestId == request.requestId then
				response = decoded
				done = true
				return
			end
		end
	end)

	local timeout = math.max(0.1, tonumber(options.timeout) or ServerPreview.DEFAULT_TIMEOUT)
	while not done and os.clock() - startedAt < timeout do
		task.wait(0.05)
	end

	closeSocket(socket)

	if not done then
		return nil, `Preview ping timed out after {timeout} seconds`
	end

	if not response then
		return nil, responseError or "Preview ping failed"
	end

	response.latency = math.floor((os.clock() - startedAt) * 1000 + 0.5)
	response.resolvedAddress = resolvedAddress
	return response
end

return ServerPreview
