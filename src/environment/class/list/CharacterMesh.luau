-- description: "Represents a CharacterMesh in the environment."
local propTable = {
	Name = "CharacterMesh",
	BaseClass = "Kinemium.instance",

	BaseTextureId = 0,
	BodyPart = 1, -- Enum
	MeshId = 0,
	OverlayTextureId = 0,
}

return {
	class = "CharacterMesh",
	-- description: "Initializes the CharacterMesh instance."
	-- args: "instance: table"
	-- returns: "table"
	callback = function(instance)
		instance:SetProperties(propTable)
		return instance
	end,
	-- description: "Inherits the properties of the CharacterMesh class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
