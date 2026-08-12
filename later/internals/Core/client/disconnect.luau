local NetworkService = game:GetService("NetworkService")
local Players = game:GetService("Players")

local RunService = game:GetService("RunService")
if RunService:IsServer() then
	return
end

local Gui = Instance.new("ScreenGui")
Gui.Parent = Players.LocalPlayer.PlayerGui

local TextLabel = Instance.new("TextLabel")
TextLabel.Size = UDim2.new(1, 0, 0, 30)
TextLabel.Text = "Disconnected"
TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.TextSize = 15
TextLabel.BackgroundColor3 = Color3.new(1, 0, 0)
TextLabel.TextXAlignment = Enum.TextXAlignment.Center
TextLabel.TextYAlignment = Enum.TextYAlignment.Center
TextLabel.Position = UDim2.new(0.5, 0, 1, 0)
TextLabel.AnchorPoint = Vector2.new(0.5, 1)
TextLabel.Visible = false
TextLabel.Parent = Gui

repeat
	task.wait()
until NetworkService.Disconnected

NetworkService.Disconnected:Connect(function(reason)
	TextLabel.Visible = true
	TextLabel.Text = `Disconnected from server. Reason: {reason}`
end)
