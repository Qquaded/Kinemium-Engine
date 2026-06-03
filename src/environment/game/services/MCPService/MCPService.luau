local Instance = require("@Instance")
local Enum = require("@EnumMap")
local KiNet = require("@KiNet")

local MCPService = Instance.new("MCPService")
MCPService.ExplorerHidden = true
MCPService._Intents = Enum.PluginIntents.Network

local JSON = zune.serde.json
local DEFAULT_ADDRESS = "127.0.0.1"
local DEFAULT_PORT = 7331

local server = nil
local datamodelRef = nil
local isRunning = false
local serverGeneration = 0
local requestHandlers = {}

local function makeError(id, code, message, data)
	return {
		jsonrpc = "2.0",
		id = id,
		error = {
			code = code,
			message = message,
			data = data,
		},
	}
end

local function makeResult(id, result)
	return {
		jsonrpc = "2.0",
		id = id,
		result = result or {},
	}
end

local function decodeRequest(message)
	if type(message) == "table" and type(message.json) == "string" then
		local ok, decoded = pcall(JSON.decode, message.json)
		if ok then
			return decoded
		end
		return nil, "Invalid JSON payload"
	end

	if type(message) == "table" and type(message.method) == "string" then
		return message
	end

	return nil, "Expected a JSON-RPC request in message.json"
end

local function sendResponse(client, response)
	if not server or not client then
		return false
	end

	local encoded = JSON.encode(response)
	server:Send(client, {
		type = "MCP_RESPONSE",
		json = encoded,
	}, false)

	return true
end

local function getServerInfo()
	return {
		name = "Kinemium MCP",
		version = "0.1.0",
	}
end

local function listTools()
	local tools = {}

	for name, handler in pairs(requestHandlers) do
		if handler.tool then
			table.insert(tools, {
				name = name,
				description = handler.description,
				inputSchema = handler.inputSchema or {
					type = "object",
					properties = {},
				},
			})
		end
	end

	table.sort(tools, function(a, b)
		return a.name < b.name
	end)

	return tools
end

local function callTool(name, arguments)
	local handler = requestHandlers[name]
	if not handler or not handler.tool then
		return nil, `Unknown tool: {tostring(name)}`
	end

	return handler.callback(arguments or {})
end

local function handleRequest(request)
	if type(request) ~= "table" then
		return makeError(nil, -32600, "Invalid Request")
	end

	local method = request.method
	if type(method) ~= "string" then
		return makeError(request.id, -32600, "Missing method")
	end

	if method == "initialize" then
		return makeResult(request.id, {
			protocolVersion = request.params and request.params.protocolVersion or "2024-11-05",
			serverInfo = getServerInfo(),
			capabilities = {
				tools = {},
			},
		})
	elseif method == "ping" then
		return makeResult(request.id, {})
	elseif method == "tools/list" then
		return makeResult(request.id, {
			tools = listTools(),
		})
	elseif method == "tools/call" then
		local params = request.params or {}
		local result, err = callTool(params.name, params.arguments)
		if err then
			return makeError(request.id, -32602, err)
		end
		return makeResult(request.id, result)
	elseif method == "notifications/initialized" then
		return nil
	end

	return makeError(request.id, -32601, `Method not found: {method}`)
end

local function registerDefaultTools()
	requestHandlers["kinemium.info"] = {
		tool = true,
		description = "Returns basic information about the active Kinemium data model.",
		inputSchema = {
			type = "object",
			properties = {},
		},
		callback = function()
			local services = {}
			if datamodelRef and datamodelRef.Services then
				for name in pairs(datamodelRef.Services) do
					table.insert(services, name)
				end
				table.sort(services)
			end

			return {
				content = {
					{
						type = "text",
						text = JSON.encode({
							name = datamodelRef and datamodelRef.Name or "datamodel",
							loaded = datamodelRef and datamodelRef.Loaded == true,
							services = services,
						}),
					},
				},
			}
		end,
	}

	requestHandlers["kinemium.echo"] = {
		tool = true,
		description = "Echoes the supplied arguments as JSON text.",
		inputSchema = {
			type = "object",
			properties = {
				message = {
					type = "string",
				},
			},
		},
		callback = function(arguments)
			return {
				content = {
					{
						type = "text",
						text = JSON.encode(arguments or {}),
					},
				},
			}
		end,
	}
end

function MCPService:StartServer(address, port, allowedTokens)
	if isRunning then
		return true, self.Address, self.Port
	end

	serverGeneration += 1
	local generation = serverGeneration
	address = address or GetFlagValue("mcp_address") or DEFAULT_ADDRESS
	port = tonumber(port or GetFlagValue("mcp_port")) or DEFAULT_PORT
	allowedTokens = allowedTokens or {}

	server = KiNet.TCPServer
	server:Init(address, port, allowedTokens)
	server:OnClientConnectionRequest(function(client)
		if generation ~= serverGeneration or not isRunning then
			return
		end

		sendResponse(client, {
			jsonrpc = "2.0",
			method = "notifications/kinemium/ready",
			params = {
				serverInfo = getServerInfo(),
			},
		})
	end)
	server:OnRecieve(function(addr, message)
		if generation ~= serverGeneration or not isRunning then
			return
		end
		if
			type(message) == "table"
			and message.type
			and message.type ~= "MCP_REQUEST"
			and not message.method
			and not message.json
		then
			return
		end

		local client = server.ConnectedClients[`{addr.address}:{addr.port}`] or server.ConnectedClients[addr.address]
		local request, decodeErr = decodeRequest(message)
		if not request then
			sendResponse(client, makeError(nil, -32700, decodeErr))
			return
		end

		local ok, response = pcall(handleRequest, request)
		if not ok then
			sendResponse(client, makeError(request.id, -32603, tostring(response)))
			return
		end
		if response then
			sendResponse(client, response)
		end
	end)
	server:Listen()

	self.Address = address
	self.Port = port
	isRunning = true

	print(`[MCPService] Listening at {address}:{port}`)
	return true, address, port
end

function MCPService:StopServer()
	if not isRunning or not server then
		return false
	end

	serverGeneration += 1
	server:Shutdown()
	isRunning = false
	server = nil
	return true
end

function MCPService:IsRunning()
	return isRunning
end

function MCPService:RegisterTool(name, description, inputSchema, callback)
	if type(name) ~= "string" or name == "" then
		return false, "Tool name must be a non-empty string"
	end
	if type(callback) ~= "function" then
		return false, "Tool callback must be a function"
	end

	requestHandlers[name] = {
		tool = true,
		description = description or "",
		inputSchema = inputSchema,
		callback = callback,
	}

	return true
end

MCPService.InitRenderer = function(renderer, rendererSignal, datamodel)
	datamodelRef = datamodel
	registerDefaultTools()

	MCPService:SetProperties({
		Address = DEFAULT_ADDRESS,
		Port = DEFAULT_PORT,
		StartServer = MCPService.StartServer,
		StopServer = MCPService.StopServer,
		IsRunning = MCPService.IsRunning,
		RegisterTool = MCPService.RegisterTool,
	})

	if FlagExists("mcp") or FlagExists("mcp_server") then
		MCPService:StartServer()
	end

	if datamodel and datamodel.ShutdownCallbacks then
		table.insert(datamodel.ShutdownCallbacks, function()
			MCPService:StopServer()
		end)
	end
end

return MCPService
