-- description: "A gui component that has a boolean state that can be toggled, And can be visible under gui containers."

local GuiObject = require("@GuiObject")
local Color3 = require("@Color3")
local UDim2 = require("@UDim2")
local signal = require("@Kinemium.signal")

local Aereon = require("@Aereon")
local gui = Aereon.gui
local arect = Aereon.rect()

local propTable = {
	Name = "UICheckbox",
	BaseClass = "GuiObject",
	AbsoluteSize = nil,
	AbsolutePosition = nil,
	Size = UDim2.new(0, 20, 0, 20),
	Value = false,
	BoxColor3 = Color3.new(0.2, 0.2, 0.2),
	CheckColor3 = Color3.new(1, 1, 1),
	OnValueChanged = nil,
	Visible = true,
}

GuiObject.inherit(propTable)

return {
	class = "UICheckbox",

	callback = function(instance, renderer, game)
		local onValueChanged = signal.new()
		local checkbox = gui.checkbox({
			x = 0,
			y = 0,
			size = 20,
			value = instance.Value,
			onChanged = function(value)
				instance.Value = value
				onValueChanged:Fire(value)
			end,
		})

		instance:SetProperties(propTable)
		instance.OnValueChanged = onValueChanged
		instance._checkbox = checkbox

		instance.render = function(lib, object, dt, structs, renderer)
			if object.Visible == false then
				return
			end

			local pos, size = GuiObject.calculatePositions(lib, object, dt, structs, renderer)
			checkbox.set("obj_rect", arect.new(pos.X, pos.Y, size.X, size.Y))
			checkbox.set("value", object.Value == true)
			checkbox.set("boxColor", object.BoxColor3)
			checkbox.set("checkColor", object.CheckColor3)
			checkbox.render(dt)

			return pos, size
		end

		return instance
	end,

	inherit = function(tble)
		GuiObject.inherit(tble)
	end,
}
