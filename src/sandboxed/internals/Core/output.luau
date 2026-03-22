-- devcell

local KinemiumRaylib = game:GetService("KinemiumRaylib")
local KinemiumIconLoader = game:GetService("KinemiumIconLoader")
local KinemiumFontService = game:GetService("KinemiumFontService")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local rl = KinemiumRaylib.lib
local LogService = game:GetService("LogService")
local structs = KinemiumRaylib.structs
local vend = KinemiumFontService.GetDefaultFont()
local Theme = game:GetService("StudioThemeService").SelectedTheme
local arectlib = require("@Arect")(rl)
local scrollOffset = 0

local TextColor = Theme.TextColor:ToRaylib(Theme.TextTransparency)
local lastLogCount = 0

local syntax_highlighter = require("@syntax_highlighter")
local syntax_autocomplete = require("@syntax_autocomplete")
local aereon = require("@Aereon")
local raylib = require("@raylib")

local textbox = aereon.textbox(Theme, game)

local kilang = require("@Kilang")

if game.Context ~= Enum.GameContext.Editor then
	return
end

if FlagExists("client") then
	return
end

if FlagExists("cli") then
	return
end

if FlagExists("headless") then
	return
end

local box = textbox.new({
	multiline = false,
	placeholder = "Enter Kilang code here..",
	fontSize = 16,
	font = vend,
	backgroundColor = Theme.SecondaryBackgroundColor,
	borderColor = Theme.SecondaryBackgroundColor,
	syntaxHighlighter = syntax_highlighter.highlight,
	autocompleteProvider = syntax_autocomplete,

	onSubmit = function(new)
		kilang:execute(new, {
			SecurityCapabilities = Enum.SecurityCapabilities.Internals,
		})
	end,
})

local aereon = import("@Aereon")
local window = aereon.window(game, nil, 1)

local blacklisted = {
	"Children",
}

local function create_window(title, frame)
	repeat
		task.wait()
	until frame.AbsolutePosition and frame.AbsoluteSize
	local myWindow = window.create({
		title = title,
		x = frame.AbsolutePosition.X,
		y = frame.AbsolutePosition.Y,
		width = frame.AbsoluteSize.X,
		height = frame.AbsoluteSize.Y,
		tabs = {
			{
				name = "Output",
				render = function(windowData)
					local winX, winY = windowData.x, windowData.y + 30
					local winWidth, winHeight = windowData.width, windowData.height
					local cellHeight = 25
					local padding = 2

					local logs = LogService.GetLogHistory()
					local logCount = #logs

					if logCount ~= lastLogCount then
						lastLogCount = logCount
						local totalHeight = logCount * (cellHeight + padding)
						if totalHeight > winHeight then
							scrollOffset = totalHeight - winHeight
						else
							scrollOffset = 0
						end
					end

					for i, log in ipairs(logs) do
						local cellY = winY + (i - 1) * (cellHeight + padding) - scrollOffset
						local rect = arectlib.new(winX + 5, cellY, winWidth - 10, cellHeight)

						if cellY + cellHeight >= winY and cellY <= winY + winHeight then
							local logColor = TextColor
							if log.type == "print" then
								logColor = structs.Color:new({ r = 200, g = 200, b = 200, a = 255 })
							elseif log.type == "warn" then
								logColor = structs.Color:new({ r = 255, g = 200, b = 0, a = 255 })
							elseif log.type == "error" then
								logColor = structs.Color:new({ r = 255, g = 50, b = 50, a = 255 })
							end

							if not log or not log.message or not log.time then
								return
							end

							local ts = os.date("%H:%M:%S", log.time)
							local text = string.format("[%s] %s", ts, log.message)

							rl.DrawTextEx(vend, text, vector.create(rect.x + 8, rect.y + 4), 17, 1, logColor)

							if arectlib.MouseIsInRect(rect) then
								rl.DrawLineEx(
									vector.create(rect.x, rect.y + cellHeight),
									vector.create(rect.x + rect.width, rect.y + cellHeight),
									1,
									Theme.Accent:ToRaylib(0)
								)
							end
						end
					end

					box:drawWithExtras(
						windowData.x + padding,
						windowData.y + windowData.height - 30 - padding,
						windowData.width - 2 * padding,
						30
					)
				end,
			},
			{
				name = "Stack Trace",
				render = function(windowData)
					-- Tab 2 content
				end,
			},
			{
				name = "Debugger",
				render = function(windowData)
					-- Tab 2 content
				end,
			},
			{
				name = "Profiler",
				render = function(windowData)
					-- Tab 2 content
				end,
			},
		},
	})
	return myWindow
end

local function create_window_back(screenGui, title, AnchorPoint, size)
	local frame = Instance.new("Frame")
	frame.Position = Theme.WindowConfig.Output.position
	frame.AnchorPoint = AnchorPoint
	frame.Size = size or UDim2.new(0, 400, 0.6, 0)
	frame.BackgroundColor3 = Color3.new(1, 1, 1)
	frame.BackgroundTransparency = 1
	frame.Parent = screenGui

	return create_window(title, frame), frame
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Console"
screenGui.Parent = LocalPlayer.PlayerGui

local propback, frame =
	create_window_back(screenGui, "Console", Theme.WindowConfig.Output.anchorPoint, Theme.WindowConfig.Output.size)

window.stepped = function(windowData)
	if windowData.title == "Console" then
		if game.Context ~= Enum.GameContext.Editor then
			return
		end

		if rl.IsWindowResized() == 1 then
			windowData.x = frame.AbsolutePosition.X
			windowData.y = frame.AbsolutePosition.Y
			windowData.width = frame.AbsoluteSize.X
			windowData.height = frame.AbsoluteSize.Y
		end
	end
end
