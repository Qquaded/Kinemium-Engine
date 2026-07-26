-- devcell

local RunService = game:GetService("RunService")
if RunService:IsServer() then
	return
end

local KinemiumFontService = game:GetService("KinemiumFontService")
local StudioThemeService = game:GetService("StudioThemeService")
local rlservice = game:GetService("KinemiumRaylib")
local adapter = require("@RaylibAdapter")
local UserInputService = game:GetService("UserInputService")

if UserInputService:GetOS() == Enum.Platform.Linux then
	-- linux not supported Yet........................
	return
end

if FlagExists("cli") or FlagExists("headless") then
	return
end

local lib = adapter.lib
local const = adapter.const
local renderer = rlservice.GetRenderer()
local Selection = game:GetService("Selection")
local freecam = renderer.Freecam
local _focusTargetCF = nil
local vend = KinemiumFontService.GetDefaultFont()
local _focusAlpha = 0
local KinemiumIconLoader = game:GetService("KinemiumIconLoader")
local moveIcon = KinemiumIconLoader.ToTexture("./src/assets/images/icons/Move.png")
local rotIcon = KinemiumIconLoader.ToTexture("./src/assets/images/icons/Rotate.png")

ishared.isToolsActive = false
ishared.Grid = 1
ishared.ForceMoveObject = false -- Disabled by default to prevent accidental dragging
ishared.RotationStep = 15

local aereon = require("@Aereon")
local Movement, Resize, Rotation = Instance.new("Handles"), Instance.new("Handles"), Instance.new("Handles")

Movement.Style = Enum.HandlesStyle.Movement
Resize.Style = Enum.HandlesStyle.Resize
Rotation.Style = Enum.HandlesStyle.Rotation

local MoveOffsets = {}
local MoveStartPivot = nil
local MoveDragging = false

local RotOffsets = {}
local RotStartPivot = nil
local RotDragging = false

local ScaleOffsets = {}
local ScaleStartPivot = nil
local ScaleDragging = false

local textbox = aereon.textbox(StudioThemeService.SelectedTheme, game)

local snapMoveEnabled = true
local snapRotEnabled = true

local function snap(v)
	if not snapMoveEnabled then
		return v
	end
	return math.round(v / ishared.Grid) * ishared.Grid
end

local function snapVec3(v)
	return Vector3.new(snap(v.X), snap(v.Y), snap(v.Z))
end

local function isModel(obj)
	return obj ~= nil and obj.ClassName == "Model"
end

local function getObjectPivot(obj)
	if obj == nil then
		return nil
	end
	if isModel(obj) then
		return obj:GetPivot()
	elseif obj.CFrame ~= nil then
		return obj.CFrame
	end
	return nil
end

local function setObjectCFrame(obj, cf)
	if obj == nil or cf == nil then
		return
	end
	if isModel(obj) then
		obj:PivotTo(cf)
	elseif obj.CFrame ~= nil then
		obj.CFrame = cf
	end
end

local function getObjectExtents(obj)
	if obj == nil then
		return Vector3.new(1, 1, 1)
	end
	if isModel(obj) then
		local s = obj:GetExtentsSize()
		return Vector3.new(math.max(s.X, 0.001), math.max(s.Y, 0.001), math.max(s.Z, 0.001))
	elseif obj.Size ~= nil then
		return obj.Size
	end
	return Vector3.new(1, 1, 1)
end

--

local function isMovable(object)
	return object:IsA("BasePart") or isModel(object) or object:GetMetadata("IsMovable")
end

local function getSelectionCenter()
	local selection = Selection:Get()
	if #selection == 0 then
		return nil
	end

	local sum = Vector3.zero
	local count = 0

	for _, obj in ipairs(selection) do
		local pivot = getObjectPivot(obj)
		if pivot ~= nil then
			sum += pivot.Position
			count += 1
		end
	end

	if count == 0 then
		return nil
	end
	return sum / count
end

