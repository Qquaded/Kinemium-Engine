local Vector3 = require("@Vector3")
local Color3 = require("@Color3")
local CFrame = require("@CFrame")
local Enum = require("@EnumMap")
local raylib = require("@raylib")
local Part = require("./src/enviroment/class/list/Part")

local propTable = {
	Name = "Union",
}
Part.inherit(propTable)

return {
	class = "Union",

	callback = function(instance, renderer)
		propTable.render = function(part, camera, lib) end

		instance:SetProperties(propTable)

		instance.Changed:Connect(function(property)
			if property == "Anchored" then
				renderer.Signal:Fire("UpdatePart", instance)
			end
		end)

		return instance
	end,

	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
