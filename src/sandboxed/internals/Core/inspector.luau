-- devcell

local KinemiumRaylib = game:GetService("KinemiumRaylib")
local KinemiumFontService = game:GetService("KinemiumFontService")
local zembed = require("@zembed")

local RunService = game:GetService("RunService")
if RunService:IsServer() then
	return
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local renderer = KinemiumRaylib.GetRenderer()
local rl = KinemiumRaylib.GetLib()
local Selection = game:GetService("Selection")
local structs = KinemiumRaylib.GetStructs()
local vend = KinemiumFontService.GetDefaultFont()
local PropertyCategories = require("@PropertyCategories")
local Theme = game:GetService("StudioThemeService").SelectedTheme
local boldFont = KinemiumFontService.GetBoldFont()
local StudioThemeService = game:GetService("StudioThemeService")
local TextColor = Theme.TextColor:ToRaylib(Theme.TextTransparency)

if game.Context ~= Enum.GameContext.Editor then
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

-- state

local scrollOffset = 0
local scrollTarget = 0
local maxScrollOffset = 0
local openCategories = {}
local overlapping = {}
local editorComps = {} -- [propName] = { comp, typeName }
local expandedSequences = {} -- [propName] = bool
local colorPickerTarget = nil -- { selected, propName, kpIndex }
local colorPickerComp = nil
local colorPickerIcon = nil

-- Scrollbar drag state
local scrollbarDrag = {
	active = false,
	offset = 0,
}

-- Divider drag state
local dividerDrag = {
	active = false,
	startX = 0,
	startWidth = 0,
}

local blacklisted = { "Children", "UniqueId" }

-- helpers

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

