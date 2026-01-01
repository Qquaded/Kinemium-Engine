local Instance = require("@Instance")
local signal = require("@Kinemium.signal")

local SoundService = Instance.new("SoundService")
SoundService.ExplorerHidden = true

local fmod = require("@fmod")

SoundService.InitRenderer = function(renderer, renderer_signal)
	SoundService:SetProperties({})
end

return SoundService
