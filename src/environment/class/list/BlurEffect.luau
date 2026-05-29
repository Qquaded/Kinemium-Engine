-- description: "Represents a BlurEffect in the environment."
local propTable = {
	Size = 5.0,
	Enabled = true,
	Name = "BlurEffect",
}

return {
	class = "BlurEffect",

	-- description: "Initializes the BlurEffect instance."
	-- args: "instance: table, renderer: number"
	-- returns: "table"
	callback = function(instance, renderer)
		-- description: "Renders the component."
		-- args: "effect: table, camera: number, lib: number"
		propTable.render = function(effect, camera, lib) end

		instance:SetProperties(propTable)
		return instance
	end,

	-- description: "Inherits the properties of the BlurEffect class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
