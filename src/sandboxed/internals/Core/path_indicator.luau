local indicator = Instance.new("ScreenGui")

if IsClient or IsServer then
	return
end

local RunService = game:GetService("RunService")
local Selection = game:GetService("Selection")
local TextService = game:GetService("TextService")

local LocalPlayer = game.Players.LocalPlayer
indicator.Parent = LocalPlayer.PlayerGui

local label = Instance.new("TextLabel")
label.TextColor3 = Color3.new(1, 1, 1)
label.BackgroundColor3 = Color3.new(0, 0, 0)
label.BackgroundTransparency = 1
label.TextSize = 15
label.Position = UDim2.new(0, 10, 0, 50)
label.TextXAlignment = Enum.TextXAlignment.Left
label.Parent = indicator

ishared.path_enabled = true

RunService.RenderStepped:Connect(function()
	local object = Selection:Get()[1]
	if object then
		local chain = {}
		local current = object
		while current do
			table.insert(chain, 1, current)
			current = current.Parent
		end

		local parts = {}
		for _, ancestor in ipairs(chain) do
			if ancestor.Destroyed then
				continue
			end
			local icon = `  <image:./src/assets/images/icons/{ancestor.ClassName}.png,size:20,20>`
			table.insert(parts, icon .. " " .. ancestor.Name)
		end
		local replaced = table.concat(parts, " > ")

		local stripped = string.gsub(replaced, "<image:[^>]+>", "")
		local size = TextService.MeasureText(stripped, Enum.Font.DefaultEngineFont, 15, 1)
		label.Size = UDim2.new(0, size.X + 20, 0, size.Y + 25)
		label.Text = replaced
	end

	label.Position = ishared.ToolbarMinimized == true and UDim2.new(0, 10, 0, 30) or UDim2.new(0, 10, 0, 180)
	label.TextTransparency = ishared.path_enabled and 0 or 1
end)
