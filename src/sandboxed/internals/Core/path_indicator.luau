local indicator = Instance.new("ScreenGui")

local RunService = game:GetService("RunService")
local Selection = game:GetService("Selection")
local TextService = game:GetService("TextService")

local LocalPlayer = game.Players.LocalPlayer
indicator.Parent = LocalPlayer.PlayerGui

local label = Instance.new("TextLabel")
label.TextColor3 = Color3.new(1, 1, 1)
label.BackgroundColor3 = Color3.new(0, 0, 0)
label.BackgroundTransparency = 0.4
label.TextSize = 15
label.Position = UDim2.new(0, 10, 0, 50)
label.TextXAlignment = Enum.TextXAlignment.Center
label.Parent = indicator

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = label

RunService.RenderStepped:Connect(function()
	local object = Selection:Get()[1]
	if object then
		local fullName = object:GetFullName()
		local replaced = string.gsub(fullName, "%.", " > ")
		local size = TextService.MeasureText(replaced, Enum.Font.DefaultEngineFont, 15, 1)

		label.Size = UDim2.new(0, size.X + 20, 0, size.Y + 25)
		label.Text = replaced
	end
end)
