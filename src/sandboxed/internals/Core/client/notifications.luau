local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

repeat
	task.wait()
until CoreGui:FindFirstChild("KinemiumCoreGui")

if not RunService:IsClient() then
	return
end

repeat
	task.wait()
until ishared.ReactPointer

repeat
	task.wait()
until ishared.EscapeMenu_Signal

export type SignalObject = typeof(Signal.new())

local screenGui = CoreGui.KinemiumCoreGui
local manager = ishared.ReactPointer

local function runtime(key, fallback)
	local value = manager:get("#runtime", key)
	if value == nil then
		return fallback
	end
	return value
end

local function bindRuntime(object, props)
	for property, key in pairs(props) do
		manager:bind(object, property, "#runtime." .. key)
	end
end

local function bindCorner(corner, radiusKey)
	radiusKey = radiusKey or "corner"
	bindRuntime(corner, {
		CornerRadius = radiusKey,
		TopLeftRadius = radiusKey,
		TopRightRadius = radiusKey,
		BottomLeftRadius = radiusKey,
		BottomRightRadius = radiusKey,
	})
end

local function springTarget(object, props)
	Spring.target(object, runtime("damping", 2), runtime("frequency", 5), props)
end

local notifLayout = Instance.new("UINotificationLayout")
notifLayout.Anchor = Enum.NotificationAnchor.BottomRight
notifLayout.DefaultTimeout = 4
notifLayout.MarginX = UDim.new(0, 16)
notifLayout.MarginY = UDim.new(0, 16)
notifLayout.Parent = screenGui

if not RunService:IsClient() then
	return
end

local TextService = game:GetService("TextService")

local function push(titleText, desc, timeout)
	local card = Instance.new("TextButton")
	card.Size = UDim2.new(0, 280, 0, 80)
	card.Text = ""
	card.BackgroundColor3 = Color3.new(0, 0, 0)
	card.BackgroundTransparency = 0.3
	card.AutoButtonColor = false
	card.Parent = screenGui
	bindRuntime(card, {
		BackgroundColor3 = "background",
		BackgroundTransparency = "bgtransparency",
	})

	local title = Instance.new("TextLabel")
	title.Text = titleText
	title.BackgroundTransparency = 1
	title.TextColor3 = Color3.new(1, 1, 1)
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextSize = 14
	title.Position = UDim2.new(0, 62, 0, 10)
	title.Size = UDim2.new(1, -70, 0, 18)
	title.Parent = card
	bindRuntime(title, {
		TextColor3 = "text",
		Font = "font",
	})

	local description = Instance.new("TextLabel")
	description.Text = desc
	description.BackgroundTransparency = 1
	description.TextColor3 = Color3.new(1, 1, 1)
	description.TextTransparency = 0.3
	description.TextXAlignment = Enum.TextXAlignment.Left
	description.TextSize = 13
	description.Position = UDim2.new(0, 62, 0, 30)
	description.Size = UDim2.new(1, -70, 0, 18)
	description.Parent = card
	bindRuntime(description, {
		TextColor3 = "mutedtext",
		TextTransparency = "mutedtexttransparency",
		Font = "font",
	})

	local icon = Instance.new("ImageLabel")
	icon.Size = UDim2.new(0, 50, 0, 50)
	icon.Position = UDim2.new(0, 6, 0.5, 0)
	icon.Image = "./src/assets/images/cat.png"
	icon.AnchorPoint = Vector2.new(0, 0.5)
	icon.Parent = card
	bindRuntime(icon, {
		ImageColor3 = "accent",
	})

	local UICorner2 = Instance.new("UICorner")
	UICorner2.CornerRadius = UDim.new(0, 25)
	UICorner2.Parent = icon
	bindCorner(UICorner2, "bubblecorner")

	local UICorner = Instance.new("UICorner")
	UICorner.CornerRadius = UDim.new(0, 25)
	UICorner.Parent = card
	bindCorner(UICorner, "bubblecorner")

	local function updateCardSize()
		local currentFont = runtime("font", Enum.Font.DefaultEngineFont)
		local titleSize = TextService.measureMultilineText(title.Text, currentFont, 14, 1)
		local descSize = TextService.measureMultilineText(description.Text, currentFont, 13, 1)

		local width = math.max(titleSize.X, descSize.X) + 70
		local height = math.max(64, 10 + titleSize.Y + 6 + descSize.Y + 10)

		title.Size = UDim2.new(0, titleSize.X, 0, titleSize.Y)
		description.Size = UDim2.new(0, descSize.X, 0, descSize.Y)
		description.Position = UDim2.new(0, 62, 0, 10 + titleSize.Y + 6)

		springTarget(card, {
			Size = UDim2.new(0, width, 0, height),
		})
	end

	manager:subscribe("#runtime", "font", updateCardSize)

	title.Changed:Connect(function(property)
		if property == "Text" then
			updateCardSize()
		end
	end)

	description.Changed:Connect(function(property)
		if property == "Text" then
			updateCardSize()
		end
	end)

	if #titleText > 1 and #desc > 1 then
		local currentFont = runtime("font", Enum.Font.DefaultEngineFont)
		local titleSize = TextService.measureMultilineText(titleText, currentFont, 14, 1)
		local descSize = TextService.measureMultilineText(desc, currentFont, 13, 1)

		title.Size = UDim2.new(0, titleSize.X, 0, titleSize.Y)
		description.Size = UDim2.new(0, descSize.X, 0, descSize.Y)
		description.Position = UDim2.new(0, 62, 0, 10 + titleSize.Y + 6)

		card.Size = UDim2.new(
			0,
			math.max(titleSize.X, descSize.X) + 70,
			0,
			math.max(64, 10 + titleSize.Y + 6 + descSize.Y + 10)
		)
	end
	card.MouseButton1Click:Connect(function()
		notifLayout.Dismiss(card)
	end)

	notifLayout.Push(card, { timeout = timeout })
end

local HUDService = game:GetService("HUDService")

HUDService.SetNotificationHandler(push)

RunService.RenderStepped:Connect(function(dt)
	Spring.stepTargets(dt)
end)
