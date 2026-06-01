-- description: "A configurable mesh object that can be applied to parts, Not functional."
local propTable = {
	Name = "SpecialMesh",
}

return {
	class = "SpecialMesh",
	callback = function(instance)
		instance:SetProperties(propTable)

		-- TODO: Implement functionality for SpecialMesh, same as MeshPart

		return instance
	end,
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
