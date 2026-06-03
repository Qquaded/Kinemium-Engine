local Instance = require("@Instance")
local signal = require("@Kinemium.signal")

local ConfigService = Instance.new("ConfigService")
ConfigService.ExplorerHidden = true

ConfigService.InitRenderer = function(renderer, renderer_signal)
	if IsHeadless == true then
		return
	end

	local configChanged = signal.new()
	local currentConfig = {}

	ConfigService:SetProperties({
		SetConfig = function(config)
			currentConfig = config
			configChanged:Fire(config)
		end,

		prop = function(prop, val)
			currentConfig[prop] = val
		end,

		get = function(prop)
			return currentConfig[prop]
		end,

		GetConfig = function()
			return currentConfig
		end,

		ConfigChanged = configChanged,
	})
end

return ConfigService
