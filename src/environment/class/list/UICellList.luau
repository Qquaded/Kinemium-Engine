-- description: "Represents an UICellList in the environment."
local GuiObject = require("@GuiObject")
local UDim2 = require("@UDim2")

local Aereon = require("@Aereon")
local gui = Aereon.gui
local arect = Aereon.rect()

local propTable = {
	Name = "UICellList",
	BaseClass = "GuiObject",
	AbsoluteSize = nil,
	AbsolutePosition = nil,
	Size = UDim2.new(1, 0, 1, 0),
	Sections = {
		HelloWorld = {
			{
				name = "Hello World",
				description = "Welcome to Kinemium!",
			},
		},
	},
	CellHeight = 70,
	GroupSpacing = 20,
	Visible = true,
}

GuiObject.inherit(propTable)

return {
	class = "UICellList",

	-- description: "Initializes the UICellList instance."
	-- args: "instance: table, renderer: number, game: table"
	-- returns: "table"
	callback = function(instance, renderer, game)
		local cellList = gui.UICellList({
			x = 0,
			y = 0,
			width = 800,
			cellHeight = instance.CellHeight,
			groupSpacing = instance.GroupSpacing,
			sections = instance.Sections,
		})

		instance:SetProperties(propTable)
		instance._cellList = cellList

		-- description: "Instance.renders."
		-- args: "lib: number, object: table, dt: number, structs: table, renderer: number"
		instance.render = function(lib, object, dt, structs, renderer)
			if object.Visible == false then
				return
			end

			local pos, size = GuiObject.calculatePositions(lib, object, dt, structs, renderer)

			cellList.set("sections", object.Sections)
			cellList.set("cellHeight", object.CellHeight)
			cellList.set("groupSpacing", object.GroupSpacing)
			cellList.set("obj_rect", arect.new(pos.X, pos.Y, size.X, size.Y))
			cellList.render(dt)

			return pos, size
		end

		return instance
	end,

	-- description: "Inherits the properties of the UICellList class."
	-- args: "tble: table"
	inherit = function(tble)
		GuiObject.inherit(tble)
	end,
}
