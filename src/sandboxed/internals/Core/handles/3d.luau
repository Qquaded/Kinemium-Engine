-- devcell

local KinemiumFontService = game:GetService("KinemiumFontService")
local StudioThemeService = game:GetService("StudioThemeService")
local rlservice = game:GetService("KinemiumRaylib")
local raylib = require("@raylib")

if zune.platform.os == "linux" then
	-- linux not supported Yet........................
	return
end

if FlagExists("cli") or FlagExists("headless") then
	return
end

local lib = raylib.lib
local const = raylib.const
local renderer = rlservice.renderer
local Selection = game:GetService("Selection")
local os = zune.platform.os
local freecam = renderer.Freecam
local focusTargetCF = nil
local vend = KinemiumFontService.GetDefaultFont()
local focusAlpha = 0
local KinemiumIconLoader = game:GetService("KinemiumIconLoader")
local grid = 1
local aereon = require("@Aereon")

local MoveOffsets = {}
local MoveStartPivot = nil
local MoveDragging = false

local textbox = aereon.textbox(StudioThemeService.SelectedTheme, game)

local function snap(v)
	return math.round(v / grid) * grid
end

local function snapVec3(v)
	return Vector3.new(snap(v.X), snap(v.Y), snap(v.Z))
end

local function isMovable(object)
	return object:GetMetadata("IsMovable")
end

local function getSelectionCenter()
	local selection = Selection:Get()
	if #selection == 0 then
		return nil
	end

	local sum = Vector3.zero
	local count = 0

	for _, obj in ipairs(selection) do
		if obj.BaseClass == "BasePart" then
			sum += obj.CFrame.Position
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
	numericMin = 0,
	numericMax = 10000,
	numericPrecision = 1,
	showStepButtons = true,
	onChange = function(new)
		if tonumber(new) and tonumber(new) > 0 then
			grid = tonumber(new)
		else
			grid = 1
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
			grid = tonumber(new)
		else
			grid = 1
		end
	end,
})

local StartCFrame
local StartSize

local gizmo = import("@gizmo")
local flags = gizmo.Flags

local Movement, Resize = Instance.new("Handles"), Instance.new("Handles")
Movement.Style = Enum.HandlesStyle.Movement
Resize.Style = Enum.HandlesStyle.Resize

connection = Movement.MouseDrag:Connect(function(newCF)
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
				table.insert(
					MoveOffsets,
					{ obj = obj, pos = MoveStartPivot:ToObjectSpace(obj.CFrame), size = obj.Size }
				)
			end
		end
	end

	local snappedPos = snapVec3(newCF.Position)
	local snappedPivot = CFrame.new(snappedPos) * (newCF - newCF.Position)

	for _, offset in ipairs(MoveOffsets) do
		local part = offset.obj
		if part and part.Parent then
			local finalCF = snappedPivot * offset.pos
			local o = part.Orientation
			local res: CFrame = finalCF * CFrame.Angles(math.rad(o.X), math.rad(o.Y), math.rad(o.Z))
			if part.Position then
				part.Position = res.Position
			end
			if part.CFrame then
				part.CFrame = res
			end
		end
	end
end)

local handlestype = "MOVEMENT"
local ScaleDragging = true

-- Read Offsets:
-- 0, 4, 8 = Position (x,y,z) (Vector3)
-- 12, 16, 20, 24 = Rotation (x,y,z,w) (Quaternion)
-- 28, 32, 36 = Scale (x,y,z) (Vector3)

local connection

Selection.SelectionAdded:Connect(function(selected)
	Movement.Adornee = nil
	Resize.Adornee = nil

	if connection then
		connection:Disconnect()
	end

	MoveDragging = false
	MoveOffsets = {}

	if selected then
		if not isMovable(selected) then
			return
		end
		if handlestype == "MOVEMENT" then
			Resize.Adornee = nil
			Movement.Adornee = selected
		elseif handlestype == "SCALE" then
			Resize.Adornee = selected
		end
	end
end)

local function Focus()
	local selected = Selection:Get()[1]
	local padding = 20

	local partPos = selected.CFrame.Position
	local camCF = freecam.GetCFrame()

	local dir = (camCF.Position - partPos)
	if dir:Magnitude() < 1e-4 then
		dir = Vector3.new(0, 0, -1)
	else
		dir = dir:Unit()
	end

	local newCamPos = partPos + dir * padding
	focusTargetCF = CFrame.lookAt(newCamPos, partPos)
	focusAlpha = 0
