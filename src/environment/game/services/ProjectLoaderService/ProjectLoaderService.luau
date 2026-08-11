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
local currentProject

if zembed.IsEmbedded() then
	projectsFile = "./projects.toml"
end

local settings = {
	["luau-lsp.types.definitionFiles"] = {
		["kinemium"] = "k.d.luau",
	},
}

export type ProjectConfig = {
	info: {
		name: string,
		icon: string,
		desc: string,
	},

	pointers: {
		assets: string,
		server: string,
		client: string,
		gui: string,
		objects: string,
	},

	plugins: {
		[string]: any,
	},

	sync: {
		live: boolean,
		debounce: number,
		ignore: {
			git: string,
			vscode: string,
		},
	},

	backups: {
		interval: number,
	},

	scripting: {
		polyglot: boolean,
		ncg: boolean,
	},
}

local function buildProjectConfig(name, iconPath, description, PluginLoader, dimension)
	local plugins_built = {}

	for i, data in pairs(PluginLoader.GetLoadedPlugins()) do
		plugins_built[data.manifest.name] =
			{ id = i, version = data.manifest.version, author = data.manifest.author, autoload = true }
	end

	return {
		info = {
			name = name,
			icon = iconPath,
			desc = description,
			dimension = dimension,
		},
		pointers = {
			assets = "game.ReplicatedStorage",
			server = "game.ServerScriptService",
			client = "game.StarterPlayer",
			gui = "game.StarterGui",
			objects = "game.Workspace",
		},
		plugins = plugins_built,

		sync = {
			live = false,
			debounce = 0.35,
			ignore = { git = ".git", vscode = ".vscode" },
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

ProjectLoaderService.InitRenderer = function(renderer, renderer_signal, datamodel)
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
					local result = {}

					for _, project in pairs(data.projects) do
						if zune.fs.stat(project.path).kind ~= "directory" then
							continue
						end
						if zune.fs.stat(project.path .. "/kproj.toml").kind ~= "file" then
							continue
						end
						project.manifest = zune.serde.toml.decode(fs.readFile(project.path .. "/kproj.toml"))
						result[project.name] = project
					end

					return result
				else
					return {}
				end
			end
			return {}
		end,

		StartObserve = function(path) end,

		NewProject = function(name, path, iconPath, description, selectedDimension)
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
				dimension = selectedDimension,
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
				fs.makeDir(path .. "/scenes", true)

				fs.writeFile(
					path .. "/.vscode/settings.json",
					zune.serde.json.encode(settings, {
						pretty_indent = 1,
					})
				)

				repeat
					task.wait()
				until datamodel:GetService("PluginLoader")

				local config = buildProjectConfig(
					name,
					iconPath,
					description,
					datamodel:GetService("PluginLoader"),
					selectedDimension
				)
				local encodedProject = serde.toml.encode(config)
				fs.writeFile(kprojFile, encodedProject)
			end)

			if not success then
				print(result)
			end

			return encoded
		end,

		CreateFile = function(folder, file, body)
			local projectPath = datamodel:GetMetadata("ProjectPath")
			assert(projectPath, "ProjectPath metadata is missing")

			local dir = fs.path.join(projectPath, folder)
			local filePath = fs.path.join(dir, file)

			fs.makeDir(dir, true)
			fs.createFile(filePath)
			fs.writeFile(filePath, body)

			return filePath
		end,

		LoadProject = function(projectPath, conf: { manifest: ProjectConfig })
			local ProjectSyncService = datamodel:GetService("ProjectSyncService")
			local PluginLoader = datamodel:GetService("PluginLoader")
			local loadedPlugins = PluginLoader.GetLoadedPlugins()

			datamodel:SetMetadata("ProjectManif", conf.manifest)
			datamodel:SetMetadata("ProjectPath", projectPath)
			-- not sure how to separate backups from the syncing function, maybe later
			if conf.manifest.sync.live == true then
				ProjectSyncService:StartSyncing(projectPath)
			end

			-- spawn in separate thread
			zune.task.spawn(function()
				-- check if conf.manifest.plugins exists (for backwards compat)
				if conf.manifest.plugins then
					for id, data in pairs(conf.manifest.plugins) do
						-- if plugin's autoload is not true then skip
						if data.autoload == false then
							continue
						end

						id = data.id

						if loadedPlugins[id] then
							local manifest = loadedPlugins[id].manifest
							-- if project plugin version is not the same as the installed plugin
							if data.version ~= manifest.version then
								-- remove plugin
								PluginLoader.UnloadPlugin(id)
								PluginLoader.DownloadPlugin(id, true)
							end

							continue
						end

						-- if the user does not have the plugin the project requires, install it
						local success, result = PluginLoader.DownloadPlugin(id, true)

						if not success then
							print(`Error while downloading project dependency {id}: {result}`)
							continue
						end
					end
				end
			end)
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

	if FlagExists("project") then
		local projectPath = GetFlagValue("project")
		-- TODO: runtime
	end
end

return ProjectLoaderService
