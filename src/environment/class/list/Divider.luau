-- description: "Creates a 2D Divider in Guis."
local GuiObject = require("@GuiObject")
local Color3 = require("@Color3")
local UDim2 = require("@UDim2")

local Aereon = require("@Aereon")
local gui = Aereon.gui

local propTable = {
	Name = "UIDivider",
	BaseClass = "GuiObject",
	AbsoluteSize = nil,
	AbsolutePosition = nil,
	Size = UDim2.new(1, 0, 0, 1),
	Vertical = false,
	LineColor3 = Color3.new(0.3, 0.3, 0.3),
	Visible = true,
}

GuiObject.inherit(propTable)

return {
	class = "UIDivider",

	callback = function(instance, renderer, game)
		local divider = gui.divider({
			x = 0,
			y = 0,
			width = 100,
			height = 1,
			vertical = instance.Vertical,
			color = instance.LineColor3,
		})

		instance:SetProperties(propTable)
		instance._divider = divider

		instance.render = function(lib, object, dt, structs, renderer)
			if object.Visible == false then
				return
			end

			local pos, size = GuiObject.calculatePositions(lib, object, dt, structs, renderer)

			divider.set("x", pos.X)
			divider.set("y", pos.Y)
			divider.set("width", size.X)
			divider.set("height", size.Y)
			divider.set("vertical", object.Vertical == true)
			divider.set("color", object.LineColor3)

			divider.render(dt)

			return pos, size
		end

		return instance
	end,

	inherit = function(tble)
		GuiObject.inherit(tble)
	end,
}
