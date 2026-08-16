local Instance = require("@Instance")
local Enum = require("@EnumMap")
local signal = require("@Kinemium.signal")

local CoreGui = Instance.new("CoreGui")
CoreGui._Intents = Enum.PluginIntents.UI

export type Variant = any

local coreGuiTypes = {
	PlayerList = true,
	Health = true,
	Backpack = true,
	Chat = true,
	All = true,
	EmotesMenu = true,
	SelfView = true,
}

local cores_registry = {}

CoreGui.InitRenderer = function(renderer, renderer_signal, datamodel)
	CoreGui:SetProperties({
		ResetOnSpawn = true,
		CoreGuiChangedSignal = signal.new(),
	})

	function CoreGui:SetCoreGuiEnabled(coreGuiType, enabled: boolean)
		CoreGui.CoreGuiChangedSignal:Fire(coreGuiType, enabled)

		if coreGuiType.Name then
			coreGuiTypes[coreGuiType.Name] = enabled
		end
	end

	function CoreGui:GetCore(coreName)
		return cores_registry[coreName]
	end

	function CoreGui:SetCore(parameterName: string, value: Variant)
		if type(parameterName) ~= "string" then
			return
		end
		-- value is a variant, basically Any
		CoreGui.CoreGuiChangedSignal:Fire(parameterName, value)

		cores_registry[parameterName] = value
	end

	function CoreGui:GetCoreGuiEnabled(coreGuiType)
		if coreGuiType.Name then
			return coreGuiTypes[coreGuiType.Name]
		end
		return false
	end

	renderer.Pool.new("2d", function()
		for _, child in pairs(CoreGui:GetChildren()) do
			if child["render"] then
				child.render()
			end
		end
	end)

	return CoreGui
end

return CoreGui
