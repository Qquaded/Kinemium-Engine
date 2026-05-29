-- description: "Represents an UIListLayout in the environment."
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

	-- description: "Renders the component."
	-- args: "lib: number, object: table, dt: number, structs: table"
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
		-- description: "Gets the AbsoluteSize."
		-- args: "obj: any"
		-- returns: "Vector3"
		local function GetAbsoluteSize(obj)
			if obj.AbsoluteSize then
				return obj.AbsoluteSize
			end
			if obj:IsA("ScreenGui") then
				local dpiScale = lib.GetWindowScaleDPI()
				return Vector2.new(lib.GetRenderWidth() / dpiScale.x, lib.GetRenderHeight() / dpiScale.y)
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

		local paddingPx = object.Padding.Scale
				* (object.FillDirection == Enum.FillDirection.Vertical and containerSize.Y or containerSize.X)
			+ object.Padding.Offset

		local totalSpan = 0
		for i, child in ipairs(children) do
			local size = child.Size:ToPixels(containerSize)
			local span = (object.FillDirection == Enum.FillDirection.Vertical) and size.Y or size.X

			totalSpan += span

			if i > 1 then
				totalSpan += paddingPx
			end
		end

		--------------------------------------------------
		-- Viewport culling bounds
		--------------------------------------------------
		local viewMin = -object.Overscan
		local viewMax = (object.FillDirection == Enum.FillDirection.Vertical and containerSize.Y or containerSize.X)
			+ object.Overscan

		local cursor

		if object.FillDirection == Enum.FillDirection.Horizontal then
			cursor = paddingX

			if object.HorizontalAlignment == Enum.HorizontalAlignment.Center then
				cursor += (containerSize.X - totalSpan) * 0.5
			elseif object.HorizontalAlignment == Enum.HorizontalAlignment.Right then
				cursor += (containerSize.X - totalSpan)
			end
		else
			cursor = paddingY

			if object.VerticalAlignment == Enum.VerticalAlignment.Center then
				cursor += (containerSize.Y - totalSpan) * 0.5
			elseif object.VerticalAlignment == Enum.VerticalAlignment.Bottom then
				cursor += (containerSize.Y - totalSpan)
			end
		end
		--------------------------------------------------
		-- Layout loop (virtualized)
		--------------------------------------------------
		for _, child in ipairs(children) do
			local size = child.Size:ToPixels(containerSize)
			local span = (object.FillDirection == Enum.FillDirection.Vertical) and size.Y or size.X

			local posStart = cursor
			local posEnd = cursor + span

			if not object.Virtualized or (posEnd >= viewMin and posStart <= viewMax) then
				rawset(child, "_LayoutControlled", true)

				if object.FillDirection == Enum.FillDirection.Vertical then
					local x = 0
					if object.HorizontalAlignment == Enum.HorizontalAlignment.Center then
						x = (containerSize.X - size.X) * 0.5
					elseif object.HorizontalAlignment == Enum.HorizontalAlignment.Right then
						x = containerSize.X - size.X
					end

					rawset(child, "_LayoutRelativePosition", Vector2.new(x + paddingX, cursor))
				else
					local y = 0
					if object.VerticalAlignment == Enum.VerticalAlignment.Center then
						y = (containerSize.Y - size.Y) * 0.5
					elseif object.VerticalAlignment == Enum.VerticalAlignment.Bottom then
						y = containerSize.Y - size.Y
					end

					rawset(child, "_LayoutRelativePosition", Vector2.new(cursor, y + paddingY))
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
	-- description: "Initializes the UIListLayout instance."
	-- args: "instance: table"
	-- returns: "table"
	callback = function(instance)
		instance:SetProperties(propTable)
		return instance
	end,
}
