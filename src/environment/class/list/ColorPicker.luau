-- description: "Represents a ColorPicker in the environment."
local GuiObject = require("@GuiObject")
local raylib = require("@Raylib")
local aereon = require("@Aereon")
local gui = aereon.gui
local signal = require("@Kinemium.signal")
local Color4 = require("@Color4")
local arect = aereon.rect()
local UDim2 = require("@UDim2")
local Enum = require("@EnumMap")
local lib = raylib.lib

local propTable = {
	Name = "ColorPicker",
	BaseClass = "GuiObject",
	AbsoluteSize = nil,
	AbsolutePosition = nil,
	Size = UDim2.new(0, 250, 0, 400),
	Font = Enum.Font.DefaultEngineFont,
	SelectedColor = nil,
	OnColorSelect = signal.new(),
	Visible = true,
}

local defaultFont = lib.GetFontDefault()

GuiObject.inherit(propTable)

return {
	class = "ColorPicker",

	-- description: "Initializes the ColorPicker instance."
	-- args: "instance: table, renderer: number, game: table"
	-- returns: "table"
	callback = function(instance, renderer, game)
		-- description: "Resolves font."
		-- args: "fontEnum: number"
		local function resolveFont(fontEnum)
			local name = fontEnum.Value
			local resolvedFont = renderer.Font.Get(name) or defaultFont
			return resolvedFont
		end

		local picker = gui.colorPicker({
			x = 0,
			y = 0,
			width = 200,
			height = 250,
			-- description: "Ons changed."
			-- args: "color: number, alpha: number"
			onChanged = function(color, alpha)
				local selected = Color4.new(color.R, color.G, color.B, alpha)
				instance.SelectedColor = selected
				instance.OnColorSelect:Fire(selected)
			end,
		})

		-- description: "Renders the component."
		-- args: "lib: number, object: table, dt: number, structs: table, renderer: number"
		propTable.render = function(lib, object, dt, structs, renderer)
			if object.Visible == false then
				return
			end
			local pos, size = GuiObject.calculatePositions(lib, object, dt, structs, renderer)

			picker.set("obj_rect", arect.new(pos.X, pos.Y, size.X, size.Y))
			picker.set("backgroundColor", object.BackgroundColor3)
			picker.set("backgroundTransparency", object.BackgroundTransparency)
			picker.set("font", resolveFont(object.Font))

			picker.render(dt)

			for _, child in pairs(object:GetChildren()) do
				if child.render then
					lib.BeginScissorMode(pos.X, pos.Y, size.X, size.Y)
					child.render(lib, child, dt, structs, renderer)
					lib.EndScissorMode()
				end
			end
		end

		instance:SetProperties(propTable)
		return instance
	end,
	-- description: "Inherits the properties of the ColorPicker class."
	-- args: "tble: table"
	inherit = function(tble)
		GuiObject.inherit(tble)
	end,
}
