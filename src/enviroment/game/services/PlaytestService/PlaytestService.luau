local Instance = require("@Instance")
local signal = require("@Kinemium.signal")
local Color3 = require("@Color3")

local serialized = nil

local PlaytestService = Instance.new("PlaytestService")
PlaytestService.ExplorerHidden = true

PlaytestService.InitRenderer = function(renderer, renderer_signal, datamodel)
	PlaytestService:SetProperties({
		CreatePlaytestAsync = function()
			local ScriptRunnerService = datamodel:GetService("ScriptRunnerService")

			-- 1. Snapshot BEFORE scripts touch anything
			serialized = datamodel:Clone(true)

			-- 2. Then run scripts against the live datamodel
			for _, script in pairs(datamodel:GetDescendants()) do
				if script.ClassName == "Script" then
					log("Running script ", script)
					ScriptRunnerService.RunScript(script)
				end
			end

			PlaytestService.IsPlaytesting = true
		end,

		StopCurrentPlaytest = function()
			local ScriptRunnerService = datamodel:GetService("ScriptRunnerService")
			local PhysicsService = datamodel:GetService("KinemiumPhysicsService")

			ScriptRunnerService.Clear()
			PlaytestService.IsPlaytesting = false

			if PhysicsService and PhysicsService.Unload then
				pcall(PhysicsService.Unload)
			end

			datamodel:RestoreFrom(serialized)

			serialized:Destroy()
			serialized = nil
		end,

		IsPlaytesting = false,
	})
end

PlaytestService.GetToolbarCategory = function(renderer, renderer_signal, datamodel)
	local toggle = true

	local Category = {
		elements = {
			{
				type = "ImageButton",
				text = "Playtest",
				callback = function(object)
					if toggle == true then
						PlaytestService.CreatePlaytestAsync()
					else
						PlaytestService.StopCurrentPlaytest()
					end
				end,
				hoverTransparency = 0.5,
				hoverColor = Color3.new(0, 0, 0),
				roundness = 0.2,
				--\\texture = PlayIcon,
			},
		},
	}

	return Category
end

return PlaytestService
