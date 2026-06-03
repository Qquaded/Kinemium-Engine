-- devcell

local RunService = game:GetService("RunService")
if RunService:IsServer() then
	return
end

local rlservice = game:GetService("KinemiumRaylib")
local raylib = require("@raylib")
local lib = raylib.lib
local structs = raylib.structs
local renderer = rlservice.GetRenderer()
local Selection = game:GetService("Selection")

local KinemiumFontService = game:GetService("KinemiumFontService")
local StudioThemeService = game:GetService("StudioThemeService")
local vend = KinemiumFontService.GetDefaultFont()

local aereon = import("@Aereon")
local gui = aereon.gui
local currentObject
local menuTarget

local backgroundColor =
	StudioThemeService.SelectedTheme.BackgroundColor:ToRaylib(StudioThemeService.SelectedTheme.BackgroundTransparency)
local TextColor = StudioThemeService.SelectedTheme.TextColor:ToRaylib(StudioThemeService.SelectedTheme.TextTransparency)

local dragStartOffset = Vector2.new(0, 0)

local dragging = nil

local activeHandle = nil
local dragStartMouse = nil
local dragStartPos = nil
local dragStartSize = nil

local Arect = require("@arect")

Selection.SelectionAdded:Connect(function(selected) end)

local handleSize = 12 -- pixels
local handleHoverSize = 16
local SelectionBorderColor = structs.Color:new({ r = 0, g = 170, b = 255, a = 255 })

local function applyAnchor(object, newAnchor)
	object.AnchorPoint = newAnchor
	object.Position = UDim2.new(newAnchor.X, 0, newAnchor.Y, 0)
end

