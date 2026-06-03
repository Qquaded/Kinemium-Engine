-- description: "A gui component that represents a selectable radio button, Can be used under gui containers."
local GuiObject = require("@GuiObject")
local Color3 = require("@Color3")
local UDim2 = require("@UDim2")
local signal = require("@Kinemium.signal")

local Aereon = require("@Aereon")
local gui = Aereon.gui
local arect = Aereon.rect()

local propTable = {
	Name = "UIRadioButton",
	BaseClass = "GuiObject",
	AbsoluteSize = nil,
	AbsolutePosition = nil,
	Size = UDim2.new(0, 20, 0, 20),
	Value = false,
	RingColor3 = Color3.new(0.3, 0.3, 0.3),
	FillColor3 = Color3.new(0.02, 0.5, 1),
	OnValueChanged = nil,
	Visible = true,
}

GuiObject.inherit(propTable)

return {
	class = "UIRadioButton",

	callback = function(instance, renderer, game)
		local onValueChanged = signal.new()
		local radioButton = gui.radioButton({
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
		instance._radioButton = radioButton

		instance.render = function(lib, object, dt, structs, renderer)
			if object.Visible == false then
				return
			end

			local pos, size = GuiObject.calculatePositions(lib, object, dt, structs, renderer)

			radioButton.set("obj_rect", arect.new(pos.X, pos.Y, size.X, size.Y))
			radioButton.setValue(object.Value == true)
			radioButton.set("ringColor", object.RingColor3)
			radioButton.set("fillColor", object.FillColor3)

			radioButton.render(dt)

			return pos, size
		end

		return instance
	end,

	inherit = function(tble)
		GuiObject.inherit(tble)
	end,
}
