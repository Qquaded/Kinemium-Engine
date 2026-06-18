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
		local name = coreGuiType.Name

		if name then
			coreGuiTypes[name] = enabled
		end
	end

	function CoreGui:GetCore(coreName)
		return cores_registry[coreName]
	end

	function CoreGui:SetCore(parameterName: string, value: Variant)
		CoreGui.CoreGuiChangedSignal:Fire(parameterName, value)

		cores_registry[parameterName] = value
	end

	function CoreGui:GetCoreGuiEnabled(coreGuiType)
		local name = coreGuiType.Name

		if name then
			return coreGuiTypes[name]
		end
		return false
	end

	CoreGui.ChildAdded:Connect(function(child)
		if type(child) == "table" and child.BaseClass == "UIContainer" then
			if child["render"] then
				local renderId
				renderId = renderer.Pool.new("2d", function()
					if not child.render then
						renderer.Pool.Destroy(renderId)
						return
					end
					local dt = renderer.Raylib.lib.GetFrameTime()
					child.render(renderer.Raylib.lib, child, dt, renderer.Raylib.structs, renderer, datamodel)
				end, -5)
			end
		end
	end)

	return CoreGui
end

return CoreGui
