local KinemiumRaylib = game:GetService("KinemiumRaylib")
local RunService = game:GetService("RunService")
local renderer = KinemiumRaylib.GetRenderer()
local freecam = renderer.Freecam
local raylib = require("@raylib")

RunService.RenderStepped:Connect(function(a0: number)
	local camera = workspace.Camera
	if camera then
		if ishared.EnableHomescreen == true then
			return
		end
		if game.Stop3DInput == true then
			return
		end
		if game.StopCameraInput == true then
			return
		end

		local dt = raylib.lib.GetFrameTime()
		freecam.Update(dt, camera)
	end
end)
