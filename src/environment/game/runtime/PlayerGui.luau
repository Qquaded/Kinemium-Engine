local Instance = require("@Instance")
local GuiMirror = require("./GuiMirror")

local PlayerGui = Instance.new("PlayerGui")
local guiMirroringBound = false
local guiMirrorController = nil

PlayerGui.InitRenderer = function(renderer, renderer_signal, datamodel)
	PlayerGui:SetProperties({
		ResetOnSpawn = true,
	})
	GuiMirror.MarkTreeLocalOnly(PlayerGui)

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

	if datamodel and guiMirroringBound == false then
		guiMirroringBound = true
		guiMirrorController = GuiMirror.new(PlayerGui)
		guiMirrorController:BindContainer(datamodel.StarterGui, "StarterGui")
	end

	return PlayerGui
end

return PlayerGui