local gridInput = textbox.new({
	multiline = false,
	placeholder = "1",
	fontSize = 16,
	font = vend,
	maxLength = 56,
	numeric = true,
	suffix = "    studs",
	numericMin = 0,
	numericMax = 10000,
	numericPrecision = 1,
	showStepButtons = true,
	onChange = function(new)
		if tonumber(new) and tonumber(new) > 0 then
			ishared.Grid = tonumber(new)
		else
			ishared.Grid = 1
		end
	end,
})

local rotateGrid = textbox.new({
	multiline = false,
	placeholder = "15",
	fontSize = 16,
	font = vend,
	maxLength = 56,
	numeric = true,
	suffix = "°",
	numericMin = 0,
	numericMax = 10000,
	numericPrecision = 1,
	showStepButtons = true,
	onChange = function(new)
		if tonumber(new) and tonumber(new) > 0 then
			ishared.RotationStep = tonumber(new)
		else
			ishared.RotationStep = 15
		end
		if Rotation then
			Rotation.RotationSnap = snapRotEnabled and ishared.RotationStep or 0
		end
	end,
})

local gizmo = import("@gizmo")
local _flags = gizmo.Flags
Rotation.RotationSnap = ishared.RotationStep

--  Movement

local _moveConnection = Movement.MouseDrag:Connect(function(newCF)
	if not ishared.ForceMoveObject then
		return
	end
	local selection = Selection:Get()
	if #selection == 0 then
		return
	end

	if not MoveDragging then
		MoveDragging = true
		MoveOffsets = {}

		local center = getSelectionCenter()
		MoveStartPivot = CFrame.new(center)

		for _, obj in ipairs(selection) do
			if isMovable(obj) then
				local pivot = getObjectPivot(obj)
				if pivot ~= nil then
					table.insert(MoveOffsets, {
						obj = obj,
						pos = MoveStartPivot:ToObjectSpace(pivot),
						size = getObjectExtents(obj),
					})
				end
			end
		end
	end

	local snappedPos = snapVec3(newCF.Position)
	local snappedPivot = CFrame.new(snappedPos) * (newCF - newCF.Position)

	for _, offset in ipairs(MoveOffsets) do
		local obj = offset.obj
		if obj and obj.Parent then
			local finalCF = snappedPivot * offset.pos
			setObjectCFrame(obj, finalCF)
		end
	end
end)

--  Rotation

local _rotationConnection = Rotation.MouseDrag:Connect(function(newCF)
	if not ishared.ForceMoveObject then
		return
	end
	local selection = Selection:Get()
	if #selection == 0 then
		return
	end

	if not RotDragging then
		RotDragging = true
		RotOffsets = {}

		local center = getSelectionCenter()
		RotStartPivot = CFrame.new(center)

		for _, obj in ipairs(selection) do
			if isMovable(obj) then
				local pivot = getObjectPivot(obj)
				if pivot ~= nil then
					table.insert(RotOffsets, {
						obj = obj,
						rel = RotStartPivot:ToObjectSpace(pivot),
					})
				end
			end
		end
	end

	-- Rotation is already snapped by the Handles gizmo
	local snappedCF = newCF

	for _, offset in ipairs(RotOffsets) do
		local obj = offset.obj
		if obj and obj.Parent then
			setObjectCFrame(obj, snappedCF * offset.rel)
		end
	end
end)

--  Scale / Resize

