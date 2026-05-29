local RunService = game:GetService("RunService")
if RunService:IsServer() then
	return
end

local raylib = require("@raylib")
local MouseCursor = require("@Kinemium.MouseCursor")
local lib = raylib.lib
local aereon = require("@Aereon")
local gui = aereon.gui
local rect = require("@arect")
local transparent = Color3.new(1, 1, 1):ToRaylib(0.5)

local KinemiumFontService = game:GetService("KinemiumFontService")
local StudioThemeService = game:GetService("StudioThemeService")
local FileDialogService = game:GetService("FileDialogService")
local ProcessService = game:GetService("Process")
local NetworkService = game:GetService("NetworkService")
local localServerProcess = nil
local localServerInfo = nil
local localServerLogs = {}
local logBuffer = ""

local vend = KinemiumFontService.GetDefaultFont()
local boldFont = KinemiumFontService.GetBoldFont()
local arect = require("@arect")
local KinemiumIconLoader = game:GetService("KinemiumIconLoader")

local defaultKinemiumIcon = "./src/assets/images/kinemium/KinemiumWhite.png"
local logoIcon = KinemiumIconLoader.ToTexture(defaultKinemiumIcon)

local TextColor = StudioThemeService.SelectedTheme.TextColor:ToRaylib(StudioThemeService.SelectedTheme.TextTransparency)

local SecondaryBackgroundColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor
local screenx, screeny = lib.GetRenderWidth(), lib.GetScreenHeight()

KinemiumIconLoader.new("Add", "./src/assets/images/plus.png")

local addIcon = KinemiumIconLoader.ToTexture(KinemiumIconLoader.Get("Add"))

local textbox = aereon.textbox(StudioThemeService.SelectedTheme, game)

local usernameTextbox = textbox.new({
	multiline = false,
	placeholder = "Enter your username",
	fontSize = 16,
	font = vend,
	maxLength = 56,
})

local serverAddress_Textbox = textbox.new({
	multiline = false,
	placeholder = "Enter server address",
	fontSize = 16,
	font = vend,
	maxLength = 56,
})

local serverPort_Textbox = textbox.new({
	multiline = false,
	placeholder = "Enter server port",
	fontSize = 16,
	font = vend,
	maxLength = 56,
})

-- Host Server textboxes
local hostPortTextbox = textbox.new({
	multiline = false,
	placeholder = "1234",
	fontSize = 16,
	font = vend,
	maxLength = 5,
})

local maxPlayersTextbox = textbox.new({
	multiline = false,
	placeholder = "16",
	fontSize = 16,
	font = vend,
	maxLength = 3,
})

local nameTextbox = textbox.new({
	multiline = false,
	placeholder = "My Server",
	fontSize = 16,
	font = vend,
	maxLength = 32,
})

local motdTextbox = textbox.new({
	multiline = false,
	placeholder = "A Kinemium server is online.",
	fontSize = 16,
	font = vend,
	maxLength = 64,
})

local descriptionTextbox = textbox.new({
	multiline = false,
	placeholder = "Optional description",
	fontSize = 16,
	font = vend,
	maxLength = 128,
})

local mapTextbox = textbox.new({
	multiline = false,
	placeholder = "MapName",
	fontSize = 16,
	font = vend,
	maxLength = 32,
})

local modeTextbox = textbox.new({
	multiline = false,
	placeholder = "Survival",
	fontSize = 16,
	font = vend,
	maxLength = 32,
})

local commandTextbox
commandTextbox = textbox.new({
	multiline = false,
	placeholder = "Run Kilang code...",
	fontSize = 16,
	font = vend,
	maxLength = 128,
	onSubmit = function()
		if localServerProcess then
			local code = commandTextbox:getText()
			if #code > 0 then
				pcall(function()
					localServerProcess.stdin:write(code .. "\n")
				end)
				commandTextbox:setText("")
			end
		end
	end,
})

