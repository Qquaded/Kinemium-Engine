local Instance = require("@Instance")
local Enum = require("@EnumMap")
local signal = require("@Kinemium.signal")
local structs = require("@raylibadapter").structs

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

	CoreGui.ChildAdded:Connect(function(child)
		if type(child) == "table" and child.BaseClass == "UIContainer" then
			if child["render"] then
				local renderId
				renderId = renderer.Pool.new("2d", function()
					if not child.render then
						renderer.Pool.Destroy(renderId)
						return
					end
					local dt = renderer.Lib2d.GetFrameTime()
					child.render(renderer.Lib2d, child, dt, structs, renderer, datamodel)
				end, -5)
			end
		end
	end)

	return CoreGui
end

return CoreGui
