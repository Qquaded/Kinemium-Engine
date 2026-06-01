-- description: "A grid layout for organizing GUI components."
local Vector2 = require("@Vector2")
local Enum = require("@EnumMap")
local UDim = require("@UDim")

local propTable = {
	Name = "UIGridLayout",
	Enabled = true,

	CellPaddingX = UDim.new(0, 5), -- horizontal gap between cells
	CellPaddingY = UDim.new(0, 5), -- vertical gap between cells

	SortOrder = Enum.SortOrder.LayoutOrder,
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	VerticalAlignment = Enum.VerticalAlignment.Top,

	FillDirection = Enum.FillDirection.Horizontal,

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

		local padX = object.CellPaddingX.Scale * effectiveSize.X + object.CellPaddingX.Offset
		local padY = object.CellPaddingY.Scale * effectiveSize.Y + object.CellPaddingY.Offset

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

		if object.FillDirection == Enum.FillDirection.Horizontal then
			local rows = {}
			local currentRow = {}
			local currentRowWidth = 0

			for _, child in ipairs(children) do
				local size = child.Size:ToPixels(effectiveSize)
				local neededWidth = currentRowWidth > 0 and (currentRowWidth + padX + size.X) or size.X

				if neededWidth > effectiveWidth and #currentRow > 0 then
					table.insert(rows, currentRow)
					currentRow = { child }
					currentRowWidth = size.X
				else
					table.insert(currentRow, child)
					currentRowWidth = neededWidth
				end
			end
			if #currentRow > 0 then
				table.insert(rows, currentRow)
			end

			local totalContentHeight = 0
			local rowHeights = {}
			for i, row in ipairs(rows) do
				local rowH = 0
				for _, child in ipairs(row) do
					local size = child.Size:ToPixels(effectiveSize)
					rowH = math.max(rowH, size.Y)
				end
				rowHeights[i] = rowH
				totalContentHeight = totalContentHeight + rowH
				if i < #rows then
					totalContentHeight = totalContentHeight + padY
				end
			end

			local startY = totalPaddingY
			if object.VerticalAlignment == Enum.VerticalAlignment.Center then
				startY = totalPaddingY + math.max(0, (effectiveHeight - totalContentHeight) * 0.5)
			elseif object.VerticalAlignment == Enum.VerticalAlignment.Bottom then
				startY = totalPaddingY + math.max(0, effectiveHeight - totalContentHeight)
			end

			local curY = startY
			for i, row in ipairs(rows) do
				local rowH = rowHeights[i]

				local rowWidth = 0
				for j, child in ipairs(row) do
					local size = child.Size:ToPixels(effectiveSize)
					rowWidth = rowWidth + size.X
					if j < #row then
						rowWidth = rowWidth + padX
					end
				end

				local startX = totalPaddingX
				if object.HorizontalAlignment == Enum.HorizontalAlignment.Center then
					startX = totalPaddingX + math.max(0, (effectiveWidth - rowWidth) * 0.5)
				elseif object.HorizontalAlignment == Enum.HorizontalAlignment.Right then
					startX = totalPaddingX + math.max(0, effectiveWidth - rowWidth)
				end

				local curX = startX
				for _, child in ipairs(row) do
					local size = child.Size:ToPixels(effectiveSize)

					-- Align cell vertically within the row
					local cellY = curY
					if object.VerticalAlignment == Enum.VerticalAlignment.Center then
						cellY = curY + (rowH - size.Y) * 0.5
					elseif object.VerticalAlignment == Enum.VerticalAlignment.Bottom then
						cellY = curY + (rowH - size.Y)
					end

					rawset(child, "_LayoutControlled", true)
					rawset(child, "_LayoutRelativePosition", Vector2.new(curX, cellY))

					curX = curX + size.X + padX
				end

				curY = curY + rowH + padY
			end
		else
			local cols = {}
			local currentCol = {}
			local currentColHeight = 0

			for _, child in ipairs(children) do
				local size = child.Size:ToPixels(effectiveSize)
				local neededHeight = currentColHeight > 0 and (currentColHeight + padY + size.Y) or size.Y

				if neededHeight > effectiveHeight and #currentCol > 0 then
					table.insert(cols, currentCol)
					currentCol = { child }
					currentColHeight = size.Y
				else
					table.insert(currentCol, child)
					currentColHeight = neededHeight
				end
			end
			if #currentCol > 0 then
				table.insert(cols, currentCol)
			end

			local totalContentWidth = 0
			local colWidths = {}
			for i, col in ipairs(cols) do
				local colW = 0
				for _, child in ipairs(col) do
					local size = child.Size:ToPixels(effectiveSize)
					colW = math.max(colW, size.X)
				end
				colWidths[i] = colW
				totalContentWidth = totalContentWidth + colW
				if i < #cols then
					totalContentWidth = totalContentWidth + padX
				end
			end

			local startX = totalPaddingX
			if object.HorizontalAlignment == Enum.HorizontalAlignment.Center then
				startX = totalPaddingX + math.max(0, (effectiveWidth - totalContentWidth) * 0.5)
			elseif object.HorizontalAlignment == Enum.HorizontalAlignment.Right then
				startX = totalPaddingX + math.max(0, effectiveWidth - totalContentWidth)
			end

			local curX = startX
			for i, col in ipairs(cols) do
				local colW = colWidths[i]

				local colHeight = 0
				for j, child in ipairs(col) do
					local size = child.Size:ToPixels(effectiveSize)
					colHeight = colHeight + size.Y
					if j < #col then
						colHeight = colHeight + padY
					end
				end

				local startY = totalPaddingY
				if object.VerticalAlignment == Enum.VerticalAlignment.Center then
					startY = totalPaddingY + math.max(0, (effectiveHeight - colHeight) * 0.5)
				elseif object.VerticalAlignment == Enum.VerticalAlignment.Bottom then
					startY = totalPaddingY + math.max(0, effectiveHeight - colHeight)
				end

				local curY = startY
				for _, child in ipairs(col) do
					local size = child.Size:ToPixels(effectiveSize)

					local cellX = curX
					if object.HorizontalAlignment == Enum.HorizontalAlignment.Center then
						cellX = curX + (colW - size.X) * 0.5
					elseif object.HorizontalAlignment == Enum.HorizontalAlignment.Right then
						cellX = curX + (colW - size.X)
					end

					rawset(child, "_LayoutControlled", true)
					rawset(child, "_LayoutRelativePosition", Vector2.new(cellX, curY))

					curY = curY + size.Y + padY
				end

				curX = curX + colW + padX
			end
		end
	end,
}

return {
	class = "UIGridLayout",
	render = propTable.render,

	callback = function(instance)
		instance:SetProperties(propTable)
		return instance
	end,
}
