local Instance = require("@Instance")
local Enum = require("@EnumMap")

local Process = Instance.new("Process")
Process.ExplorerHidden = true
Process._Intents = Enum.PluginIntents.Graphics

Process.InitRenderer = function(renderer, renderer_signal)
	Process:SetProperties({
		RunProcessZune = function(flags, ioOpts)
			local process = zune.process.create(zune.fs.getExePath(), flags, {
				opts = ioOpts or { stdin = "inherit", stdout = "inherit", stderr = "inherit" },
			})
			return process
		end,

		CreateKinemiumClientProcess = function(flags: { string })
			local info = {
				"run",
				"game",
				"--client",
				"--username",
				"Dev",
				"--max3dpixels",
				"144000",
				"--perfoverlay",
			}

			if flags then
				for _, flag in ipairs(flags) do
					table.insert(info, flag)
				end
			end

			return Process.RunProcessZune(info)
		end,

		CreateKinemiumClientProcessEx = function(username, ip, port, flags)
			local info = {
				"run",
				"game",
				"--client",
				"--username",
				username,
				"--address",
				ip,
				"--port",
				tostring(port),
				"--max3dpixels",
				"144000",
				"--perfoverlay",
			}

			if flags then
				for _, flag in ipairs(flags) do
					table.insert(info, flag)
				end
			end

			return Process.RunProcessZune(info)
		end,

		CreateKinemiumServerProcessPiped = function(ip, port, maxPlayers)
			local info = {
				"run",
				"game",
				"--server",
				"--kilang",
				"--port",
				tostring(port),
				"--address",
				ip,
			}

			if maxPlayers then
				table.insert(info, "--max-players")
				table.insert(info, tostring(maxPlayers))
			end

			local process = zune.process.create(zune.fs.getExePath(), info, {
				opts = { stdout = "piped", stderr = "piped" },
			})
			return process
		end,

		CreateKinemiumServerProcessEx = function(ip, port)
			-- example zune run game --server --port 1234 --address 0.0.0.0
			local info = {
				"run",
				"game",
				"--server",
				"--kilang",
				"--port",
				tostring(port),
				"--address",
				ip,
			}

			return Process.RunProcessZune(info)
		end,

		ForceKill = function(process)
			if process then
				task.spawn(function()
					pcall(function()
						process:kill()
					end)
				end)
			end
		end,

		CreateKinemiumServerProcess = function(flags: { string })
			local info = {
				"run",
				"game",
				"--server",
				"--kilang",
			}

			if flags then
				for _, flag in ipairs(flags) do
					table.insert(info, flag)
				end
			end

			return Process.RunProcessZune(info)
		end,
	})
end
return Process