local utilsMenu = gui.menu({
	x = 0,
	y = 0,
	width = 200,
	height = 300,
	Font = vend,
	items = {
		{ type = "category", label = "ANCHOR" },

		{
			label = "Top",
			submenu = {
				{
					label = "Top Left",
					onClick = function()
						if menuTarget then
							applyAnchor(menuTarget, Vector2.new(0, 0))
						end
					end,
				},
				{
					label = "Top Center",
					onClick = function()
						if menuTarget then
							applyAnchor(menuTarget, Vector2.new(0.5, 0))
						end
					end,
				},
				{
					label = "Top Right",
					onClick = function()
						if menuTarget then
							applyAnchor(menuTarget, Vector2.new(1, 0))
						end
					end,
				},
			},
		},
		{
			label = "Center",
			submenu = {
				{
					label = "Center Left",
					onClick = function()
						if menuTarget then
							applyAnchor(menuTarget, Vector2.new(0, 0.5))
						end
					end,
				},
				{
					label = "Center Center",
					onClick = function()
						if menuTarget then
							applyAnchor(menuTarget, Vector2.new(0.5, 0.5))
						end
					end,
				},
				{
					label = "Center Right",
					onClick = function()
						if menuTarget then
							applyAnchor(menuTarget, Vector2.new(1, 0.5))
						end
					end,
				},
			},
		},
		{
			label = "Bottom",
			submenu = {
				{
					label = "Bottom Left",
					onClick = function()
						if currentObject then
							applyAnchor(currentObject, Vector2.new(0, 1))
						end
					end,
				},
				{
					label = "Bottom Center",
					onClick = function()
						if menuTarget then
							applyAnchor(menuTarget, Vector2.new(0.5, 1))
						end
					end,
				},
				{
					label = "Bottom Right",
					onClick = function()
						if menuTarget then
							applyAnchor(menuTarget, Vector2.new(1, 1))
						end
					end,
				},
			},
		},

		{ type = "category", label = "VISUAL" },
		{
			label = "Corner",
			submenu = {
				{
					label = "0 px",
					onClick = function()
						if menuTarget then
							if menuTarget:FindFirstChild("UICorner") then
								menuTarget.UICorner.CornerRadius = UDim.new(0, 0)
							else
								local UICorner = Instance.new("UICorner")
								UICorner.CornerRadius = UDim.new(0, 0)
								UICorner.Parent = menuTarget
							end
						end
					end,
				},
				{
					label = "5 px",
					onClick = function()
						if menuTarget then
							if menuTarget:FindFirstChild("UICorner") then
								menuTarget.UICorner.CornerRadius = UDim.new(0, 5)
							else
								local UICorner = Instance.new("UICorner")
								UICorner.CornerRadius = UDim.new(0, 5)
								UICorner.Parent = menuTarget
							end
						end
					end,
				},
				{
					label = "10 px",
					onClick = function()
						if menuTarget then
							if menuTarget:FindFirstChild("UICorner") then
								menuTarget.UICorner.CornerRadius = UDim.new(0, 10)
							else
								local UICorner = Instance.new("UICorner")
								UICorner.CornerRadius = UDim.new(0, 10)
								UICorner.Parent = menuTarget
							end
						end
					end,
				},
				{
					label = "15 px",
					onClick = function()
						if menuTarget then
							if menuTarget:FindFirstChild("UICorner") then
								menuTarget.UICorner.CornerRadius = UDim.new(0, 15)
							else
								local UICorner = Instance.new("UICorner")
								UICorner.CornerRadius = UDim.new(0, 15)
								UICorner.Parent = menuTarget
							end
						end
					end,
				},
			},
		},
		{
			label = "Border",
			submenu = {
				{
					label = "0 px",
					onClick = function()
						if menuTarget then
							if menuTarget:FindFirstChild("UIStroke") then
								menuTarget.UIStroke.Thickness = 0
							else
								local UIStroke = Instance.new("UIStroke")
								UIStroke.Thickness = 0
								UIStroke.Parent = menuTarget
							end
						end
					end,
				},
				{
					label = "5 px",
					onClick = function()
						if menuTarget then
							if menuTarget:FindFirstChild("UIStroke") then
								menuTarget.UIStroke.Thickness = 5
							else
								local UIStroke = Instance.new("UIStroke")
								UIStroke.Thickness = 5
								UIStroke.Parent = menuTarget
							end
						end
					end,
				},
				{
					label = "10 px",
					onClick = function()
						if menuTarget then
							if menuTarget:FindFirstChild("UIStroke") then
								menuTarget.UIStroke.Thickness = 10
							else
								local UIStroke = Instance.new("UIStroke")
								UIStroke.Thickness = 10
								UIStroke.Parent = menuTarget
							end
						end
					end,
				},
				{
					label = "15 px",
					onClick = function()
						if menuTarget then
							if menuTarget:FindFirstChild("UIStroke") then
								menuTarget.UIStroke.Thickness = 15
							else
								local UIStroke = Instance.new("UIStroke")
								UIStroke.Thickness = 15
								UIStroke.Parent = menuTarget
							end
						end
					end,
				},
			},
		},
		{
			label = "Graph",
			onClick = function()
				if menuTarget then
					if menuTarget:FindFirstChild("UIGraph") then
						return
					else
						local UIGraph = Instance.new("UIGraph")
						UIGraph.BackgroundTransparency = 1
						UIGraph.Size = UDim2.new(1, 0, 1, 0)
						UIGraph.Parent = menuTarget
					end
				end
			end,
		},
		{ type = "category", label = "TRANSFORM" },

		{
			label = "Reset Position",
			onClick = function()
				if menuTarget then
					menuTarget.Position = UDim2.fromScale(0.5, 0.5)
					menuTarget.AnchorPoint = Vector2.new(0.5, 0.5)
				end
			end,
		},

		{
			label = "Reset Size",
			onClick = function()
				if menuTarget then
					menuTarget.Size = UDim2.fromOffset(100, 100)
				end
			end,
		},

		{
			label = "Fill Parent",
			onClick = function()
				if menuTarget then
					menuTarget.Size = UDim2.fromScale(1, 1)
					menuTarget.Position = UDim2.new(0, 0, 0, 0)
					menuTarget.AnchorPoint = Vector2.new(0, 0)
				end
			end,
		},
		{ type = "category", label = "VISIBILITY" },

		{
			label = "Toggle Visible",
			onClick = function()
				if menuTarget and menuTarget:IsA("GuiObject") then
					menuTarget.Visible = not menuTarget.Visible
				end
			end,
		},

		{
			label = "50% Transparency",
			onClick = function()
				if menuTarget then
					menuTarget.BackgroundTransparency = 0.5
				end
			end,
		},
		{ type = "category", label = "LAYOUT" },

		{
			label = "Add UIListLayout",
			onClick = function()
				if menuTarget and not menuTarget:FindFirstChildOfClass("UIListLayout") then
					Instance.new("UIListLayout", menuTarget)
				end
			end,
		},

		{
			label = "Add UIAspectRatio",
			onClick = function()
				if menuTarget and not menuTarget:FindFirstChildOfClass("UIAspectRatioConstraint") then
					Instance.new("UIAspectRatioConstraint", menuTarget)
				end
			end,
		},
		{ type = "category", label = "UTILS" },

		{
			label = "Duplicate",
			onClick = function()
				if menuTarget and menuTarget.Parent then
					menuTarget:Clone().Parent = menuTarget.Parent
				end
			end,
		},

		{
			label = "Delete",
			onClick = function()
				if menuTarget then
					menuTarget:Destroy()
				end
			end,
		},
	},
})
utilsMenu:hide()

