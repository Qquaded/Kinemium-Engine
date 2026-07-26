--[[
local aereon = require("@Aereon")
local gui = aereon.gui
local KinemiumRaylib = game:GetService("KinemiumRaylib")
local KinemiumFontService = game:GetService("KinemiumFontService")

local renderer = KinemiumRaylib.GetRenderer()
local rl = KinemiumRaylib.GetLib()
local const = KinemiumRaylib.GetConst()
local Theme = game:GetService("StudioThemeService").SelectedTheme
local StudioThemeService = game:GetService("StudioThemeService")
local arect = require("@Arect")
local font = KinemiumFontService.GetDefaultFont()
local git = require("@git")

local window = aereon.window(game)
local git_window = window.create({
	title = "Git Source Control",
	x = 0,
	y = 0,
	width = 300,
	height = 500,
})

local history = gui.githistory({
	x = 0,
	y = 100,
	backgroundTransparency = 1,
	width = 300,
	height = 200,
	font = font,
	commits = {},
	onCommitClick = function(commit, index)
		print(index, commit.text)
	end,
})

local textbox = aereon.textbox(StudioThemeService.SelectedTheme, game)

local commit_message = textbox.new({
	multiline = false,
	placeholder = `Message (Ctrl+Enter to commit on main)`,
	fontSize = 14,
	font = font,
	maxLength = 100,
	cornerRadius = StudioThemeService.SelectedTheme.CornerRadius,
})

local commit_button = gui.textButton({
	x = 0,
	y = 0,
	width = 120,
	height = 32,
	text = "Commit",
	backgroundColor = Color3.new(0.2, 0.2, 0.2),
	hoverColor = Color3.new(0.3, 0.3, 0.3),
	pressColor = Color3.new(0.15, 0.15, 0.15),
	textColor = Color3.new(1, 1, 1),
	rounded = { 0.3, 8 },
	onClick = function()
		print("Button clicked!")
	end,
})

local componentSwitcher = gui.comptoggle({
	x = 0,
	y = 10,
	width = 220,
	height = 32,
	backgroundTransparency = 1,
	font = font,
	label = "Changes",
	items = {
		{ name = "Git History", key = "githistory", visible = true },
		{ name = "Commit Box", key = "commitbox", visible = true },
		{ name = "Color Picker", key = "colorpicker", visible = false },
	},
	onToggle = function(item, visible)
		if item.key == "githistory" then
			history.set("backgroundTransparency", visible and 1 or nil) -- or however you gate rendering
		end
	end,
})

renderer.Pool.new("2d", function(data)
	local dt = rl.GetFrameTime()
	local mainTheme = StudioThemeService.SelectedTheme

	window.update(dt)
	window.draw(dt, mainTheme, renderer.Lib2d)
end)

local commits = {}
local got_commits = false

window.focused = function()
	if not ishared.FolderPath then
		return
	end
	commits = git:GetCommits(ishared.FolderPath, 100)
	history.set("commits", commits)
	print(git:Status(ishared.FolderPath))
end

window.stepped = function(data)
	local dt = rl.GetFrameTime()

	local x, y, width, height = data.x, data.y, data.width, data.height

	rl.DrawTextEx(font, "Username", vector.create(x + 10, y), 16, 1, const.WHITE)
	commit_message:drawWithExtras(x + 10, y + 40, width - 20, 33)
	commit_button.set("obj_rect", arect.new(x + 10, y + 80, width - 20, 28))
	commit_button.render(dt)

	componentSwitcher.set("obj_rect", arect.new(x + 10, y + 118, width - 20, 32))
	componentSwitcher.render(dt)

	if componentSwitcher.isVisible("githistory") then
		history.render(dt)
	end

	if ishared.FolderPath then
		if got_commits == false then
			got_commits = true
			commits = git:GetCommits(ishared.FolderPath, 100)
		end
		history.set("commits", commits)
	end

	history.set("obj_rect", arect.new(data.x, data.y + data.height - 200, data.width, 200))
	history.set("rounded", { 0, StudioThemeService.SelectedTheme.CornerRadius })
end
--[[