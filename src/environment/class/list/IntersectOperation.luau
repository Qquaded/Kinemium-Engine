-- description: "A modifier class representing the intersection of multiple parts."
local Part = require("@Part")
local Enum = require("@EnumMap")

local propTable = {
	Name = "Intersect",
	BaseClass = "BasePart",
	ConnectedParts = {},

	_manifoldptr = nil,
	_mesh = nil,
	_cpuMeshData = nil,
	CollisionFidelity = Enum.CollisionFidelity.Default,
	RenderFidelity = Enum.RenderFidelity.Automatic,
}

Part.inherit(propTable)

return {
	class = "IntersectOperation",

	callback = function(instance, renderer, game)
		Part.callback(instance, renderer, game)
		instance:SetProperties(propTable)

		function instance:GetConnectedParts()
			return instance.ConnectedParts
		end

		instance.Changed:Connect(function(property)
			if property == "_mesh" or property == "_cpuMeshData" or property == "Material" or property == "Color" then
				renderer.EventBus:Fire("UpdatePart", instance)
			end
		end)

		return instance
	end,

	inherit = function(tble)
		Part.inherit(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
