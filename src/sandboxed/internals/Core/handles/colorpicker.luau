local RunService = game:GetService("RunService")
if RunService:IsServer() then
	return
end

repeat
	task.wait()
until ishared.NewToolbarElement
local NewToolbarElement = ishared.NewToolbarElement
local KinemiumIconLoader = game:GetService("KinemiumIconLoader")
local aRect = require("@aRect")

local renderer = game:GetService("KinemiumRaylib").GetRenderer()
local StudioThemeService = game:GetService("StudioThemeService")
local raylib = require("@raylib")
local Selection = game:GetService("Selection")
local rl = raylib.lib

local aereon = require("@Aereon")
local gui = aereon.gui

local picker = gui.colorPicker({
	x = 100,
	y = 100,
	width = 260,
	height = 500,

	onChanged = function(color, alpha)
		local selected = Selection.Get()[1]
		if selected then
			if selected:IsA("BasePart") then
				selected.Color = color
				selected.Transparency = alpha
			elseif selected:IsA("GuiObject") then
				selected.BackgroundColor3 = color
				selected.BackgroundTransparency = alpha
			elseif selected:IsA("Model") then
				for _, object in pairs(selected:GetDescendants()) do
					if object:IsA("BasePart") then
						object.Color = color
						object.Transparency = alpha
					end
				end
			end
		end
	end,
})

local visible = false

renderer.Pool.new("2d", function(data)
	if game.Context ~= Enum.GameContext.Editor then
		return
	end

	local dt = rl.GetFrameTime()
	if visible then
		picker.render(dt)
	end
end)

local toggle = true

NewToolbarElement:Fire("Tools", "Color", {
	type = "ImageButton",
	text = "Color",
	callback = function(element, rect)
		toggle = not toggle

		local pickerWidth = 260
		local pickerHeight = 460

		local x = rect.x + (rect.width / 2) - (pickerWidth / 2)
		local y = rect.y + rect.height + 14

		local SelectedTheme = StudioThemeService.SelectedTheme

		picker.set("obj_rect", aRect.new(x, y, pickerWidth, pickerHeight))
		picker.set("backgroundTransparency", SelectedTheme.WindowBackgroundTransparency)
		picker.set("backgroundColor", SelectedTheme.BackgroundColor)

		visible = not visible
	end,
	hoverTransparency = 0.5,
	hoverColor = Color3.new(0, 0, 0),
	roundness = 0.2,
	texture = KinemiumIconLoader.ToTexture("./src/assets/images/icons/Color3Value.png"),
})

local options = {}

for _, material in pairs(Enum.Material:GetEnumItems()) do
	table.insert(options, {
		label = material.Name,
		onClick = function()
			local Selected = Selection.Get()[1]
			if Selected then
				if Selected:IsA("BasePart") then
					Selected.Material = material
				end
			end
		end,
	})
end

NewToolbarElement:Fire("Tools", "Material", {
	type = "ImageDropdownButton",
	text = "Material",
	options = options,
	callback = function(element, rect) end,
	hoverTransparency = 0.5,
	hoverColor = Color3.new(0, 0, 0),
	roundness = 0.2,
	texture = KinemiumIconLoader.ToTexture("./src/assets/images/icons/Texture.png"),
})
