local Signal = require("@Kinemium.signal")

local ReactPointer = {}
ReactPointer.__index = ReactPointer

function ReactPointer.new()
	return setmetatable({
		store = {},
		signals = {},
	}, ReactPointer)
end

function ReactPointer:_resolveKey(key, subkey)
	if subkey then
		return key .. "." .. subkey
	end
	return key
end

function ReactPointer:_getSignal(key)
	local sig = self.signals[key]
	if not sig then
		sig = Signal.new()
		self.signals[key] = sig
	end
	return sig
end

function ReactPointer:set(key, subkey, value)
	-- allow both: set("#dark", value) OR set("#dark", "bg", value)
	if value == nil then
		value = subkey
		subkey = nil
	end

	local fullKey = self:_resolveKey(key, subkey)

	if self.store[fullKey] == value then
		return
	end

	self.store[fullKey] = value
	self:_getSignal(fullKey):Fire(value)
end

function ReactPointer:get(key, subkey)
	return self.store[self:_resolveKey(key, subkey)]
end

function ReactPointer:subscribe(key, subkey, fn)
	if typeof(subkey) == "function" then
		fn = subkey
		subkey = nil
	end

	return self:_getSignal(self:_resolveKey(key, subkey)):Connect(fn)
end

function ReactPointer:bind(object, property, value)
	if typeof(value) == "string" and value:sub(1, 1) == "#" then
		local key, sub = value:match("^(#[^%.]+)%.?(.*)$")
		if sub == "" then
			sub = nil
		end

		object[property] = self:get(key, sub)

		return self:subscribe(key, sub, function(v)
			object[property] = v
		end)
	end

	object[property] = value
end

function ReactPointer:setGroup(key, tbl)
	for sub, value in pairs(tbl) do
		self:set(key, sub, value)
	end
end

function ReactPointer:resolve(value, apply)
	if typeof(value) == "string" and value:sub(1, 1) == "#" then
		local key, sub = value:match("^(#[^%.]+)%.?(.*)$")
		if sub == "" then
			sub = nil
		end

		apply(self:get(key, sub))

		return self:subscribe(key, sub, apply)
	end

	apply(value)
end

function ReactPointer:compute(key, dependencies, fn)
	local function recompute()
		local values = {}

		for i, dep in ipairs(dependencies) do
			values[i] = self:get(dep)
		end

		self:set(key, fn(table.unpack(values)))
	end

	-- subscribe to all deps
	for _, dep in ipairs(dependencies) do
		self:subscribe(dep, recompute)
	end

	-- initial compute
	recompute()
end

function ReactPointer:destroy()
	for _, sig in pairs(self.signals) do
		sig:Destroy()
	end

	self.signals = {}
	self.store = {}
end

return ReactPointer
