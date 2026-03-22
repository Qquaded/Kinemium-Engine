-- devcell

if IsHeadless then
	return
end
local Chat = Instance.new("ScreenGui")
Chat.Name = "Chat"
Chat.Parent = game.Players.LocalPlayer.PlayerGui

local chatFrame = Instance.new("CanvasGroup")
chatFrame.AnchorPoint = Vector2.new(0, 1)
chatFrame.BackgroundColor3 = Color3.new(0, 0, 0)
chatFrame.BackgroundTransparency = 0.5
chatFrame.Size = UDim2.new(0, 500, 0, 250)
chatFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
--chatFrame.Parent = Chat

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 154)
UICorner.Parent = chatFrame

local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, 0, 1, 0)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.CanvasSize = 800
ScrollingFrame.AutoScrollSize = false
ScrollingFrame.ScrollBarThickness = 8
ScrollingFrame.Parent = chatFrame

local BlurEffect = Instance.new("BlurEffect")
BlurEffect.Parent = chatFrame

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 10)
Corner.Parent = chatFrame

local ChatBox = Instance.new("TextBox")
ChatBox.Size = UDim2.new(1, 0, 0, 50)
ChatBox.AnchorPoint = Vector2.new(0.5, 0)
ChatBox.Position = UDim2.new(0.5, 0, 1, 0)
ChatBox.Parent = Chat

local messageHeight = 15
local numMessages = 10
for i = 1, numMessages do
	local exampleFrame = Instance.new("TextLabel")
	exampleFrame.Size = UDim2.new(0, 480, 0, messageHeight)
	exampleFrame.Position = UDim2.new(0, 10, 0, (i - 1) * (messageHeight + 5))
	exampleFrame.BackgroundTransparency = 1
	exampleFrame.Text = "Hello World"
	exampleFrame.Font = Enum.Font.Filted
	exampleFrame.TextXAlignment = Enum.TextXAlignment.Left
	exampleFrame.TextColor3 = Color3.new(1, 1, 1)
	exampleFrame.TextSize = 18
	exampleFrame.Parent = ScrollingFrame
end
