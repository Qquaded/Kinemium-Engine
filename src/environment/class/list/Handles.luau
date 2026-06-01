-- description: "A 3d handle that can be moved or scaled and appears under an Adornee."
local Color3 = require("@Color3")
local signal = require("@kinemium.signal")
local Enum = require("@EnumMap")
local ffi = zune.ffi
local CFrame = require("@CFrame")
local Vector3 = require("@Vector3")

local propTable = {
	Color = Color3.new(0.5, 0.5, 0.5),
	Adornee = nil,
	CastShadows = false,
	Name = "Handles",

	-- signals
	MouseButton1Down = signal.new(),
	MouseButton1Up = signal.new(),
	MouseDrag = signal.new(),
	MouseEnter = signal.new(),
	MouseLeave = signal.new(),

	-- enum
	Style = Enum.HandlesStyle.Movement,
	RotationSnap = 0,

	_gizmoTransform = ffi.alloc(12 + 16 + 12),
	_isDragging = false,
}

return {
	class = "Handles",

	callback = function(instance, renderer)
		local gizmo = require("@gizmo")

		instance.Changed:Connect(function(prop)
			if prop == "Adornee" then
				local part = instance.Adornee
				if part == nil then
					return
				end
				if part and part.BaseClass == "BasePart" then
					local pos = part.CFrame.Position
					instance._gizmoTransform:writef32(0, pos.X)
					instance._gizmoTransform:writef32(4, pos.Y)
					instance._gizmoTransform:writef32(8, pos.Z)

					local x, y, z, w = part.CFrame:ToQuaternion()
					instance._gizmoTransform:writef32(12, x)
					instance._gizmoTransform:writef32(16, y)
					instance._gizmoTransform:writef32(20, z)
					instance._gizmoTransform:writef32(24, w)

					local size = part.Size
					instance._gizmoTransform:writef32(28, size.X)
					instance._gizmoTransform:writef32(32, size.Y)
					instance._gizmoTransform:writef32(36, size.Z)
				elseif part and part.ClassName == "Model" then
					local pivot = part:GetPivot()
					local pos = pivot.Position
					instance._gizmoTransform:writef32(0, pos.X)
					instance._gizmoTransform:writef32(4, pos.Y)
					instance._gizmoTransform:writef32(8, pos.Z)

					local x, y, z, w = pivot:ToQuaternion()
					instance._gizmoTransform:writef32(12, x)
					instance._gizmoTransform:writef32(16, y)
					instance._gizmoTransform:writef32(20, z)
					instance._gizmoTransform:writef32(24, w)

					local size = part:GetExtentsSize()
					instance._gizmoTransform:writef32(28, math.max(size.X, 0.001))
					instance._gizmoTransform:writef32(32, math.max(size.Y, 0.001))
					instance._gizmoTransform:writef32(36, math.max(size.Z, 0.001))
				end
			end
		end)

		propTable.render = function(handles, renderer, datamodel)
			if handles.Adornee then
				local part = handles.Adornee
				if part and part:IsA("BasePart") then
					if not handles._isDragging then
						local pos = part.CFrame.Position
						handles._gizmoTransform:writef32(0, pos.X)
						handles._gizmoTransform:writef32(4, pos.Y)
						handles._gizmoTransform:writef32(8, pos.Z)

						local x, y, z, w = part.CFrame:ToQuaternion()
						handles._gizmoTransform:writef32(12, x)
						handles._gizmoTransform:writef32(16, y)
						handles._gizmoTransform:writef32(20, z)
						handles._gizmoTransform:writef32(24, w)

						local size = part.Size
						handles._gizmoTransform:writef32(28, size.X)
						handles._gizmoTransform:writef32(32, size.Y)
						handles._gizmoTransform:writef32(36, size.Z)
					end
				elseif part and part.ClassName == "Model" then
					if not handles._isDragging then
						local pivot = part:GetPivot()
						local pos = pivot.Position
						handles._gizmoTransform:writef32(0, pos.X)
						handles._gizmoTransform:writef32(4, pos.Y)
						handles._gizmoTransform:writef32(8, pos.Z)

						local x, y, z, w = pivot:ToQuaternion()
						handles._gizmoTransform:writef32(12, x)
						handles._gizmoTransform:writef32(16, y)
						handles._gizmoTransform:writef32(20, z)
						handles._gizmoTransform:writef32(24, w)

						local size = part:GetExtentsSize()
						handles._gizmoTransform:writef32(28, math.max(size.X, 0.001))
						handles._gizmoTransform:writef32(32, math.max(size.Y, 0.001))
						handles._gizmoTransform:writef32(36, math.max(size.Z, 0.001))
					end
				end

				local success = false

				if handles.Style == Enum.HandlesStyle.Movement then
					success = gizmo.DrawGizmo3D(gizmo.Flags.TRANSLATE, handles._gizmoTransform)
				elseif handles.Style == Enum.HandlesStyle.Rotation then
					success = gizmo.DrawGizmo3D(gizmo.Flags.ROTATE, handles._gizmoTransform)
				elseif handles.Style == Enum.HandlesStyle.Resize then
					success = gizmo.DrawGizmo3D(gizmo.Flags.SCALE, handles._gizmoTransform)
				end

				handles._isDragging = success

				if success then
					local gt = handles._gizmoTransform
					local pos = Vector3.new(gt:readf32(0), gt:readf32(4), gt:readf32(8))
					local qx, qy, qz, qw = gt:readf32(12), gt:readf32(16), gt:readf32(20), gt:readf32(24)

					local newCF = CFrame.fromQuaternion(qx, qy, qz, qw, pos)
					local newScale = Vector3.new(gt:readf32(28), gt:readf32(32), gt:readf32(36))

					handles.Transform = newCF
					instance.MouseDrag:Fire(newCF, newScale)
				end
			end
		end

		instance:SetProperties(propTable)

		return instance
	end,

	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
