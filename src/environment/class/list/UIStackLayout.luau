-- description: "A modifier class that stacks GUI elements in a vertical or horizontal layout."
local Vector2 = require("@Vector2")
local Enum = require("@EnumMap")
local UDim2 = require("@UDim2")

local propTable = {
	Name = "UIStackLayout",
	Enabled = true,

	-- "ZIndex" stacks by ZIndex order, "LayoutOrder" stacks by LayoutOrder
	SortOrder = Enum.SortOrder.LayoutOrder,

	-- Which corner/edge children anchor to when stacking
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	VerticalAlignment = Enum.VerticalAlignment.Top,

	-- If true, each child fills the full parent size (classic overlay stack)
	-- If false, children keep their own size and are just layered at the alignment point
	FillParent = true,

	-- Offset applied between each layer (creates a "fanned" effect when > 0)
	LayerOffset = UDim2.new(0, 0, 0, 0),

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

		local offsetX = object.LayerOffset.X.Scale * effectiveSize.X + object.LayerOffset.X.Offset
		local offsetY = object.LayerOffset.Y.Scale * effectiveSize.Y + object.LayerOffset.Y.Offset

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
		elseif #children > 1 then
			-- ZIndex sort
			table.sort(children, function(a, b)
				return (a.ZIndex or 0) < (b.ZIndex or 0)
			end)
		end

		for i, child in ipairs(children) do
			rawset(child, "_LayoutControlled", true)

			local layerX = totalPaddingX + offsetX * (i - 1)
			local layerY = totalPaddingY + offsetY * (i - 1)

			if object.FillParent then
				-- Each layer fills the full effective area (offset aside)
				rawset(child, "_LayoutRelativePosition", Vector2.new(layerX, layerY))
			else
				-- Position child at the alignment point without resizing it
				local childSize = child.Size:ToPixels(effectiveSize)

				local x = layerX
				if object.HorizontalAlignment == Enum.HorizontalAlignment.Center then
					x = totalPaddingX + (effectiveWidth - childSize.X) * 0.5 + offsetX * (i - 1)
				elseif object.HorizontalAlignment == Enum.HorizontalAlignment.Right then
					x = totalPaddingX + effectiveWidth - childSize.X + offsetX * (i - 1)
				end

				local y = layerY
				if object.VerticalAlignment == Enum.VerticalAlignment.Center then
					y = totalPaddingY + (effectiveHeight - childSize.Y) * 0.5 + offsetY * (i - 1)
				elseif object.VerticalAlignment == Enum.VerticalAlignment.Bottom then
					y = totalPaddingY + effectiveHeight - childSize.Y + offsetY * (i - 1)
				end

				rawset(child, "_LayoutRelativePosition", Vector2.new(x, y))
			end
		end
	end,
}

return {
	class = "UIStackLayout",
	render = propTable.render,
	callback = function(instance)
		instance:SetProperties(propTable)
		return instance
	end,
}
