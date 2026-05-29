-- description: "Represents a Trail in the environment."
local ColorSequence = require("@ColorSequence")
local Color3 = require("@Color3")
local NumberSequence = require("@NumberSequence")
local Enum = require("@EnumMap")

local propTable = {
	Attachment0 = nil,
	Attachment1 = nil,
	Color = ColorSequence.new(Color3.new(1, 1, 1)),
	Transparency = NumberSequence.new(0.5),
	Lifetime = 2,
	MinLength = 0.1,
	MaxLength = 0,
	Texture = "",
	TextureLength = 1,
	TextureMode = Enum.TextureMode.Stretch,
	LightEmission = 0,
	LightInfluence = 1,
	FaceCamera = false,
	Enabled = true,
}

return {
	class = "Trail",

	-- description: "Initializes the Trail instance."
	-- args: "instance: table"
	-- returns: "table"
	callback = function(instance)
		instance:SetProperties(propTable)

		-- TODO: Implement functionality, use already existing Particle Emitter

		return instance
	end,

	-- description: "Inherits the properties of the Trail class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
