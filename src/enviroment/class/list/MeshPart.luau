local Vector3 = require("@Vector3")
local Part = require("./Part")
local Enum = require("@EnumMap")

local propTable = {
	MeshObject = nil,
	_showhitbox = false,
	CollisionFidelity = Enum.CollisionFidelity.Default,
	RenderFidelity = Enum.RenderFidelity.Automatic,
	CollisionScale = 1,
	Name = "MeshPart",
	BaseClass = "BasePart",
	MeshScale = 1,
	Transparency = 1,
	Size = Vector3.new(1, 1, 1),
}

Part.inherit(propTable)

return {
	class = "MeshPart",

	callback = function(instance, renderer)
		instance:SetProperties(propTable)
		instance:SetMetadata("IsMovable", true)

		return instance
	end,
	inherit = function()
		return propTable
	end,
}
