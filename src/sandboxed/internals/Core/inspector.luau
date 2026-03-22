-- devcell

local KinemiumRaylib = game:GetService("KinemiumRaylib")
local KinemiumFontService = game:GetService("KinemiumFontService")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local renderer = KinemiumRaylib.renderer
local rl = KinemiumRaylib.lib
local Selection = game:GetService("Selection")
local structs = KinemiumRaylib.structs
local vend = KinemiumFontService.GetDefaultFont()
local PropertyCategories = require("@PropertyCategories")
local Theme = game:GetService("StudioThemeService").SelectedTheme

local TextColor = Theme.TextColor:ToRaylib(Theme.TextTransparency)
local SecondaryBackgroundColor = Theme.SecondaryBackgroundColor:ToRaylib(Theme.SecondaryBackgroundColorTransparency)

if game.Context ~= Enum.GameContext.Editor then
	return
end
if FlagExists("client") then
	return
end
if FlagExists("cli") then
	return
end
if FlagExists("headless") then
	return
end

local aereon = require("@Aereon")
local gui = aereon.gui
local window = aereon.window(game)
local arect = aereon.rect()
local textbox = aereon.textbox(Theme, game)

local CATEGORY_ORDER = { "Object", "Appearance", "Transform", "Behavior", "Other" }
local CATEGORY_HEADER_HEIGHT = 22
local CELL_HEIGHT = 30
local NAME_COL_WIDTH = 160
local PADDING = 8

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Inspector"
screenGui.Parent = LocalPlayer.PlayerGui

local frame = Instance.new("Frame")
frame.Position = Theme.WindowConfig.Inspector.position
frame.AnchorPoint = Theme.WindowConfig.Inspector.anchorPoint
frame.Size = Theme.WindowConfig.Inspector.size
frame.BackgroundTransparency = 1
frame.Parent = screenGui

local propback
repeat
	task.wait()
until frame.AbsolutePosition and frame.AbsoluteSize
propback = window.create({
	title = "Inspector",
	x = frame.AbsolutePosition.X,
	y = frame.AbsolutePosition.Y,
	width = frame.AbsoluteSize.X,
	height = frame.AbsoluteSize.Y,
})

local windowObject

RunService.GuiRender:Connect(function()
	if not windowObject then
		return
	end
	renderer.Blur:DrawBlurredRegion(
		windowObject.x,
		windowObject.y,
		windowObject.width,
		windowObject.height,
		Color3.new(1, 1, 1):ToRaylib(0)
	)
end)

-- ── state

local scrollOffset = 0
local maxScrollOffset = 0
local openCategories = {}
local overlapping = {}
local editorComps = {} -- [propName] = { comp, typeName }

local blacklisted = { "Children", "UniqueId" }

-- ── helpers

local function round(n)
	return math.floor(n * 1000 + 0.5) / 1000
end

local function makeTextbox(opts)
	local base = {
		padding = 4,
		backgroundColor = Theme.SecondaryBackgroundColor,
		textColor = Theme.TextColor,
		cornerRadius = 0.2,
		BackgroundTransparency = 0.1,
		BorderTransparency = 1,
	}
	if opts then
		for k, v in pairs(opts) do
			base[k] = v
		end
	end
	return textbox.new(base)
end

local function numTb(col, onSubmit)
	return makeTextbox({ numeric = true, TextColor = col:ToRaylib(0), onSubmit = onSubmit })
end

-- ── datatypes
--
-- each datatype table can contain:
--   build(selected, propName, propValue) → comp
--   render(comp, ex, ey, ew, eh)
--   cellHeight(comp)  [optional] → number   (total height this entry occupies)
--   onRowClick(comp, propName)  [optional]  (called when the parent row is clicked)

local datatypes = {}

