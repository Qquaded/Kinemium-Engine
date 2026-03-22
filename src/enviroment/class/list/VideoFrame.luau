local GuiObject = require("@GuiObject")

local propTable = {
	Name = "VideoFrame",
	AbsoluteSize = nil,
	AbsolutePosition = nil,
	VideoObject = nil,
}

GuiObject.inherit(propTable)

propTable.render = function(lib, object, dt, structs, renderer)
	if not object.Visible then
		return
	end
	local pos, size = GuiObject.render(lib, object, dt, structs, renderer)

	GuiObject.renderChildren(lib, object, dt, structs, renderer)

	return pos, size
end

return {
	class = "VideoFrame",
	render = propTable.render,
	callback = function(instance, renderer)
		instance:SetProperties(propTable)
		return instance
	end,
	inherit = function(tble)
		GuiObject.inherit(tble)
	end,
}