local IMAGE_EXTENSIONS = { ".png", ".jpg", ".jpeg", ".bmp", ".tga" }
local function isImagePath(s)
	if type(s) ~= "string" or #s < 5 then
		return false
	end
	local ls = s:lower()
	-- print("isImagePath checking:", ls)
	for _, ext in ipairs(IMAGE_EXTENSIONS) do
		if ls:sub(-#ext) == ext then
			return true
		end
	end
	return false
end

local textureCache = {}
local function getTexture(path)
	if textureCache[path] then
		return textureCache[path]
	end
	path = zembed.AssetPath(path)
	local ok, tex = pcall(function()
		return rl.LoadTexture(path)
	end)
	if ok and tex then
		textureCache[path] = tex
		return tex
	end
	return nil
end

local pathIcon = nil
local function getPathIcon()
	if not pathIcon then
		local tex = rl.LoadTexture(zembed.AssetPath("kineasset://images/icons/Folder.png"))
		if tex then
			pathIcon = {
				texture = tex,
				x = buffer.readi32(tex, 4),
				y = buffer.readi32(tex, 8),
			}
		end
	end
	return pathIcon
end

local function getCPIcon()
	if not colorPickerIcon then
		local cpTex = rl.LoadTexture(zembed.AssetPath("kineasset://images/icons/ColorPicker.png"))
		colorPickerIcon = {
			texture = cpTex,
			x = buffer.readi32(cpTex, 4),
			y = buffer.readi32(cpTex, 8),
		}
	end
	return colorPickerIcon
end

local function openColorPicker(selected, propName, initialColor, kpIndex)
	colorPickerTarget = { selected = selected, propName = propName, kpIndex = kpIndex }
	if not colorPickerComp then
		colorPickerComp = gui.colorPicker({
			backgroundColor = Theme.SecondaryBackgroundColor,
			backgroundTransparency = Theme.BackgroundTransparency,

			onChanged = function(newColor)
				if not colorPickerTarget then
					return
				end
				local s = colorPickerTarget.selected
				local p = colorPickerTarget.propName
				local idx = colorPickerTarget.kpIndex

				local localColor = Color3.new(newColor.R, newColor.G, newColor.B)

				if idx then
					local cs = s[p]
					local kps = cs.Keypoints
					kps[idx] = ColorSequenceKeypoint.new(kps[idx].Position, localColor)
					s[p] = ColorSequence.new(kps)
				else
					s[p] = localColor
				end
			end,
		})
	end
	colorPickerComp.setColor(initialColor)
end

-- datatypes
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
		local comps = {}
		comps.tb = makeTextbox({
			onSubmit = function(new)
				selected[propName] = type(propValue) == "number" and (tonumber(new) or 0) or new
			end,
		})
		comps.tb:setText(tostring(propValue))

		comps.explorer = gui.imageButton({
			image = getPathIcon(),
			imageScale = 0.6,
			backgroundColor = Theme.SecondaryBackgroundColor,
			onClick = function()
				local FileDialogService = game:GetService("FileDialogService")
				local path = FileDialogService.RequestFile({
					{ name = "Images", extensions = { "png", "jpg", "jpeg", "bmp" } },
					{ name = "All Files", extensions = { "*" } },
				})
				if path then
					selected[propName] = path
					comps.tb:setText(path)
				end
			end,
		})

		return comps
	end,
	cellHeight = function(comp, propName, propValue)
		if isImagePath(propValue) then
			return CELL_HEIGHT + 180
		end
		return CELL_HEIGHT
	end,
	render = function(comps, ex, ey, ew, eh, propName, propValue)
		local btnW = 24
		local sp = 3

		local mainH = CELL_HEIGHT
		local mainY = ey

		if isImagePath(propValue) then
			local previewH = 170
			local previewY = ey + 5
			mainY = ey + 175

			-- Checkerboard background
			local checkerX, checkerY = ex, previewY
			local checkerW, checkerH = ew, previewH - 5
			rl.DrawRectangle(checkerX, checkerY, checkerW, checkerH, Theme.SecondaryBackgroundColor:ToRaylib(0))

			local size = 10
			for r = 0, math.ceil(checkerH / size) - 1 do
				for c = 0, math.ceil(checkerW / size) - 1 do
					if (r + c) % 2 == 0 then
						rl.DrawRectangle(
							checkerX + c * size,
							checkerY + r * size,
							math.min(size, checkerW - c * size),
							math.min(size, checkerH - r * size),
							Color3.new(0.2, 0.2, 0.2):ToRaylib(0)
						)
					end
				end
			end

			-- Render image preview
			local tex = getTexture(propValue)
			if tex then
				local tw = buffer.readi32(tex, 4)
				local th = buffer.readi32(tex, 8)

				local drawW = math.min(ew - 20, (previewH - 60) * (tw / th))
				local drawH = drawW * (th / tw)
				if drawH > previewH - 60 then
					drawH = previewH - 60
					drawW = drawH * (tw / th)
				end

				local drawX = ex + (ew - drawW) / 2
				local drawY = previewY + (previewH - 60 - drawH) / 2 + 10

				rl.DrawTexturePro(
					tex,
					structs.Rectangle:new({ x = 0, y = 0, width = tw, height = th }),
					structs.Rectangle:new({ x = drawX, y = drawY, width = drawW, height = drawH }),
					vector.create(0, 0),
					0,
					Color3.new(1, 1, 1):ToRaylib(0)
				)

				-- Metadata
				local metaX = ex + 10
				local metaY = previewY + previewH - 45
				rl.DrawTextEx(
					vend,
					string.format("%dx%d", tw, th),
					vector.create(metaX, metaY),
					13,
					1,
					Theme.TextColor:ToRaylib(0)
				)
				rl.DrawTextEx(
					vend,
					"Memory: " .. string.format("%.2f MiB", (tw * th * 4) / (1024 * 1024)),
					vector.create(metaX, metaY + 15),
					11,
					1,
					Theme.SecondaryTextColor:ToRaylib(0)
				)
			else
				rl.DrawTextEx(
					vend,
					"Failed to load texture",
					vector.create(ex + 10, previewY + 10),
					13,
					1,
					Color3.new(1, 0.4, 0.4):ToRaylib(0)
				)
			end
		end

		comps.tb:drawWithExtras(ex, mainY + (CELL_HEIGHT - 22) / 2, ew - sp - btnW, 22)
		comps.explorer.set("obj_rect", arect.new(ex + ew - btnW, mainY + (CELL_HEIGHT - 22) / 2, btnW, 22))
		comps.explorer.render(rl.GetFrameTime())
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

-- UDim
datatypes["UDim"] = {
	build = function(selected, propName, propValue)
		local comps = {
			x = numTb(Color3.new(1, 0, 0), function(v)
				local c = selected[propName]
				selected[propName] = UDim.new(tonumber(v) or 0, c.Offset)
			end),
			y = numTb(Color3.new(0, 1, 0), function(v)
				local c = selected[propName]
				selected[propName] = UDim.new(c.Scale, tonumber(v) or 0)
			end),
		}
		comps.x:setText(tostring(propValue.Scale))
		comps.y:setText(tostring(propValue.Offset))
		return comps
	end,
	render = function(comps, ex, ey, ew, eh)
		local sp = 3
		local w = (ew - sp) / 2
		comps.x:drawWithExtras(ex, ey, w, eh)
		comps.y:drawWithExtras(ex + w + sp, ey, w, eh)
	end,
}

-- NumberRange
datatypes["NumberRange"] = {
	build = function(selected, propName, propValue)
		local comps = {
			min = numTb(Color3.new(1, 0.8, 0.4), function(v)
				local c = selected[propName]
				selected[propName] = NumberRange.new(tonumber(v) or 0, c.Max)
			end),
			max = numTb(Color3.new(0.4, 0.8, 1), function(v)
				local c = selected[propName]
				selected[propName] = NumberRange.new(c.Min, tonumber(v) or 0)
			end),
		}
		comps.min:setText(tostring(propValue.Min))
		comps.max:setText(tostring(propValue.Max))
		return comps
	end,
	render = function(comps, ex, ey, ew, eh)
		local sp = 3
		local w = (ew - sp) / 2
		comps.min:drawWithExtras(ex, ey, w, eh)
		comps.max:drawWithExtras(ex + w + sp, ey, w, eh)
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
				numericStep = 0.01,
				TextColor = col:ToRaylib(0),
				onSubmit = function(new)
					local r, g, b = selected[propName].R, selected[propName].G, selected[propName].B
					local vals = { r, g, b }
					vals[idx] = tonumber(new) or vals[idx]
					selected[propName] = Color3.new(vals[1], vals[2], vals[3])
				end,
			})
		end
		local comps = {
			r = tb(Color3.new(1, 0, 0), 1),
			g = tb(Color3.new(0, 1, 0), 2),
			b = tb(Color3.new(0.2, 0.4, 1), 3),
			pick = gui.imageButton({
				image = getCPIcon(),
				imageScale = 0.8,
				onClick = function()
					openColorPicker(selected, propName, selected[propName])
				end,
			}),
		}
		comps.r:setText(tostring(round(propValue.R)))
		comps.g:setText(tostring(round(propValue.G)))
		comps.b:setText(tostring(round(propValue.B)))
		return comps
	end,
	render = function(comps, ex, ey, ew, eh)
		local sp = 3
		local btnW = 24
		local w = (ew - sp * 3 - btnW) / 3
		comps.r:drawWithExtras(ex, ey, w, eh)
		comps.g:drawWithExtras(ex + (w + sp), ey, w, eh)
		comps.b:drawWithExtras(ex + (w + sp) * 2, ey, w, eh)
		comps.pick.set("obj_rect", arect.new(ex + (w + sp) * 3, ey, btnW, eh))
		comps.pick.render(rl.GetFrameTime())
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
			rl.DrawRectangle(
				rx2,
				subY,
				rw2,
				CELL_HEIGHT,
				Theme.SecondaryBackgroundColor:ToRaylib(StudioThemeService.SelectedTheme.WindowBackgroundTransparency)
			)
			rl.DrawRectangle(
				rx2 + subIndent - 4,
				subY,
				1,
				CELL_HEIGHT,
				Theme.ThirdBackgroundColor:ToRaylib(StudioThemeService.SelectedTheme.WindowBackgroundTransparency)
			)
			rl.DrawTextEx(
				vend,
				label,
				vector.create(rx2 + subIndent, subY + (CELL_HEIGHT - 13) / 2),
				13,
				1,
				Theme.SecondaryTextColor:ToRaylib(0)
			)

			local divX = rx2 + NAME_COL_WIDTH
			rl.DrawRectangle(
				divX,
				subY,
				1,
				CELL_HEIGHT,
				Theme.ThirdBackgroundColor:ToRaylib(StudioThemeService.SelectedTheme.WindowBackgroundTransparency)
			)

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
			rl.DrawRectangle(
				rx2,
				subY,
				rw2,
				CELL_HEIGHT,
				Theme.SecondaryBackgroundColor:ToRaylib(StudioThemeService.SelectedTheme.WindowBackgroundTransparency)
			)

			-- indent line
			rl.DrawRectangle(
				rx2 + subIndent - 4,
				subY,
				1,
				CELL_HEIGHT,
				Theme.ThirdBackgroundColor:ToRaylib(StudioThemeService.SelectedTheme.WindowBackgroundTransparency)
			)

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

