-- description: "Represents an Attachment2D in the environment."
local Vector2 = require("@Vector2")

local propTable = {
	-- local transform
	Position = Vector2.new(0, 0),
	Rotation = 0, -- radians

	BaseClass = "Attachment2D",

	-- api
	-- description: "Gets the WorldPosition."
	-- args: "self: table"
	-- returns: "Vector3"
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

	-- description: "Gets the WorldRotation."
	-- args: "self: table"
	-- returns: "any"
	GetWorldRotation = function(self)
		local parentRot = (self.Parent and self.Parent.Rotation) or 0
		return parentRot + self.Rotation
	end,
}

return {
	class = "Attachment2D",

	-- description: "Initializes the Attachment2D instance."
	-- args: "instance: table"
	-- returns: "table"
	callback = function(instance)
		instance:SetProperties(propTable)
		return instance
	end,

	-- description: "Inherits the properties of the Attachment2D class."
	-- args: "tble: table"
	inherit = function(tble)
		for k, v in pairs(propTable) do
			tble[k] = v
		end
	end,
}
