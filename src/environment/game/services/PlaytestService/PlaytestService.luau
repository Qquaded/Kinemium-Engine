local Instance = require("@Instance")

local PlaytestService = Instance.new("PlaytestService")
PlaytestService.ExplorerHidden = true

local signal = require("@Kinemium.signal")

local task = zune.task

local function outputProcess(prefix, proc, cb)
	local buffer = ""
	return task.spawn(function()
		while true do
			local err = proc.stderr:read(1024)

			if err and #err > 0 then
				buffer ..= err

				while true do
					local lineEnd = string.find(buffer, "\n")

					if not lineEnd then
						break
					end

					local line = string.sub(buffer, 1, lineEnd - 1)
					buffer = string.sub(buffer, lineEnd + 1)

					if #line > 0 then
						if cb then
							cb(line)
						end
						print(prefix, line)
					end
				end
			end

			task.wait(0.01)
		end
	end)
end

local server_process: ProcessChild
local client_process: ProcessChild

local client_logger
local server_logger

PlaytestService.InitRenderer = function(renderer, renderer_signal, datamodel)
	PlaytestService:SetProperties({
		OnClientLog = signal.new(),
		OnServerLog = signal.new(),

		OnPlaytestStarted = signal.new(),
		OnPlaytestFinished = signal.new(),

		CreatePlaytestAsync = function(gameName)
			pcall(function()
				zune.fs.deleteFile("./.temp/" .. gameName .. ".kine")
			end)

			PlaytestService.OnPlaytestStarted:Fire()

			local KineFileService = datamodel:GetService("KineFileService")

			KineFileService.ExportGameAsFile("./.temp/", gameName)

			local Process = datamodel:GetService("Process")

			local serverReady = false

			task.spawn(function()
				server_process = Process.CreateKinemiumServerProcess({
					"--headless",
					"--blob",
					"./.temp/" .. gameName .. ".kine",
				})
				server_logger = outputProcess("[SERVER]", server_process, function(line)
					PlaytestService.OnServerLog:Fire(line)
				end)
			end)

			task.spawn(function()
				-- wait 2 seconds for the server to startup
				task.wait(2)

				local playerName = "Player"
				pcall(function()
					local players = datamodel:GetService("Players")
					if players and players.LocalPlayer and players.LocalPlayer.Name then
						playerName = players.LocalPlayer.Name
					end
				end)
				if playerName == "Player" then
					pcall(function()
						local envName = zune.process.env["USERNAME"] or zune.process.env["USER"]
						if envName and #envName > 0 then
							playerName = envName
						end
					end)
				end

				client_process = Process.CreateKinemiumClientProcess({
					"--username " .. playerName,
				})
				client_logger = outputProcess("[CLIENT]", client_process, function(line)
					PlaytestService.OnClientLog:Fire(line)
				end)
			end)
		end,

		StopCurrentPlaytest = function(gameName)
			PlaytestService.OnPlaytestFinished:Fire()

			pcall(function()
				zune.fs.deleteFile("./.temp/" .. gameName .. ".kine")
			end)
			if client_logger then
				task.cancel(client_logger)
			end
			if server_logger then
				task.cancel(server_logger)
			end

			if client_process then
				task.spawn(function()
					pcall(function()
						client_process:kill()
					end)
				end)
			end
			if server_process then
				task.spawn(function()
					pcall(function()
						server_process:kill()
					end)
				end)
			end
		end,

		IsPlaytesting = true,
	})
end

return PlaytestService
