-- description: "Contains everything. (I don't know what you would use it for.)"

local Enum = require("@EnumMap")
local signal = require("@Kinemium.signal")
local Pipeline = require("@Pipeline")

local propTable = {
	Name = "DataModel",
	Dimension = Enum.Dimension["3D"],
	Context = Enum.GameContext.Editor,
	EngineSignal = signal.new(),
	EnginePipeline = Pipeline.Get("Engine"),
	Stop3DInput = false,
	ShutdownCallbacks = {},
	Loaded = false,
	MultiplayerMode = Enum.MultiplayerMode.Multiplayer,
}

return {
	class = "DataModel",
	non_creatable = true,

	callback = function(instance)
		instance:SetProperties(propTable)
		return instance
	end,

	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
