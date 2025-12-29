local Instance = require("@Instance")
local signal = require("@Kinemium.signal")

local gates = require("./LogicGateService/gates")

local LogicGateService = Instance.new("LogicGateService")
LogicGateService.ExplorerHidden = true

LogicGateService.InitRenderer = function(renderer, renderer_signal)
	LogicGateService:SetProperties(gates)
end

return LogicGateService
