local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Selection = game:GetService("Selection")

if RunService:IsClient() then
	return
end

_G.IsHoveringOnWindow = _G.IsHoveringOnWindow or false

local player = Players.LocalPlayer
while not player do
	task.wait()
	player = Players.LocalPlayer
end

local mouse = player:GetMouse()

local Highlight = Instance.new("Highlight")
Highlight.FillTransparency = 0.9
Highlight.OutlineTransparency = 0
Highlight.FillColor = Color3.new(0, 0.682, 1)
Highlight.OutlineColor = Color3.new(0, 0.306, 1)
Highlight.Parent = game.InternalStorage

local dragging = false
local draggedObject = nil
local rotationCF = CFrame.new()

RunService.RenderStepped:Connect(function()
	if dragging and draggedObject and mouse.Hit then
		local ROTATION_STEP = math.rad(90)

		if UserInputService:IsKeyReleased(Enum.KeyCode.R) then
			rotationCF = rotationCF * CFrame.fromEulerAnglesYXZ(0, ROTATION_STEP, 0)
		elseif UserInputService:IsKeyReleased(Enum.KeyCode.T) then
			rotationCF = rotationCF * CFrame.fromEulerAnglesYXZ(ROTATION_STEP, 0, 0)
		elseif UserInputService:IsKeyReleased(Enum.KeyCode.Y) then
			rotationCF = rotationCF * CFrame.fromEulerAnglesYXZ(0, 0, ROTATION_STEP)
		end

		local normal = mouse.TargetSurface or Vector3.new(0, 1, 0)

		local right = rotationCF:GetRightVector()
		local up = rotationCF:GetUpVector()
		local look = rotationCF:GetLookVector()
		if not draggedObject.Size then
			return
		end
		local size = draggedObject.Size * 0.5

		local extent = math.abs(normal:Dot(right)) * size.X
			+ math.abs(normal:Dot(up)) * size.Y
			+ math.abs(normal:Dot(look)) * size.Z

		local targetPos = mouse.Hit.Position + normal * extent

		local grid = ishared.Grid or 0
		if grid > 0 then
			targetPos = Vector3.new(
				math.round(targetPos.X / grid) * grid,
				math.round(targetPos.Y / grid) * grid,
				math.round(targetPos.Z / grid) * grid
			)
		end

		draggedObject.CFrame = CFrame.new(targetPos) * rotationCF

		if UserInputService:IsMouseButtonReleased(Enum.MouseButton.Left) then
			dragging = false
			Selection.Remove({ draggedObject })
			draggedObject = nil
			mouse.TargetFilter = {}
			ishared.ForceMoveObject = true
			ishared.MouseDragging = false
			if ishared.Update3DHandles then
				ishared.Update3DHandles()
			end
		end

		return
	end

	if UserInputService:IsMouseButtonDown(Enum.MouseButton.Left) then
		if ishared.isToolsActive then
			return
		end
		if _G.IsHoveringOnWindow == true then
			return
		end
		if mouse.Target and mouse.Target:IsA("BasePart") then
			if mouse.Target.Size.X > 200 or mouse.Target.Size.Y > 200 or mouse.Target.Size.Z > 200 then
				Highlight.Adornee = nil
				mouse.Icon = Enum.KinemiumMouseCursor.MOUSE_CURSOR_DEFAULT
				return
			end
			if mouse.Target.Transparency > 0.3 then
				Highlight.Adornee = nil
				mouse.Icon = Enum.KinemiumMouseCursor.MOUSE_CURSOR_DEFAULT
				return
			end
			if Selection.Get()[1] and Selection.Get()[1]:IsA("Model") then
				if mouse.Target:IsDescendantOf(Selection.Get()[1]) then
					return
				end
			end

			dragging = true
			draggedObject = mouse.Target
			mouse.TargetFilter = { draggedObject }
			rotationCF = draggedObject.CFrame - draggedObject.CFrame.Position
			Selection.Add(draggedObject)
			ishared.MouseDragging = true
			ishared.ForceMoveObject = false
		end
	end

	if mouse.Target then
		if ishared.isToolsActive then
			return
		end
		if _G.IsHoveringOnWindow == true then
			return
		end
		if mouse.Target.BaseClass ~= "BasePart" then
			return
		end
		if Selection.Get()[1] and Selection.Get()[1]:IsA("Model") then
			if mouse.Target:IsDescendantOf(Selection.Get()[1]) then
				return
			end
		end
		if mouse.Target.Size.X > 200 or mouse.Target.Size.Y > 200 or mouse.Target.Size.Z > 200 then
			Highlight.Adornee = nil
			mouse.Icon = Enum.KinemiumMouseCursor.MOUSE_CURSOR_DEFAULT
			return
		end
		if mouse.Target.Transparency > 0.3 then
			Highlight.Adornee = nil
			mouse.Icon = Enum.KinemiumMouseCursor.MOUSE_CURSOR_DEFAULT
			return
		end
		Highlight.Adornee = mouse.Target
		mouse.Icon = Enum.KinemiumMouseCursor.MOUSE_CURSOR_POINTING_HAND
	else
		Highlight.Adornee = nil
		mouse.Icon = Enum.KinemiumMouseCursor.MOUSE_CURSOR_DEFAULT
	end
end)