-- string
datatypes["string"] = {
	build = function(selected, propName, propValue)
		local tb = makeTextbox({
			onSubmit = function(new)
				selected[propName] = type(propValue) == "number" and (tonumber(new) or 0) or new
			end,
		})
		tb:setText(tostring(propValue))
		return tb
	end,
	render = function(comp, ex, ey, ew, eh)
		comp:drawWithExtras(ex, ey, ew, eh)
	end,
}

-- number
datatypes["number"] = {
	build = function(selected, propName, propValue)
		local tb = makeTextbox({
			numeric = true,
			numericMin = 0,
			numericMax = 100000,
			numericStep = 1,
			showStepButtons = true,
			onSubmit = function(new)
				selected[propName] = tonumber(new) or 0
			end,
		})
		tb:setText(tostring(propValue))
		return tb
	end,
	render = function(comp, ex, ey, ew, eh)
		comp:drawWithExtras(ex, ey, ew, eh)
	end,
}

-- boolean
datatypes["boolean"] = {
	build = function(selected, propName, propValue)
		return gui.checkbox({
			value = propValue,
			onChanged = function(new)
				selected[propName] = new
			end,
		})
	end,
	render = function(comp, ex, ey, ew, eh)
		comp.set("obj_rect", arect.new(ex, ey, 22, 22))
		comp.render(rl.GetFrameTime())
	end,
}

-- Vector2
datatypes["Vector2"] = {
	build = function(selected, propName, propValue)
		local comps = {
			x = numTb(Color3.new(1, 0, 0), function(v)
				local c = selected[propName]
				selected[propName] = Vector2.new(tonumber(v) or 0, c.Y)
			end),
			y = numTb(Color3.new(0, 1, 0), function(v)
				local c = selected[propName]
				selected[propName] = Vector2.new(c.X, tonumber(v) or 0)
			end),
		}
		comps.x:setText(tostring(propValue.X))
		comps.y:setText(tostring(propValue.Y))
		return comps
	end,
	render = function(comps, ex, ey, ew, eh)
		local sp = 3
		local w = (ew - sp) / 2
		comps.x:drawWithExtras(ex, ey, w, eh)
		comps.y:drawWithExtras(ex + w + sp, ey, w, eh)
	end,
}

-- Vector3
datatypes["Vector3"] = {
	build = function(selected, propName, propValue)
		local comps = {
			x = numTb(Color3.new(1, 0, 0), function(v)
				local c = selected[propName]
				selected[propName] = Vector3.new(tonumber(v), c.Y, c.Z)
			end),
			y = numTb(Color3.new(0, 1, 0.27), function(v)
				local c = selected[propName]
				selected[propName] = Vector3.new(c.X, tonumber(v), c.Z)
			end),
			z = numTb(Color3.new(0.2, 0.4, 1), function(v)
				local c = selected[propName]
				selected[propName] = Vector3.new(c.X, c.Y, tonumber(v))
			end),
		}
		comps.x:setText(tostring(propValue.X))
		comps.y:setText(tostring(propValue.Y))
		comps.z:setText(tostring(propValue.Z))
		return comps
	end,
	render = function(comps, ex, ey, ew, eh)
		local sp = 3
		local w = (ew - sp * 2) / 3
		comps.x:drawWithExtras(ex, ey, w, eh)
		comps.y:drawWithExtras(ex + (w + sp), ey, w, eh)
		comps.z:drawWithExtras(ex + (w + sp) * 2, ey, w, eh)
	end,
}