-- NumberSequence
datatypes["NumberSequence"] = {
	build = function(selected, propName, propValue)
		local comps = { _isSequence = true, keypoints = {} }
		for i, kp in ipairs(propValue.Keypoints) do
			local kcomps = {
				time = numTb(Color3.new(1, 1, 0), function(v)
					local ns = selected[propName]
					local kps = ns.Keypoints
					kps[i] = NumberSequenceKeypoint.new(tonumber(v) or kps[i].Time, kps[i].Value)
					selected[propName] = NumberSequence.new(kps)
				end),
				value = numTb(Color3.new(1, 1, 1), function(v)
					local ns = selected[propName]
					local kps = ns.Keypoints
					kps[i] = NumberSequenceKeypoint.new(kps[i].Time, tonumber(v) or kps[i].Value)
					selected[propName] = NumberSequence.new(kps)
				end),
			}
			kcomps.time:setText(tostring(kp.Time))
			kcomps.value:setText(tostring(kp.Value))
			table.insert(comps.keypoints, kcomps)
		end
		return comps
	end,
	cellHeight = function(comp, propName)
		if expandedSequences[propName] and comp and comp.keypoints then
			return CELL_HEIGHT * (1 + #comp.keypoints)
		end
		return CELL_HEIGHT
	end,
	onRowClick = function(comp, propName)
		expandedSequences[propName] = not expandedSequences[propName]
	end,
	render = function(comp, ex, ey, ew, eh, propName, propValue)
		if propValue then
			rl.DrawTextEx(
				vend,
				string.format("[%d points]", #propValue.Keypoints),
				vector.create(ex, ey + (CELL_HEIGHT - 14) / 2),
				13,
				1,
				Theme.SecondaryTextColor:ToRaylib(0)
			)
		end

		if not expandedSequences[propName] or not comp then
			return
		end

		local rx2 = ex - PADDING - NAME_COL_WIDTH
		local rw2 = ew + NAME_COL_WIDTH + PADDING
		local subIndent = 16

		for i, kcomps in ipairs(comp.keypoints) do
			local subY = ey + CELL_HEIGHT * i
			rl.DrawRectangle(
				rx2,
				subY,
				rw2,
				CELL_HEIGHT,
				Theme.SecondaryBackgroundColor:ToRaylib(StudioThemeService.SelectedTheme.WindowBackgroundTransparency)
			)
			rl.DrawRectangle(
				rx2 + subIndent - 4,
				subY,
				1,
				CELL_HEIGHT,
				Theme.ThirdBackgroundColor:ToRaylib(StudioThemeService.SelectedTheme.WindowBackgroundTransparency)
			)
			rl.DrawTextEx(
				vend,
				"Point " .. i,
				vector.create(rx2 + subIndent, subY + (CELL_HEIGHT - 13) / 2),
				12,
				1,
				Theme.SecondaryTextColor:ToRaylib(0)
			)

			local divX = rx2 + NAME_COL_WIDTH
			rl.DrawRectangle(
				divX,
				subY,
				1,
				CELL_HEIGHT,
				Theme.ThirdBackgroundColor:ToRaylib(StudioThemeService.SelectedTheme.WindowBackgroundTransparency)
			)

			local sp = 3
			local w = (ew - sp) / 2
			local edH = CELL_HEIGHT - 8
			local edY = subY + (CELL_HEIGHT - edH) / 2
			kcomps.time:drawWithExtras(ex, edY, w, edH)
			kcomps.value:drawWithExtras(ex + w + sp, edY, w, edH)
		end
	end,
}

-- ColorSequence
datatypes["ColorSequence"] = {
	build = function(selected, propName, propValue)
		local comps = { _isSequence = true, keypoints = {} }
		for i, kp in ipairs(propValue.Keypoints) do
			local kcomps = {
				pos = numTb(Color3.new(1, 1, 0), function(v)
					local cs = selected[propName]
					local kps = cs.Keypoints
					kps[i] = ColorSequenceKeypoint.new(tonumber(v) or kps[i].Position, kps[i].Color)
					selected[propName] = ColorSequence.new(kps)
				end),
				r = numTb(Color3.new(1, 0, 0), function(v)
					local cs = selected[propName]
					local kps = cs.Keypoints
					local c = kps[i].Color
					kps[i] = ColorSequenceKeypoint.new(kps[i].Position, Color3.new(tonumber(v) or c.R, c.G, c.B))
					selected[propName] = ColorSequence.new(kps)
				end),
				g = numTb(Color3.new(0, 1, 0), function(v)
					local cs = selected[propName]
					local kps = cs.Keypoints
					local c = kps[i].Color
					kps[i] = ColorSequenceKeypoint.new(kps[i].Position, Color3.new(c.R, tonumber(v) or c.G, c.B))
					selected[propName] = ColorSequence.new(kps)
				end),
				b = numTb(Color3.new(0, 0, 1), function(v)
					local cs = selected[propName]
					local kps = cs.Keypoints
					local c = kps[i].Color
					kps[i] = ColorSequenceKeypoint.new(kps[i].Position, Color3.new(c.R, c.G, tonumber(v) or c.B))
					selected[propName] = ColorSequence.new(kps)
				end),
				pick = gui.imageButton({
					image = getCPIcon(),
					imageScale = 0.8,
					onClick = function()
						openColorPicker(selected, propName, propValue.Keypoints[i].Color, i)
					end,
				}),
			}
			kcomps.pos:setText(tostring(kp.Position))
			kcomps.r:setText(tostring(round(kp.Color.R)))
			kcomps.g:setText(tostring(round(kp.Color.G)))
			kcomps.b:setText(tostring(round(kp.Color.B)))
			table.insert(comps.keypoints, kcomps)
		end
		return comps
	end,
	cellHeight = function(comp, propName)
		if expandedSequences[propName] and comp and comp.keypoints then
			return CELL_HEIGHT * (1 + #comp.keypoints)
		end
		return CELL_HEIGHT
	end,
	onRowClick = function(comp, propName)
		expandedSequences[propName] = not expandedSequences[propName]
	end,
	render = function(comp, ex, ey, ew, eh, propName, propValue)
		if propValue then
			rl.DrawTextEx(
				vend,
				string.format("[%d points]", #propValue.Keypoints),
				vector.create(ex, ey + (CELL_HEIGHT - 14) / 2),
				13,
				1,
				Theme.SecondaryTextColor:ToRaylib(0)
			)
		end

		if not expandedSequences[propName] or not comp then
			return
		end

		local rx2 = ex - PADDING - NAME_COL_WIDTH
		local rw2 = ew + NAME_COL_WIDTH + PADDING
		local subIndent = 16

		for i, kcomps in ipairs(comp.keypoints) do
			local subY = ey + CELL_HEIGHT * i
			rl.DrawRectangle(
				rx2,
				subY,
				rw2,
				CELL_HEIGHT,
				Theme.SecondaryBackgroundColor:ToRaylib(StudioThemeService.SelectedTheme.WindowBackgroundTransparency)
			)
			rl.DrawRectangle(
				rx2 + subIndent - 4,
				subY,
				1,
				CELL_HEIGHT,
				Theme.ThirdBackgroundColor:ToRaylib(StudioThemeService.SelectedTheme.WindowBackgroundTransparency)
			)

			local divX = rx2 + NAME_COL_WIDTH
			rl.DrawRectangle(
				divX,
				subY,
				1,
				CELL_HEIGHT,
				Theme.ThirdBackgroundColor:ToRaylib(StudioThemeService.SelectedTheme.WindowBackgroundTransparency)
			)

			local sp = 3
			local btnW = 24
			local w = (ew - sp * 4 - btnW) / 4
			local edH = CELL_HEIGHT - 8
			local edY = subY + (CELL_HEIGHT - edH) / 2
			kcomps.pos:drawWithExtras(ex, edY, w, edH)
			kcomps.r:drawWithExtras(ex + (w + sp), edY, w, edH)
			kcomps.g:drawWithExtras(ex + (w + sp) * 2, edY, w, edH)
			kcomps.b:drawWithExtras(ex + (w + sp) * 3, edY, w, edH)
			kcomps.pick.set("obj_rect", arect.new(ex + (w + sp) * 4, edY, btnW, edH))
			kcomps.pick.render(rl.GetFrameTime())
		end
	end,
}

--  filtering

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
		return dt.cellHeight(ec and ec.comp, entry.propName, entry.propValue)
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
		table.insert(buckets[cat], { propName = propName, propValue = propValue, displayName = propName })
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
			return a.displayName < b.displayName
		end)
	end
	return buckets, order
end

--  selection

Selection.SelectionAdded:Connect(function(selected)
	table.clear(editorComps)
	table.clear(overlapping)
	table.clear(cfExpanded)
	table.clear(udim2Expanded)
	table.clear(expandedSequences)
	scrollOffset = 0

	if not selected then
		return
	end

	for propName, propValue in pairs(selected._props) do
		if isBlacklisted(propName, propValue) then
			continue
		end
		local typeName = getPropTypeName(propValue)
		local dt = datatypes[typeName]
		if dt then
			local comp = dt.build(selected, propName, propValue)
			editorComps[propName] = { comp = comp, typeName = typeName, displayName = propName }
			if type(comp) == "table" and comp._isDropdown then
				overlapping[propName] = comp
			end
		end
	end
end)

--  draw category header

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
	local lineColor = Theme.ThirdBackgroundColor:ToRaylib(StudioThemeService.SelectedTheme.WindowBackgroundTransparency)

	rl.DrawRectangle(winX, centerY, PADDING - 4, 1, lineColor)
	rl.DrawTextEx(
		boldFont,
		indicatorText,
		vector.create(blockX, centerY - 6),
		11,
		1,
		Theme.SecondaryTextColor:ToRaylib(0.4)
	)
	rl.DrawTextEx(
		boldFont,
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

--  draw property row

local function drawPropertyRow(winX, winW, y, i, propName, propValue, selected, mousePos, winY, winH)
	local rw = winW - 12
	local rh = CELL_HEIGHT
	local divX = winX + NAME_COL_WIDTH

	local isHovered = mousePos.x >= winX and mousePos.x <= winX + rw and mousePos.y >= y and mousePos.y <= y + rh

	local tr = StudioThemeService.SelectedTheme.WindowBackgroundTransparency

	local bgCol = isHovered and Theme.ThirdBackgroundColor:Lerp(Color3.new(1, 1, 1), 0.06):ToRaylib(tr)
		or (i % 2 == 0 and Theme.SecondaryBackgroundColor:ToRaylib(tr) or Theme.BackgroundColor:ToRaylib(tr))

	rl.DrawRectangle(winX, y, rw, rh, bgCol)
	rl.DrawRectangle(
		divX,
		y,
		1,
		rh,
		Theme.ThirdBackgroundColor:ToRaylib(StudioThemeService.SelectedTheme.WindowBackgroundTransparency)
	)

	local entry = editorComps[propName]
	local displayName = entry and entry.displayName or propName

	local function drawName(indent)
		local textX = winX + PADDING + (indent or 0)
		local textY = y + (rh - 14) / 2
		local maxWidth = NAME_COL_WIDTH - PADDING * 2 - (indent or 0)

		-- Measure text to check if it needs clipping
		local measured = rl.MeasureTextEx(vend, displayName, 14, 1)
		if measured.x <= maxWidth then
			-- Text fits, draw normally
			rl.DrawTextEx(vend, displayName, vector.create(textX, textY), 14, 1, TextColor)
		else
			-- Text is too long, use scissor mode to clip it
			rl.BeginScissorMode(textX, y, maxWidth, rh)
			rl.DrawTextEx(vend, displayName, vector.create(textX, textY), 14, 1, TextColor)
			rl.EndScissorMode()
		end
	end

	if not entry then
		-- no editor, just draw name plainly
		drawName(0)
		return
	end

	local dt = datatypes[entry.typeName]
	local comp = entry.comp
	local editorX = divX + PADDING
	local editorW = rw - NAME_COL_WIDTH - PADDING * 2
	local editorH = rh - 8
	local editorY = y + (rh - editorH) / 2

	local isExpandable = type(comp) == "table" and (comp._isCFrame or comp._isUDim2 or comp._isSequence)

	if isExpandable then
		local expanded = false
		if comp._isCFrame then
			expanded = cfExpanded[propName]
		elseif comp._isUDim2 then
			expanded = udim2Expanded[propName]
		elseif comp._isSequence then
			expanded = expandedSequences[propName]
		end

		local ind = expanded and "v" or ">"
		rl.DrawTextEx(
			vend,
			ind,
			vector.create(winX + PADDING, y + (rh - 13) / 2),
			12,
			1,
			Theme.SecondaryTextColor:ToRaylib(0.5)
		)
		drawName(14)

		if rl.IsMouseButtonPressed(0) == 1 and isHovered and dt.onRowClick then
			dt.onRowClick(comp, propName)
		end
		if dt.render then
			dt.render(comp, editorX, y, editorW, editorH, propName, propValue)
		end
	elseif type(comp) == "table" and comp._isDropdown then
		drawName(0)
	else
		drawName(0)
		if dt then
			local entryH = getEntryHeight(entry)
			dt.render(comp, editorX, editorY, editorW, entryH - 8, propName, propValue)
		end
	end
end

--  main loop

renderer.Pool.new("2d", function(data)
	local dt = rl.GetFrameTime()
	local mainTheme = StudioThemeService.SelectedTheme

	if game.Context == Enum.GameContext.Editor then
		window.update(dt)
		window.draw(dt, mainTheme.aereon)
	end

	if rl.IsWindowResized() == 1 then
		propback.x = frame.AbsolutePosition.X
		propback.y = frame.AbsolutePosition.Y
		propback.width = frame.AbsoluteSize.X
		propback.height = frame.AbsoluteSize.Y
	end
end)

local raylib = require("@raylib")
local scrollableComp

window.stepped = function(windowData)
	for _, ov in pairs(overlapping) do
		ov._framePos = nil
	end
	if windowData.title ~= "Inspector" then
		return
	end

	windowObject = windowData

	local winX = windowData.x
	local titleBarH = windowData._titleBarH or 28
	local winY = windowData.y + titleBarH
	local winW = windowData.width
	local winH = windowData.height - titleBarH

	local dt = rl.GetFrameTime()
	local mousePos = rl.GetMousePosition()

	-- Divider drag handling
	local divX = winX + NAME_COL_WIDTH
	local mousePressed = rl.IsMouseButtonPressed(0) == 1
	local mouseDown = rl.IsMouseButtonDown(0) == 1

	-- Check if mouse is over divider
	local isOverDivider = mousePos.x >= divX - 3
		and mousePos.x <= divX + 3
		and mousePos.y >= winY
		and mousePos.y <= winY + winH

	-- Start drag
	if mousePressed and isOverDivider and not dividerDrag.active then
		dividerDrag.active = true
		dividerDrag.startX = mousePos.x
		dividerDrag.startWidth = NAME_COL_WIDTH
	end

	-- Handle dragging
	if dividerDrag.active and mouseDown then
		local dx = mousePos.x - dividerDrag.startX
		NAME_COL_WIDTH = math.clamp(dividerDrag.startWidth + dx, 80, winW - 100)
	elseif not mouseDown then
		dividerDrag.active = false
	end

	-- Change cursor when hovering over divider
	if isOverDivider then
		local MouseCursor = require("@Kinemium.MouseCursor")
		local Enum = require("@EnumMap")
		MouseCursor.request(Enum.KinemiumMouseCursor.MOUSE_CURSOR_RESIZE_EW.Value)
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

	local inspectorContent
	inspectorContent = {
		get_rect = function()
			return arect.new(0, 0, winW, totalH)
		end,
		set = function(prop, value)
			if prop == "obj_rect" then
				inspectorContent.rect = value
			end
		end,
		render = function(dt)
			local r = inspectorContent.rect
			local cursorY = r.y

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
							drawPropertyRow(
								winX + 1,
								winW - 1,
								rowY,
								i,
								entry.propName,
								entry.propValue,
								selected,
								mousePos,
								winY,
								winH
							)

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
		end,
	}

	if not scrollableComp then
		scrollableComp = gui.scrollable({
			child = inspectorContent,
			input = rl,
			inputButtons = raylib.lib,
			disableClipping = true,
			debug = false,
			scrollbarWidth = 6,
			scrollbarColor = Color3.new(0.3, 0.3, 0.3),
			scrollbarHoverColor = Color3.new(0.4, 0.4, 0.4),
			scrollbarBackgroundTransparency = 1,
		})
	end

	scrollableComp.set("child", inspectorContent)
	scrollableComp.set("obj_rect", arect.new(winX, winY, winW, winH))
	scrollableComp.set("contentHeight", totalH)

	raylib.lib.BeginScissorMode(winX, winY, winW, winH)
	scrollableComp.render(dt)

	for _, ov in pairs(overlapping) do
		if ov._framePos then
			local p = ov._framePos
			if p.ey + p.eh >= winY and p.ey <= winY + winH then
				datatypes["EnumItem"].render(ov, p.ex, p.ey, p.ew, p.eh)
			end
		end
	end
	raylib.lib.EndScissorMode()

	if colorPickerTarget then
		local cpW, cpH = 240, winH
		local cpX = winX + winW + 5
		local cpY = winY

		if cpX + cpW > rl.GetRenderWidth() then
			cpX = winX - cpW - 5
		end

		colorPickerComp.set("obj_rect", arect.new(cpX, cpY, cpW, cpH))
		colorPickerComp.render(dt)

		if rl.IsMouseButtonPressed(0) == 1 then
			local m = rl.GetMousePosition()
			if not (m.x >= cpX and m.x <= cpX + cpW and m.y >= cpY and m.y <= cpY + cpH) then
				colorPickerTarget = nil
			end
		end
	end
end
