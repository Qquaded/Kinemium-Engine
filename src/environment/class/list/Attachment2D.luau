-- description: "Represents an attachment in 2d, usually used for 2D Physics."
local Vector2 = require("@Vector2")

local propTable = {
	-- local transform
	Position = Vector2.new(0, 0),
	Rotation = 0, -- radians

	BaseClass = "Attachment2D",

	-- api
	-- description: "Gets the World Position."
	-- args: "self: table"
	-- returns: "Vector2"
	GetWorldPosition = function(self)
		local parent = self.Parent
		if not parent then
			return self.Position
		end

		local parentPos = parent.WorldPosition or parent.Position
		local parentRot = parent.Rotation or 0

		local c = math.cos(parentRot)
		local s = math.sin(parentRot)

		local x = self.Position.X * c - self.Position.Y * s
		local y = self.Position.X * s + self.Position.Y * c

		return parentPos + Vector2.new(x, y)
	end,

	-- description: "Gets the World Rotation."
	-- args: "self: table"
	-- returns: "number"
	GetWorldRotation = function(self)
		local parentRot = (self.Parent and self.Parent.Rotation) or 0
		return parentRot + self.Rotation
	end,
}

return {
	class = "Attachment2D",

	callback = function(instance)
		instance:SetProperties(propTable)
		return instance
	end,

	inherit = function(tble)
		for k, v in pairs(propTable) do
			tble[k] = v
		end
	end,
}