-- Color3
datatypes["Color3"] = {
	build = function(selected, propName, propValue)
		local function tb(col, idx)
			return makeTextbox({
				numeric = true,
				numericMin = 0,
				numericMax = 1,
				numericStep = 1,
				TextColor = col:ToRaylib(0),
				onSubmit = function(new)
					local r, g, b = selected[propName]:ToRGB()
					local vals = { r, g, b }
					vals[idx] = tonumber(new) or vals[idx]
					selected[propName] = Color3.fromRGB(vals[1], vals[2], vals[3])
				end,
			})
		end
		local r, g, b = propValue:ToRGB()
		local comps =
			{ r = tb(Color3.new(1, 0, 0), 1), g = tb(Color3.new(0, 1, 0), 2), b = tb(Color3.new(0.2, 0.4, 1), 3) }
		comps.r:setText(tostring(r))
		comps.g:setText(tostring(g))
		comps.b:setText(tostring(b))
		return comps
	end,
	render = function(comps, ex, ey, ew, eh)
		local sp = 3
		local w = (ew - sp * 2) / 3
		comps.r:drawWithExtras(ex, ey, w, eh)
		comps.g:drawWithExtras(ex + (w + sp), ey, w, eh)
		comps.b:drawWithExtras(ex + (w + sp) * 2, ey, w, eh)
	end,
}

-- UDim2
local udim2Expanded = {}

datatypes["UDim2"] = {
	build = function(selected, propName, propValue)
		local cyan = Color3.new(0.4, 1, 1):ToRaylib(0)
		local white = Color3.new(1, 1, 1):ToRaylib(0)
		local function tb(col, fn)
			return makeTextbox({ numeric = true, TextColor = col, onSubmit = fn })
		end
		local comps = {
			_isUDim2 = true,
			sx = tb(cyan, function(v)
				local u = selected[propName]
				selected[propName] = UDim2.new(tonumber(v) or 0, u.X.Offset, u.Y.Scale, u.Y.Offset)
			end),
			ox = tb(white, function(v)
				local u = selected[propName]
				selected[propName] = UDim2.new(u.X.Scale, tonumber(v) or 0, u.Y.Scale, u.Y.Offset)
			end),
			sy = tb(cyan, function(v)
				local u = selected[propName]
				selected[propName] = UDim2.new(u.X.Scale, u.X.Offset, tonumber(v) or 0, u.Y.Offset)
			end),
			oy = tb(white, function(v)
				local u = selected[propName]
				selected[propName] = UDim2.new(u.X.Scale, u.X.Offset, u.Y.Scale, tonumber(v) or 0)
			end),
		}
		comps.sx:setText(tostring(propValue.X.Scale))
		comps.ox:setText(tostring(propValue.X.Offset))
		comps.sy:setText(tostring(propValue.Y.Scale))
		comps.oy:setText(tostring(propValue.Y.Offset))
		return comps
	end,

	cellHeight = function(comp, propName)
		return udim2Expanded[propName] and CELL_HEIGHT * 3 or CELL_HEIGHT
	end,

	onRowClick = function(comp, propName)
		udim2Expanded[propName] = not udim2Expanded[propName]
	end,

	render = function(comp, ex, ey, ew, eh, propName, propValue)
		-- summary on parent row
		if propValue then
			local summary = string.format(
				"{%s, %s}, {%s, %s}",
				propValue.X.Scale,
				propValue.X.Offset,
				propValue.Y.Scale,
				propValue.Y.Offset
			)
			rl.DrawTextEx(
				vend,
				summary,
				vector.create(ex, ey + (CELL_HEIGHT - 14) / 2),
				13,
				1,
				Theme.SecondaryTextColor:ToRaylib(0)
			)
		end

		if not udim2Expanded[propName] then
			return
		end

		local rx2 = ex - PADDING - NAME_COL_WIDTH
		local rw2 = ew + NAME_COL_WIDTH + PADDING
		local subIndent = 16
		local subY1 = ey + CELL_HEIGHT
		local subY2 = ey + CELL_HEIGHT * 2
		local edH = CELL_HEIGHT - 8

		local function drawSubRow(subY, label, tb1, tb2)
			rl.DrawRectangle(rx2, subY, rw2, CELL_HEIGHT, Theme.SecondaryBackgroundColor:ToRaylib(0))
			rl.DrawRectangle(rx2 + subIndent - 4, subY, 1, CELL_HEIGHT, Theme.ThirdBackgroundColor:ToRaylib(0))
			rl.DrawTextEx(
				vend,
				label,
				vector.create(rx2 + subIndent, subY + (CELL_HEIGHT - 13) / 2),
				13,
				1,
				Theme.SecondaryTextColor:ToRaylib(0)
			)

			local divX = rx2 + NAME_COL_WIDTH
			rl.DrawRectangle(divX, subY, 1, CELL_HEIGHT, Theme.ThirdBackgroundColor:ToRaylib(0))

			local sp = 3
			local w = (ew - sp) / 2
			local edY = subY + (CELL_HEIGHT - edH) / 2
			tb1:drawWithExtras(ex, edY, w, edH)
			tb2:drawWithExtras(ex + w + sp, edY, w, edH)
		end

		drawSubRow(subY1, "Scale", comp.sx, comp.sy)
		drawSubRow(subY2, "Offset", comp.ox, comp.oy)
	end,
}

