local Instance = require("@Instance")
local signal = require("@Kinemium.signal")

local fs = zune.fs

local KinemiumIconLoader = Instance.new("KinemiumIconLoader")
KinemiumIconLoader.ExplorerHidden = true

local general = "./src/assets/images/icons/vanilla3/general/32x/200"
local objects = "./src/assets/images/icons/vanilla3/instance/16x/200"
local kinemiumIcons = "./src/assets/images/icons/vanilla3/kinemium"

KinemiumIconLoader.InitRenderer = function(renderer, renderer_signal)
	local registry = {}
	local textures = {}

	local function reload()
		table.clear(registry)
		table.clear(textures)

		for _, file in pairs(fs.entries(general)) do
			registry[file.name] = general .. "/" .. file.name
		end

		for _, file in pairs(fs.entries(objects)) do
			registry[file.name] = objects .. "/" .. file.name
		end

		for _, file in pairs(fs.entries(kinemiumIcons)) do
			registry[file.name] = kinemiumIcons .. "/" .. file.name
		end
	end

	KinemiumIconLoader:SetProperties({
		Reload = reload,
		ToTexture = function(path: string)
			local texture = renderer.lib.LoadTexture(path)
			local size = vector.create(buffer.readi32(texture, 4), buffer.readi32(texture, 8))

			return {
				texture = texture,
				x = size.x,
				y = size.y,
			}
		end,
		new = function(name, path)
			registry[name] = path
		end,
		Get = function(name)
			return registry[name]
		end,
		Remove = function(name)
			registry[name] = nil
		end,
		Change = function(name, newPath)
			if not registry[name] then
				return
			end
			registry[name] = newPath
		end,
	})

	reload()

	return registry
end

return KinemiumIconLoader
