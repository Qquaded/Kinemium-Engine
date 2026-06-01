-- description: "A loading spinner for indicating activity."
local GuiObject = require("@GuiObject")
local Color3 = require("@Color3")
local UDim2 = require("@UDim2")

local Aereon = require("@Aereon")
local gui = Aereon.gui

local propTable = {
	Name = "UILoadingSpinner",
	BaseClass = "GuiObject",
	AbsoluteSize = nil,
	AbsolutePosition = nil,
	Size = UDim2.new(0, 40, 0, 40),
	SpinnerColor3 = Color3.new(0.02, 0.5, 1),
	Thickness = 3,
	Visible = true,
}

GuiObject.inherit(propTable)

return {
	class = "UILoadingSpinner",

	callback = function(instance, renderer, game)
		local spinner = gui.spinner({
			x = 0,
			y = 0,
			radius = 20,
			color = instance.SpinnerColor3,
			thickness = instance.Thickness,
		})

		instance:SetProperties(propTable)
		instance._spinner = spinner

		instance.render = function(lib, object, dt, structs, renderer)
			if object.Visible == false then
				return
			end

			local pos, size = GuiObject.calculatePositions(lib, object, dt, structs, renderer)
			spinner.set("x", pos.X + size.X / 2)
			spinner.set("y", pos.Y + size.Y / 2)
			spinner.set("radius", math.max(2, math.min(size.X, size.Y) / 2))
			spinner.set("color", object.SpinnerColor3)
			spinner.set("thickness", math.max(1, tonumber(object.Thickness) or 3))
			spinner.render(dt)

			return pos, size
		end

		return instance
	end,

	inherit = function(tble)
		GuiObject.inherit(tble)
	end,
}
