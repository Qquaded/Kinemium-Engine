local Instance = require("@Instance")
local Workspace = Instance.new("Workspace")
local Enum = require("@EnumMap")

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

	renderer.Hook.new("Renderstep", function() end)
end

return Workspace