task.spawn(function()
	while true do
		if localServerProcess then
			local err = localServerProcess.stderr:read(1024)
			if err and #err > 0 then
				logBuffer = logBuffer .. err
			end

			if err and #err > 0 then
				while true do
					local lineEnd = string.find(logBuffer, "\n")
					if not lineEnd then
						break
					end
					local line = string.sub(logBuffer, 1, lineEnd - 1)
					logBuffer = string.sub(logBuffer, lineEnd + 1)
					if #line > 0 then
						table.insert(localServerLogs, line)
						if #localServerLogs > 15 then
							table.remove(localServerLogs, 1)
						end
					end
				end
			end

			local port = tonumber(hostPortTextbox:getText()) or 1234
			local info, p_err = NetworkService:Ping("127.0.0.1", port)
			if info then
				localServerInfo = info
			else
				localServerInfo = nil
			end
		else
			localServerInfo = nil
			localServerLogs = {}
		end
		task.wait(0.1)
	end
end)

local group

local function stopServer()
	pcall(function()
		localServerProcess:kill()
	end)
	localServerProcess = nil
	group.manageServerPrompt.set("buttons", {
		{
			text = "Start Server",
			color = StudioThemeService.SelectedTheme.Accent,
			onClick = function()
				group.manageServerPrompt.get("buttons")[1].onClick()
			end,
		},
	})
end

local function startServer()
	local port = tonumber(hostPortTextbox:getText()) or 1234
	local maxPlayers = tonumber(maxPlayersTextbox:getText()) or 16
	localServerProcess = ProcessService.CreateKinemiumServerProcessPiped("0.0.0.0", port, maxPlayers)

	local sName = nameTextbox:getText()
	if sName == "" then
		sName = "My Server"
	end
	local sMotd = motdTextbox:getText()
	if sMotd == "" then
		sMotd = "A Kinemium server is online."
	end
	local sDesc = descriptionTextbox:getText()
	local sMap = mapTextbox:getText()
	if sMap == "" then
		sMap = "MapName"
	end
	local sMode = modeTextbox:getText()
	if sMode == "" then
		sMode = "Survival"
	end

	task.spawn(function()
		task.wait(1.5)
		if localServerProcess then
			local code = string.format(
				"pcall(function() game:GetService('NetworkService'):SetPreviewData({name='%s', motd='%s', description='%s', map='%s', mode='%s'}) end)\n",
				sName,
				sMotd,
				sDesc,
				sMap,
				sMode
			)
			pcall(function()
				localServerProcess.stdin:write(code)
			end)
		end
	end)

	group.manageServerPrompt.set("buttons", {
		{
			text = "Stop Server",
			color = Color3.new(0.8, 0.2, 0.2),
			onClick = function()
				stopServer()
			end,
		},
	})
end

local serverStack = gui.vstack({
	spacing = 10,
	padding = 0,
	autoSize = true,
	backgroundColor = Color3.new(0, 0, 0),
	backgroundTransparency = 1,
})

local scrollArea = gui.scrollable({
	child = serverStack,
	scrollbarWidth = 8,
	scrollbarColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
	scrollbarHoverColor = StudioThemeService.SelectedTheme.Accent,
	scrollbarBackground = StudioThemeService.SelectedTheme.ThirdBackgroundColor,
	scrollbarBackgroundTransparency = 0.7,
})

