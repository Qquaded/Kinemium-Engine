-- description: "Represents a Frame in the environment."
local GuiObject = require("@GuiObject")

local propTable = {
	Name = "Frame",
	AbsoluteSize = nil,
	AbsolutePosition = nil,
}

GuiObject.inherit(propTable)

-- description: "Renders the component."
-- args: "lib: number, object: table, dt: number, structs: table, renderer: number"
propTable.render = function(lib, object, dt, structs, renderer)
	if not object.Visible then
		return
	end
	local pos, size = GuiObject.render(lib, object, dt, structs, renderer)

	GuiObject.renderChildren(lib, object, dt, structs, renderer)

	return pos, size
end

return {
	class = "Frame",
	render = propTable.render,
	-- description: "Initializes the Frame instance."
	-- args: "instance: table, renderer: number"
	-- returns: "table"
	callback = function(instance, renderer)
		instance:SetProperties(propTable)
		return instance
	end,
	-- description: "Inherits the properties of the Frame class."
	-- args: "tble: table"
	inherit = function(tble)
		GuiObject.inherit(tble)
	end,
}
