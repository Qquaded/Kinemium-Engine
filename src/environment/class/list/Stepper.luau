-- description: "A progress indicator that displays a series of steps with visual feedback."
local GuiObject = require("@GuiObject")
local Color3 = require("@Color3")
local UDim2 = require("@UDim2")

local Aereon = require("@Aereon")
local gui = Aereon.gui

local propTable = {
	Name = "UIStepper",
	BaseClass = "GuiObject",
	AbsoluteSize = nil,
	AbsolutePosition = nil,
	Size = UDim2.new(0, 220, 0, 30),
	Steps = 4,
	CurrentStep = 1,
	StepSize = 30,
	StepSpacing = 60,
	ActiveColor3 = Color3.new(0.02, 0.5, 1),
	InactiveColor3 = Color3.new(0.3, 0.3, 0.3),
	TextColor3 = Color3.new(1, 1, 1),
	Visible = true,
}

GuiObject.inherit(propTable)

return {
	class = "UIStepper",

	callback = function(instance, renderer, game)
		local stepper = gui.stepper({
			x = 0,
			y = 0,
			steps = instance.Steps,
			currentStep = instance.CurrentStep,
			size = instance.StepSize,
			spacing = instance.StepSpacing,
		})

		instance:SetProperties(propTable)
		instance._stepper = stepper

		instance.render = function(lib, object, dt, structs, renderer)
			if object.Visible == false then
				return
			end

			local pos, size = GuiObject.calculatePositions(lib, object, dt, structs, renderer)
			local steps = math.max(1, math.floor(tonumber(object.Steps) or 1))
			local currentStep = math.clamp(math.floor(tonumber(object.CurrentStep) or 1), 1, steps)
			if object.CurrentStep ~= currentStep then
				object.CurrentStep = currentStep
			end

			stepper.set("x", pos.X)
			stepper.set("y", pos.Y)
			stepper.set("steps", steps)
			stepper.set("currentStep", currentStep)
			stepper.set("size", math.max(8, tonumber(object.StepSize) or 30))
			stepper.set("spacing", math.max(8, tonumber(object.StepSpacing) or 60))
			stepper.set("activeColor", object.ActiveColor3)
			stepper.set("inactiveColor", object.InactiveColor3)
			stepper.set("textColor", object.TextColor3)
			stepper.render(dt)

			return pos, size
		end

		return instance
	end,

	inherit = function(tble)
		GuiObject.inherit(tble)
	end,
}
