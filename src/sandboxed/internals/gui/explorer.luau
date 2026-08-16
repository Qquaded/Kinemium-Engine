local RunService = game:GetService("RunService")
local StudioThemeService = game:GetService("StudioThemeService")
local Immco = require("@Immco")
local theme = StudioThemeService.SelectedTheme
local Selection = game:GetService("Selection")
local Argon = require("@Argon")

repeat
	task.wait()
until game.CoreGui:FindFirstChild("Studio")

local Explorer = Instance.new("Frame")
Explorer.Name = "Explorer"
Explorer.Size = theme.ExplorerCoordinates.Size
Explorer.Position = theme.ExplorerCoordinates.Position
Explorer.Parent = game.CoreGui:FindFirstChild("Studio")
Explorer.BackgroundTransparency = 1

local iconCache = {}
local iconPath = "./src/assets/images/icons/"

local arrowRight = Argon:CreateImageFromPath(iconPath .. "ArrowRight.png")
local expandedIcon = Argon:CreateImageFromPath(iconPath .. "ArrowDown.png")
local expanded = {}

local uiScale = 1

local textSize = 16 * uiScale
local imageSize = 16 * uiScale
local rowHeight = 20 * uiScale
local indentSize = 16 * uiScale
local contentPadding = 10 * uiScale

local serviceOrder = {
	"Workspace",
	"Players",
	"Lighting",
	"ReplicatedFirst",
	"ReplicatedStorage",
	"ServerScriptService",
	"ServerStorage",
	"StarterGui",
	"StarterPack",
	"StarterPlayer",
	"Teams",
	"SoundService",
	"Chat",
	"TextChatService",
	"MaterialService",
	"TestService",
}

renderer.Pool.new("2d", function()
	local dt = renderer.RuntimeLibrary.dt
	local absolutePosition = Explorer.AbsolutePosition
	local absoluteSize = Explorer.AbsoluteSize

	Explorer.Size = theme.ExplorerCoordinates.Size
	Explorer.Position = theme.ExplorerCoordinates.Position

	if not absolutePosition then
		return
	end
	if not absoluteSize then
		return
	end

	Immco.Widget({
		x = absolutePosition.X,
		y = absolutePosition.Y + 5,
		width = absoluteSize.X,
		height = absoluteSize.Y,
		title = "Explorer",
		theme = theme,
		engine_window = renderer.Window,

		callback = function(params)
			local y = params.y + 20

			local function renderInstance(instance, depth)
				if instance.ExplorerHidden then
					return
				end

				local children = instance:GetChildren()
				local hasChildren = false

				for _, child in ipairs(children) do
					if not child.ExplorerHidden then
						hasChildren = true
						break
					end
				end

				if not iconCache[instance.ClassName] then
					local path = iconPath .. instance.ClassName .. ".png"
					iconCache[instance.ClassName] = Argon:CreateImageFromPath(path)
				end

				local indent = params.x + contentPadding + (depth * indentSize)
				local rowY = y

				local isSelected = table.find(Selection.Get(), instance) ~= nil

				if isSelected then
					local x = params.x + (6 * uiScale)
					local y = rowY - (18 * uiScale)
					local width = params.width - (12 * uiScale)
					local height = 25 * uiScale
					local border = 5 * uiScale

					Argon:Save(renderer.Window)

					Argon:ClipRoundRect(renderer.Window, {
						x = x,
						y = y,
						width = width,
						height = height,
					}, 6, 6)

					Argon:DrawRectangle(renderer.Window, {
						x = x,
						y = y,
						width = width,
						height = height,
						Color = Argon:RGBA(45, 125, 255, 255),
					})

					Argon:Restore(renderer.Window)

					Argon:Save(renderer.Window)

					Argon:ClipRoundRect(renderer.Window, {
						x = x + border,
						y = y + border,
						width = width - border * 2,
						height = height - border * 2,
					}, 4, 4)

					Argon:DrawRectangle(renderer.Window, {
						x = x + border,
						y = y + border,
						width = width - border * 2,
						height = height - border * 2,
						Color = Argon:RGBA(45, 125, 255, 100),
					})

					Argon:Restore(renderer.Window)
				end

				if
					renderer:HasClicked({
						x = params.x + (6 * uiScale),
						y = rowY - (18 * uiScale),
						width = params.width - (12 * uiScale),
						height = rowHeight,
					})
				then
					Selection.Set({ instance })
				end

				if hasChildren then
					local arrow = expanded[instance] and expandedIcon or arrowRight

					Immco.Image({
						x = indent,
						y = rowY - (14 * uiScale),
						width = imageSize,
						height = imageSize,
						Image = arrow,
						theme = theme,
						engine_window = renderer.Window,
					}, dt)

					if
						renderer:HasClicked({
							x = indent,
							y = rowY - (14 * uiScale),
							width = imageSize,
							height = imageSize,
						})
					then
						expanded[instance] = not expanded[instance]
					end
				end

				Immco.Image({
					x = indent + imageSize,
					y = rowY - (14 * uiScale),
					width = imageSize,
					height = imageSize,
					Image = iconCache[instance.ClassName],
					theme = theme,
					engine_window = renderer.Window,
				}, dt)

				Immco.Text({
					x = indent + (36 * uiScale),
					y = rowY,
					TextSize = textSize,
					theme = theme,
					Font = Argon:CreateFont(theme.Font),
					text = instance.Name,
					Color = theme.TextColor,
					engine_window = renderer.Window,
				}, dt)

				y += rowHeight

				if expanded[instance] then
					for _, child in ipairs(children) do
						renderInstance(child, depth + 1)
					end
				end
			end

			local services = game:GetChildren()

			local order = {}
			for index, name in ipairs(serviceOrder) do
				order[name] = index
			end

			table.sort(services, function(a, b)
				local aOrder = order[a.Name]
				local bOrder = order[b.Name]

				if aOrder and bOrder then
					return aOrder < bOrder
				elseif aOrder then
					return true
				elseif bOrder then
					return false
				end

				return a.Name < b.Name
			end)

			for _, service in ipairs(services) do
				renderInstance(service, 0)
			end
		end,
	}, dt)
end)