end

renderer.Pool.new("gizmo", function()
	Movement.render(Movement, renderer, game)
	Resize.render(Resize, renderer, game)

	local selected = Selection:Get()[1]

	if selected then
		if not isMovable(selected) then
			return
		end

		if handlestype == "MOVEMENT" then
			if not Movement.Transform then
				return
			end
		elseif handlestype == "SCALE" then
			if connection then
				connection:Disconnect()
			end

			if not ScaleDragging then
				StartCFrame = selected.CFrame
				StartSize = selected.Size
				ScaleDragging = true
			end

			connection = Resize.MouseDrag:Connect(function(newCF)
				local startPos = StartCFrame.Position
				local t = newCF.Position

				local dx = (t.X - startPos.X)
				local dy = (t.Y - startPos.Y)
				local dz = (t.Z - startPos.Z)

				local newSize = snapVec3(
					Vector3.new(
						math.max(StartSize.X + dx, grid),
						math.max(StartSize.Y + dy, grid),
						math.max(StartSize.Z + dz, grid)
					)
				)

				local offset = Vector3.new(
					(newSize.X - StartSize.X) / 2,
					(newSize.Y - StartSize.Y) / 2,
					(newSize.Z - StartSize.Z) / 2
				)

				--selected.Size = newSize
				--selected.CFrame = StartCFrame + offset
			end)
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
				focusTargetCF = CFrame.lookAt(newPos, center)
				focusAlpha = 0
			end
		end
		if lib.IsKeyPressed(const.KeyboardKey.KEY_HOME) == 1 then
			freecam.SetCFrame(CFrame.new(Vector3.new(0, 20, 40), Vector3.zero))
		end
	else
		MoveDragging = false
		MoveOffsets = {}
		ScaleDragging = false
	end
	if focusTargetCF then
		local camCF = freecam.GetCFrame()

		focusAlpha = math.min(focusAlpha + 0.08, 1) -- speed (0.08 slower, 0.2 faster)
		freecam.SetCFrame(focusTargetCF)

		if focusAlpha >= 1 then
			focusTargetCF = nil
		end
	end
end)

game.EngineSignal:Connect(function(Route)
	if Route == "CameraFocus" then
		Focus()
	end
end)

-- Toolbar functionality
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
				handlestype = "MOVEMENT"
			end,
			hoverTransparency = 0.5,
			hoverColor = Color3.new(0, 0, 0),
			roundness = 0.2,
			texture = KinemiumIconLoader.ToTexture("./src/assets/images/icons/Move.svg"),
		},
		{
			type = "ImageButton",

			callback = function()
				handlestype = "ROTATE"
			end,
			hoverTransparency = 0.5,
			text = "Rotate",
			hoverColor = Color3.new(0, 0, 0),
			roundness = 0.2,
			texture = KinemiumIconLoader.ToTexture("./src/assets/images/icons/Rotate.svg"),
		},
		{
			type = "ImageButton",
			text = "Resize",
			callback = function()
				handlestype = "SCALE"
			end,
			hoverTransparency = 0.5,
			hoverColor = Color3.new(0, 0, 0),
			roundness = 0.2,
			texture = KinemiumIconLoader.ToTexture("./src/assets/images/icons/Size.svg"),
		},
		{
			type = "Separator",
		},
		{
			type = "Custom",
			width = 250,
			render = function(arect, data)
				local x, y = data.x, data.y
				local width, height = data.width, data.height + 25

				lib.DrawRectangle(x, y, width, height, raylib.const.WHITE)

				local textboxWidth = 60 -- small width for numbers
				local textboxHeight = height -- keep full rectangle height
				local textboxX = x + width - textboxWidth - 10 -- right edge with 10px padding
				local textboxY = y -- top aligned

				-- both textboxes occupy the same vertical space
				gridInput:drawWithExtras(textboxX, textboxY, textboxWidth, textboxHeight)
				rotateGrid:drawWithExtras(textboxX + textboxWidth + 2, textboxY, textboxWidth, textboxHeight)
			end,
		},
	},
})