-- EnumItem
datatypes["EnumItem"] = {
	build = function(selected, propName, propValue)
		local items = propValue.EnumType:GetItemsNames()
		local selIdx = 1
		for i, name in ipairs(items) do
			if name == propValue.Name then
				selIdx = i
				break
			end
		end
		local dp = gui.dropdown({
			options = items,
			font = vend,
			selectedIndex = selIdx,
			backgroundColor = Theme.SecondaryBackgroundColor,
			hoverColor = Theme.BackgroundColor,
			onSelect = function(_, option)
				selected[propName] = Enum[propValue.EnumType.Name][option]
			end,
		})
		return { _isDropdown = true, dp = dp }
	end,
	render = function(comp, ex, ey, ew, eh)
		comp.dp.set("obj_rect", arect.new(ex, ey, ew, eh))
		comp.dp.render(rl.GetFrameTime())
	end,
}

-- CFrame
-- renders as:
--   [CFrame]          ← parent row, click to expand/collapse
--     [Position]  X Y Z sub-row
--     [Orientation] X Y Z sub-row

local cfExpanded = {} -- [propName] = bool

datatypes["CFrame"] = {
	build = function(selected, propName, propValue)
		local comps = {
			_isCFrame = true,
			px = numTb(Color3.new(1, 0, 0), function(v)
				local c = selected[propName]
				local rx, ry, rz = c:ToEulerAnglesXYZ()
				selected[propName] = CFrame.new(tonumber(v) or c.Position.X, c.Position.Y, c.Position.Z)
					* CFrame.Angles(rx, ry, rz)
			end),
			py = numTb(Color3.new(0, 1, 0.27), function(v)
				local c = selected[propName]
				local rx, ry, rz = c:ToEulerAnglesXYZ()
				selected[propName] = CFrame.new(c.Position.X, tonumber(v) or c.Position.Y, c.Position.Z)
					* CFrame.Angles(rx, ry, rz)
			end),
			pz = numTb(Color3.new(0.2, 0.4, 1), function(v)
				local c = selected[propName]
				local rx, ry, rz = c:ToEulerAnglesXYZ()
				selected[propName] = CFrame.new(c.Position.X, c.Position.Y, tonumber(v) or c.Position.Z)
					* CFrame.Angles(rx, ry, rz)
			end),
			rx = numTb(Color3.new(1, 0, 0), function(v)
				local c = selected[propName]
				local _, ry, rz = c:ToEulerAnglesXYZ()
				selected[propName] = CFrame.new(c.Position.X, c.Position.Y, c.Position.Z)
					* CFrame.Angles(math.rad(tonumber(v) or 0), ry, rz)
			end),
			ry = numTb(Color3.new(0, 1, 0.27), function(v)
				local c = selected[propName]
				local rx, _, rz = c:ToEulerAnglesXYZ()
				selected[propName] = CFrame.new(c.Position.X, c.Position.Y, c.Position.Z)
					* CFrame.Angles(rx, math.rad(tonumber(v) or 0), rz)
			end),
			rz = numTb(Color3.new(0.2, 0.4, 1), function(v)
				local c = selected[propName]
				local rx, ry, _ = c:ToEulerAnglesXYZ()
				selected[propName] = CFrame.new(c.Position.X, c.Position.Y, c.Position.Z)
					* CFrame.Angles(rx, ry, math.rad(tonumber(v) or 0))
			end),
		}
		local ex, ey, ez = propValue:ToEulerAnglesXYZ()
		comps.px:setText(tostring(round(propValue.Position.X)))
		comps.py:setText(tostring(round(propValue.Position.Y)))
		comps.pz:setText(tostring(round(propValue.Position.Z)))
		comps.rx:setText(tostring(round(math.deg(ex))))
		comps.ry:setText(tostring(round(math.deg(ey))))
		comps.rz:setText(tostring(round(math.deg(ez))))
		return comps
	end,

	-- total height: parent row + (if expanded) 2 sub-rows
	cellHeight = function(comp, propName)
		if cfExpanded[propName] then
			return CELL_HEIGHT * 3
		end
		return CELL_HEIGHT
	end,

	-- called when the parent row header is clicked
	onRowClick = function(comp, propName)
		cfExpanded[propName] = not cfExpanded[propName]
	end,

	-- ex,ey,ew,eh is the full allocated rect (may be 1 or 3 rows tall)
	render = function(comp, ex, ey, ew, eh, propName, propValue)
		-- summary text on the parent row (always shown in right column)
		if propValue then
			local summary = string.format(
				"%s, %s, %s",
				round(propValue.Position.X),
				round(propValue.Position.Y),
				round(propValue.Position.Z)
			)
			rl.DrawTextEx(
				vend,
				summary,
				vector.create(ex, ey + (CELL_HEIGHT - 14) / 2),
				13,
				1,
				Theme.SecondaryTextColor:ToRaylib(0)
			)
		end

		if not cfExpanded[propName] then
			return
		end

		-- sub-row backgrounds
		local rx2 = ex - PADDING - NAME_COL_WIDTH -- back to full row left edge
		local rw2 = ew + NAME_COL_WIDTH + PADDING -- full row width

		local subIndent = 16
		local subNameW = NAME_COL_WIDTH - subIndent
		local subY1 = ey + CELL_HEIGHT
		local subY2 = ey + CELL_HEIGHT * 2

		local function drawSubRow(subY, label, tbx, tby, tbz)
			-- background (slightly inset)
			rl.DrawRectangle(rx2, subY, rw2, CELL_HEIGHT, Theme.SecondaryBackgroundColor:ToRaylib(0))

			-- indent line
			rl.DrawRectangle(rx2 + subIndent - 4, subY, 1, CELL_HEIGHT, Theme.ThirdBackgroundColor:ToRaylib(0))

			-- sub-label
			rl.DrawTextEx(
				vend,
				label,
				vector.create(rx2 + subIndent, subY + (CELL_HEIGHT - 13) / 2),
				13,
				1,
				Theme.SecondaryTextColor:ToRaylib(0)
			)

			-- divider
			local divX = rx2 + NAME_COL_WIDTH
			rl.DrawRectangle(divX, subY, 1, CELL_HEIGHT, Theme.ThirdBackgroundColor:ToRaylib(0))

			-- three textboxes
			local sp = 3
			local w = (ew - sp * 2) / 3
			local edY = subY + (CELL_HEIGHT - (CELL_HEIGHT - 8)) / 2
			local edH = CELL_HEIGHT - 8
			tbx:drawWithExtras(ex, edY, w, edH)
			tby:drawWithExtras(ex + (w + sp), edY, w, edH)
			tbz:drawWithExtras(ex + (w + sp) * 2, edY, w, edH)
		end

		drawSubRow(subY1, "Position", comp.px, comp.py, comp.pz)
		drawSubRow(subY2, "Orientation", comp.rx, comp.ry, comp.rz)
	end,
}

