-- description: "Renders descendant GUI objects as a single canvas."
local utils = require("@bufferutils")
local Color3 = require("@Color3")

local GuiObject = require("@GuiObject")

local propTable = {
	Name = "CanvasGroup",
	AbsoluteSize = nil,
	AbsolutePosition = nil,
	GroupColor3 = Color3.new(1, 1, 1),
	GroupTransparency = 0,
}

GuiObject.inherit(propTable)

propTable.render = function(lib, object, dt, structs, renderer) end

return {
	class = "CanvasGroup",
	render = propTable.render,
	callback = function(instance, renderer)
		return instance
	end,

	inherit = function(tble)
		GuiObject.inherit(tble)
	end,
}