local _resizeConnection = Resize.MouseDrag:Connect(function(newCF, newSize)
	if not ishared.ForceMoveObject then
		return
	end
	local selection = Selection:Get()
	if #selection == 0 then
		return
	end

	if not ScaleDragging then
		ScaleDragging = true
		ScaleOffsets = {}

		local center = getSelectionCenter()
		ScaleStartPivot = CFrame.new(center)

		for _, obj in ipairs(selection) do
			if isMovable(obj) then
				local pivot = getObjectPivot(obj)
				if pivot ~= nil then
					local entry = {
						obj = obj,
						rel = ScaleStartPivot:ToObjectSpace(pivot),
						startSize = getObjectExtents(obj),
						lastScale = 1,
					}

					table.insert(ScaleOffsets, entry)
				end
			end
		end
	end

	local snappedSize = snapVec3(newSize)

	for _, offset in ipairs(ScaleOffsets) do
		local obj = offset.obj
		if obj and obj.Parent then
			if isModel(obj) then
				local startSize = offset.startSize
				local avgStart = (startSize.X + startSize.Y + startSize.Z) / 3
				local avgNew = (snappedSize.X + snappedSize.Y + snappedSize.Z) / 3
				local targetScale = math.max(avgNew / avgStart, 0.001)
				local delta = targetScale / offset.lastScale
				obj:ScaleTo(delta)
				offset.lastScale = targetScale
				obj:PivotTo(newCF * offset.rel)
			else
				-- BasePart: apply size and position directly
				obj.Size = snappedSize
				obj.CFrame = newCF * offset.rel
			end
		end
	end
end)

local handlestype = ""

-- Read Offsets:
-- 0, 4, 8 = Position (x,y,z) (Vector3)
-- 12, 16, 20, 24 = Rotation (x,y,z,w) (Quaternion)
-- 28, 32, 36 = Scale (x,y,z) (Vector3)

-- Expose updateAdornees for external use
ishared.Update3DHandles = updateAdornees

--  Selection signals

Selection.SelectionAdded:Connect(function(selected)
	Movement.Adornee = nil
	Resize.Adornee = nil
	Rotation.Adornee = nil

	MoveDragging = false
	RotDragging = false
	ScaleDragging = false
	MoveOffsets = {}
	RotOffsets = {}
	ScaleOffsets = {}

	if selected then
		if not isMovable(selected) then
			return
		end
		if handlestype == "MOVEMENT" then
			Movement.Adornee = selected
		elseif handlestype == "SCALE" then
			Resize.Adornee = selected
		elseif handlestype == "ROTATE" then
			Rotation.Adornee = selected
		end
	end
end)

local function updateAdornees()
	local selected = Selection:Get()[1]
	Movement.Adornee = nil
	Resize.Adornee = nil
	Rotation.Adornee = nil

	if selected and isMovable(selected) then
		if handlestype == "MOVEMENT" then
			Movement.Adornee = selected
		elseif handlestype == "SCALE" then
			Resize.Adornee = selected
		elseif handlestype == "ROTATE" then
			Rotation.Adornee = selected
		end
	end
end

--  Focus

local function Focus()
	local selected = Selection:Get()[1]
	if not selected then
		return
	end
	local padding = 20

	-- Works for both BaseParts (via CFrame.Position) and Models (via GetPivot)
	local pivot = getObjectPivot(selected)
	if not pivot then
		return
	end
	local partPos = pivot.Position

	local camCF = freecam.GetCFrame()
	local dir = camCF.Position - partPos
	if dir:Magnitude() < 1e-4 then
		dir = Vector3.new(0, 0, -1)
	else
		dir = dir:Unit()
	end

	local newCamPos = partPos + dir * padding
	_focusTargetCF = CFrame.lookAt(newCamPos, partPos)
	_focusAlpha = 0
end

--  Render loop

