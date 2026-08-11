local Instance = require("@Instance")
local Color3 = require("@Color3")
local Enum = require("@EnumMap")
local signal = require("@Kinemium.signal")

local StudioService = Instance.new("StudioService")
StudioService.ExplorerHidden = true
StudioService._Intents = Enum.PluginIntents.UI

StudioService.InitRenderer = function(renderer, renderer_signal, datamodel)
	StudioService.ActiveScript = ""
end

return StudioService
