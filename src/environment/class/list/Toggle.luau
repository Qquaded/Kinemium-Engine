-- description: "A toggle switch UI component that allows users to switch between two states."
local GuiObject = require("@GuiObject")
local Color3 = require("@Color3")
local UDim2 = require("@UDim2")
local signal = require("@Kinemium.signal")

local Aereon = require("@Aereon")
local gui = Aereon.gui
local arect = Aereon.rect()

local propTable = {
	Name = "UIToggle",
	BaseClass = "GuiObject",
	AbsoluteSize = nil,
	AbsolutePosition = nil,
	Size = UDim2.new(0, 56, 0, 28),
	Value = false,
	OffColor3 = Color3.new(0.3, 0.3, 0.3),
	OnColor3 = Color3.new(0.02, 0.5, 1),
	HandleColor3 = Color3.new(1, 1, 1),
	OnValueChanged = nil,
	Visible = true,
}

local function renderChildren(lib, object, dt, structs, renderer, pos, size)
	for _, child in pairs(object:GetChildren()) do
		if child.render then
			lib.BeginScissorMode(pos.X, pos.Y, size.X, size.Y)
			child.render(lib, child, dt, structs, renderer)
			lib.EndScissorMode()
		end
	end
end

GuiObject.inherit(propTable)

return {
	class = "UIToggle",

	callback = function(instance, renderer, game)
		local onValueChanged = signal.new()
		local toggle = gui.toggle({
			x = 0,
			y = 0,
			width = 56,
			height = 28,
			value = instance.Value,
			onChanged = function(value)
				instance.Value = value
				onValueChanged:Fire(value)
			end,
		})

		instance:SetProperties(propTable)
		instance.OnValueChanged = onValueChanged
		instance._toggle = toggle

		instance.render = function(lib, object, dt, structs, renderer)
			if object.Visible == false then
				return
			end

			local pos, size = GuiObject.calculatePositions(lib, object, dt, structs, renderer)

			toggle.set("obj_rect", arect.new(pos.X, pos.Y, size.X, size.Y))
			toggle.set("value", object.Value == true)
			toggle.set("offColor", object.OffColor3)
			toggle.set("onColor", object.OnColor3)
			toggle.set("handleColor", object.HandleColor3)

			toggle.render(dt)
			renderChildren(lib, object, dt, structs, renderer, pos, size)

			return pos, size
		end

		return instance
	end,

	inherit = function(tble)
		GuiObject.inherit(tble)
	end,
}
