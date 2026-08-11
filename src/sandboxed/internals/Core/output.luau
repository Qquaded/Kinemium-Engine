-- devcell

local KinemiumRaylib = game:GetService("KinemiumRaylib")
local KinemiumFontService = game:GetService("KinemiumFontService")

local RunService = game:GetService("RunService")
if RunService:IsServer() then
	return
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local rl = KinemiumRaylib.GetLib()
local LogService = game:GetService("LogService")
local structs = KinemiumRaylib.GetStructs()
local vend = KinemiumFontService.GetDefaultFont()
local Theme = game:GetService("StudioThemeService").SelectedTheme
local arectlib = require("@arect")
local scrollableComp
local scrollTarget = 0
local repr = require("@repr")

local TextColor = Theme.TextColor:ToRaylib(Theme.TextTransparency)
local pumpTabData = {}
local pumpTabScrollables = {}
local lastLogCount = 0
local lastMaxScroll = 0
local LOG_FONT_SIZE = 13
local LOG_FONT_SPACING = 1
local MIN_CELL_HEIGHT = 25

local logLayoutCache = {}

local function getLineHeight()
	local size = rl.MeasureTextEx(vend, "Ag", LOG_FONT_SIZE, LOG_FONT_SPACING)
	return math.max(16, math.floor(size.y + 2))
end

local function wrapTextToWidth(text, maxWidth)
	local lines = {}
	local lineWidthLimit = math.max(32, maxWidth)
	local source = tostring(text or "")

	local function measureWidth(s)
		return rl.MeasureTextEx(vend, s, LOG_FONT_SIZE, LOG_FONT_SPACING).x
	end

	for rawLine in (source .. "\n"):gmatch("(.-)\n") do
		if rawLine == "" then
			table.insert(lines, "")
		else
			local remaining = rawLine
			while #remaining > 0 do
				if measureWidth(remaining) <= lineWidthLimit then
					table.insert(lines, remaining)
					break
				end

				local cut = 1
				local lastWhitespace = nil
				for i = 1, #remaining do
					local ch = remaining:sub(i, i)
					if ch == " " or ch == "\t" then
						lastWhitespace = i
					end

					local part = remaining:sub(1, i)
					if measureWidth(part) > lineWidthLimit then
						if lastWhitespace and lastWhitespace > 1 then
							cut = lastWhitespace
						else
							cut = math.max(1, i - 1)
						end
						break
					end
					cut = i
				end

				local chunk = remaining:sub(1, cut)
				if chunk == "" then
					chunk = remaining:sub(1, 1)
					cut = 1
				end

				table.insert(lines, chunk)
				remaining = remaining:sub(cut + 1)
			end
		end
	end

	if #lines == 0 then
		table.insert(lines, "")
	end

	return lines
end

local function stringifyLogMessage(message)
	if message == nil then
		return "nil"
	end

	if type(message) == "string" then
		return message
	end

	if type(message) == "table" then
		local ok, asString = pcall(repr, message)
		if ok and type(asString) == "string" then
			return asString
		end
		return "<table>"
	end

	local ok, asString = pcall(tostring, message)
	if ok then
		return asString
	end
	return "<unprintable>"
end

local syntax_highlighter = require("@kilang_sh")
local syntax_autocomplete = require("@luau_autocomplete")
local aereon = require("@Aereon")

local textbox = aereon.textbox(Theme, game)

if game.Context ~= Enum.GameContext.Editor then
	return
end

if FlagExists("headless") then
	return
end

local ScriptContext = game:GetService("ScriptContext")

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
		ScriptContext.RunSource(new)
	end,
})

local window = aereon.window(game, nil, 1)

window.focused = function(window)
	_G.IsHoveringOnWindow = true
end

window.unfocused = function(window)
	_G.IsHoveringOnWindow = false
end

