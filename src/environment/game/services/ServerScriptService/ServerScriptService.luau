local Instance = require("@Instance")
local ServerScriptService = Instance.new("ServerScriptService")

ServerScriptService:SetProperties({
	LoadStringEnabled = false,
})

ServerScriptService.InitRenderer = function(renderer, signal) end

return ServerScriptService
