-- description: "A modifier class that arranges GUI elements in a table-like grid layout."
local Vector2 = require("@Vector2")
local Enum = require("@EnumMap")
local UDim = require("@UDim")

local propTable = {
	Name = "UITableLayout",
	Enabled = true,

	Columns = {},

	RowHeight = UDim.new(0, 40), -- height of each row (uniform)
	PaddingX = UDim.new(0, 8), -- horizontal padding inside each cell
	PaddingY = UDim.new(0, 4), -- vertical padding between rows

	SortOrder = Enum.SortOrder.LayoutOrder,
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	VerticalAlignment = Enum.VerticalAlignment.Top,

	FillEmptyColumns = true,

	render = function(lib, object, dt, structs)
		if not object.Enabled then
			return
		end
		local parent = object.Parent
		if not parent then
			return
		end

		local function GetAbsoluteSize(obj)
			if obj.AbsoluteSize then
				return obj.AbsoluteSize
			end
			if obj:IsA("ScreenGui") then
				local dpiScale = lib.GetWindowScaleDPI()
				return Vector2.new(lib.GetRenderWidth() / dpiScale.x, lib.GetRenderHeight() / dpiScale.y)
			else
				local parentSize = GetAbsoluteSize(obj.Parent)
				return obj.Size:ToPixels(parentSize)
			end
		end

		local parentSize = GetAbsoluteSize(parent)

		local totalPaddingX = 0
		local totalPaddingY = 0
		for _, child in ipairs(parent:GetChildren()) do
			if child.ClassName == "UIPadding" then
				local px = child.Padding:ToPixels(parentSize)
				totalPaddingX = totalPaddingX + px.X
				totalPaddingY = totalPaddingY + px.Y
			end
		end

		local effectiveWidth = math.max(0, parentSize.X - totalPaddingX * 2)
		local effectiveHeight = math.max(0, parentSize.Y - totalPaddingY * 2)
		local effectiveSize = Vector2.new(effectiveWidth, effectiveHeight)

		local padX = object.PaddingX.Scale * effectiveSize.X + object.PaddingX.Offset
		local padY = object.PaddingY.Scale * effectiveSize.Y + object.PaddingY.Offset
		local rowH = object.RowHeight.Scale * effectiveSize.Y + object.RowHeight.Offset

		local children = {}
		for _, child in ipairs(parent:GetChildren()) do
			if child.Visible and child ~= object and child.ClassName ~= "UIPadding" then
				table.insert(children, child)
			end
		end

		if object.SortOrder == Enum.SortOrder.LayoutOrder and #children > 1 then
			table.sort(children, function(a, b)
				return (a.LayoutOrder or 0) < (b.LayoutOrder or 0)
			end)
		end

		local rows = {}
		local maxCols = 0

		for _, child in ipairs(children) do
			local cells = {}
			local subChildren = child:GetChildren()

			local visibleSubs = {}
			for _, sub in ipairs(subChildren) do
				if sub.Visible and sub.ClassName ~= "UIPadding" and sub.ClassName ~= "UITableLayout" then
					table.insert(visibleSubs, sub)
				end
			end

			if #visibleSubs > 0 then
				for _, sub in ipairs(visibleSubs) do
					table.insert(cells, sub)
				end
			else
				table.insert(cells, child)
			end

			if #cells > maxCols then
				maxCols = #cells
			end

			table.insert(rows, { container = (#visibleSubs > 0) and child or nil, cells = cells })
		end

		if maxCols == 0 then
			return
		end

		local colDefs = object.Columns or {}
		local colWidths = {}

		if #colDefs > 0 then
			local fixedTotal = 0
			local scaleTotal = 0

			for i = 1, maxCols do
				local def = colDefs[i]
				if def and def.Width then
					local w = def.Width.Scale * effectiveWidth + def.Width.Offset
					colWidths[i] = w
					if def.Width.Scale > 0 then
						scaleTotal = scaleTotal + def.Width.Scale
					else
						fixedTotal = fixedTotal + w
					end
				else
					colWidths[i] = nil
				end
			end

			local remaining = effectiveWidth - fixedTotal
			local undefinedCount = 0
			for i = 1, maxCols do
				if not colWidths[i] then
					undefinedCount = undefinedCount + 1
				end
			end
			if undefinedCount > 0 then
				local share = math.max(0, remaining / undefinedCount)
				for i = 1, maxCols do
					if not colWidths[i] then
						colWidths[i] = share
					end
				end
			end
		else
			local share = effectiveWidth / maxCols
			for i = 1, maxCols do
				colWidths[i] = share
			end
		end

		local colOffsets = {}
		local cursor = totalPaddingX

		local totalTableWidth = 0
		for i = 1, maxCols do
			totalTableWidth = totalTableWidth + (colWidths[i] or 0)
		end

		if object.HorizontalAlignment == Enum.HorizontalAlignment.Center then
			cursor = totalPaddingX + math.max(0, (effectiveWidth - totalTableWidth) * 0.5)
		elseif object.HorizontalAlignment == Enum.HorizontalAlignment.Right then
			cursor = totalPaddingX + math.max(0, effectiveWidth - totalTableWidth)
		end

		for i = 1, maxCols do
			colOffsets[i] = cursor
			cursor = cursor + (colWidths[i] or 0)
		end

		local totalTableHeight = #rows * rowH + math.max(0, #rows - 1) * padY
		local startY = totalPaddingY

		if object.VerticalAlignment == Enum.VerticalAlignment.Center then
			startY = totalPaddingY + math.max(0, (effectiveHeight - totalTableHeight) * 0.5)
		elseif object.VerticalAlignment == Enum.VerticalAlignment.Bottom then
			startY = totalPaddingY + math.max(0, effectiveHeight - totalTableHeight)
		end

		local curY = startY

		for _, row in ipairs(rows) do
			if row.container then
				rawset(row.container, "_LayoutControlled", true)
				rawset(row.container, "_LayoutRelativePosition", Vector2.new(colOffsets[1], curY))
				rawset(row.container, "_LayoutRowWidth", totalTableWidth)
				rawset(row.container, "_LayoutRowHeight", rowH)
			end

			-- Place each cell
			for colIndex, cell in ipairs(row.cells) do
				if colIndex > maxCols then
					break
				end

				local colX = colOffsets[colIndex]
				local colW = colWidths[colIndex] or 0

				-- Per-column horizontal alignment
				local colDef = colDefs[colIndex]
				local colAlign = (colDef and colDef.HorizontalAlignment) or object.HorizontalAlignment

				-- Cell size (use child's own size, clamped to column width minus padding)
				local cellSize = cell.Size:ToPixels(Vector2.new(colW, rowH))
				local cellW = math.min(cellSize.X, colW - padX * 2)
				local cellH = math.min(cellSize.Y, rowH)

				-- Horizontal position within column
				local cellX = colX + padX
				if colAlign == Enum.HorizontalAlignment.Center then
					cellX = colX + (colW - cellW) * 0.5
				elseif colAlign == Enum.HorizontalAlignment.Right then
					cellX = colX + colW - cellW - padX
				end

				-- Vertical centering within row
				local cellY = curY + (rowH - cellH) * 0.5

				rawset(cell, "_LayoutControlled", true)
				rawset(cell, "_LayoutRelativePosition", Vector2.new(cellX, cellY))
			end

			curY = curY + rowH + padY
		end
	end,
}

return {
	class = "UITableLayout",
	render = propTable.render,

	callback = function(instance)
		instance:SetProperties(propTable)
		return instance
	end,
}