local function drawHandles(absPos, absSize, object)
	-- draw handles
	local hs = handleSize / 2
	local cx, cy = absPos.X + absSize.X / 2, absPos.Y + absSize.Y / 2

	local btmRight = vector.create(absPos.X + absSize.X, absPos.Y + absSize.Y)
	local btmRightText = vector.create(absPos.X + absSize.X, absPos.Y + absSize.Y + 15)

	local handles = {
		{ pos = vector.create(absPos.X, absPos.Y), sx = -1, sy = -1 }, -- TL
		{ pos = vector.create(absPos.X + absSize.X, absPos.Y), sx = 1, sy = -1 }, -- TR
		{ pos = vector.create(absPos.X, absPos.Y + absSize.Y), sx = -1, sy = 1 }, -- BL
		{ pos = vector.create(absPos.X + absSize.X, absPos.Y + absSize.Y), sx = 1, sy = 1 }, -- BR

		{ pos = vector.create(cx, absPos.Y), sx = 0, sy = -1 }, -- top
		{ pos = vector.create(cx, absPos.Y + absSize.Y), sx = 0, sy = 1 }, -- bottom
		{ pos = vector.create(absPos.X, cy), sx = -1, sy = 0 }, -- left
		{ pos = vector.create(absPos.X + absSize.X, cy), sx = 1, sy = 0 }, -- right
	}

	for _, h in ipairs(handles) do
		local r = Arect.new(h.pos.X - hs, h.pos.Y - hs, handleSize, handleSize)
		local isHovering = Arect.MouseIsInRect(r)

		local currentHandleSize = isHovering and handleHoverSize or handleSize
		local chs = currentHandleSize / 2

		-- Draw circular handle
		lib.DrawCircleV(vector.create(h.pos.X, h.pos.Y), chs, structs.Color:new({ r = 255, g = 255, b = 255, a = 255 }))
		lib.DrawCircleLinesV(vector.create(h.pos.X, h.pos.Y), chs, SelectionBorderColor)

		if isHovering then
			if raylib.lib.IsMouseButtonPressed(0) == 1 then
				activeHandle = h
				dragStartMouse = raylib.lib.GetMousePosition()
				dragStartPos = absPos
				dragStartSize = absSize
				object._EditorOverride = true
			end
		end
	end

	if activeHandle and raylib.lib.IsMouseButtonDown(0) == 1 then
		local mouse = raylib.lib.GetMousePosition()
		local dx = mouse.x - dragStartMouse.x
		local dy = mouse.y - dragStartMouse.y

		local newSize = dragStartSize
		local newPos = dragStartPos

		if activeHandle.sx ~= 0 then
			newSize = vector.create(dragStartSize.X + dx * activeHandle.sx, newSize.Y)

			if activeHandle.sx == -1 then
				newPos = vector.create(dragStartPos.X + dx, newPos.Y)
			end
		end

		if activeHandle.sy ~= 0 then
			newSize = vector.create(newSize.X, dragStartSize.Y + dy * activeHandle.sy)

			if activeHandle.sy == -1 then
				newPos = vector.create(newPos.X, dragStartPos.Y + dy)
			end
		end

		object.AbsolutePosition = newPos
		object.AbsoluteSize = newSize

		local parent = object.Parent
		local parentAbsPos = Vector2.new(0, 0)
		if parent and parent.AbsolutePosition then
			parentAbsPos = parent.AbsolutePosition
		end

		local anchor = object.AnchorPoint or Vector2.new(0, 0)
		local relativeX = newPos.X - parentAbsPos.X + newSize.X * anchor.X
		local relativeY = newPos.Y - parentAbsPos.Y + newSize.Y * anchor.Y

		object.Size = UDim2.new(0, newSize.X, 0, newSize.Y)
		object.Position = UDim2.new(0, relativeX, 0, relativeY)
	end

	if raylib.lib.IsMouseButtonReleased(0) == 1 then
		if activeHandle then
			object._EditorOverride = nil
			activeHandle = nil
		end
	end

	local text = absSize.X .. "x" .. absSize.Y
	local fontSize = 17
	local padding = 6

	local textSize = raylib.lib.MeasureTextEx(vend, text, fontSize, 1)

	local bgX = absPos.X + absSize.X - textSize.X - padding * 2
	local bgY = absPos.Y + absSize.Y - textSize.Y - padding * 2

	local backgroundRect = Arect.new(bgX, bgY, textSize.X + padding * 2, textSize.Y + padding * 2)

	raylib.lib.DrawRectangleRec(Arect:translate(backgroundRect), backgroundColor)
	raylib.lib.DrawTextEx(vend, text, vector.create(bgX + padding, bgY + padding), fontSize, 1, TextColor)