renderer.Pool.new("gizmo", function()
	if ishared.MouseDragging then
		Movement.Adornee = nil
		Resize.Adornee = nil
		Rotation.Adornee = nil
	end

	Movement.render(Movement, renderer, game)
	Resize.render(Resize, renderer, game)
	Rotation.render(Rotation, renderer, game)

	local selection = Selection:Get()
	local selected = selection[1]

	-- Reset dragging states when mouse is released
	if lib.IsMouseButtonDown(const.MouseButton.MOUSE_BUTTON_LEFT) == 0 then
		MoveDragging = false
		RotDragging = false
		ScaleDragging = false
	end

	if selected then
		if not isMovable(selected) then
			return
		end

		if handlestype == "MOVEMENT" then
			if not Movement.Transform then
				return
			end
			local newCF = CFrame.new(snapVec3(Movement.Transform.Position))
			if selected:IsA("BasePart") then
				selected.CFrame = newCF
			elseif selected:IsA("Model") then
				selected:PivotTo(newCF)
			end
		end

		if handlestype == "ROTATE" then
			if not Rotation.Transform then
				return
			end

			local pos = Rotation.Transform.Position

			local x, y, z = Rotation.Transform:ToOrientation()

			local snap = math.rad(15) -- 15 degree snapping

			x = math.round(x / snap) * snap
			y = math.round(y / snap) * snap
			z = math.round(z / snap) * snap

			local newCF = CFrame.new(pos) * CFrame.fromOrientation(x, y, z)

			if selected:IsA("BasePart") then
				selected.CFrame = newCF
			elseif selected:IsA("Model") then
				selected:PivotTo(newCF)
			end
		end

		if lib.IsKeyDown(const.KeyboardKey.KEY_F) == 1 then
			Focus()
		end

		if lib.IsKeyPressed(const.KeyboardKey.KEY_Z) == 1 then
			local center = getSelectionCenter()
			if center then
				local camCF = freecam.GetCFrame()
				local dir = (center - camCF.Position):Unit()
				local zoomAmount = 10

				if lib.IsKeyDown(const.KeyboardKey.KEY_LEFT_CONTROL) == 1 then
					zoomAmount = -zoomAmount
				end

				local newPos = camCF.Position + dir * zoomAmount
				_focusTargetCF = CFrame.lookAt(newPos, center)
				_focusAlpha = 0
			end
		end

		if lib.IsKeyPressed(const.KeyboardKey.KEY_HOME) == 1 then
			freecam.SetCFrame(CFrame.new(Vector3.new(0, 20, 40), Vector3.zero))
		end
	else
		MoveDragging = false
		RotDragging = false
		ScaleDragging = false
		MoveOffsets = {}
		RotOffsets = {}
		ScaleOffsets = {}
	end

	if _focusTargetCF then
		_focusAlpha = math.min(_focusAlpha + 0.08, 1)
		freecam.SetCFrame(_focusTargetCF)

		if _focusAlpha >= 1 then
			_focusTargetCF = nil
		end
	end
end)

game.EngineSignal:Connect(function(Route)
	if Route == "CameraFocus" then
		Focus()
	end
end)

--  Toolbar

repeat
	task.wait()
until ishared.NewCategoryToolbar
local NewCategoryToolbar = ishared.NewCategoryToolbar

