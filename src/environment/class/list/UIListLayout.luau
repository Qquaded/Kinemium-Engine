-- description: "A layout that arranges GUI components in a list."
local Vector2 = require("@Vector2")
local Enum = require("@EnumMap")
local UDim = require("@UDim")

local propTable = {
	FillDirection = Enum.FillDirection.Vertical,
	Padding = UDim.new(0, 5),
	SortOrder = Enum.SortOrder.LayoutOrder,
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	VerticalAlignment = Enum.VerticalAlignment.Top,
	Enabled = true,
	Name = "UIListLayout",

	Virtualized = true,
	Overscan = 100,

	render = function(lib, object, dt, structs)
		if not object.Enabled then
			return
		end

		local parent = object.Parent
		if not parent then
			return
		end

		--------------------------------------------------
		-- Utility
		--------------------------------------------------
		local function GetAbsoluteSize(obj)
			if obj.AbsoluteSize then
				return obj.AbsoluteSize
			end

			if obj:IsA("ScreenGui") then
				local dpiScale = lib.GetWindowScaleDPI()
				return Vector2.new(lib.GetRenderWidth() / dpiScale.X, lib.GetRenderHeight() / dpiScale.Y)
			end

			local parentSize = GetAbsoluteSize(obj.Parent)
			return obj.Size:ToPixels(parentSize)
		end

		local parentSize = GetAbsoluteSize(parent)

		--------------------------------------------------
		-- Padding
		--------------------------------------------------
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

		local isVertical = object.FillDirection == Enum.FillDirection.Vertical
		local mainSize = isVertical and containerSize.Y or containerSize.X
		local crossSize = isVertical and containerSize.X or containerSize.Y

		--------------------------------------------------
		-- Collect children
		--------------------------------------------------
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

		--------------------------------------------------
		-- Get FlexItem
		--------------------------------------------------
		local function GetFlexItem(child)
			for _, modifier in ipairs(child:GetChildren()) do
				if modifier.ClassName == "UIFlexItem" then
					return modifier
				end
			end

			return nil
		end

		--------------------------------------------------
		-- Calculate basis sizes
		--------------------------------------------------
		local items = {}
		local totalBasis = 0

		for _, child in ipairs(children) do
			local size = child.Size:ToPixels(containerSize)

			local basis = isVertical and size.Y or size.X
			local cross = isVertical and size.X or size.Y

			local flex = GetFlexItem(child)

			local mode = Enum.UIFlexMode.None
			local growRatio = 0
			local shrinkRatio = 0
			local lineAlignment = Enum.ItemLineAlignment.Automatic

			if flex then
				mode = flex.FlexMode
				growRatio = math.max(0, flex.GrowRatio or 0)
				shrinkRatio = math.max(0, flex.ShrinkRatio or 0)
				lineAlignment = flex.ItemLineAlignment
			end

			--------------------------------------------------
			-- Convert FlexMode into effective ratios
			--------------------------------------------------
			local grow = 0
			local shrink = 0

			if mode == Enum.UIFlexMode.Grow then
				grow = 1
				shrink = 0
			elseif mode == Enum.UIFlexMode.Shrink then
				grow = 0
				shrink = 1
			elseif mode == Enum.UIFlexMode.Fill then
				grow = 1
				shrink = 1
			elseif mode == Enum.UIFlexMode.Custom then
				grow = growRatio
				shrink = shrinkRatio
			end

			table.insert(items, {
				child = child,
				basis = basis,
				size = basis,
				crossSize = cross,

				grow = grow,
				shrink = shrink,

				lineAlignment = lineAlignment,
			})

			totalBasis += basis
		end

		--------------------------------------------------
		-- Padding between items
		--------------------------------------------------
		local paddingPx = object.Padding.Scale * mainSize + object.Padding.Offset

		local totalPadding = math.max(0, #items - 1) * paddingPx

		local availableSpace = mainSize - totalBasis - totalPadding

		--------------------------------------------------
		-- FLEX GROW
		--------------------------------------------------
		if availableSpace > 0 then
			local totalGrow = 0

			for _, item in ipairs(items) do
				totalGrow += item.grow
			end

			if totalGrow > 0 then
				for _, item in ipairs(items) do
					if item.grow > 0 then
						item.size += availableSpace * (item.grow / totalGrow)
					end
				end
			end

		--------------------------------------------------
		-- FLEX SHRINK
		--------------------------------------------------
		elseif availableSpace < 0 then
			local overflow = -availableSpace
			local totalShrink = 0

			for _, item in ipairs(items) do
				totalShrink += item.shrink
			end

			if totalShrink > 0 then
				for _, item in ipairs(items) do
					if item.shrink > 0 then
						local reduction = overflow * (item.shrink / totalShrink)

						-- Don't allow a flex item to become negative.
						item.size = math.max(0, item.size - reduction)
					end
				end
			end
		end

		--------------------------------------------------
		-- Final total span
		--------------------------------------------------
		local totalSpan = totalPadding

		for _, item in ipairs(items) do
			totalSpan += item.size
		end

		--------------------------------------------------
		-- Container alignment
		--------------------------------------------------
		local cursor

		if isVertical then
			cursor = paddingY

			if object.VerticalAlignment == Enum.VerticalAlignment.Center then
				cursor += (containerSize.Y - totalSpan) * 0.5
			elseif object.VerticalAlignment == Enum.VerticalAlignment.Bottom then
				cursor += containerSize.Y - totalSpan
			end
		else
			cursor = paddingX

			if object.HorizontalAlignment == Enum.HorizontalAlignment.Center then
				cursor += (containerSize.X - totalSpan) * 0.5
			elseif object.HorizontalAlignment == Enum.HorizontalAlignment.Right then
				cursor += containerSize.X - totalSpan
			end
		end

		--------------------------------------------------
		-- Viewport culling
		--------------------------------------------------
		local viewMin = -object.Overscan
		local viewMax = mainSize + object.Overscan

		--------------------------------------------------
		-- Layout
		--------------------------------------------------
		for _, item in ipairs(items) do
			local child = item.child
			local span = item.size

			local posStart = cursor
			local posEnd = cursor + span

			if not object.Virtualized or (posEnd >= viewMin and posStart <= viewMax) then
				rawset(child, "_LayoutControlled", true)

				--------------------------------------------------
				-- Cross-axis alignment
				--------------------------------------------------
				local alignment = item.lineAlignment

				if alignment == Enum.ItemLineAlignment.Automatic then
					if isVertical then
						alignment = object.HorizontalAlignment
					else
						alignment = object.VerticalAlignment
					end
				end

				local crossPosition = 0
				local crossChildSize = item.crossSize

				if
					alignment == Enum.ItemLineAlignment.Center
					or alignment == Enum.HorizontalAlignment.Center
					or alignment == Enum.VerticalAlignment.Center
				then
					crossPosition = (crossSize - crossChildSize) * 0.5
				elseif
					alignment == Enum.ItemLineAlignment.End
					or alignment == Enum.HorizontalAlignment.Right
					or alignment == Enum.VerticalAlignment.Bottom
				then
					crossPosition = crossSize - crossChildSize
				elseif alignment == Enum.ItemLineAlignment.Stretch then
					crossChildSize = crossSize
				end

				--------------------------------------------------
				-- Position
				--------------------------------------------------
				if isVertical then
					rawset(child, "_LayoutRelativePosition", Vector2.new(crossPosition + paddingX, cursor))

					rawset(child, "_LayoutRelativeSize", Vector2.new(crossChildSize, span))
				else
					rawset(child, "_LayoutRelativePosition", Vector2.new(cursor, crossPosition + paddingY))

					rawset(child, "_LayoutRelativeSize", Vector2.new(span, crossChildSize))
				end
			end

			cursor += span + paddingPx

			if object.Virtualized and cursor > viewMax then
				break
			end
		end
	end,
}

return {
	class = "UIListLayout",
	render = propTable.render,
	callback = function(instance)
		instance:SetProperties(propTable)
		return instance
	end,
}
