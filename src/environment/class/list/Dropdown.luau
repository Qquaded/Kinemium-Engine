-- description: "Represents a Dropdown in the environment."
local GuiObject = require("@GuiObject")
local Color3 = require("@Color3")
local UDim2 = require("@UDim2")
local signal = require("@Kinemium.signal")

local Aereon = require("@Aereon")
local gui = Aereon.gui
local arect = Aereon.rect()

local propTable = {
	Name = "UIDropdown",
	BaseClass = "GuiObject",
	AbsoluteSize = nil,
	AbsolutePosition = nil,
	Size = UDim2.new(0, 220, 0, 36),
	Options = { "Option 1", "Option 2", "Option 3" },
	SelectedIndex = 1,
	SelectedOption = "Option 1",
	TextSize = 16,
	BackgroundColor3 = Color3.new(0.15, 0.15, 0.18),
	HoverColor3 = Color3.new(0.25, 0.35, 0.55),
	SelectedColor3 = Color3.new(0.2, 0.3, 0.5),
	BorderColor3 = Color3.new(0.3, 0.3, 0.35),
	TextColor3 = Color3.new(0.95, 0.95, 0.97),
	SecondaryTextColor3 = Color3.new(0.7, 0.7, 0.75),
	OnSelectionChanged = nil,
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

-- description: "Sanitizes options."
-- args: "options: table"
local function sanitizeOptions(options)
	local sanitized = {}
	for _, option in ipairs(type(options) == "table" and options or {}) do
		sanitized[#sanitized + 1] = tostring(option)
	end

	if #sanitized == 0 then
		sanitized[1] = "Option 1"
	end

	return sanitized
end

GuiObject.inherit(propTable)

return {
	class = "UIDropdown",

	-- description: "Initializes the Dropdown instance."
	-- args: "instance: table, renderer: number, game: table"
	-- returns: "table"
	callback = function(instance, renderer, game)
		local onSelectionChanged = signal.new()
		local dropdown = gui.dropdown({
			x = 0,
			y = 0,
			width = 220,
			height = 36,
			options = sanitizeOptions(instance.Options),
			selectedIndex = instance.SelectedIndex,
			-- description: "Ons select."
			-- args: "index: number, option: any"
			onSelect = function(index, option)
				instance.SelectedIndex = index
				instance.SelectedOption = option
				onSelectionChanged:Fire(index, option)
			end,
		})

		instance:SetProperties(propTable)
		instance.OnSelectionChanged = onSelectionChanged
		instance._dropdown = dropdown

		-- description: "Instance.renders."
		-- args: "lib: number, object: table, dt: number, structs: table, renderer: number"
		instance.render = function(lib, object, dt, structs, renderer)
			if object.Visible == false then
				return
			end

			local pos, size = GuiObject.calculatePositions(lib, object, dt, structs, renderer)
			local options = sanitizeOptions(object.Options)
			local selectedIndex = math.clamp(tonumber(object.SelectedIndex) or 1, 1, #options)
			local selectedOption = options[selectedIndex]

			if object.SelectedIndex ~= selectedIndex then
				object.SelectedIndex = selectedIndex
			end
			if object.SelectedOption ~= selectedOption then
				object.SelectedOption = selectedOption
			end

			dropdown.set("obj_rect", arect.new(pos.X, pos.Y, size.X, size.Y))
			dropdown.set("options", options)
			dropdown.set("selectedIndex", selectedIndex)
			dropdown.set("backgroundColor", object.BackgroundColor3)
			dropdown.set("hoverColor", object.HoverColor3)
			dropdown.set("selectedColor", object.SelectedColor3)
			dropdown.set("borderColor", object.BorderColor3)
			dropdown.set("textColor", object.TextColor3)
			dropdown.set("secondaryTextColor", object.SecondaryTextColor3)
			dropdown.set("fontSize", object.TextSize)

			dropdown.render(dt)
			renderChildren(lib, object, dt, structs, renderer, pos, size)

			return pos, size
		end

		return instance
	end,

	-- description: "Inherits the properties of the Dropdown class."
	-- args: "tble: table"
	inherit = function(tble)
		GuiObject.inherit(tble)
	end,
}