-- ── filtering

local function isBlacklisted(propName, propValue)
	if table.find(blacklisted, propName) then
		return true
	end
	if type(propValue) == "function" then
		return true
	end
	if string.find(propName, "_") then
		return true
	end
	if type(propValue) == "userdata" then
		return true
	end
	if type(propValue) == "table" then
		if propValue.__type == "KinemiumSignal" or propValue.__type == "KinemiumConnection" then
			return true
		end
		if propValue._history then
			return true
		end
	end
	return false
end

local function getPropTypeName(propValue)
	return type(propValue) == "table" and propValue.__type or type(propValue)
end

local function getEntryHeight(entry)
	local typeName = getPropTypeName(entry.propValue)
	local dt = datatypes[typeName]
	if dt and dt.cellHeight then
		local ec = editorComps[entry.propName]
		return dt.cellHeight(ec and ec.comp, entry.propName)
	end
	return CELL_HEIGHT
end

local function buildBuckets(selected)
	local buckets, seen = {}, {}
	for propName, propValue in pairs(selected._props) do
		if isBlacklisted(propName, propValue) then
			continue
		end
		local cat = PropertyCategories.getPropertyCategory(propName) or "Other"
		if not buckets[cat] then
			buckets[cat] = {}
		end
		table.insert(buckets[cat], { propName = propName, propValue = propValue })
		seen[cat] = true
	end
	local order = {}
	for _, cat in ipairs(CATEGORY_ORDER) do
		if seen[cat] then
			table.insert(order, cat)
		end
	end
	for _, cat in ipairs(order) do
		table.sort(buckets[cat], function(a, b)
			return a.propName < b.propName
		end)
	end
	return buckets, order
