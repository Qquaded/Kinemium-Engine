local Instance = require("@Instance")
local Enum = require("@Enum")
local Vector2 = require("@Vector2")

local TextService = Instance.new("TextService")
TextService.ExplorerHidden = true
TextService._Intents = Enum.PluginIntents.UI

TextService.InitRenderer = function(renderer, signal, datamodel) end

return TextService
