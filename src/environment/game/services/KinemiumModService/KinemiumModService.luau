local Instance = require("@Instance")
local Enum = require("@EnumMap")
local Schema = require("@Schema")
local kilang = require("@Kilang")

local enabled_mods = {}

local KinemiumModService = Instance.new("KinemiumModService")
KinemiumModService.ExplorerHidden = true
KinemiumModService._Intents = Enum.PluginIntents.Threading

export type ModSchemaType = {
	files: typeof(Schema.new()),
	manifest: typeof(Schema.new()),
}

export type ManifestDecoder = "JSON" | "JSON5" | "TOML" | "YAML"

KinemiumModService.InitRenderer = function(renderer, renderer_signal, datamodel)
	KinemiumModService:SetProperties({})

	function KinemiumModService:GetEnabledMods()
		return enabled_mods
	end

	function KinemiumModService:CreateModManager()
		-- detect if editor
		if not IsClient and not IsServer then
			print("Cannot create mod manager in engine editor mode")
			return
		end
		local mod_manager = {
			environment = {},
			manifest_decoder = "JSON",
		}

		local ScriptContext = datamodel:GetService("ScriptContext")

		local mod_schema = nil

		function mod_manager:CreateModSchema(schema: ModSchemaType)
			if type(schema) ~= "table" then
				return false
			end
			if not schema.manifest then
				return false
			end
			if not schema.files then
				return false
			end
			mod_schema = schema
			return true
		end

		function mod_manager:SetManifestDecoder(decoder: ManifestDecoder)
			local valid = { JSON = true, JSON5 = true, YAML = true, TOML = true }
			if not valid[decoder] then
				return false, "unknown decoder: " .. tostring(decoder)
			end
			mod_manager.manifest_decoder = decoder
			return true
		end

		function mod_manager:ExposeGlobal(name, value)
			mod_manager.environment[name] = value
		end

		function mod_manager:RemoveGlobal(name)
			mod_manager.environment[name] = nil
		end

		function mod_manager:RunThread(code, language)
			ScriptContext = datamodel:GetService("ScriptContext")
			if ScriptContext then
				return ScriptContext.RunSource(code, language)
			end
			return false
		end

		function mod_manager:ValidateMod(manifest, files)
			if mod_schema then
				return mod_schema.manifest:validate(manifest), mod_schema.files:validate(files)
			end
			return false
		end

		function mod_manager:LoadSourceWithGlobals(source, language, opts)
			local clone = table.clone(mod_manager.environment)

			if opts then
				for key, val in pairs(opts) do
					clone[key] = val
				end
			end

			return kilang:execute(source, {}, clone)
		end

		function mod_manager:UnloadMod(name)
			if enabled_mods[name] then
				local thread = enabled_mods[name].thread
				task.cancel(thread)
				enabled_mods[name] = nil
			end
		end

		function mod_manager:ReloadMod(name)
			local path = enabled_mods[name].path
			mod_manager:UnloadMod(name)
			return mod_manager:LoadMod(path)
		end

		function mod_manager:LoadMod(path)
			local function read(file)
				local toRead = path .. "/" .. file
				return zune.fs.readFile(toRead)
			end

			local manifest = read(`manifest.{string.lower(mod_manager.manifest_decoder)}`)
			if manifest then
				local decoder
				if mod_manager.manifest_decoder == "JSON" then
					decoder = zune.serde.json
				elseif mod_manager.manifest_decoder == "JSON5" then
					decoder = zune.serde.json5
				elseif mod_manager.manifest_decoder == "YAML" then
					decoder = zune.serde.yaml
				elseif mod_manager.manifest_decoder == "TOML" then
					decoder = zune.serde.toml
				end

				if not decoder then
					error("Did not find manifest decoder for " .. mod_manager.manifest_decoder)
					return false
				end

				local result = decoder.decode(manifest)

				if result then
					if not mod_schema then
						error("mod_schema is not set")
						return false
					end
					local isValid = mod_schema.manifest:validate(result)

					if isValid then
						local files = {}

						local list = zune.fs.entries(path .. "/")

						if list then
							for _, entry in pairs(list) do
								files[entry.name] = {
									name = entry.name,
									path = path .. "/" .. entry.name,
									kind = entry.kind,
								}
							end
						else
							error("no entries found", list)
							return false
						end

						local filesValid = mod_schema.files:validate(files)

						if not filesValid then
							error("files in schema are not valid")

							return false
						end

						local entry_source = read(result.entry)
						if not entry_source then
							return false, "entry file not found: " .. tostring(result.entry)
						end
						local _, success, thread_result, thread =
							mod_manager:LoadSourceWithGlobals(entry_source, result.language or "luau", {
								modPath = path,
							})
						if not success then
							error("Got error " .. thread_result)
							return false
						end
						enabled_mods[result.name] = {
							manifest = result,
							thread = thread,
							path = path,
						}
						return true, thread_result
					else
						error("Manifest isn't valid")
						return false
					end
				else
					error("Got error while decoding manifest")
					return false
				end
			else
				error("Manifest does not exist")
				return false
			end
		end

		return mod_manager
	end
end

return KinemiumModService
