local Instance = require("@Instance")

local serde = zune.serde
local fs = zune.fs
local libzip = require("@zip")

local Enum = require("@EnumMap")

local PluginLoader = Instance.new("PluginLoader")
PluginLoader.ExplorerHidden = true
PluginLoader._PluginAccess = false

local Schema = require("@Schema")

local function parseSemver(v)
	local major, minor, patch = v:match("^(%d+)%.(%d+)%.(%d+)$")
	if not major then
		return nil
	end
	return { major = tonumber(major), minor = tonumber(minor), patch = tonumber(patch) }
end

local function resolveUrl(baseUrl, maybeRelative)
	if type(maybeRelative) ~= "string" or maybeRelative == "" then
		return nil
	end

	if maybeRelative:match("^https?://") then
		return maybeRelative
	end

	local base = tostring(baseUrl or "")
	local origin = base:match("^(https?://[^/]+)")
	if not origin then
		return maybeRelative
	end

	if maybeRelative:sub(1, 1) == "/" then
		return origin .. maybeRelative
	end

	local baseDir = base:match("^(https?://.*/)") or (origin .. "/")
	return baseDir .. maybeRelative
end

-- Supports: "1.2.3" (exact), "^1.2.3" (compatible), ">=1.2.3" (minimum)
local function satisfiesVersion(wanted, got)
	local gotV = parseSemver(got)
	if not gotV then
		return false
	end

	local op, vstr = wanted:match("^([%^><=~]*)(.+)$")
	local wantedV = parseSemver(vstr)
	if not wantedV then
		return false
	end

	if op == "^" then
		-- Same major, got >= wanted
		return gotV.major == wantedV.major
			and (gotV.minor > wantedV.minor or (gotV.minor == wantedV.minor and gotV.patch >= wantedV.patch))
	elseif op == ">=" then
		return gotV.major > wantedV.major
			or (gotV.major == wantedV.major and gotV.minor > wantedV.minor)
			or (gotV.major == wantedV.major and gotV.minor == wantedV.minor and gotV.patch >= wantedV.patch)
	elseif op == "" or op == "=" then
		-- Exact match
		return gotV.major == wantedV.major and gotV.minor == wantedV.minor and gotV.patch == wantedV.patch
	end

	return false
end

local plugin_schema = Schema.new({
	name = Schema.nonEmptyString(),
	id = Schema.stringPattern("^[%a%d_%-]+%.[%a%d_%-]+$"),
	version = Schema.stringPattern("^%d+%.%d+%.%d+$"),
	description = Schema.optional(Schema.string()),
	icon = Schema.optional(Schema.string()),
	thumbnail = Schema.optional(Schema.string()),
	homepage = Schema.optional(Schema.url()),
	repository = Schema.optional(Schema.url()),
	keywords = Schema.optional(Schema.arrayOf(Schema.string())),
	author = Schema.optional(Schema.string()),
	license = Schema.optional(Schema.string()),
	main = Schema.nonEmptyString(),
	engine = Schema.optional(Schema.map({
		minVersion = Schema.stringPattern("^%d+%.%d+%.%d+$"),
	})),
	dependencies = Schema.optional(Schema.record(Schema.string())),
	permissions = Schema.optional(Schema.arrayOf(Schema.string())),
	intents = Schema.optional(Schema.arrayOf(Schema.string())),
})

local loadedPlugins = {}
local marketplaceCache = nil

local function getMarketplace()
	if not marketplaceCache then
		marketplaceCache = PluginLoader.GetPluginsMarketplace()
	end
	return marketplaceCache
end

local kilang = require("@Kilang")
local Transpiler = require("@Transpiler")

