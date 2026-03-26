-- devcell
local IsPlaytesting = false

local KinemiumIconLoader = game:GetService("KinemiumIconLoader")
local clients = {}
local playtestService = game:GetService("PlaytestService")

repeat
	task.wait()
until ishared.NewCategoryToolbar
local NewCategoryToolbar = ishared.NewCategoryToolbar

NewCategoryToolbar:Fire("Playtest", {
	elements = {
		{
			type = "ImageButton",
			text = "Playtest",
			callback = function()
				if IsPlaytesting then
					return
				end
				print("playtesting..")

				playtestService.CreatePlaytestAsync()
				IsPlaytesting = true
			end,
			hoverTransparency = 0.5,
			hoverColor = Color3.new(0, 0, 0),
			roundness = 0.2,
			texture = KinemiumIconLoader.ToTexture("./src/assets/images/icons/Play.svg"),
		},
		{
			type = "ImageButton",

			callback = function()
				local playtestService = game:GetService("PlaytestService")

				if not IsPlaytesting then
					return
				end
				print("Stopping the simulation")

				playtestService.StopCurrentPlaytest()
				IsPlaytesting = false
			end,
			hoverTransparency = 0.5,
			text = "Stop",
			hoverColor = Color3.new(1, 0, 0),
			roundness = 0.2,
			texture = KinemiumIconLoader.ToTexture("./src/assets/images/icons/Pause.svg"),
		},
		{
			type = "ImageButton",
			text = "Run Multiple",
			callback = function()
				table.insert(
					clients,
					task.spawn(function()
						zune.process.create(zune.fs.getExePath(), {
							"run",
							"game",
							"--client",
							"--dhs",
						})
					end)
				)

				task.spawn(function()
					zune.process.create(zune.fs.getExePath(), {
						"run",
						"game",
						"--server",
					})
				end)
			end,
			hoverTransparency = 0.5,
			hoverColor = Color3.new(0, 0, 0),
			roundness = 0.2,
			texture = KinemiumIconLoader.ToTexture("./src/assets/images/icons/MultipleDevices.svg"),
		},
	},
})
