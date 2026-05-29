-- description: "Represents a Checkbox in the environment."
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

	-- description: "Initializes the Checkbox instance."
	-- args: "instance: table, renderer: number, game: table"
	-- returns: "table"
	callback = function(instance, renderer, game)
		local onValueChanged = signal.new()
		local checkbox = gui.checkbox({
			x = 0,
			y = 0,
			size = 20,
			value = instance.Value,
			-- description: "Ons changed."
			-- args: "value: number"
			onChanged = function(value)
				instance.Value = value
				onValueChanged:Fire(value)
			end,
		})

		instance:SetProperties(propTable)
		instance.OnValueChanged = onValueChanged
		instance._checkbox = checkbox

		-- description: "Instance.renders."
		-- args: "lib: number, object: table, dt: number, structs: table, renderer: number"
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

	-- description: "Inherits the properties of the Checkbox class."
	-- args: "tble: table"
	inherit = function(tble)
		GuiObject.inherit(tble)
	end,
}
