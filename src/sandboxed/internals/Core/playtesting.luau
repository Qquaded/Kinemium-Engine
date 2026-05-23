-- devcell
local IsPlaytesting = false

local KinemiumIconLoader = game:GetService("KinemiumIconLoader")
local playtestService = game:GetService("PlaytestService")

local RunService = game:GetService("RunService")
if RunService:IsServer() then
	return
end

repeat
	task.wait()
until ishared.NewCategoryToolbar
local NewCategoryToolbar = ishared.NewCategoryToolbar

local Process = game:GetService("Process")
local processes = {}

local playerCount = 1

NewCategoryToolbar:Fire("Playtest", {
	elements = {
		{
			type = "ImageButton",
			text = "Play Test",
			callback = function()
				if IsPlaytesting then
					return
				end

				playtestService.CreatePlaytestAsync(ishared.GameName or "Game")
				IsPlaytesting = true
			end,
			hoverTransparency = 0.5,
			hoverColor = Color3.new(0, 0, 0),
			roundness = 0.2,
			texture = KinemiumIconLoader.ToTexture("./src/assets/images/icons/Play.png"),
		},
		{
			type = "ImageButton",

			callback = function()
				if not IsPlaytesting then
					return
				end

				playtestService.StopCurrentPlaytest(ishared.GameName or "Game")
				IsPlaytesting = false
				for _, client in pairs(processes) do
					Process.ForceKill(client)
				end
			end,
			hoverTransparency = 0.5,
			text = "Stop",
			hoverColor = Color3.new(1, 0, 0),
			roundness = 0.2,
			texture = KinemiumIconLoader.ToTexture("./src/assets/images/icons/Pause.png"),
		},

		{
			type = "ImageButton",
			text = "New Client",
			callback = function()
				task.spawn(function()
					table.insert(
						processes,
						Process.RunProcessZune({
							"run",
							"engine",
							"--client",
							"--username",
							"Player" .. playerCount,
						})
					)
					playerCount += 1
				end)
			end,
			hoverTransparency = 0.5,
			hoverColor = Color3.new(0, 0, 0),
			roundness = 0.2,
			texture = KinemiumIconLoader.ToTexture("./src/assets/images/icons/MultipleDevices.png"),
		},
	},
})
