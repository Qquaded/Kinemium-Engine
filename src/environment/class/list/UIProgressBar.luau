-- description: "A visual component that displays a progress bar with customizable colors and size."
local GuiObject = require("@GuiObject")
local Color3 = require("@Color3")
local UDim2 = require("@UDim2")

local Aereon = require("@Aereon")
local gui = Aereon.gui
local arect = Aereon.rect()

local propTable = {
	Name = "UIProgressBar",
	BaseClass = "GuiObject",
	AbsoluteSize = nil,
	AbsolutePosition = nil,
	Size = UDim2.new(0, 220, 0, 20),
	Progress = 0,
	BackgroundColor3 = Color3.new(0.15, 0.15, 0.15),
	FillColor3 = Color3.new(0.02, 0.5, 1),
	Visible = true,
}

GuiObject.inherit(propTable)

return {
	class = "UIProgressBar",

	callback = function(instance, renderer, game)
		local progressBar = gui.progressBar({
			x = 0,
			y = 0,
			width = 220,
			height = 20,
			progress = instance.Progress,
		})

		instance:SetProperties(propTable)
		instance._progressBar = progressBar

		instance.render = function(lib, object, dt, structs, renderer)
			if object.Visible == false then
				return
			end

			local pos, size = GuiObject.calculatePositions(lib, object, dt, structs, renderer)
			local progress = math.clamp(tonumber(object.Progress) or 0, 0, 1)
			if object.Progress ~= progress then
				object.Progress = progress
			end

			progressBar.set("obj_rect", arect.new(pos.X, pos.Y, size.X, size.Y))
			progressBar.set("progress", progress)
			progressBar.set("backgroundColor", object.BackgroundColor3)
			progressBar.set("fillColor", object.FillColor3)
			progressBar.render(dt)

			return pos, size
		end

		return instance
	end,

	inherit = function(tble)
		GuiObject.inherit(tble)
	end,
}
