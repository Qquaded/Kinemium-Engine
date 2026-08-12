local Instance = require("@Instance")
local StarterGui = Instance.new("StarterGui")
local Enum = require("@EnumMap")

StarterGui:SetProperties({
	Enabled = true,
	ResetOnSpawn = true,
	ZIndexBehavior = "Sibling",
	CoreGuiEnabled = true,
})

StarterGui._Intents = Enum.PluginIntents.UI

StarterGui.InitRenderer = function(renderer, signal, datamodel)
	task.spawn(function()
		repeat
			task.wait()
		until datamodel.Loaded == true

		local CoreGui = datamodel:GetService("CoreGui")

		local cache = {}

		local function renderGui(child)
			if cache[child.UniqueId] then
				return
			end

			if type(child) == "table" and child.BaseClass == "UIContainer" then
				if child["render"] then
					local renderId
					renderId = renderer.Pool.new("2d", function()
						if not child.render then
							renderer.Pool.Destroy(renderId)
							return
						end
						local dt = renderer.Lib2d.GetFrameTime()
						--child.render(renderer.Lib2d, child, dt, adapter.structs, renderer, datamodel)
					end, -5)
					cache[child.UniqueId] = renderId
				end
			end
		end

		StarterGui.ChildAdded:Connect(function(child)
			renderGui(child)
		end)

		for _, child in pairs(StarterGui:GetChildren()) do
			renderGui(child)
		end

		function StarterGui:SetCoreGuiEnabled(coreGuiType, enabled: boolean)
			CoreGui:SetCoreGuiEnabled(coreGuiType, enabled)
		end

		function StarterGui:GetCore(coreName)
			return CoreGui:GetCore(coreName)
		end

		function StarterGui:SetCore(parameterName: string, value)
			CoreGui:SetCore(parameterName, value)
		end

		function StarterGui:GetCoreGuiEnabled(coreGuiType)
			return CoreGui:GetCoreGuiEnabled(coreGuiType)
		end
	end)
	return StarterGui
end

return StarterGui