end

-- ── selection

Selection.SelectionAdded:Connect(function(selected)
	table.clear(editorComps)
	table.clear(overlapping)
	table.clear(cfExpanded)
	table.clear(udim2Expanded)
	scrollOffset = 0

	for propName, propValue in pairs(selected._props) do
		if isBlacklisted(propName, propValue) then
			continue
		end
		local typeName = getPropTypeName(propValue)
		local dt = datatypes[typeName]
		if dt then
			local comp = dt.build(selected, propName, propValue)
			editorComps[propName] = { comp = comp, typeName = typeName }
			if type(comp) == "table" and comp._isDropdown then
				overlapping[propName] = comp
			end
		end
	end
end)

-- ── draw category header ──────────────────────────────────────────────────────

local function drawCategoryHeader(winX, winW, y, label, isOpen, mousePos)
	local w = winW - 12

	local labelText = string.upper(label)
	local labelSize = rl.MeasureTextEx(vend, labelText, 11, 1.5)
	local indicatorText = isOpen and "v" or ">"
	local indicatorSize = rl.MeasureTextEx(vend, indicatorText, 11, 1)

	local gap = 5
	local blockW = indicatorSize.x + gap + labelSize.x
	local blockX = winX + PADDING
	local centerY = y + (CATEGORY_HEADER_HEIGHT / 2)
	local lineColor = Theme.ThirdBackgroundColor:ToRaylib(0)

	rl.DrawRectangle(winX, centerY, PADDING - 4, 1, lineColor)
	rl.DrawTextEx(
		vend,
		indicatorText,
		vector.create(blockX, centerY - 6),
		11,
		1,
		Theme.SecondaryTextColor:ToRaylib(0.4)
	)
	rl.DrawTextEx(
		vend,
		labelText,
		vector.create(blockX + indicatorSize.x + gap, centerY - 6),
		11,
		1.5,
		Theme.SecondaryTextColor:ToRaylib(0)
	)
	local lineStartX = blockX + blockW + PADDING - 4
	rl.DrawRectangle(lineStartX, centerY, w - lineStartX + winX, 1, lineColor)

	if
		rl.IsMouseButtonPressed(0) == 1
		and mousePos.x >= winX
		and mousePos.x <= winX + w
		and mousePos.y >= y
		and mousePos.y <= y + CATEGORY_HEADER_HEIGHT
	then
		return true
	end
	return false
