local Instance = require("@Instance")

local Enum = require("@EnumMap")

local adapter = require("@RaylibAdapter")

local KinemiumRaylib = Instance.new("KinemiumRaylib")
KinemiumRaylib.ExplorerHidden = true
KinemiumRaylib._Intents = Enum.PluginIntents.UI

KinemiumRaylib.InitRenderer = function(renderer, renderer_signal)
	KinemiumRaylib:SetProperties({
		_SecurityCapabilities = Enum.SecurityCapabilities.Internals,

		GetLib = function()
			return adapter.lib
		end,

		GetConst = function()
			return adapter.const
		end,

		GetStructs = function()
			return adapter.structs
		end,

		GetRenderer = function()
			return renderer
		end,
	})
end

return KinemiumRaylib
