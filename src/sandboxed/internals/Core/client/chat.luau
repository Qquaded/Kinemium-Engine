local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local InternalStorage = game:GetService("InternalStorage")
local ChatService = game:GetService("ChatService")
local RunService = game:GetService("RunService")

repeat
	task.wait()
until CoreGui:FindFirstChild("KinemiumCoreGui")

if RunService:IsServer() then
	return
end

repeat
	task.wait()
until ishared.CoreGuiSignal

repeat
	task.wait()
until ishared.ReactPointer

repeat
	task.wait()
until InternalStorage:FindFirstChild("ChatRemote")

if not RunService:IsClient() then
	return
end

local signal = ishared.CoreGuiSignal
local manager = ishared.ReactPointer

local chatRemote: RemoteEvent = InternalStorage:FindFirstChild("ChatRemote")

local screenGui = CoreGui.KinemiumCoreGui
local chatOpen = false

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

local ChatGui = Instance.new("CanvasGroup")
ChatGui.BackgroundColor3 = Color3.new(0, 0, 0)
ChatGui.BackgroundTransparency = 0.3
ChatGui.ZIndex = 10
ChatGui.AnchorPoint = Vector2.new(0, 0)
ChatGui.Position = UDim2.new(0, 10, 0, 80)
ChatGui.Size = UDim2.new(0, 400, 0.25, 0)
ChatGui.Parent = screenGui
bindRuntime(ChatGui, {
	BackgroundColor3 = "background",
	BackgroundTransparency = "bgtransparency",
})

local UIScaleDetector = Instance.new("UIScaleDetector")
UIScaleDetector.Parent = ChatGui

UIScaleDetector.newSizeCallback = function(newSize, newPos)
	springTarget(ChatGui, {
		Position = newPos,
		Size = newSize,
	})
end

local content = Instance.new("ScrollingFrame")
content.BackgroundTransparency = 1
content.Size = UDim2.new(1, 0, 1, -50)
content.AutoScrollSize = false
content.ClipsDescendants = true
content.Parent = ChatGui

local padding = Instance.new("UIPadding")
padding.Padding = UDim2.new(0, 15, 0, 15)
padding.Parent = content

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 4)
layout.FillDirection = Enum.FillDirection.Vertical
layout.Parent = content

local TextService = game:GetService("TextService")

local shadow = Instance.new("UIShadow")
shadow.Transparency = 0.9
shadow.Parent = ChatGui
bindRuntime(shadow, {
	Color = "shadow",
	Transparency = "shadowtransparency",
})

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 25)
Corner.Parent = ChatGui
bindCorner(Corner, "bubblecorner")

local Input = Instance.new("TextBox")
Input.AnchorPoint = Vector2.new(0, 1)
Input.Position = UDim2.new(0, 10, 1, -10)
Input.Size = UDim2.new(1, -20, 0, 40)
Input.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
Input.BackgroundTransparency = 0.5
Input.BorderWidth = 0
Input.TextColor3 = Color3.new(1, 1, 1)
Input.Text = "Hello world"
Input.ClearTextOnFocus = false
Input.TextXAlignment = Enum.TextXAlignment.Left
Input.TextYAlignment = Enum.TextYAlignment.Top
Input.TextSize = 14
Input.TextWrapped = true
Input.CornerRadius = 0.5
Input.Parent = ChatGui
bindRuntime(Input, {
	BackgroundColor3 = "secondarybackground",
	BackgroundTransparency = "chatinputtransparency",
	TextColor3 = "text",
	CornerRadius = "chatinputcornerradius",
	Font = "font",
})

Input.OnSubmit = function()
	chatRemote:FireServer(Input.Text)
	Input.Text = ""
end

local function openChat()
	chatOpen = true
	springTarget(ChatGui, {
		GroupTransparency = 0,
		Size = UDim2.new(0, 400, 0.25, 0),
	})

	springTarget(Input, {
		BackgroundTransparency = runtime("chatinputtransparency", 0.5),
		Size = UDim2.new(1, -20, 0, 40),
		TextSize = 14,
	})
end

local function closeChat()
	chatOpen = false
	springTarget(Input, {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -20, 0, 0),
		TextSize = 0,
	})

	springTarget(ChatGui, {
		GroupTransparency = 1,
		Size = UDim2.new(0, 0, 0, 0),
	})
end

manager:subscribe("#runtime", "bgtransparency", function()
	if chatOpen then
		openChat()
	end
end)
manager:subscribe("#runtime", "chatinputtransparency", function()
	if chatOpen then
		openChat()
	end
end)
manager:subscribe("#runtime", "damping", function()
	if chatOpen then
		openChat()
	else
		closeChat()
	end
end)
manager:subscribe("#runtime", "frequency", function()
	if chatOpen then
		openChat()
	else
		closeChat()
	end
end)

signal:Fire("NewTopbarButton", {
	icon = "chat-icon",
	open_callback = function()
		openChat()
	end,

	routeName = "chat",

	close_callback = function()
		closeChat()
	end,
})

if chatRemote then
	local function formatMessage(msg)
		local localPlayer = Players.LocalPlayer

		return msg:gsub("@(%w+)", function(username)
			if username == localPlayer.Name then
				return '<font color="rgb(255,200,0)">@' .. username .. "</font>"
			end

			local plr = Players:FindFirstChild(username)
			if plr then
				return '<font color="rgb(0,170,255)">@' .. username .. "</font>"
			end

			return "@" .. username
		end)
	end

	chatRemote.OnClientEvent:Connect(function(chatData)
		local player = Players:GetPlayerByName(chatData.name)
		local message = chatData.message
		local color = chatData.color

		local textSize = TextService.MeasureText(message, runtime("font", Enum.Font.DefaultEngineFont), 18, 1)
		ChatService.OnMessageRecieveClient:Fire(player, message)

		if ChatService.OnMessageClientReplace then
			message = ChatService.OnMessageClientReplace(player, message) or message
		end

		local label = Instance.new("TextLabel")
		label.BackgroundTransparency = 1
		label.TextColor3 = Color3.new(1, 1, 1)
		label.RichText = true
		label.Text = formatMessage(message)
		label.LayoutOrder = #content:GetChildren() + 1
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.TextYAlignment = Enum.TextYAlignment.Top
		label.AutomaticSize = Enum.AutomaticSize.XY
		label.Size = UDim2.new(0, textSize.X, 0, textSize.Y)
		label.TextSize = 18
		label.TextWrapped = true
		label.Parent = content
		bindRuntime(label, {
			TextColor3 = "text",
			Font = "font",
		})

		content.CanvasSize += textSize.Y + 30
	end)
end
