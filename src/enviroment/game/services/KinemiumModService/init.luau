local Instance = require("@Instance")
local signal = require("@Kinemium.signal")
local sandboxer = require("@sandboxer")

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

local KinemiumModService = Instance.new("KinemiumModService")
KinemiumModService.ExplorerHidden = true

local ModAdded = signal.new()
local ModRemoved = signal.new()
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
			run = function(code)
				-- dont ask why i added that number
				-- it was totally random
				return sandboxer.run(code, "sandboxVM#676767", KinemiumModService.modenv)
			end,
		},
	})
end

return KinemiumModService
