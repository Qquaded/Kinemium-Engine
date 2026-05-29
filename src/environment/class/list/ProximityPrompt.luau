-- description: "Represents a ProximityPrompt in the environment."
local Enum = require("@EnumMap")
local Vector2 = require("@Vector2")
local signal = require("@Kinemium.signal")

local propTable = {
	ActionText = "Interact",
	AutoLocalize = true,
	ClickablePrompt = true,
	Enabled = true,
	Exclusivity = Enum.ProximityPromptExclusivity.OnePerButton,
	GamepadKeyCode = Enum.KeyCode.ButtonX,
	HoldDuration = 0,
	KeyboardKeyCode = Enum.KeyCode.E,
	MaxActivationDistance = 10,
	MaxIndicatorDistance = 10,
	ObjectText = "",
	RequiresLineOfSight = true,
	RootLocalizationTable = nil,
	Style = Enum.ProximityPromptStyle.Default,
	UIOffset = Vector2.new(0, 0),
}

return {
	class = "ProximityPrompt",

	-- description: "Initializes the ProximityPrompt instance."
	-- args: "instance: table"
	-- returns: "table"
	callback = function(instance)
		instance:SetProperties(propTable)

		-- TODO: Implement functionality, inherit from BillBoard gui and use BillBoardGui functionality with custom GUI

		instance.Triggered = signal.new()
		instance.TriggerEnded = signal.new()
		instance.PromptButtonHoldBegan = signal.new()
		instance.PromptButtonHoldEnded = signal.new()
		instance.PromptHidden = signal.new()
		instance.PromptShown = signal.new()

		return instance
	end,

	-- description: "Inherits the properties of the ProximityPrompt class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
