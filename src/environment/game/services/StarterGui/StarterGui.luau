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
						local dt = renderer.Raylib.lib.GetFrameTime()
						child.render(renderer.Raylib.lib, child, dt, renderer.Raylib.structs, renderer, datamodel)
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
	end)
	return StarterGui
end

return StarterGui
