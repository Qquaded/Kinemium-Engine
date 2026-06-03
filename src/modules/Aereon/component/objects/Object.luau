local Object = {}
Object.__index = Object
Object.__type = "AereonObject"

function Object.new(name)
	local self = setmetatable({}, Object)
	self.Name = name or "Object"
	self.Parent = nil
	self.Children = {}
	return self
end

return Object
