-- description: "A flow layout manager for UI elements."
local Vector2 = require("@Vector2")

local Enum = require("@EnumMap")

local UDim = require("@UDim")

local propTable = {
	FillDirection = Enum.FillDirection.Horizontal,
	Padding = UDim.new(0, 5),
	SortOrder = Enum.SortOrder.LayoutOrder,
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	VerticalAlignment = Enum.VerticalAlignment.Top,
	ItemAlignment = Enum.VerticalAlignment.Top, -- Alignment of items within a row/column
	Enabled = true,
	Name = "UIFlowLayout",
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
				return Vector2.new(lib.GetRenderWidth(), lib.GetRenderHeight())
			end

			local parentSize = GetAbsoluteSize(obj.Parent)

			return obj.Size:ToPixels(parentSize)
		end

		local parentSize = GetAbsoluteSize(parent)

		local paddingX, paddingY = 0, 0

		for _, child in ipairs(parent:GetChildren()) do
			if child.ClassName == "UIPadding" then
				local px = child.Padding:ToPixels(parentSize)

				paddingX += px.X

				paddingY += px.Y
			end
		end

		local containerSize =
			Vector2.new(math.max(0, parentSize.X - paddingX * 2), math.max(0, parentSize.Y - paddingY * 2))

		local children = {}

		for _, child in ipairs(parent:GetChildren()) do
			if child ~= object and child.Visible and child.ClassName ~= "UIPadding" then
				table.insert(children, child)
			end
		end

		if object.SortOrder == Enum.SortOrder.LayoutOrder and #children > 1 then
			table.sort(children, function(a, b)
				return (a.LayoutOrder or 0) < (b.LayoutOrder or 0)
			end)
		end

		local paddingPx = object.Padding.Scale
				* (object.FillDirection == Enum.FillDirection.Vertical and containerSize.Y or containerSize.X)
			+ object.Padding.Offset
		local rows = {}
		local currentRow = { children = {}, size = Vector2.new(0, 0) }

		table.insert(rows, currentRow)

		local isHorizontal = object.FillDirection == Enum.FillDirection.Horizontal

		for _, child in ipairs(children) do
			local size = child.Size:ToPixels(containerSize)

			if isHorizontal then
				if currentRow.size.X + size.X > containerSize.X and #currentRow.children > 0 then
					currentRow = { children = {}, size = Vector2.new(0, 0) }

					table.insert(rows, currentRow)
				end

				table.insert(currentRow.children, { child = child, size = size })

				currentRow.size = Vector2.new(
					currentRow.size.X + size.X + (#currentRow.children > 1 and paddingPx or 0),
					math.max(currentRow.size.Y, size.Y)
				)
			else
				if currentRow.size.Y + size.Y > containerSize.Y and #currentRow.children > 0 then
					currentRow = { children = {}, size = Vector2.new(0, 0) }

					table.insert(rows, currentRow)
				end

				table.insert(currentRow.children, { child = child, size = size })

				currentRow.size = Vector2.new(
					math.max(currentRow.size.X, size.X),
					currentRow.size.Y + size.Y + (#currentRow.children > 1 and paddingPx or 0)
				)
			end
		end

		local totalSize = Vector2.new(0, 0)

		for i, row in ipairs(rows) do
			if isHorizontal then
				totalSize = Vector2.new(
					math.max(totalSize.X, row.size.X),
					totalSize.Y + row.size.Y + (i > 1 and paddingPx or 0)
				)
			else
				totalSize = Vector2.new(
					totalSize.X + row.size.X + (i > 1 and paddingPx or 0),
					math.max(totalSize.Y, row.size.Y)
				)
			end
		end

		local currentPos = isHorizontal and paddingY or paddingX

		if isHorizontal then
			if object.VerticalAlignment == Enum.VerticalAlignment.Center then
				currentPos += (containerSize.Y - totalSize.Y) * 0.5
			elseif object.VerticalAlignment == Enum.VerticalAlignment.Bottom then
				currentPos += (containerSize.Y - totalSize.Y)
			end
		else
			if object.HorizontalAlignment == Enum.HorizontalAlignment.Center then
				currentPos += (containerSize.X - totalSize.X) * 0.5
			elseif object.HorizontalAlignment == Enum.HorizontalAlignment.Right then
				currentPos += (containerSize.X - totalSize.X)
			end
		end

		for _, row in ipairs(rows) do
			local rowCursor = isHorizontal and paddingX or paddingY

			if isHorizontal then
				if object.HorizontalAlignment == Enum.HorizontalAlignment.Center then
					rowCursor += (containerSize.X - row.size.X) * 0.5
				elseif object.HorizontalAlignment == Enum.HorizontalAlignment.Right then
					rowCursor += (containerSize.X - row.size.X)
				end
			else
				if object.VerticalAlignment == Enum.VerticalAlignment.Center then
					rowCursor += (containerSize.Y - row.size.Y) * 0.5
				elseif object.VerticalAlignment == Enum.VerticalAlignment.Bottom then
					rowCursor += (containerSize.Y - row.size.Y)
				end
			end

			for _, item in ipairs(row.children) do
				local child = item.child

				local size = item.size

				rawset(child, "_LayoutControlled", true)

				local itemOffset = 0

				if isHorizontal then
					if object.ItemAlignment == Enum.VerticalAlignment.Center then
						itemOffset = (row.size.Y - size.Y) * 0.5
					elseif object.ItemAlignment == Enum.VerticalAlignment.Bottom then
						itemOffset = row.size.Y - size.Y
					end

					rawset(child, "_LayoutRelativePosition", Vector2.new(rowCursor, currentPos + itemOffset))

					rowCursor += size.X + paddingPx
				else
					if object.ItemAlignment == Enum.HorizontalAlignment.Center then
						itemOffset = (row.size.X - size.X) * 0.5
					elseif object.ItemAlignment == Enum.HorizontalAlignment.Right then
						itemOffset = row.size.X - size.X
					end

					rawset(child, "_LayoutRelativePosition", Vector2.new(currentPos + itemOffset, rowCursor))

					rowCursor += size.Y + paddingPx
				end
			end

			currentPos += (isHorizontal and row.size.Y or row.size.X) + paddingPx
		end
	end,
}

return {
	class = "UIFlowLayout",
	render = propTable.render,
	callback = function(instance)
		instance:SetProperties(propTable)

		return instance
	end,
}
