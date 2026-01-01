local Vector3 = require("@Vector3")
local Color3 = require("@Color3")
local CFrame = require("@CFrame")
local NumberRange = require("@NumberSequence")
local Enum = require("@EnumMap")

local propTable = {}

return {
	class = "ParticleEmitter",

	callback = function(instance, renderer, game)
		propTable.render = function(part, camera, lib) end

		instance:SetProperties(propTable)

		return instance
	end,

	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
