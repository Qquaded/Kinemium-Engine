local Instance = require("@Instance")
local Enum = require("@EnumMap")

local ProjectLoaderService = Instance.new("LogService")
ProjectLoaderService.ExplorerHidden = true
ProjectLoaderService._Intents = Enum.PluginIntents.Filesystem

local serde = zune.serde

local toml = zune.serde.toml
local fs = zune.fs
local projectsFile = "./src/projects.toml"
local zembed = require("@zembed")

if zembed.IsEmbedded() then
	projectsFile = "./projects.toml"
end

local settings = {
	["luau-lsp.types.definitionFiles"] = {
		["kinemium"] = "k.d.luau",
	},
}

local function buildProjectConfig(name, iconPath, description)
	return {
		info = {
			name = name,
			icon = iconPath,
			desc = description,
		},
		pointers = {
			assets = "game.ReplicatedStorage",
			server = "game.ServerScriptService",
			client = "game.StarterPlayer",
			gui = "game.StarterGui",
			objects = "game.Workspace",
		},
		sync = {
			live = false,
			debounce = 0.35,
			ignore = { git = ".git", vscode = ".vscode", autosave = "autosave" },
		},
		backups = {
			interval = 300,
		},
		scripting = {
			polyglot = true,
			ncg = true,
		},
	}
end

ProjectLoaderService.InitRenderer = function(renderer, renderer_signal)
	ProjectLoaderService:SetProperties({
		GetProjects = function()
			local success, read = pcall(fs.readFile, projectsFile)
			if not success or read == "" then
				return {}
			end

			local decodeSuccess, data = pcall(toml.decode, read)
			if not decodeSuccess then
				return {}
			end

			if data then
				if data.projects then
					return data.projects
				else
					return {}
				end
			end
			return {}
		end,

		StartObserve = function(path) end,

		NewProject = function(name, path, iconPath, description)
			if not name then
				return
			end
			if not path then
				return
			end

			local kprojFile = path .. "/kproj.toml"
			-- write to projects list
			local projects = ProjectLoaderService.GetProjects()

			projects[name] = {
				icon = iconPath,
				path = path,
				name = name,
				engine_version = ENGINE_VERSION,
				last_opened = os.time(),
			}

			local encoded = toml.encode({
				projects = projects,
			})

			fs.writeFile(projectsFile, encoded)

			-- write project settings file
			local success, result = pcall(function()
				fs.makeDir(path .. "/assets", true)
				fs.makeDir(path .. "/server", true)
				fs.makeDir(path .. "/client", true)
				fs.makeDir(path .. "/gui", true)
				fs.makeDir(path .. "/objects", true)
				fs.makeDir(path .. "/.vscode", true)
				fs.makeDir(path .. "/autosave", true)

				fs.writeFile(
					path .. "/.vscode/settings.json",
					zune.serde.json.encode(settings, {
						pretty_indent = 1,
					})
				)

				local config = buildProjectConfig(name, iconPath, description)
				local encodedProject = serde.toml.encode(config)
				fs.writeFile(kprojFile, encodedProject)
			end)
			print(success, result)

			return encoded
		end,

		GetGamesAsSubmenu = function(func)
			local read = fs.readFile(projectsFile)
			local data = toml.decode(read)
			local result = {}

			if data then
				local pjs = data.projects

				if pjs then
					for _, projectData in pairs(pjs) do
						table.insert(result, {
							label = projectData.name,
							onClick = function()
								func(projectData)
							end,
						})
					end
				end
			end

			return result
		end,
	})
end

return ProjectLoaderService
