repeat
	task.wait()
until ishared.NewCategoryToolbar
local NewCategoryToolbar = ishared.NewCategoryToolbar
local KinemiumIconLoader = game:GetService("KinemiumIconLoader")

local Selection = game:GetService("Selection")

local function newClassInSelected(className)
	local selected = Selection.Get()[1]
	local new = Instance.new(className)

	if selected then
		new.Parent = selected
	else
		new.Parent = game.StarterGui
	end

	return new
end

local classes = {
	"Frame",
	"ImageLabel",
	"ImageButton",
	"TextButton",
	"ScreenGui",
	"TextBox",
	"TextLabel",
}

local elements = {}

for _, className in ipairs(classes) do
	table.insert(elements, {
		type = "ImageButton",
		text = className,
		callback = function()
			newClassInSelected(className)
		end,
		hoverTransparency = 0.5,
		hoverColor = Color3.new(0, 0, 0),
		roundness = 0.2,
		texture = KinemiumIconLoader.ToTexture("./src/assets/images/icons/" .. className .. ".png"),
	})
end

table.insert(elements, {
	type = "Separator",
})

local options = {}

local effectClasses = {
	"UICorner",
	"UIGlow",
	"UIShadow",
	"UIStroke",
	"UIBlend",
	"UIMask",
	"UITilt",
	"UIVignette",
	"UIRipple",
	"UIScaleDetector",
	"UIAspectRatioConstraint",
	"UIBevel",
	"UICellList",
	"UIDragDetector",
	"UIFlowLayout",
	"UIGraph",
	"UIGridLayout",
	"UIListLayout",
	"UILoadingSpinner",
	"UINotificationLayout",
	"UIPadding",
	"UIPageLayout",
	"UIProgressBar",
	"UIScale",
	"UISizeConstraint",
	"UISquircle",
	"UIStackLayout",
	"UITextSizeConstraint",
	"UITooltip",
}

for _, className in ipairs(effectClasses) do
	table.insert(options, {
		label = className,
		onClick = function()
			local Selected = Selection.Get()[1]
			if Selected then
				local new = Instance.new(className)
				new.Parent = Selected
			end
		end,
	})
end

table.insert(elements, {
	type = "ImageDropdownButton",
	text = "Effects",
	options = options,
	callback = function(element, rect) end,
	hoverTransparency = 0.5,
	hoverColor = Color3.new(0, 0, 0),
	roundness = 0.2,
	texture = KinemiumIconLoader.ToTexture("./src/assets/images/icons/UIStroke.png"),
})

NewCategoryToolbar:Fire("UI", {
	elements = elements,
})
