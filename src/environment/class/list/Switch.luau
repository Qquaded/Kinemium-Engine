-- description: "Represents a Switch in the environment."
local GuiObject = require("@GuiObject")
local Color3 = require("@Color3")
local UDim2 = require("@UDim2")
local signal = require("@Kinemium.signal")

local Aereon = require("@Aereon")
local gui = Aereon.gui
local arect = Aereon.rect()

local propTable = {
	Name = "UISwitch",
	BaseClass = "GuiObject",
	AbsoluteSize = nil,
	AbsolutePosition = nil,
	Size = UDim2.new(0, 60, 0, 30),
	Value = false,
	OffColor3 = Color3.new(0.25, 0.25, 0.25),
	OnColor3 = Color3.new(0.3, 0.7, 0.3),
	HandleColor3 = Color3.new(1, 1, 1),
	OnValueChanged = nil,
	Visible = true,
}

-- description: "Renders the component."
-- args: "lib: number, object: table, dt: number, structs: table, renderer: number, pos: Vector3, size: number"
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
	class = "UISwitch",

	-- description: "Initializes the Switch instance."
	-- args: "instance: table, renderer: number, game: table"
	-- returns: "table"
	callback = function(instance, renderer, game)
		local onValueChanged = signal.new()
		local switch = gui.switch({
			x = 0,
			y = 0,
			width = 60,
			height = 30,
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
		instance._switch = switch

		-- description: "Instance.renders."
		-- args: "lib: number, object: table, dt: number, structs: table, renderer: number"
		instance.render = function(lib, object, dt, structs, renderer)
			if object.Visible == false then
				return
			end

			local pos, size = GuiObject.calculatePositions(lib, object, dt, structs, renderer)

			switch.set("obj_rect", arect.new(pos.X, pos.Y, size.X, size.Y))
			switch.set("value", object.Value == true)
			switch.set("offColor", object.OffColor3)
			switch.set("onColor", object.OnColor3)
			switch.set("handleColor", object.HandleColor3)

			switch.render(dt)
			renderChildren(lib, object, dt, structs, renderer, pos, size)

			return pos, size
		end

		return instance
	end,

	-- description: "Inherits the properties of the Switch class."
	-- args: "tble: table"
	inherit = function(tble)
		GuiObject.inherit(tble)
	end,
}
