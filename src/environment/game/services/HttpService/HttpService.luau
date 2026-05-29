local Instance = require("@Instance")
local signal = require("@Kinemium.signal")
local net = zune.net
local Enum = require("@EnumMap")

local HttpService = Instance.new("HttpService")
HttpService.ExplorerHidden = true
HttpService._Intents = Enum.PluginIntents.Network

local msgpack = require("@msgpack")

HttpService.InitRenderer = function(renderer, renderer_signal, game)
	HttpService.RequestStarted = signal.new()
	HttpService.RequestFinished = signal.new()
	HttpService.RequestFailed = signal.new()

	local JSON = zune.serde.json

	local function request(method, url, body, headers, opts)
		opts = opts or {}
		headers = headers or {}

		HttpService.RequestStarted:Fire({ Method = method, URL = url })

		local success, response = pcall(function()
			return net.http.request(url, {
				method = method,
				headers = headers,
				body = body,
				timeout = opts.Timeout,
				allow_redirects = opts.AllowRedirects,
			}, opts.ReturnBuffer and true or false)
		end)

		if not success then
			HttpService.RequestFailed:Fire({ Method = method, URL = url, Error = response })
			print("HttpService Request Error: " .. tostring(response))
		end

		local res = {
			Body = response.body,
			StatusCode = response.status_code,
			StatusReason = response.status_reason,
			Headers = response.headers,
			Ok = response.ok,
		}

		HttpService.RequestFinished:Fire(res)
		return res
	end

	function HttpService:GetAsync(url, headers, opts)
		local res = request("GET", url, nil, headers, opts)
		return res.Body, res
	end

	function HttpService:PostAsync(url, body, headers, opts)
		local res = request("POST", url, body, headers, opts)
		return res.Body, res
	end

	function HttpService:JSONEncode(tbl)
		return JSON.encode(tbl)
	end

	function HttpService:JSONDecode(str)
		return JSON.decode(str)
	end

	function HttpService:MsgPackEncode(tbl)
		return msgpack.encode(tbl)
	end

	function HttpService:MsgPackDecode(data)
		return msgpack.decode(data)
	end

	function HttpService:GenerateGUID(curly)
		local function generateGUID(): string
			local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
			return template:gsub("[xy]", function(c)
				local r = math.random(0, 15)
				local v = c == "x" and r or (r % 4 + 8)
				return string.format("%x", v)
			end)
		end
		return generateGUID()
	end

	function HttpService:CreateSocket()
		-- TODO: add Socket implementation (using zune.net)
	end

	function HttpService:Websocket(opts, accepted)
		local host = opts.host
		local socketObject = {
			OnMessage = signal.new(),
			OnOpen = signal.new(),
			OnClose = signal.new(),
			OnError = signal.new(),
			OnAccept = signal.new(),
			Host = host,
		}

		local new = zune.net.http.websocket(host, {
			headers = opts.headers,
			timeout = opts.timeout,

			open = function(self)
				socketObject.OnOpen:Fire()
				return true
			end,
			close = function(self, code)
				socketObject.OnClose:Fire(code)
				return true
			end,
			message = function(self, message)
				socketObject.OnMessage:Fire(message)
				return true
			end,
		})

		function socketObject:Destroy(code)
			if new then
				new:close(code)
			end
		end

		function socketObject:isConnected()
			return new ~= nil and new:isConnected()
		end

		function socketObject:Send(message)
			if new then
				new:send(message)
			end
		end

		return socketObject
	end
end

return HttpService
