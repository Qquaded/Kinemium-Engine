-- description: "A clickable 2D button that displays an image."
local ImageLabel = require("@ImageLabel")
local GuiObject = require("@GuiObject")
local logic = require("@Kinemium.2dbutton")
local signal = require("@Kinemium.signal")

local buttonProps = {
	AutoButtonColor = true,
	ChangeCursorOnHover = true,
	Visible = true,
	Name = "ImageButton",
}

ImageLabel.inherit(buttonProps)

local function createSignals()
	return {
		MouseButton1Click = signal.new(),
		MouseButton2Click = signal.new(),
		MouseButton1Down = signal.new(),
		MouseButton1Up = signal.new(),
		MouseButton2Down = signal.new(),
		Activated = signal.new(),
		MouseButton2Up = signal.new(),
	}
end

buttonProps.render = function(lib, object, dt, structs, renderer)
	local framePos, frameSize, texture = ImageLabel.render(lib, object, dt, structs, renderer)
	if not object.Visible or not framePos or not frameSize then
		return
	end

	logic:Step(object, lib)
	GuiObject.renderChildren(lib, object, dt, structs, renderer)

	return framePos, frameSize, texture
end

return {
	class = "ImageButton",

	callback = function(instance, renderer)
		ImageLabel.callback(instance, renderer)

		for prop, value in pairs(createSignals()) do
			instance:SetProperty(prop, value)
		end

		instance:SetProperties(buttonProps)
		return instance
	end,

	inherit = function(tble)
		ImageLabel.inherit(tble)

		for prop, value in pairs(createSignals()) do
			if tble[prop] == nil then
				tble[prop] = value
			end
		end

		for prop, val in pairs(buttonProps) do
			if tble[prop] == nil then
				tble[prop] = val
			end
		end
	end,
}
