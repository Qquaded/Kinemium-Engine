-- description: "Displays a poll that allows users to vote on a set of options."
local GuiObject = require("@GuiObject")
local Color3 = require("@Color3")
local UDim2 = require("@UDim2")

local Aereon = require("@Aereon")
local gui = Aereon.gui
local arect = Aereon.rect()

local propTable = {
	Name = "UIPoll",
	BaseClass = "GuiObject",
	AbsoluteSize = nil,
	AbsolutePosition = nil,
	Size = UDim2.new(0, 300, 0, 400),
	BackgroundColor3 = Color3.new(0.11, 0.11, 0.13),
	OptionBackgroundColor3 = Color3.new(0.16, 0.16, 0.18),
	OptionHoverColor3 = Color3.new(0.18, 0.18, 0.20),
	SelectedOptionColor3 = Color3.new(0.20, 0.35, 0.28),
	TextColor3 = Color3.new(0.90, 0.90, 0.92),
	DimTextColor3 = Color3.new(0.60, 0.60, 0.63),
	Visible = true,
}

GuiObject.inherit(propTable)

return {
	class = "UIPoll",

	callback = function(instance, renderer, game)
		local poll = gui.poll({
			x = 0,
			y = 0,
			width = 300,
			height = 400,
		})

		instance:SetProperties(propTable)
		instance._poll = poll

		instance.render = function(lib, object, dt, structs, renderer)
			if object.Visible == false then
				return
			end

			local pos, size = GuiObject.calculatePositions(lib, object, dt, structs, renderer)

			poll.set("obj_rect", arect.new(pos.X, pos.Y, size.X, size.Y))
			poll.set("backgroundColor", object.BackgroundColor3)
			poll.set("optionBackgroundColor", object.OptionBackgroundColor3)
			poll.set("optionHoverColor", object.OptionHoverColor3)
			poll.set("selectedOptionColor", object.SelectedOptionColor3)
			poll.set("textColor", object.TextColor3)
			poll.set("dimTextColor", object.DimTextColor3)

			poll.render(dt)

			return pos, size
		end

		return instance
	end,

	inherit = function(tble)
		GuiObject.inherit(tble)
	end,
}