local function createPumpTabRenderFn(tabName)
	return function(windowData)
		local dt = rl.GetFrameTime()
		local titleBarH = windowData._titleBarH or 28
		local tabBarH = windowData._tabBarH or 28
		local contentOffsetY = titleBarH + tabBarH
		local winX = windowData.x
		local winY = windowData.y + contentOffsetY
		local winWidth, winHeight = windowData.width, windowData.height
		local padding = 2
		local lineHeight = getLineHeight()
		local lines = pumpTabData[tabName] or {}
		local textWidth = math.max(64, winWidth - 26)

		local listHeight = math.max(0, winHeight - contentOffsetY - padding * 2)
		local totalHeight = 0
		local wrappedLines = {}
		for _, line in ipairs(lines) do
			local wrapped = wrapTextToWidth(line, textWidth)
			table.insert(wrappedLines, wrapped)
			totalHeight = totalHeight + math.max(MIN_CELL_HEIGHT, #wrapped * lineHeight + 8) + padding
		end

		local listRect = {
			x = winX,
			y = winY,
			width = winWidth,
			height = listHeight,
		}

		local consoleContent
		consoleContent = {
			get_rect = function()
				return arectlib.new(0, 0, textWidth + 16, totalHeight)
			end,
			set = function(prop, value)
				if prop == "obj_rect" then
					consoleContent.rect = value
				end
			end,
			render = function(dt)
				local r = consoleContent.rect
				local currentY = r.y
				for i, wrapped in ipairs(wrappedLines) do
					local cellHeight = math.max(MIN_CELL_HEIGHT, #wrapped * lineHeight + 8)
					local cellRect = arectlib.new(winX + 5, currentY, winWidth - 10, cellHeight)
					if currentY + cellHeight >= listRect.y and currentY <= listRect.y + listRect.height then
						for lineIndex, lineText in ipairs(wrapped) do
							local textY = cellRect.y + 4 + (lineIndex - 1) * lineHeight
							rl.DrawTextEx(
								vend,
								lineText,
								vector.create(cellRect.x + 8, textY),
								LOG_FONT_SIZE,
								LOG_FONT_SPACING,
								TextColor
							)
						end
					end
					currentY = currentY + cellHeight + padding
				end
			end,
		}

		if not pumpTabScrollables[tabName] then
			pumpTabScrollables[tabName] = aereon.gui.scrollable({
				child = consoleContent,
				scrollbarWidth = 6,
				scrollbarColor = Theme.SecondaryBackgroundColor,
				scrollbarHoverColor = Theme.Accent,
				scrollbarBackgroundTransparency = 1,
			})
		end
		local scrollable = pumpTabScrollables[tabName]
		local maxScroll = math.max(0, totalHeight - listRect.height)
		scrollable.set("scrollTarget", maxScroll)
		scrollable.set("obj_rect", arectlib.new(listRect.x, listRect.y, listRect.width, listRect.height))
		scrollable.set("contentHeight", totalHeight)
		scrollable.render(dt)
	end
end

local function create_window(title, frame)
	local initialPos = frame.AbsolutePosition or vector.create(0, 0)
	local initialSize = frame.AbsoluteSize or vector.create(800, 200)

	local myWindow = window.create({
		title = title,
		x = initialPos.X,
		y = initialPos.Y,
		width = initialSize.X,
		height = initialSize.Y,
		DisableClipping = true,
		tabs = {
			{
				name = "Output",
				render = function(windowData)
					local titleBarH = windowData._titleBarH or 28
					local tabBarH = windowData._tabBarH or 28
					local contentOffsetY = titleBarH + tabBarH
					local winX = windowData.x
					local winY = windowData.y + contentOffsetY
					local winWidth, winHeight = windowData.width, windowData.height
					local padding = 2
					local dt = rl.GetFrameTime()
					local lineHeight = getLineHeight()

					local logs = LogService.GetLogHistory() or {}
					local logCount = #logs
					local textBoxHeight = 30
					local listRect = {
						x = winX,
						y = winY,
						width = winWidth,
						height = math.max(0, winHeight - contentOffsetY - textBoxHeight - padding * 2),
					}
					local textWidth = math.max(64, winWidth - 26)

					local usedCacheKeys = {}
					local totalHeight = 0
					for i, log in ipairs(logs) do
						if log then
							local logColor = TextColor
							if log.type == "print" then
								logColor = structs.Color:new({ r = 200, g = 200, b = 200, a = 255 })
							elseif log.type == "warn" then
								logColor = structs.Color:new({ r = 255, g = 200, b = 0, a = 255 })
							elseif log.type == "error" then
								logColor = structs.Color:new({ r = 255, g = 50, b = 50, a = 255 })
							end

							local message = stringifyLogMessage(log.message)
							local ts = log.time and os.date("%H:%M:%S", log.time) or "--:--:--"
							local text = string.format("[%s] %s", ts, message)

							local cacheKey = log.id or i
							usedCacheKeys[cacheKey] = true
							local cacheEntry = logLayoutCache[cacheKey]
							if not cacheEntry or cacheEntry.text ~= text or cacheEntry.width ~= textWidth then
								local wrapped = wrapTextToWidth(text, textWidth)
								cacheEntry = {
									text = text,
									width = textWidth,
									lines = wrapped,
									lineCount = #wrapped,
									height = math.max(MIN_CELL_HEIGHT, #wrapped * lineHeight + 8),
									color = logColor,
								}
								logLayoutCache[cacheKey] = cacheEntry
							else
								cacheEntry.color = logColor
							end

							totalHeight = totalHeight + cacheEntry.height + padding
						end
					end

					for cacheKey in pairs(logLayoutCache) do
						if not usedCacheKeys[cacheKey] then
							logLayoutCache[cacheKey] = nil
						end
					end

					if not scrollableComp then
						local _contentObj = {}
						_contentObj.rect = nil
						_contentObj._logs = logs
						_contentObj._logLayoutCache = logLayoutCache
						_contentObj._listRect = listRect
						_contentObj._winX = winX
						_contentObj._winWidth = winWidth
						_contentObj._totalHeight = totalHeight
						_contentObj._lineHeight = lineHeight
						_contentObj._padding = padding
						_contentObj.get_rect = function()
							return arectlib.new(0, 0, _contentObj._winWidth, _contentObj._totalHeight)
						end
						_contentObj.set = function(prop, value)
							if prop == "obj_rect" then
								_contentObj.rect = value
							end
						end
						_contentObj.render = function(dt)
							local r = _contentObj.rect
							if not r then
								return
							end
							local _logs = _contentObj._logs
							local _cache = _contentObj._logLayoutCache
							local _lr = _contentObj._listRect
							local _wx = _contentObj._winX
							local _ww = _contentObj._winWidth
							local _lh = _contentObj._lineHeight
							local _pad = _contentObj._padding
							local currentY = r.y
							local visibleBottom = _lr.y + _lr.height
							for i, log in ipairs(_logs) do
								if log then
									local cacheKey = log.id or i
									local cacheEntry = _cache[cacheKey]
									if cacheEntry then
										local cellBottom = currentY + cacheEntry.height
										if cellBottom >= _lr.y and currentY <= visibleBottom then
											local logRect = arectlib.new(_wx + 5, currentY, _ww - 10, cacheEntry.height)
											for lineIndex, lineText in ipairs(cacheEntry.lines) do
												local textY = logRect.y + 4 + (lineIndex - 1) * _lh
												rl.DrawTextEx(
													vend,
													lineText,
													vector.create(logRect.x + 8, textY),
													LOG_FONT_SIZE,
													LOG_FONT_SPACING,
													cacheEntry.color
												)
											end
											if arectlib.MouseIsInRect(logRect) then
												rl.DrawLineEx(
													vector.create(logRect.x, logRect.y + cacheEntry.height),
													vector.create(
														logRect.x + logRect.width,
														logRect.y + cacheEntry.height
													),
													1,
													Theme.Accent:ToRaylib(0)
												)
											end
										elseif currentY > visibleBottom then
											break -- nothing below is visible, early out
										end
										currentY = currentY + cacheEntry.height + _pad
									end
								end
							end
						end
						scrollableComp = aereon.gui.scrollable({
							child = _contentObj,
							scrollbarWidth = 6,
							scrollbarColor = Theme.SecondaryBackgroundColor,
							scrollbarHoverColor = Theme.Accent,
							scrollbarBackgroundTransparency = 1,
						})
						-- Store reference to content object on the scrollable so we can update it each frame
						scrollableComp._contentObj = _contentObj
					end

					-- Update the persistent content object with the latest per-frame data
					local _co = scrollableComp._contentObj
					if _co then
						_co._logs = logs
						_co._logLayoutCache = logLayoutCache
						_co._listRect = listRect
						_co._winX = winX
						_co._winWidth = winWidth
						_co._totalHeight = totalHeight
						_co._lineHeight = lineHeight
						_co._padding = padding
					end

					local maxScroll = math.max(0, totalHeight - listRect.height)
					local wasAtBottom = math.abs(scrollTarget - lastMaxScroll) < 2

					if logCount ~= lastLogCount then
						lastLogCount = logCount
						if wasAtBottom then
							scrollableComp.set("scrollTarget", maxScroll)
						end
					end

					lastMaxScroll = maxScroll
					scrollableComp.set(
						"obj_rect",
						arectlib.new(listRect.x, listRect.y, listRect.width, listRect.height)
					)
					scrollableComp.set("contentHeight", totalHeight)
					scrollableComp.render(dt)

					box:drawWithExtras(
						windowData.x + padding,
						windowData.y + windowData.height - textBoxHeight - padding,
						windowData.width - 2 * padding,
						textBoxHeight
					)
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

local renderer = KinemiumRaylib.GetRenderer()

local StudioThemeService = game:GetService("StudioThemeService")

game.EngineSignal:Connect(function(prop, data)
	if prop == "NewOutputTab" then
		table.insert(propback.tabs, data)
	elseif prop == "PumpOutputToTab" then
		local tabName = data.tab
		local rawData = data.data
		if type(tabName) ~= "string" or type(rawData) ~= "table" then
			return
		end

		if not pumpTabData[tabName] then
			pumpTabData[tabName] = {}
			local tabExists = false
			for _, t in ipairs(propback.tabs) do
				if t.name == tabName then
					tabExists = true
					break
				end
			end
			if not tabExists then
				table.insert(propback.tabs, {
					name = tabName,
					render = createPumpTabRenderFn(tabName),
				})
			end
		end

		for _, line in ipairs(rawData) do
			table.insert(pumpTabData[tabName], tostring(line))
		end
	end
end)

renderer.Pool.new("2d", function(data)
	local dt = rl.GetFrameTime()
	local mainTheme = StudioThemeService.SelectedTheme

	Theme = game:GetService("StudioThemeService").SelectedTheme

	vend = KinemiumFontService.GetDefaultFont()

	if game.Context == Enum.GameContext.Editor then
		window.update(dt)
		window.draw(dt, mainTheme, renderer.Lib2d)
	end

	frame.Position = Theme.WindowConfig.Output.position
	frame.AnchorPoint = Theme.WindowConfig.Output.anchorPoint
	frame.Size = Theme.WindowConfig.Output.size

	if rl.IsWindowResized() == 1 then
		if not frame.AbsolutePosition then
			return
		end
		propback.x = frame.AbsolutePosition.X
		propback.y = frame.AbsolutePosition.Y
		propback.width = frame.AbsoluteSize.X
		propback.height = frame.AbsoluteSize.Y
	end
end)

window.stepped = function(windowData)
	if windowData.title == "Console" then
		if windowData.x == 0 and windowData.y == 0 and frame.AbsolutePosition and frame.AbsolutePosition.X ~= 0 then
			if frame.AbsolutePosition and frame.AbsoluteSize then
				windowData.x = frame.AbsolutePosition.X
				windowData.y = frame.AbsolutePosition.Y
				windowData.width = frame.AbsoluteSize.X
				windowData.height = frame.AbsoluteSize.Y
			end
		end
	end
end
