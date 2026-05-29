-- description: "Represents a Slider in the environment."
local GuiObject = require("@GuiObject")
local Color3 = require("@Color3")
local UDim2 = require("@UDim2")
local signal = require("@Kinemium.signal")

local Aereon = require("@Aereon")
local gui = Aereon.gui
local arect = Aereon.rect()

local propTable = {
	Name = "UISlider",
	BaseClass = "GuiObject",
	AbsoluteSize = nil,
	AbsolutePosition = nil,
	Size = UDim2.new(0, 200, 0, 28),
	Value = 0.5,
	Min = 0,
	Max = 1,
	TrackColor3 = Color3.new(0.15, 0.15, 0.15),
	FillColor3 = Color3.new(0.02, 0.5, 1),
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
	class = "UISlider",

	-- description: "Initializes the Slider instance."
	-- args: "instance: table, renderer: number, game: table"
	-- returns: "table"
	callback = function(instance, renderer, game)
		local onValueChanged = signal.new()
		local slider = gui.slider({
			x = 0,
			y = 0,
			width = 200,
			height = 28,
			value = instance.Value,
			min = instance.Min,
			max = instance.Max,
			-- description: "Ons changed."
			-- args: "value: number"
			onChanged = function(value)
				instance.Value = value
				onValueChanged:Fire(value)
			end,
		})

		instance:SetProperties(propTable)
		instance.OnValueChanged = onValueChanged
		instance._slider = slider

		-- description: "Instance.renders."
		-- args: "lib: number, object: table, dt: number, structs: table, renderer: number"
		instance.render = function(lib, object, dt, structs, renderer)
			if object.Visible == false then
				return
			end

			local pos, size = GuiObject.calculatePositions(lib, object, dt, structs, renderer)
			local minValue = tonumber(object.Min) or 0
			local maxValue = tonumber(object.Max) or 1
			if maxValue < minValue then
				minValue, maxValue = maxValue, minValue
			end
			local value = math.clamp(tonumber(object.Value) or minValue, minValue, maxValue)
			if object.Value ~= value then
				object.Value = value
			end

			slider.set("obj_rect", arect.new(pos.X, pos.Y, size.X, size.Y))
			slider.set("min", minValue)
			slider.set("max", maxValue)
			slider.set("value", value)
			slider.set("trackColor", object.TrackColor3)
			slider.set("fillColor", object.FillColor3)
			slider.set("handleColor", object.HandleColor3)

			slider.render(dt)
			renderChildren(lib, object, dt, structs, renderer, pos, size)

			return pos, size
		end

		return instance
	end,

	-- description: "Inherits the properties of the Slider class."
	-- args: "tble: table"
	inherit = function(tble)
		GuiObject.inherit(tble)
	end,
}
