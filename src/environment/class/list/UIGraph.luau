-- description: "A graph component for visualizing data."
local UDim2 = require("@UDim2")
local Color3 = require("@Color3")
local Aereon = require("@Aereon")
local gui = Aereon.gui
local arect = Aereon.rect()
local GuiObject = require("@GuiObject")

local propTable = {
	Name = "UIGraph",

	Position = UDim2.new(0, 0, 0, 0),
	Size = UDim2.new(0, 200, 0, 100),

	LineColor = Color3.new(0.02, 0.5, 1),
	BgColor = Color3.new(0.1, 0.1, 0.1),
	GridColor = Color3.new(0.25, 0.25, 0.25),
	DrawGrid = true,

	TooltipTextColor = Color3.new(1, 1, 1),
	TooltipBackgroundColor = Color3.new(0, 0, 0),
	TooltipFontSize = 14,

	Capacity = 120,

	Values = {},
	MaxPoints = 50,

	Min = 0,
	Max = 100,
}

return {
	class = "UIGraph",
	callback = function(instance, renderer, datamodel)
		local graph = gui.graph({
			x = 0,
			y = 0,
			width = 200,
			height = 100,
			lineColor = propTable.LineColor,
			bgColor = propTable.BgColor,
			gridColor = propTable.GridColor,
			tooltipTextColor = propTable.TooltipTextColor,
			tooltipBackgroundColor = propTable.TooltipBackgroundColor,
			tooltipFontSize = propTable.TooltipFontSize,
			capacity = propTable.Capacity, -- max number of stored points
			maxPoints = propTable.MaxPoints, -- how many points shown on graph
			min = propTable.Min, -- optional fixed min value
			max = propTable.Max, -- optional fixed max value
		})

		propTable.Clear = function()
			graph.clear()
		end

		propTable.Push = function(value)
			graph.push(value)
		end

		propTable.render = function(lib, object, dt, structs, renderer)
			local framePos, frameSize = GuiObject.calculatePositions(lib, object, dt, structs, renderer)
			graph.set("obj_rect", arect.new(framePos.X, framePos.Y, frameSize.X, frameSize.Y))
			graph.set("lineColor", object.LineColor)
			graph.set("bgTransparency", object.BackgroundTransparency)
			graph.set("bgColor", object.BackgroundColor)
			graph.set("gridColor", object.GridColor)
			graph.set("tooltipTextColor", object.TooltipTextColor)
			graph.set("tooltipBackgroundColor", object.TooltipBackgroundColor)
			graph.set("tooltipFontSize", object.TooltipFontSize)
			graph.set("capacity", object.Capacity)
			graph.set("maxPoints", object.MaxPoints)
			graph.set("min", object.Min)
			graph.set("max", object.Max)
			graph.render(dt)
		end

		instance:SetProperties(propTable)
		instance._graph = graph

		return instance
	end,
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
