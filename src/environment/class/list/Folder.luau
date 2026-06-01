-- description: "Stores objects."
local propTable = {
	Name = "Folder",
}

return {
	class = "Folder",
	callback = function(instance)
		instance:SetProperties(propTable)

		return instance
	end,

	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
