--[[ cube
local RunService = game:GetService("RunService")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EditableImageDemoGui"
screenGui.Parent = game.Players.LocalPlayer.PlayerGui

local imageLabel = Instance.new("ImageLabel")
imageLabel.Size = UDim2.new(0, 512, 0, 512)
imageLabel.Position = UDim2.new(0.5, -256, 0.5, -256) -- center on screen
imageLabel.BackgroundTransparency = 1
imageLabel.Parent = screenGui

local editableImage = Instance.new("EditableImage")
editableImage.Size = Vector2.new(512, 512)

imageLabel.Image = editableImage
editableImage.Parent = imageLabel

local angle = 0

local vertices = {
	Vector3.new(-1, -1, -1),
	Vector3.new(1, -1, -1),
	Vector3.new(1, 1, -1),
	Vector3.new(-1, 1, -1),
	Vector3.new(-1, -1, 1),
	Vector3.new(1, -1, 1),
	Vector3.new(1, 1, 1),
	Vector3.new(-1, 1, 1),
}

local edges = {
	{ 1, 2 },
	{ 2, 3 },
	{ 3, 4 },
	{ 4, 1 },
	{ 5, 6 },
	{ 6, 7 },
	{ 7, 8 },
	{ 8, 5 },
	{ 1, 5 },
	{ 2, 6 },
	{ 3, 7 },
	{ 4, 8 },
}

local function project(v)
	local dist = 3
	local z = v.Z + dist
	local scale = 150 / z
	return Vector2.new(256 + v.X * scale, 256 + v.Y * scale)
end

RunService.RenderStepped:Connect(function(dt)
	angle += dt

	editableImage:Sharpen()

	-- clear
	editableImage:DrawRectangle(Vector2.new(0, 0), Vector2.new(512, 512), Color3.new(0, 0, 0), 0)

	local projected = {}

	for i, v in ipairs(vertices) do
		-- rotate Y
		local cos = math.cos(angle)
		local sin = math.sin(angle)

		local x = v.X * cos - v.Z * sin
		local z = v.X * sin + v.Z * cos

		-- rotate X
		local cosX = math.cos(angle * 0.7)
		local sinX = math.sin(angle * 0.7)

		local y = v.Y * cosX - z * sinX
		z = v.Y * sinX + z * cosX

		projected[i] = project(Vector3.new(x, y, z))
	end

	for _, e in ipairs(edges) do
		local p1 = projected[e[1]]
--		local p2 = projected[e[2]]

--		editableImage:DrawLine(p1, p2, Color3.new(1, 1, 1), 0)
--	end
--end)
--]]
