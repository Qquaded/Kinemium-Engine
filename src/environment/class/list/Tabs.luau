-- description: "A tabbed interface for organizing content."
local GuiObject = require("@GuiObject")
local Color3 = require("@Color3")
local UDim2 = require("@UDim2")
local signal = require("@Kinemium.signal")

local Aereon = require("@Aereon")
local Enum = require("@Enum")
local gui = Aereon.gui
local arect = Aereon.rect()

local propTable = {
	Name = "UITabs",
	BaseClass = "GuiObject",
	AbsoluteSize = nil,
	AbsolutePosition = nil,
	Size = UDim2.new(0, 240, 0, 40),
	Tabs = { "Tab 1", "Tab 2", "Tab 3" },
	ActiveIndex = 1,
	ActiveTab = "Tab 1",
	TextSize = 16,
	Font = Enum.Font.DefaultEngineFont,
	BackgroundTransparency = 0,
	BackgroundColor3 = Color3.new(0.15, 0.15, 0.15),
	ActiveColor3 = Color3.new(0.02, 0.5, 1),
	TextColor3 = Color3.new(1, 1, 1),
	OnTabChanged = nil,
	Visible = true,
}

local function sanitizeTabs(tabs)
	local sanitized = {}
	for _, tab in ipairs(type(tabs) == "table" and tabs or {}) do
		sanitized[#sanitized + 1] = tostring(tab)
	end

	if #sanitized == 0 then
		sanitized[1] = "Tab 1"
	end

	return sanitized
end

GuiObject.inherit(propTable)

local adapter = require("@RaylibAdapter")
local lib = adapter.lib
local defaultFont = lib.GetFontDefault()

return {
	class = "UITabs",

	callback = function(instance, renderer, game)
		local function resolveFont(fontEnum)
			local name = fontEnum.Value
			local resolvedFont = renderer.Font.Get(name) or defaultFont
			return resolvedFont
		end

		local onTabChanged = signal.new()
		local tabs = gui.tabs({
			x = 0,
			y = 0,
			width = 240,
			height = 40,
			tabs = sanitizeTabs(instance.Tabs),
			activeIndex = instance.ActiveIndex,
			onTabChange = function(index, tab)
				instance.ActiveIndex = index
				instance.ActiveTab = tab
				onTabChanged:Fire(index, tab)
			end,
		})

		instance:SetProperties(propTable)
		instance.OnTabChanged = onTabChanged
		instance._tabs = tabs

		instance.render = function(lib, object, dt, structs, renderer)
			if object.Visible == false then
				return
			end

			local pos, size = GuiObject.calculatePositions(lib, object, dt, structs, renderer)
			local tabNames = sanitizeTabs(object.Tabs)
			local activeIndex = math.clamp(math.floor(tonumber(object.ActiveIndex) or 1), 1, #tabNames)
			local activeTab = tabNames[activeIndex]
			if object.ActiveIndex ~= activeIndex then
				object.ActiveIndex = activeIndex
			end
			if object.ActiveTab ~= activeTab then
				object.ActiveTab = activeTab
			end

			tabs.set("obj_rect", arect.new(pos.X, pos.Y, size.X, size.Y))
			tabs.set("tabs", tabNames)
			tabs.set("activeIndex", activeIndex)
			tabs.set("backgroundColor", object.BackgroundColor3)
			tabs.set("activeColor", object.ActiveColor3)
			tabs.set("textColor", object.TextColor3)
			tabs.set("fontSize", object.TextSize)
			tabs.set("font", resolveFont(object.Font))
			tabs.set("backgroundTransparency", object.BackgroundTransparency)
			tabs.render(dt)

			return pos, size
		end

		return instance
	end,

	inherit = function(tble)
		GuiObject.inherit(tble)
	end,
}
