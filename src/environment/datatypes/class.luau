local Class = {}
Class.__index = Class

function Class.New(name, base)
	local cls = {}
	cls.__name = name or "Class"
	cls.__index = cls
	cls.__base = base

	-- Inherit methods
	if base then
		setmetatable(cls, { __index = base })
	else
		setmetatable(cls, { __index = Class })
	end

	function cls:New(...)
		local instance = setmetatable({}, cls)
		if instance.Init then
			instance:Init(...)
		end
		return instance
	end

	function cls:Super(methodName, ...)
		local base = rawget(cls, "__base")
		if base and base[methodName] then
			return base[methodName](self, ...)
		end
	end

	return cls
end

function Class.IsInstance(obj, cls)
	local mt = getmetatable(obj)
	while mt do
		if mt == cls then
			return true
		end
		mt = rawget(mt, "__base")
	end
	return false
end

return Class
