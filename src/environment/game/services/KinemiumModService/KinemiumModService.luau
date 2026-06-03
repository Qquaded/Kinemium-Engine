local Instance = require("@Instance")
local Enum = require("@EnumMap")

export type KinemiumMod = {
	Name: string,
	Version: string,
	Author: string?,
	Description: string?,
	Dependencies: { string }?,
	Settings: { [string]: any }?,
	Init: (self: any, engine: any) -> (),
	Destroy: ((self: any) -> ())?,
}

local namespaces = {}

local KinemiumModService = Instance.new("KinemiumModService")
KinemiumModService.ExplorerHidden = true
KinemiumModService._Intents = Enum.PluginIntents.Threading

local mods_cache = {}

KinemiumModService.InitRenderer = function(renderer, renderer_signal)
	KinemiumModService:SetProperties({
		modenv = {},

		Register = function(self, mod: KinemiumMod)
			mods_cache[mod.Name] = {
				Name = mod.Name,
				Version = mod.Version,
				Author = mod.Author,
				Description = mod.Description,
				Dependencies = mod.Dependencies,
				Destroy = mod.Destroy,
			}

			if mod.Init then
				mod.Init(mod, KinemiumModService.modenv)
			end

			return true
		end,

		luau = {
			NewVM = function(options, environment) end,
		},
	})

	function KinemiumModService:ExposeNamespace(namespace, methods)
		namespaces[namespace] = methods
	end
end

return KinemiumModService
