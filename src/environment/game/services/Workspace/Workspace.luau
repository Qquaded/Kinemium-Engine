local Instance = require("@Instance")
local Workspace = Instance.new("Workspace")
local Enum = require("@EnumMap")
local argon = require("@argon")

Workspace._Intents = Enum.PluginIntents.Graphic

local materialTextures = {}

Workspace.InitRenderer = function(renderer, signal, game)
	Workspace:SetProperties({
		Test = 1,
		MaterialMode = Enum.WorkspaceMaterialMode.Compressed,
	})

	local material_index = {}

	for _, material in pairs(Enum.Material:GetEnumItems()) do
		material_index[material.Value] = material
	end

	local function fillMaterialTex(WorkspaceMaterialMode)
		if WorkspaceMaterialMode == Enum.WorkspaceMaterialMode.Compressed then
			local path = "./src/assets/materials/compressed"
			local entries = zune.fs.entries(path)
			for _, dir in pairs(entries) do
				if dir.kind ~= "directory" then
					continue
				end

				local albedo_tex = path .. `/{dir.name}/albedo.png` -- assume pngs

				local image = adapter.lib.LoadImage(albedo_tex)
				local texture = adapter.lib.LoadTextureFromImage(image)
				adapter.lib.UnloadImage(image)
				adapter.lib.GenTextureMipmaps(texture)
				materialTextures[material_index[dir.name]] = renderer.CreateFilamentMaterial(texture)
			end
		end
	end

	local function getMaterialKind(materialEnum)
		if not materialEnum then
			return 0
		end
		if materialEnum == Enum.Material.Glass then
			return 1
		end
		if materialEnum == Enum.Material.Neon then
			return 2
		end
		if materialEnum == Enum.Material.Water then
			return 3
		end
		return 0
	end
end

return Workspace
