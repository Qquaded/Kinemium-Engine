local Instance = require("@Instance")
local signal = require("@Kinemium.signal")
local Enum = require("@EnumMap")

local UserInputService = Instance.new("UserInputService")
local Vector2 = require("@Vector2")
UserInputService._Intents = Enum.PluginIntents.Input

local MAX_GAMEPADS = 4
local GAMEPAD_AXIS_DEADZONE = 0.1
local GAMEPAD_BUTTONS = {
	-- D-pad
	{ Name = "DPadUp", Value = 1 },
	{ Name = "DPadRight", Value = 2 },
	{ Name = "DPadDown", Value = 3 },
	{ Name = "DPadLeft", Value = 4 },
	-- Face buttons (Xbox layout)
	{ Name = "ButtonY", Value = 5 },
	{ Name = "ButtonB", Value = 6 },
	{ Name = "ButtonA", Value = 7 },
	{ Name = "ButtonX", Value = 8 },
	-- Bumpers/Triggers
	{ Name = "ButtonLB", Value = 9 },
	{ Name = "ButtonLT", Value = 10 },
	{ Name = "ButtonRB", Value = 11 },
	{ Name = "ButtonRT", Value = 12 },
	-- Menu buttons
	{ Name = "ButtonSelect", Value = 13 },
	{ Name = "ButtonStart", Value = 15 },
	-- Thumbsticks
	{ Name = "ButtonL3", Value = 16 },
	{ Name = "ButtonR3", Value = 17 },
}

local InputBegan = signal.new()
local InputEnded = signal.new()
local MouseMoved = signal.new()
local MouseWheel = signal.new()

local active_keys = {} -- [keyValue: number] = true | nil

UserInputService.InitRenderer = function(renderer, renderer_signal)
	if IsHeadless then
		UserInputService:SetProperties({})
		return
	end
end

return UserInputService
