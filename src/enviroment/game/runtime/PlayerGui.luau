local Instance = require("@Instance")
local signal = require("@Kinemium.signal")

local PlayerGui = Instance.new("PlayerGui")

PlayerGui.InitRenderer = function(renderer, renderer_signal, datamodel)
	PlayerGui:SetProperties({
		ResetOnSpawn = true,
	})

	PlayerGui.ChildAdded:Connect(function(child)
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

	return PlayerGui
end

return PlayerGui
