local Instance = require("@Instance")
local Enum = require("@EnumMap")

local GeometryService = Instance.new("GeometryService")
GeometryService.ExplorerHidden = true
GeometryService._Intents = Enum.PluginIntents.Graphics

GeometryService.InitRenderer = function(renderer, renderer_signal, datamodel)
	GeometryService:SetProperties({})
end

return GeometryService
