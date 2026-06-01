-- description: "Adds padding around child content."
local UDim2 = require("@UDim2")
local UDim = require("@UDim")
local Vector2 = require("@Vector2")

local propTable = {
	Name = "UIPadding",
	BaseClass = "Instance",

	Padding = UDim2.new(0, 0, 0, 0),
	PaddingLeft = nil,
	PaddingRight = nil,
	PaddingTop = nil,
	PaddingBottom = nil,

	_CachedParentSize = nil,
	_CachedResolved = nil,
}

local function resolveLegacyPaddingSide(padding, primaryKey, secondaryKey)
	local side = padding and padding[primaryKey]
	if side then
		return side
	end

	return padding and padding[secondaryKey] or UDim.new(0, 0)
end

local function resolvePaddingSide(instance, propertyName, primaryKey, secondaryKey)
	local explicit = instance[propertyName]
	if explicit ~= nil then
		return explicit
	end

	return resolveLegacyPaddingSide(instance.Padding, primaryKey, secondaryKey)
end

-- description: "Gets the resolved padding."
-- args: "parentSize: number"
function propTable:GetResolvedPadding(parentSize)
	local cachedSize = self._CachedParentSize
	local cachedResolved = self._CachedResolved

	if cachedSize and cachedResolved and cachedSize == parentSize then
		return cachedResolved
	end

	local leftUDim = resolvePaddingSide(self, "PaddingLeft", "X", "X")
	local rightUDim = resolvePaddingSide(self, "PaddingRight", "X2", "X")
	local topUDim = resolvePaddingSide(self, "PaddingTop", "Y", "Y")
	local bottomUDim = resolvePaddingSide(self, "PaddingBottom", "Y2", "Y")

	local left = leftUDim.Scale * parentSize.X + leftUDim.Offset
	local right = rightUDim.Scale * parentSize.X + rightUDim.Offset
	local top = topUDim.Scale * parentSize.Y + topUDim.Offset
	local bottom = bottomUDim.Scale * parentSize.Y + bottomUDim.Offset

	local resolved = {
		Left = left,
		Right = right,
		Top = top,
		Bottom = bottom,

		Horizontal = left + right,
		Vertical = top + bottom,
	}

	self._CachedParentSize = parentSize
	self._CachedResolved = resolved

	return resolved
end

-- description: "Get inner padding size."
-- args: "containerSize: number"
function propTable:GetInnerSize(containerSize)
	local p = self:GetResolvedPadding(containerSize)

	return Vector2.new(math.max(0, containerSize.X - p.Horizontal), math.max(0, containerSize.Y - p.Vertical))
end

-- description: "Get cached offset padding (resolved)."
function propTable:GetOffset()
	local p = self._CachedResolved
	return Vector2.new(p.Left, p.Top)
end

-- description: "Applies position to padding"
-- args: "pos: Vector3"
function propTable:ApplyToPosition(pos)
	local p = self._CachedResolved
	return pos + Vector2.new(p.Left, p.Top)
end

-- description: "Gets all UIPadding objects in the container's children"
-- args: "container: number"
function propTable.GetAll(container)
	local out = {}

	for _, child in ipairs(container:GetChildren()) do
		if child.ClassName == "UIPadding" then
			table.insert(out, child)
		end
	end

	return out
end

-- description: "Resolves padding properties."
-- args: "container: number, containerSize: number"
function propTable.ResolveAll(container, containerSize)
	local total = {
		Left = 0,
		Right = 0,
		Top = 0,
		Bottom = 0,
	}

	for _, padding in ipairs(propTable.GetAll(container)) do
		local p = padding:GetResolvedPadding(containerSize)

		total.Left += p.Left
		total.Right += p.Right
		total.Top += p.Top
		total.Bottom += p.Bottom
	end

	total.Horizontal = total.Left + total.Right
	total.Vertical = total.Top + total.Bottom

	return total
end

-- description: "Gets the TotalInnerSize."
-- args: "container: number, containerSize: number"
function propTable.GetTotalInnerSize(container, containerSize)
	local p = propTable.ResolveAll(container, containerSize)

	return Vector2.new(math.max(0, containerSize.X - p.Horizontal), math.max(0, containerSize.Y - p.Vertical))
end

-- description: "Gets the TotalOffset."
-- args: "container: number, containerSize: number"
function propTable.GetTotalOffset(container, containerSize)
	local p = propTable.ResolveAll(container, containerSize)
	return Vector2.new(p.Left, p.Top)
end

return {
	class = "UIPadding",
	render = function()
		-- no render; purely layout modifier
	end,
	callback = function(instance)
		instance:SetProperties(propTable)
		return instance
	end,
}