end

-- ── draw property row ─────────────────────────────────────────────────────────

local function drawPropertyRow(winX, winW, y, i, propName, propValue, selected, mousePos)
	local rw = winW - 12
	local rh = CELL_HEIGHT
	local divX = winX + NAME_COL_WIDTH

	local isHovered = mousePos.x >= winX and mousePos.x <= winX + rw and mousePos.y >= y and mousePos.y <= y + rh

	local bgCol = isHovered and Theme.ThirdBackgroundColor:Lerp(Color3.new(1, 1, 1), 0.06):ToRaylib(0)
		or (i % 2 == 0 and SecondaryBackgroundColor or Theme.BackgroundColor:ToRaylib(Theme.BackgroundTransparency))

	rl.DrawRectangle(winX, y, rw, rh, bgCol)
	rl.DrawRectangle(divX, y, 1, rh, Theme.ThirdBackgroundColor:ToRaylib(0))

	local entry = editorComps[propName]
	if not entry then
		-- no editor, just draw name plainly
		rl.DrawTextEx(vend, propName, vector.create(winX + PADDING, y + (rh - 14) / 2), 14, 1, TextColor)
		return
	end

	local dt = datatypes[entry.typeName]
	local comp = entry.comp
	local editorX = divX + PADDING
	local editorW = rw - NAME_COL_WIDTH - PADDING * 2
	local editorH = rh - 8
	local editorY = y + (rh - editorH) / 2

	if type(comp) == "table" and comp._isCFrame then
		-- arrow + name (single draw, no duplicate)
		local ind = cfExpanded[propName] and "v" or ">"
		rl.DrawTextEx(
			vend,
			ind,
			vector.create(winX + PADDING, y + (rh - 13) / 2),
			12,
			1,
			Theme.SecondaryTextColor:ToRaylib(0.5)
		)
		rl.DrawTextEx(vend, propName, vector.create(winX + PADDING + 14, y + (rh - 14) / 2), 14, 1, TextColor)

		if rl.IsMouseButtonPressed(0) == 1 and isHovered and dt.onRowClick then
			dt.onRowClick(comp, propName)
		end
		if dt.render then
			dt.render(comp, editorX, y, editorW, editorH, propName, propValue)
		end
	elseif type(comp) == "table" and comp._isUDim2 then
		local ind = udim2Expanded[propName] and "v" or ">"
		rl.DrawTextEx(
			vend,
			ind,
			vector.create(winX + PADDING, y + (rh - 13) / 2),
			12,
			1,
			Theme.SecondaryTextColor:ToRaylib(0.5)
		)
		rl.DrawTextEx(vend, propName, vector.create(winX + PADDING + 14, y + (rh - 14) / 2), 14, 1, TextColor)

		if rl.IsMouseButtonPressed(0) == 1 and isHovered and dt.onRowClick then
			dt.onRowClick(comp, propName)
		end
		if dt.render then
			dt.render(comp, editorX, y, editorW, editorH, propName, propValue)
		end
	elseif type(comp) == "table" and comp._isDropdown then
		rl.DrawTextEx(vend, propName, vector.create(winX + PADDING, y + (rh - 14) / 2), 14, 1, TextColor)
	else
		rl.DrawTextEx(vend, propName, vector.create(winX + PADDING, y + (rh - 14) / 2), 14, 1, TextColor)
		if dt then
			dt.render(comp, editorX, editorY, editorW, editorH)
		end
	end
end

-- ── main loop

