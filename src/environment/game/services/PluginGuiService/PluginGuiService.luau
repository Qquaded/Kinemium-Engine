local Instance = require("@Instance")
local Enum = require("@EnumMap")

local PluginGuiService = Instance.new("PluginGuiService")
PluginGuiService.ExplorerHidden = false
PluginGuiService._Intents = Enum.PluginIntents.Graphics

PluginGuiService.InitRenderer = function(renderer, renderer_signal)
	-- Plugin gui container
	PluginGuiService:SetProperties({})
end
return PluginGuiService
