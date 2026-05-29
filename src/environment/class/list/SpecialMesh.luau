-- description: "Represents a SpecialMesh in the environment."
local propTable = {
	Name = "SpecialMesh",
}

return {
	class = "SpecialMesh",
	-- description: "Initializes the SpecialMesh instance."
	-- args: "instance: table"
	-- returns: "table"
	callback = function(instance)
		instance:SetProperties(propTable)

		-- TODO: Implement functionality for SpecialMesh, same as MeshPart

		return instance
	end,
	-- description: "Inherits the properties of the SpecialMesh class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
