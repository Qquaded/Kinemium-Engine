-- description: "Represents a Beam in the environment."
local ColorSequence = require("@ColorSequence")
local Color3 = require("@Color3")
local NumberSequence = require("@NumberSequence")
local Enum = require("@EnumMap")

local propTable = {
	Attachment0 = nil,
	Attachment1 = nil,
	Color = ColorSequence.new(Color3.new(1, 1, 1)),
	Transparency = NumberSequence.new(0.5),
	CurveSize0 = 0,
	CurveSize1 = 0,
	Segments = 10,
	Width0 = 1,
	Width1 = 1,
	Texture = "",
	TextureLength = 1,
	TextureMode = Enum.TextureMode.Stretch,
	TextureSpeed = 1,
	LightEmission = 0,
	LightInfluence = 1,
	FaceCamera = false,
	Enabled = true,
	ZOffset = 0,
}

return {
	class = "Beam",

	-- description: "Initializes the Beam instance."
	-- args: "instance: table"
	-- returns: "table"
	callback = function(instance)
		instance:SetProperties(propTable)

		return instance
	end,

	-- description: "Inherits the properties of the Beam class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