PluginLoader.InitRenderer = function(renderer, signal, datamodel)
	PluginLoader:SetProperties({
		LoadPluginDir = function(path)
			local manifest = fs.readFile(path .. "/manifest.json")
			local json = serde.json.decode(manifest)
			local main = fs.readFile(path .. "/" .. json.main, true)

			local files = {}

			local function scan(absDir, relDir)
				relDir = relDir or ""

				for _, entry in pairs(fs.entries(absDir)) do
					local relPath = relDir == "" and entry.name or (relDir .. "/" .. entry.name)

					if entry.kind == "directory" then
						scan(absDir .. "/" .. entry.name, relPath)
					else
						print("Adding", relPath)
						files[relPath] = fs.readFile(absDir .. "/" .. entry.name, true)
					end
				end
			end

			scan(path)

			local success, result = PluginLoader.LoadPluginCode(files)

			print("Got result from plugin " .. json.id .. "\n" .. tostring(success) .. "\n" .. tostring(result))

			return success, result
		end,

		LoadPluginCode = function(files)
			repeat
				task.wait()
			until datamodel.Loaded == true

			local success, result = pcall(function()
				-- find manifest inside zip
				local manifestRaw = files["manifest.json"]
				if not manifestRaw then
					print("Manifest does not exist in zip")
					return false
				end

				local json = serde.json.decode(buffer.tostring(manifestRaw))
				if not json then
					print("Failed to decode manifest")
					return false
				end

				local plugin_id = json.id
				local plugin_boot = json.main
				local plugin_intents = json.intents

				local resolved_intents = {}

				for i, intent in pairs(plugin_intents) do
					resolved_intents[i] = Enum.PluginIntents[intent]
				end

				if loadedPlugins[plugin_id] then
					print("Plugin already loaded")
					return false
				end

				-- dependency check
				if json.dependencies then
					for dep in pairs(json.dependencies) do
						if not loadedPlugins[dep] then
							print("Missing dependency: " .. dep)
							return false
						end
					end
				end

				-- schema validation
				local ok, path, err = plugin_schema:validate(json)
				if not ok then
					print("Invalid manifest at", path, "-", err)
					return false
				end

				-- resolve deps
				if json.dependencies then
					for dep, versionWanted in pairs(json.dependencies) do
						local existing = loadedPlugins[dep]

						if existing then
							local gotVersion = existing.manifest.version
							if not satisfiesVersion(versionWanted, gotVersion) then
								print(
									`Dependency "{dep}" loaded as {gotVersion} but {plugin_id} requires {versionWanted}`
								)
								return
							end
						else
							local marketplace = getMarketplace()
							local depEntry = marketplace[dep]

							if not depEntry then
								print(`Missing dependency "{dep}" not found in marketplace`)
								return
							end

							if not satisfiesVersion(versionWanted, depEntry.manifest.version) then
								print(
									`Marketplace has "{dep}@{depEntry.manifest.version}" but {plugin_id} requires {versionWanted}`
								)
								return
							end

							local depSuccess, depResult = PluginLoader.DownloadPlugin(depEntry.manifest, true)
							if not depSuccess then
								print(`Failed to auto-install dependency "{dep}": {tostring(depResult)}`)
								return
							end
						end
					end
				end

				-- read main file directly from zip
				local mainPath = plugin_boot
				local plugin_boot_read = files[mainPath]

				if not plugin_boot_read then
					print("Main file does not exist in zip:", mainPath)
					return false
				end

				local source = buffer.tostring(plugin_boot_read)

				local plugin_require

				local function plugin_run(source, path)
					local _, success, result = kilang:execute(source, {
						SecurityCapabilities = Enum.SecurityCapabilities.Internals,
						StackId = path,
					}, {
						GetFileContents = function(fileName)
							return files[fileName]
						end,
						game = datamodel,
						require = plugin_require,
						ThreadPluginIntents = resolved_intents,
						PluginId = plugin_id,
					})

					print(kilang.env)
					return success, result
				end

				local requireCache = {}

				plugin_require = function(filePath)
					if requireCache[filePath] ~= nil then
						return requireCache[filePath]
					end

					if filePath:sub(1, 1) == "@" then
						local rest = filePath:sub(2)

						if rest == "Transpiler" then
							requireCache[filePath] = Transpiler
							return Transpiler
						end

						-- @engine/libname -> engine library via host require
						local engineLib = rest:match("^engine/(.+)$")
						if engineLib then
							local result = require("@" .. engineLib)
							requireCache[filePath] = result
							return result
						end

						-- @pluginid -> inter-plugin require
						local plugin = loadedPlugins[rest]
						if plugin then
							requireCache[filePath] = plugin.module
							return plugin.module
						end

						-- fallback to host require
						return require(filePath)
					end

					local normalized = filePath:gsub("^%./", "")
					local file: buffer? = files[normalized]

					if not file then
						warn(`[PluginLoader] require("{filePath}") -> file not found in plugin bundle`)
						return nil
					end

					local ext = normalized:match("%.([^%.]+)$")
					if ext == "lua" or ext == "luau" then
						local source = buffer.tostring(file)
						local success, result = plugin_run(source, filePath)

						if not success then
							warn("[PluginLoader] Failed to load file: " .. tostring(filePath), result)
							return nil
						end
						requireCache[filePath] = result
						return result
					else
						requireCache[filePath] = file
						return file
					end
				end

				local success, result = plugin_run(source, plugin_id)

				if not success then
					print(`Failed to load plugin {plugin_id}: {result}`)
					return false
				end

				loadedPlugins[plugin_id] = {
					manifest = json,
					module = result,
					files = files, -- keep zip in memory
				}

				if type(result) ~= "table" then
					print(`Plugin {plugin_id} does not return table`)
					return false
				end

				if type(result.activate) ~= "function" then
					print(`Expected function for activate, got {type(result.activate)}`)
					return false
				end

				if type(result.deactivate) ~= "function" then
					print(`Expected function for deactivate, got {type(result.deactivate)}`)
					return false
				end

				result.activate({
					Renderer = renderer,
					Signal = signal,
				})

				return true
			end)

			return success, result
		end,

		DownloadPlugin = function(pluginManifest, autoLoad)
			if type(pluginManifest) == "string" then
				local marketplace = PluginLoader.GetPluginsMarketplace()
				local found = marketplace and marketplace[string.lower(pluginManifest)]

				if not found then
					return false, "Plugin not found"
				end

				pluginManifest = found.manifest
			end
			local downloader = require("@Downloader")

			local function repoToZip(url, refType, ref)
				local user, repo = url:match("github%.com/([^/]+)/([^/]+)")
				if not user or not repo then
					return nil, "Invalid GitHub URL"
				end

				repo = repo:gsub("%.git$", "")

				refType = refType or "branch"
				ref = ref or "main"

				local typePath = refType == "tag" and "tags" or "heads"

				return ("https://github.com/%s/%s/archive/refs/%s/%s.zip"):format(user, repo, typePath, ref)
			end

			local dest = "./plugins/" .. pluginManifest.id .. ".kineplug"
			local zip = repoToZip(pluginManifest.repository, "branch", pluginManifest.branch or "main")

			local downloaded = downloader.download(zip, dest)

			local decoded = libzip.read(downloaded :: buffer)
			local normalized = {}

			for path, data in pairs(decoded) do
				local stripped = path:gsub("^[^/]+/", "")
				normalized[stripped] = data
			end

			local success, result

			if autoLoad then
				success, result = PluginLoader.LoadPluginCode(normalized)
			end

			return success, result, normalized
		end,

		UnloadPlugin = function(pluginId)
			local plugin = loadedPlugins[pluginId]

			if not plugin then
				print(`Plugin {pluginId} does not exist`)
				return
			end

			plugin.module.deactivate({
				Renderer = renderer,
				Signal = signal,
			})

			loadedPlugins[pluginId] = nil
		end,

		GetLoadedPlugins = function()
			return loadedPlugins
		end,

		GetPluginApi = function(id)
			local plugin = loadedPlugins[id]
			return plugin and plugin.module or nil
		end,

		GetPluginsMarketplace = function()
			local HttpService = datamodel:GetService("HttpService")

			local decoded, response = HttpService:GetAsync(ENGINE_ENDPOINT.MARKETPLACE, {
				["User-Agent"] = "Kinemium-Engine",
			})

			if type(response) == "string" then
				if string.find(response, "UnknownHostName") then
					return nil, "Invalid host name"
				end
			end

			local success, result = pcall(function()
				return HttpService:JSONDecode(decoded)
			end)

			if not success then
				print("Failed decoding json: " .. result)
				return {}
			end

			decoded = result

			local base64 = zune.serde.base64
			local marketplaceUrl = ENGINE_ENDPOINT.MARKETPLACE

			local function decodeImageBlob(value)
				if type(value) ~= "string" or value == "" then
					return nil
				end

				local b64 = value:match("^data:[^;]+;base64,(.+)$")
				if b64 then
					return base64.decode(buffer.fromstring(b64))
				end

				-- keep remote assets as URLs; do not fetch here to avoid blocking UI thread
				if value:match("^https?://") then
					return nil
				end

				-- plain base64 payload without data: prefix
				local ok, decodedValue = pcall(base64.decode, buffer.fromstring(value))
				if ok then
					return decodedValue
				end

				return nil
			end

			local list = {}

			for _, entry in ipairs(decoded.plugins or {}) do
				local manifest = entry.manifest
				if not manifest or not manifest.id then
					continue
				end

				local iconBlob = decodeImageBlob(entry.icon)
				local thumbnailBlob = decodeImageBlob(entry.thumbnail)

				if not iconBlob and entry.assets and entry.assets.iconUrl then
					iconBlob = decodeImageBlob(entry.assets.iconUrl)
				end

				if not thumbnailBlob and entry.assets and entry.assets.thumbnailUrl then
					thumbnailBlob = decodeImageBlob(entry.assets.thumbnailUrl)
				end

				list[manifest.id] = {
					manifest = manifest,
					url = entry.url
						or (entry.download and resolveUrl(marketplaceUrl, entry.download.url))
						or resolveUrl(marketplaceUrl, entry.detailsUrl),
					thumbnail = thumbnailBlob,
					icon = iconBlob,
					iconUrl = resolveUrl(marketplaceUrl, entry.icon or (entry.assets and entry.assets.iconUrl)),
					thumbnailUrl = resolveUrl(
						marketplaceUrl,
						entry.thumbnail or (entry.assets and entry.assets.thumbnailUrl)
					),
				}
			end

			return list
		end,
	})

	task.spawn(function()
		repeat
			task.wait()
		until datamodel.Loaded == true
		local entries = zune.fs.entries("./plugins")
		for _, entry in pairs(entries) do
			local path = "./plugins/" .. entry.name
			if entry.kind == "directory" then
				PluginLoader.LoadPluginDir(path)
			elseif entry.kind == "file" then
				if string.find(entry.name, ".kineplug") then
					local contents = fs.readFile(path, true)
					local decoded = libzip.read(contents)
					local normalized = {}

					for path, data in pairs(decoded) do
						local stripped = path:gsub("^[^/]+/", "")
						normalized[stripped] = data
					end
					PluginLoader.LoadPluginCode(normalized)
				elseif string.find(entry.name, ".rbxm") then
					-- make a special task for this one
					task.spawn(function()
						repeat
							task.wait()
						until datamodel.Loaded == true

						task.wait(2)

						warn(`Running RBXM plugin {entry.name}`)

						local RBXModelImporter = datamodel:GetService("RBXModelImporter")
						local ScriptContext = datamodel:GetService("ScriptContext")
						local contents = fs.readFile(path, true)
						local imported = RBXModelImporter.ImportModel(contents)

						imported.Parent = datamodel:GetService("Plugin")

						if imported:IsA("Script") then
							warn(`[PLUGIN LOADER]	Running {imported.Name}`)
							print(imported.Source)

							local thread, id, success, result = ScriptContext.MakeThreadObject(imported)
							print(thread, id, success, result)
						end

						for _, Script in pairs(imported:GetDescendants()) do
							if Script:IsA("Script") then
								warn(`[PLUGIN LOADER]	Running {Script.Name}`)

								local thread, id, success, result = ScriptContext.MakeThreadObject(Script)
								print(thread, id, success, result)
							end
						end
					end)
				end
			end
		end
	end)

	task.spawn(function()
		repeat
			task.wait()
		until datamodel.Loaded == true
		local pluginArg = GetFlagValue("plugin")
		if pluginArg then
			PluginLoader.LoadPluginDir(pluginArg)
		end
	end)
end

return PluginLoader
