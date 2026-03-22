local Instance = require("@Instance")
local signal = require("@Kinemium.signal")

local LogService = Instance.new("LogService")
LogService.ExplorerHidden = true

local MessageOut = signal.new()
local BeforeLog = signal.new()

local logs = {}

LogService.InitRenderer = function(renderer, renderer_signal)
	LogService:SetProperties({
		ClearOutput = function()
			table.clear(logs)
		end,
		GetLogHistory = function()
			return logs
		end,
		BeforeLog = BeforeLog,
		MessageOut = MessageOut,

		Errortest = function()
			error("Should error from stack")
		end,

		-- Engine API surface
		CreateLog = function(type: "print" | "error" | "warn", message)
			local id = math.random(1, 999999)
			table.insert(logs, { type = type, message = message, id = id, time = os.clock() })
			return id
		end,

		GetLog = function(id)
			for _, log in pairs(logs) do
				if log.id == id then
					return log
				end
			end
		end,

		UpdateLog = function(id, message)
			local logData = logs.GetLog(id)
			if logData then
				logData.message = message
			end
		end,
	})

	renderer_signal:Connect(function(route, dt) end)
end

return LogService
