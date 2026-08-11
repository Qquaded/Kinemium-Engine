-- description: "Use with TextService:GetTextBoundsAsync() to measure the size of text."
local GuiObject = require("@GuiObject")
local Enum = require("@Enum")
local Font = require("@Font")

local propTable = {
	Font = Enum.Font.Montserrat,
	RichText = false,
	Size = 20,
	Text = "Hello World",
	Width = 100,
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
	class = "GetTextBoundsParams",
	render = propTable.render,

	callback = function(instance, renderer)
		instance:SetProperties(propTable)
		return instance
	end,

	inherit = function(tble)
		GuiObject.inherit(tble)
	end,
}
