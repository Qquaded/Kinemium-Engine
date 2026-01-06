local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Gui"
ScreenGui.Parent = game:GetService("Players").LocalPlayer.PlayerGui

--[[
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(1, 0, 0.2, 0)
Frame.Position = UDim2.new(0.5, 0, 1, 0)
Frame.AnchorPoint = Vector2.new(0.5, 1)
Frame.BackgroundColor = Color3.new(0.14902, 0.14902, 0.14902)
Frame.Anchored = true
Frame.Parent = ScreenGui

local UIPhysicsService = game:GetService("UIPhysicsService")

local success, result = pcall(function()
	UIPhysicsService.init(ScreenGui)
end)

if not success then
	warn(result)
end
--]]