window.stepped = function(windowData)
	for _, ov in pairs(overlapping) do
		ov._framePos = nil
	end
	if windowData.title ~= "Inspector" then
		return
	end

	windowObject = windowData

	local winX = windowData.x
	local winY = windowData.y + 30
	local winW = windowData.width
	local winH = windowData.height - 30

	local mousePos = rl.GetMousePosition()
	local mouseWheel = rl.GetMouseWheelMove()

	if
		mouseWheel ~= 0
		and mousePos.x >= winX
		and mousePos.x <= winX + winW
		and mousePos.y >= winY
		and mousePos.y <= winY + winH
	then
		scrollOffset = math.clamp(scrollOffset - mouseWheel * 40, 0, math.max(0, maxScrollOffset))
	end

	if rl.IsWindowResized() == 1 then
		windowData.x = frame.AbsolutePosition.X
		windowData.y = frame.AbsolutePosition.Y
		windowData.width = frame.AbsoluteSize.X
		windowData.height = frame.AbsoluteSize.Y
	end

	local selected = Selection.Get()[1]
	if not selected or selected.Destroyed then
		return
	end

	gui.clear()

	local buckets, order = buildBuckets(selected)

	-- total scrollable height (respects per-entry heights)
	local totalH = 0
	for _, cat in ipairs(order) do
		totalH = totalH + CATEGORY_HEADER_HEIGHT
		if openCategories[cat] ~= false then
			for _, entry in ipairs(buckets[cat]) do
				totalH = totalH + getEntryHeight(entry)
			end
		end
	end
	maxScrollOffset = math.max(0, totalH - winH)
	scrollOffset = math.clamp(scrollOffset, 0, maxScrollOffset)

	rl.BeginScissorMode(winX, winY, winW, winH)

	local cursorY = winY - scrollOffset

	for _, cat in ipairs(order) do
		local props = buckets[cat]
		local isOpen = openCategories[cat] ~= false

		if cursorY + CATEGORY_HEADER_HEIGHT >= winY and cursorY <= winY + winH then
			if drawCategoryHeader(winX + 1, winW - 1, cursorY, cat, isOpen, mousePos) then
				openCategories[cat] = not isOpen
				isOpen = not isOpen
			end
		end
		cursorY = cursorY + CATEGORY_HEADER_HEIGHT

		if isOpen then
			for i, entry in ipairs(props) do
				local entryH = getEntryHeight(entry)
				local rowY = cursorY

				if rowY + entryH >= winY and rowY <= winY + winH then
					drawPropertyRow(winX + 1, winW - 1, rowY, i, entry.propName, entry.propValue, selected, mousePos)

					local ov = overlapping[entry.propName]
					if ov then
						local rw = winW - 12
						local editorX = winX + NAME_COL_WIDTH + PADDING
						local editorW = rw - NAME_COL_WIDTH - PADDING * 2
						local editorH = CELL_HEIGHT - 8
						ov._framePos = {
							ex = editorX,
							ey = rowY + (CELL_HEIGHT - editorH) / 2,
							ew = editorW,
							eh = editorH,
						}
					end
				end
				cursorY = cursorY + entryH
			end
		end
	end

	rl.EndScissorMode()

	for _, ov in pairs(overlapping) do
		if ov._framePos then
			local p = ov._framePos
			if p.ey + p.eh >= winY and p.ey <= winY + winH then
				datatypes["EnumItem"].render(ov, p.ex, p.ey, p.ew, p.eh)
			end
		end
	end

	if maxScrollOffset > 0 then
		local sbW = 5
		local sbX = winX + winW - sbW - 2
		local thumbH = math.max(24, (winH / totalH) * winH)
		local thumbY = winY + (scrollOffset / maxScrollOffset) * (winH - thumbH)

		rl.DrawRectangle(sbX, winY, sbW, winH, Theme.SecondaryBackgroundColor:ToRaylib(0.6))
		rl.DrawRectangleRounded(
			structs.Rectangle:new({ x = sbX, y = thumbY, width = sbW, height = thumbH }),
			0.5,
			4,
			Color3.new(0.3, 0.3, 0.3):ToRaylib(0)
		)
	end
end