group = aereon.create({
	addButton = {
		comp = "imageButton",
		image = addIcon,
		y = 110,
		x = screenx - 50,
		width = 30,
		height = 30,
		zindex = 3,
		onClick = function()
			group.newProjectPrompt.show()
		end,
	},

	hostServerButton = {
		comp = "textButton",
		text = "Host Server",
		y = 110,
		x = screenx - 200,
		width = 130,
		height = 30,
		zindex = 3,
		color = Color3.new(0.368627, 0.368627, 0.368627),
		onClick = function()
			group.manageServerPrompt.set("visible", true)
		end,
	},

	manageServerPrompt = {
		comp = "prompt",
		visible = false,
		width = 900,
		height = 250,
		bodyHeight = 500,
		font = vend,
		backgroundColor = SecondaryBackgroundColor,
		title = "MANAGE SERVER",
		buttons = {
			{
				text = "Start Server",
				color = StudioThemeService.SelectedTheme.Accent,
				onClick = function()
					if localServerProcess then
						stopServer()
					else
						startServer()
					end
				end,
			},
		},
		bodyRenderer = function(dt, x, y, width, height)
			-- Settings column
			lib.DrawTextEx(vend, "Settings", vector.create(x + 20, y + 20), 20, 1, TextColor)

			lib.DrawTextEx(vend, "Name", vector.create(x + 20, y + 50), 16, 1, TextColor)
			nameTextbox:drawWithExtras(x + 20, y + 70, 200, 40)

			lib.DrawTextEx(vend, "MOTD", vector.create(x + 20, y + 120), 16, 1, TextColor)
			motdTextbox:drawWithExtras(x + 20, y + 140, 200, 40)

			lib.DrawTextEx(vend, "Description", vector.create(x + 20, y + 190), 16, 1, TextColor)
			descriptionTextbox:drawWithExtras(x + 20, y + 210, 200, 40)

			lib.DrawTextEx(vend, "Map", vector.create(x + 20, y + 260), 16, 1, TextColor)
			mapTextbox:drawWithExtras(x + 20, y + 280, 200, 40)

			lib.DrawTextEx(vend, "Mode", vector.create(x + 20, y + 330), 16, 1, TextColor)
			modeTextbox:drawWithExtras(x + 20, y + 350, 200, 40)

			lib.DrawTextEx(vend, "Port", vector.create(x + 20, y + 400), 16, 1, TextColor)
			hostPortTextbox:drawWithExtras(x + 20, y + 420, 90, 40)

			lib.DrawTextEx(vend, "Max Players", vector.create(x + 130, y + 400), 16, 1, TextColor)
			maxPlayersTextbox:drawWithExtras(x + 130, y + 420, 90, 40)

			-- Stats column
			local statsX = x + 260
			lib.DrawTextEx(vend, "Status", vector.create(statsX, y + 20), 20, 1, TextColor)
			if localServerProcess then
				lib.DrawTextEx(
					vend,
					"Server is Running!",
					vector.create(statsX, y + 50),
					18,
					1,
					StudioThemeService.SelectedTheme.TextColor:ToRaylib()
				)
				if localServerInfo then
					local uptime = math.floor(localServerInfo.uptime or 0)
					local players = tostring(#(localServerInfo.players and localServerInfo.players.sample or {}))
						.. " / "
						.. tostring(localServerInfo.players and localServerInfo.players.max or 0)
					local tick = tostring(localServerInfo.tickRate or 0)
					local smap = tostring(localServerInfo.map or "unknown")

					lib.DrawTextEx(vend, "Uptime: " .. uptime .. "s", vector.create(statsX, y + 80), 16, 1, TextColor)
					lib.DrawTextEx(vend, "Players: " .. players, vector.create(statsX, y + 110), 16, 1, TextColor)
					lib.DrawTextEx(vend, "Tick Rate: " .. tick, vector.create(statsX, y + 140), 16, 1, TextColor)
					lib.DrawTextEx(vend, "Map: " .. smap, vector.create(statsX, y + 170), 16, 1, TextColor)
				else
					lib.DrawTextEx(
						vend,
						"Fetching stats...",
						vector.create(statsX, y + 80),
						16,
						1,
						StudioThemeService.SelectedTheme.TextColor:ToRaylib()
					)
				end
			else
				lib.DrawTextEx(
					vend,
					"Server is Offline",
					vector.create(statsX, y + 50),
					18,
					1,
					StudioThemeService.SelectedTheme.TextColor:ToRaylib()
				)
			end

			-- Terminal
			lib.DrawTextEx(vend, "Logs", vector.create(statsX, y + 210), 20, 1, TextColor)
			local termY = y + 240
			local termH = 195
			local termW = width - 280
			lib.DrawRectangle(statsX, termY, termW, termH, raylib.const.BLACK)

			for i, logLine in ipairs(localServerLogs) do
				lib.DrawText(logLine, statsX + 5, termY + 5 + (i - 1) * 12, 10, raylib.const.WHITE)
			end

			-- Terminal input
			commandTextbox:drawWithExtras(statsX, termY + termH + 10, termW, 30)
		end,
		zindex = 5,
	},

	newProjectPrompt = {
		comp = "prompt",
		visible = false,
		width = 600,
		height = 250,
		bodyHeight = 400,
		font = vend,
		backgroundColor = SecondaryBackgroundColor,
		title = "JOIN SERVER",
		buttons = {
			{
				text = "JOIN",
				color = Color3.new(0.368627, 0.368627, 0.368627),
				onClick = function()
					local username = usernameTextbox:getText()
					local server_address = serverAddress_Textbox:getText()
					local server_port = serverPort_Textbox:getText()

					if username == "" then
						return
					end

					local info, err = NetworkService:Ping(server_address, server_port)

					print(info, err)

					if info then
						local serverCardData = {
							x = 0,
							y = 0,
							width = 520,
							font = vend,
							onPlay = function()
								ProcessService.CreateKinemiumClientProcessEx(username, server_address, server_port)
							end,
						}
						for prop, value in pairs(info) do
							serverCardData[prop] = value
						end
						serverStack.add(gui.servercard(serverCardData))
					end
				end,
			},
		},
		bodyRenderer = function(dt, x, y, width, height)
			local iconRectSource = rect.new(0, 0, logoIcon.x, logoIcon.y)
			local iconRect = rect.new(x, y, 200, 200)

			local tint = raylib.const.WHITE
			if rect.MouseIsInRect(iconRect) then
				tint = transparent
				MouseCursor.request(raylib.const.MouseCursor.MOUSE_CURSOR_POINTING_HAND)
			else
				MouseCursor.request(raylib.const.MouseCursor.MOUSE_CURSOR_DEFAULT)
			end
			lib.DrawTexturePro(
				logoIcon.texture,
				rect:translate(iconRectSource),
				rect:translate(iconRect),
				vector.create(0, 0),
				0,
				tint
			)
			rect.Button(iconRect, function()
				local imagePath = FileDialogService.RequestFile({
					{ name = "Kinemium Project", extensions = { "kproj" } },
					{ name = "All Files", extensions = { "*" } },
				})
				logoIcon = KinemiumIconLoader.ToTexture(imagePath)
			end)

			lib.DrawTextEx(vend, "Username", vector.create(x + 210, y), 16, 1, raylib.const.WHITE)
			usernameTextbox:drawWithExtras(x + 210, y + 30, 300, 50)

			lib.DrawTextEx(vend, "Server Address", vector.create(x + 210, y + 100), 16, 1, raylib.const.WHITE)
			serverAddress_Textbox:drawWithExtras(x + 210, y + 130, 300, 50)

			lib.DrawTextEx(vend, "Server Port", vector.create(x + 210, y + 200), 16, 1, raylib.const.WHITE)
			serverPort_Textbox:drawWithExtras(x + 210, y + 230, 300, 50)
		end,
		zindex = 5,
	},
})

group.manageServerPrompt.set("buttons", {
	{
		text = "Start Server",
		color = StudioThemeService.SelectedTheme.Accent,
		onClick = function()
			if localServerProcess then
				stopServer()
			else
				startServer()
			end
		end,
	},
})

repeat
	task.wait()
until ishared.Home

ishared.Home.pages["Servers"] = function(dt, alpha, slideOffset)
	local fade = function(col, a)
		return col:ToRaylib(1 - (a or 1) * alpha)
	end

	if ishared.Home.activePage ~= "Servers" and ishared.Home.previousPage ~= "Servers" then
		return
	end

	screenx, screeny = lib.GetRenderWidth(), lib.GetScreenHeight()

	local startX = 100
	local headerY = 80 + slideOffset
	local headerDesc = 120 + slideOffset

	group.addButton.set("obj_rect", arect.new(screenx - 50, 110 + slideOffset, 30, 30))
	group.hostServerButton.set("obj_rect", arect.new(screenx - 190, 110 + slideOffset, 130, 30))
	group.render(dt, { "newProjectPrompt", "manageServerPrompt" })

	if vend then
		raylib.lib.DrawTextEx(
			boldFont,
			"Servers",
			vector.create(startX, headerY),
			32,
			1,
			fade(StudioThemeService.SelectedTheme.TextColor, 1)
		)
		raylib.lib.DrawTextEx(
			vend,
			"Connect to Kinemium servers and explore multiplayer worlds",
			vector.create(startX, headerDesc),
			16,
			1,
			fade(StudioThemeService.SelectedTheme.SecondaryTextColor, 1)
		)
	end

	-- Render scroll area
	scrollArea.set("obj_rect", arect.new(startX, 150 + slideOffset, screenx - 170, screeny - 200))
	serverStack.set("width", screenx - 180)
	scrollArea.render(dt)

	group.manageServerPrompt.render(dt)
	group.newProjectPrompt.render(dt)
end