end

local function highlight(selected)
	if not selected then
		return
	end
	local ancestor = selected:FindFirstAncestor("ScreenGui")
	if not ancestor then
		return
	end

	local absPos, absSize = selected.AbsolutePosition, selected.AbsoluteSize
	if not absPos or not absSize then
		return
	end

	local objRect = Arect.new(absPos.X, absPos.Y, absSize.X, absSize.Y)

	lib.DrawRectangleLinesEx(Arect:translate(objRect), 2, SelectionBorderColor)

	local parent = selected.Parent
	if parent and parent.AbsolutePosition and parent.AbsoluteSize then
		local pAbsPos = parent.AbsolutePosition
		local pAbsSize = parent.AbsoluteSize

		local guideColor = structs.Color:new({ r = 0, g = 170, b = 255, a = 100 })

		lib.DrawLineEx(
			vector.create(absPos.X + absSize.X / 2, absPos.Y),
			vector.create(absPos.X + absSize.X / 2, pAbsPos.Y),
			1,
			guideColor
		)

		lib.DrawLineEx(
			vector.create(absPos.X + absSize.X / 2, absPos.Y + absSize.Y),
			vector.create(absPos.X + absSize.X / 2, pAbsPos.Y + pAbsSize.Y),
			1,
			guideColor
		)

		lib.DrawLineEx(
			vector.create(absPos.X, absPos.Y + absSize.Y / 2),
			vector.create(pAbsPos.X, absPos.Y + absSize.Y / 2),
			1,
			guideColor
		)

		lib.DrawLineEx(
			vector.create(absPos.X + absSize.X, absPos.Y + absSize.Y / 2),
			vector.create(pAbsPos.X + pAbsSize.X, absPos.Y + absSize.Y / 2),
			1,
			guideColor
		)
	end

	drawHandles(absPos, absSize, selected)
end

renderer.Pool.new("2d", function()
	local dt = raylib.lib.GetFrameTime()
	local mousePos = raylib.lib.GetMousePosition()

	local selected = Selection:Get()
	local first = Selection:Get()[1]

	currentObject = first

	for _, v in pairs(selected) do
		highlight(v)
	end

	if first and game.Stop3DInput ~= true then
		if first.MouseIsInObject == true then
			game.Stop3DInput = true

			if lib.IsMouseButtonPressed(0) == 1 then
				dragging = first
				dragging._EditorOverride = true
				dragStartOffset =
					Vector2.new(mousePos.X - dragging.AbsolutePosition.X, mousePos.Y - dragging.AbsolutePosition.Y)
			end

			if lib.IsMouseButtonPressed(1) == 1 then
				menuTarget = first
				utilsMenu:show()
				utilsMenu.set("obj_rect", Arect.new(mousePos.X + 5, mousePos.Y + 5, 200, 400))
			end
		else
			game.Stop3DInput = false
		end
	end

	if dragging then
		if lib.IsMouseButtonDown(0) == 1 then
			local newAbsPos = Vector2.new(mousePos.X - dragStartOffset.X, mousePos.Y - dragStartOffset.Y)
			dragging.AbsolutePosition = newAbsPos

			local parent = dragging.Parent
			local parentAbsPos = Vector2.new(0, 0)
			if parent and parent.AbsolutePosition then
				parentAbsPos = parent.AbsolutePosition
			end

			local anchor = dragging.AnchorPoint or Vector2.new(0, 0)
			local size = dragging.AbsoluteSize or Vector2.new(0, 0)
			local relativeX = newAbsPos.X - parentAbsPos.X + size.X * anchor.X
			local relativeY = newAbsPos.Y - parentAbsPos.Y + size.Y * anchor.Y

			dragging.Position = UDim2.new(0, relativeX, 0, relativeY)
		else
			dragging._EditorOverride = nil
			dragging = nil
		end
	end

	utilsMenu.render(dt)
end, -5)