NewCategoryToolbar:Fire("Tools", {
	elements = {
		{
			type = "ImageButton",
			text = "Move",
			callback = function()
				ishared.isToolsActive = true
				handlestype = "MOVEMENT"
				updateAdornees()
			end,
			hoverTransparency = 0.5,
			hoverColor = Color3.new(0, 0, 0),
			roundness = 0.2,
			texture = KinemiumIconLoader.ToTexture("./src/assets/images/icons/Move.png"),
		},
		{
			type = "ImageButton",
			callback = function()
				ishared.isToolsActive = true
				handlestype = "ROTATE"
				updateAdornees()
			end,
			hoverTransparency = 0.5,
			text = "Rotate",
			hoverColor = Color3.new(0, 0, 0),
			roundness = 0.2,
			texture = KinemiumIconLoader.ToTexture("./src/assets/images/icons/Rotate.png"),
		},
		{
			type = "ImageButton",
			text = "Resize",
			callback = function()
				handlestype = "SCALE"
				ishared.isToolsActive = true
				updateAdornees()
			end,
			hoverTransparency = 0.5,
			hoverColor = Color3.new(0, 0, 0),
			roundness = 0.2,
			texture = KinemiumIconLoader.ToTexture("./src/assets/images/icons/Size.png"),
		},
		{
			type = "Separator",
		},
		{
			type = "Custom",
			width = 250,
			render = function(arect, data)
				local x, y = data.x, data.y + 15
				local width, height = data.width, data.height

				-- layout config
				local padding = 12
				local spacing = 8
				local rowHeight = 26
				local checkboxSize = 16
				local smallIconSize = 16
				local geoSize = 28

				-- vertical centering
				local contentHeight = rowHeight * 2 + spacing
				local startY = y + (height - contentHeight) / 2

				local row1Y = startY
				local row2Y = startY + rowHeight + spacing

				-- theme
				local iconColor = StudioThemeService.SelectedTheme.ImageColor:ToRaylib(0)
				local textColor = StudioThemeService.SelectedTheme.TextColor:ToRaylib(0)

				-- === COLUMN POSITIONS ===
				local cbX = x + padding
				local iconX = cbX + checkboxSize + 10
				local textboxX = iconX + smallIconSize + 10
				local textboxWidth = width - (textboxX - x) - padding

				-- mouse
				local mx, my = lib.GetMouseX(), lib.GetMouseY()
				local function isHovered(rx, ry, rw, rh)
					return mx >= rx and mx <= rx + rw and my >= ry and my <= ry + rh
				end

				-- === CHECKBOX DRAW FUNCTION ===
				local function drawCheckbox(px, py, state)
					local hovered = isHovered(px, py, checkboxSize, checkboxSize)

					local bg = state and Color3.new(0.2, 0.5, 0.9):ToRaylib(0)
						or (
							hovered and Color3.new(0.3, 0.3, 0.3):ToRaylib(0)
							or Color3.new(0.18, 0.18, 0.18):ToRaylib(0)
						)

					lib.DrawRectangleRounded(
						adapter.structs.Rectangle:new({
							x = px,
							y = py,
							width = checkboxSize,
							height = checkboxSize,
						}),
						0.25,
						4,
						bg
					)

					if state then
						lib.DrawLineEx(
							vector.create(px + 3, py + 9),
							vector.create(px + 7, py + 13),
							2,
							adapter.const.WHITE
						)
						lib.DrawLineEx(
							vector.create(px + 7, py + 13),
							vector.create(px + 13, py + 4),
							2,
							adapter.const.WHITE
						)
					end

					return hovered
				end

				-- === ROW 1 (MOVE) ===
				local cbMoveY = row1Y + (rowHeight - checkboxSize) / 2
				local moveHovered = drawCheckbox(cbX, cbMoveY, snapMoveEnabled)

				if moveHovered and lib.IsMouseButtonPressed(0) == 1 then
					snapMoveEnabled = not snapMoveEnabled
				end

				if moveIcon then
					lib.DrawTexturePro(
						moveIcon.texture,
						adapter.structs.Rectangle:new({ x = 0, y = 0, width = moveIcon.x, height = moveIcon.y }),
						adapter.structs.Rectangle:new({
							x = iconX,
							y = row1Y + (rowHeight - smallIconSize) / 2,
							width = smallIconSize,
							height = smallIconSize,
						}),
						vector.create(0, 0),
						0,
						iconColor
					)
				end

				gridInput:drawWithExtras(textboxX, row1Y, textboxWidth, rowHeight)

				-- === ROW 2 (ROTATE) ===
				local cbRotY = row2Y + (rowHeight - checkboxSize) / 2
				local rotHovered = drawCheckbox(cbX, cbRotY, snapRotEnabled)

				if rotHovered and lib.IsMouseButtonPressed(0) == 1 then
					snapRotEnabled = not snapRotEnabled
					if Rotation then
						Rotation.RotationSnap = snapRotEnabled and ishared.RotationStep or 0
					end
				end

				if rotIcon then
					lib.DrawTexturePro(
						rotIcon.texture,
						adapter.structs.Rectangle:new({ x = 0, y = 0, width = rotIcon.x, height = rotIcon.y }),
						adapter.structs.Rectangle:new({
							x = iconX,
							y = row2Y + (rowHeight - smallIconSize) / 2,
							width = smallIconSize,
							height = smallIconSize,
						}),
						vector.create(0, 0),
						0,
						iconColor
					)
				end

				rotateGrid:drawWithExtras(textboxX, row2Y, textboxWidth, rowHeight)
			end,
		},
		{
			type = "Separator",
		},
	},
})
