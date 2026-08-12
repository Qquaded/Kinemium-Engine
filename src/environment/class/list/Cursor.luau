-- description: "Controls the appearance and behavior of the mouse cursor in the user interface."
local GuiObject = require("@GuiObject")

local zembed = require("@zembed")
local Vector2 = require("@Vector2")
local Color3 = require("@Color3")

local fs = zune.fs

local propTable = {
	Name = "Cursor",
	IconPack = "./src/assets/icon/cursor",
	Size = Vector2.new(42, 42),
	Color = Color3.new(1, 1, 1),
	Transparency = 0,
}

GuiObject.inherit(propTable)

propTable.render = function(lib, object, dt, structs, renderer) end

return {
	class = "Cursor",
	render = propTable.render,

	callback = function(instance, renderer) end,

	inherit = function(tble)
		GuiObject.inherit(tble)
	end,
}
