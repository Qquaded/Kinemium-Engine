-- description: "A basic UI container used to group and organize interface elements."
local GuiObject = require("@GuiObject")

local propTable = {
	Name = "Frame",
	AbsoluteSize = nil,
	AbsolutePosition = nil,
}

GuiObject.inherit(propTable)

propTable.render = function(Window, object, dt, renderer)
	if not object.Visible then
		return
	end
	local pos, size = GuiObject.render(Window, object, dt, renderer)

	GuiObject.renderChildren(Window, object, dt, renderer)

	return pos, size
end

return {
	class = "Frame",
	render = propTable.render,

	callback = function(instance, renderer)
		instance:SetProperties(propTable)
		return instance
	end,

	inherit = function(tble)
		GuiObject.inherit(tble)
	end,
}
