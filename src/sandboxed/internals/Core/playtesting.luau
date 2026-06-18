-- devcell
local IsPlaytesting = false

local KinemiumIconLoader = game:GetService("KinemiumIconLoader")
local playtestService = game:GetService("PlaytestService")
local KineFileService = game:GetService("KineFileService")

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
local offlinePlayerCount = 1

local function readStderr(proc)
	local logBuffer = ""
	task.spawn(function()
		while true do
			if proc then
				local err = proc.stderr:read(1024)
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
			else
				localServerInfo = nil
				localServerLogs = {}
			end
			task.wait(0.1)
		end
	end)
end

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
		{
			type = "ImageButton",
			text = "Offline Client",
			callback = function()
				task.spawn(function()
					local gameName = ishared.GameName or "Game"

					pcall(function()
						zune.fs.deleteFile("./.temp/offline_" .. gameName .. ".kine")
					end)

					KineFileService.ExportGameAsFile("./.temp/", "offline_" .. gameName)

					local new = Process.RunProcessZune({
						"run",
						"game",
						"--client",
						"--offline",
						"--no-multiplayer",
						"--blob",
						"./.temp/offline_" .. gameName .. ".kine",
						"--username",
						"OfflinePlayer" .. offlinePlayerCount,
					}, { stdin = "inherit", stdout = "inherit", stderr = "piped" })

					table.insert(processes, new)

					task.spawn(function()
						local buffer = ""
						while new do
							local ok, err = pcall(function()
								return new.stderr:read(1024)
							end)
							if not ok then
								break
							end
							if err == nil then
								break
							end
							if #err > 0 then
								buffer = buffer .. err
							end

							local lines = {}
							while true do
								local lineEnd = string.find(buffer, "\n")
								if not lineEnd then
									break
								end
								local line = string.sub(buffer, 1, lineEnd - 1)
								buffer = string.sub(buffer, lineEnd + 1)
								if #line > 0 then
									table.insert(lines, line)
								end
							end
							if #lines > 0 then
								game.EngineSignal:Fire("PumpOutputToTab", {
									tab = string.format("Playtest Output (%d)", new.pid),
									data = lines,
								})
							end
							task.wait()
						end
					end)

					offlinePlayerCount += 1
				end)
			end,
			hoverTransparency = 0.5,
			hoverColor = Color3.new(0, 0, 0),
			roundness = 0.2,
			texture = KinemiumIconLoader.ToTexture("./src/assets/images/icons/NetworkController.png"),
		},
	},
})
