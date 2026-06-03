local Instance = require("@Instance")
local Enum = require("@EnumMap")

local ProfilerService = Instance.new("ProfilerService")
ProfilerService.ExplorerHidden = true
ProfilerService._Intents = Enum.PluginIntents.Debugging

ProfilerService.InitRenderer = function(renderer, renderer_signal)
	ProfilerService:SetProperties({
		ENGINE_PROFILER = ENGINE_PROFILER,
	})
end

return ProfilerService
