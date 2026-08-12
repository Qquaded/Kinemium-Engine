local Aereon = require("@Aereon")
local gui = Aereon.gui
local kinemiumRaylib = game:GetService("KinemiumRaylib")
local renderer = kinemiumRaylib.GetRenderer()
local lib = kinemiumRaylib.GetLib()
local UserInputService = game:GetService("UserInputService")
local StudioThemeService = game:GetService("StudioThemeService")
local EngineSignal = game.EngineSignal
local git = require("@Git")
local BackgroundColor = StudioThemeService.SelectedTheme.BackgroundColor
local BackgroundTransparency = StudioThemeService.SelectedTheme.BackgroundTransparency
local files = {}

-- template: 		{ name = "commandPalette.luau", path = "src\\modules\\Aereon\\component\\objects", tag = "recently opened" },

local fileSearch = gui.fileSearch({
	game = game,
	width = 700,
	backgroundColor = BackgroundColor,
	backgroundTransparency = BackgroundTransparency,

	files = {},
	onOpen = function(file)
		if file == "git init" then
			print(ishared)
		end
		EngineSignal:Fire("idestate", true, file.instance)
	end,

	onSubmit = function(text)
		print(text)
		local args = string.split(text, " ")

		if args[1] ~= "git" then
			return
		end

		print("helo")

		if args[2] == "init" then
			git:InitProject(ishared.FolderPath)
		elseif args[2] == "add" then
			print("Added")
			git:Add(args[3] or ".", ishared.FolderPath)
		elseif args[2] == "commit" then
			local message = text:match('git%s+commit%s+"(.-)"') or text:match("git%s+commit%s+'(.-)'")

			if message then
				git:Commit(message, ishared.FolderPath)
			end
		elseif args[2] == "remote" then
			if args[3] == "add" and args[4] == "origin" then
				local url = args[5]

				if url then
					git:RemoteAdd("origin", url, ishared.FolderPath)
				end
			end
		elseif args[2] == "push" then
			git:Push(ishared.FolderPath)
		end
	end,
})

renderer.Pool.new("2d", function()
	local dt = lib.GetFrameTime()

	fileSearch.render(dt)

	if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
		if UserInputService:IsKeyPressed(Enum.KeyCode.P) then
			if ishared.EnableHomescreen == false then
				table.clear(files)
				for _, object in pairs(game:GetDescendants()) do
					if object.BaseClass == "ScriptContainer" then
						table.insert(files, {
							name = object.Name,
							path = object:GetFullName(),
							instance = object,
						})
					end
				end
				fileSearch.setFiles(files)
				fileSearch.toggle()
			end
		end
	end
end, -99999999)
