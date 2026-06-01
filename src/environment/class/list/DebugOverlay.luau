-- description: "Creates a debug overlay of 3d instances in the current environment."
local raylib = require("@raylib")
local lib = raylib.lib
local structs = raylib.structs
local const = raylib.const

local propTable = {
	Enabled = true,
	ShowWireframes = true,
	ShowAttachments = true,
	ShowNormals = false,
	Name = "DebugOverlay",
}

return {
	class = "DebugOverlay",

	callback = function(instance, renderer, datamodel)
		instance:SetProperties(propTable)

		if _G.IsHeadless or not renderer then
			return instance
		end

		local renderId = renderer.Pool.new("gizmo", function()
			if not instance.Enabled then
				return
			end

			local workspace = datamodel:GetService("Workspace")
			if not workspace then
				return
			end

			local parts = workspace:Get3DObjects()
			for _, part in ipairs(parts) do
				if not part.CFrame or not part.Size then
					continue
				end

				local matrix = part.CFrame:ToRaylibMatrixScale(part.Size, structs)

				if instance.ShowWireframes then
					lib.rlPushMatrix()
					lib.rlMultMatrixf(matrix)
					lib.DrawCubeWires(vector.create(0, 0, 0), 1, 1, 1, const.LIME)
					lib.rlPopMatrix()
				end

				if instance.ShowAttachments then
					for _, child in ipairs(part:GetChildren()) do
						if child:IsA("Attachment") then
							local worldPos = part.CFrame * child.Position
							lib.DrawSphere(vector.create(worldPos.X, worldPos.Y, worldPos.Z), 0.1, const.ORANGE)
						end
					end
				end
			end
		end)

		instance.Destroying:Connect(function()
			if renderId then
				renderer.Pool.Destroy(renderId)
			end
		end)

		return instance
	end,
}
