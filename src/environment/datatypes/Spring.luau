-- Spring.lua
local Spring = {}
Spring.__index = Spring

local CFrame, Vector3, Vector2, UDim2, UDim, Color3, Ray, Color4, BoundingBox =
	require("@CFrame"),
	require("@Vector3"),
	require("@Vector2"),
	require("@UDim2"),
	require("@UDim"),
	require("@Color3"),
	require("@Ray"),
	require("@Color4"),
	require("@BoundingBox")

local pi = math.pi
local exp = math.exp
local sqrt = math.sqrt
local cos = math.cos
local sin = math.sin
local EPS = 1e-4

local function inferTypeName(value)
	local luaType = type(value)
	if luaType == "number" then
		return "Number"
	end

	if luaType ~= "table" then
		return nil
	end

	local mt = getmetatable(value)
	if mt == Vector3 then
		return "Vector3"
	end
	if mt == Vector2 then
		return "Vector2"
	end
	if mt == Color3 then
		return "Color3"
	end
	if mt == Color4 then
		return "Color4"
	end
	if mt == CFrame then
		return "CFrame"
	end
	if mt == UDim then
		return "UDim"
	end
	if mt == UDim2 then
		return "UDim2"
	end
	if mt == Ray then
		return "Ray"
	end
	if mt == BoundingBox then
		return "BoundingBox"
	end

	return value.__type or value.type
end

local function serializeValue(value)
	if type(value) == "table" and value.ToTable then
		return value:ToTable()
	end

	return value
end

local function zeroLike(v, typeName)
	if typeName == "Number" then
		return 0
	end
	if typeName == "Vector3" then
		return v - v
	end
	if typeName == "Color3" then
		return v - v
	end
	if typeName == "CFrame" then
		return Vector3.new(0, 0, 0)
	end -- track only position for velocity
	if typeName == "UDim2" then
		return UDim2.new(0, 0, 0, 0)
	end
	if typeName == "UDim" then
		return UDim.new(0, 0)
	end

	error("Unsupported type: " .. tostring(typeName))
end

local function numberStep(x, v, target, dampingRatio, freq, dt)
	local f = freq * 2 * pi
	local offset = x - target
	local decay = exp(-dampingRatio * f * dt)
	local p1, v1

	if dampingRatio == 1 then -- critically damped
		p1 = (offset * (1 + f * dt) + v * dt) * decay + target
		v1 = (v * (1 - f * dt) - offset * (f * f * dt)) * decay
	elseif dampingRatio < 1 then -- underdamped
		local c = sqrt(1 - dampingRatio * dampingRatio)
		local i = cos(f * c * dt)
		local j = sin(f * c * dt)
		local z = c > EPS and j / c or dt
		local y = f * c > EPS and j / (f * c) or dt
		p1 = (offset * (i + dampingRatio * z) + v * y) * decay + target
		v1 = (v * (i - z * dampingRatio) - offset * (z * f)) * decay
	else -- overdamped
		local c = sqrt(dampingRatio * dampingRatio - 1)
		local r1 = -f * (dampingRatio + c)
		local r2 = -f * (dampingRatio - c)
		local co2 = (v - offset * r1) / (2 * f * c)
		local co1 = offset - co2
		local e1 = co1 * exp(r1 * dt)
		local e2 = co2 * exp(r2 * dt)
		p1 = e1 + e2 + target
		v1 = e1 * r1 + e2 * r2
	end
	return p1, v1
end

-- Datatypes table
local Datatypes = {}

Datatypes.Number = {
	step = numberStep,
}

Datatypes.Vector3 = {
	step = function(x, v, target, d, f, dt)
		local nx, vx = numberStep(x.X, v.X, target.X, d, f, dt)
		local ny, vy = numberStep(x.Y, v.Y, target.Y, d, f, dt)
		local nz, vz = numberStep(x.Z, v.Z, target.Z, d, f, dt)
		return Vector3.new(nx, ny, nz), Vector3.new(vx, vy, vz)
	end,
}

Datatypes.Color3 = {
	step = function(x, v, target, d, f, dt)
		local nr, vr = numberStep(x.R, v.R, target.R, d, f, dt)
		local ng, vg = numberStep(x.G, v.G, target.G, d, f, dt)
		local nb, vb = numberStep(x.B, v.B, target.B, d, f, dt)
		return Color3.new(nr, ng, nb), Color3.new(vr, vg, vb)
	end,
}

Datatypes.CFrame = {
	step = function(x, v, target, d, f, dt)
		local pos, vel = Datatypes.Vector3.step(x.Position, v, target.Position, d, f, dt)
		local cf = CFrame.new(pos) * (x - x.Position) -- preserve rotation
		return cf, vel
	end,
}

Datatypes.UDim = {
	step = function(x, v, target, d, f, dt)
		local scale, scaleV = numberStep(x.Scale, v.Scale, target.Scale, d, f, dt)
		local offset, offsetV = numberStep(x.Offset, v.Offset, target.Offset, d, f, dt)
		return UDim.new(scale, offset), UDim.new(scaleV, offsetV)
	end,
}

Datatypes.Color4 = {
	step = function(c, v, target, d, f, dt)
		local r, vr = numberStep(c.R, v.R, target.R, d, f, dt)
		local g, vg = numberStep(c.G, v.G, target.G, d, f, dt)
		local b, vb = numberStep(c.B, v.B, target.B, d, f, dt)
		local a, va = numberStep(c.A, v.A, target.A, d, f, dt)
		return Color4.new(r, g, b, a), { R = vr, G = vg, B = vb, A = va }
	end,
}

Datatypes.UDim2 = {
	step = function(x, v, target, d, f, dt)
		local xVal, xVel = Datatypes.UDim.step(x.X, v.X, target.X, d, f, dt)
		local yVal, yVel = Datatypes.UDim.step(x.Y, v.Y, target.Y, d, f, dt)
		return UDim2.new(xVal.Scale, xVal.Offset, yVal.Scale, yVal.Offset), UDim2.new(
			xVel.Scale,
			xVel.Offset,
			yVel.Scale,
			yVel.Offset
		)
	end,
}

--[[
Datatypes.NumberRange = {
	step = function(x, v, target, d, f, dt)
		local minVal, minV = numberStep(x.Min, v.Min, target.Min, d, f, dt)
		local maxVal, maxV = numberStep(x.Max, v.Max, target.Max, d, f, dt)
		return NumberRange.new(minVal, maxVal), NumberRange.new(minV, maxV)
	end,
}

Datatypes.Rect = {
	step = function(x, v, target, d, f, dt)
		local minPos, minVel = Datatypes.Vector3.step(x.Min, v.Min, target.Min, d, f, dt)
		local maxPos, maxVel = Datatypes.Vector3.step(x.Max, v.Max, target.Max, d, f, dt)
		return Rect.new(minPos, maxPos), Rect.new(minVel, maxVel)
	end,
}
--]]

Datatypes.Vector2 = {
	step = function(x, v, target, d, f, dt)
		local nx, vx = numberStep(x.X, v.X, target.X, d, f, dt)
		local ny, vy = numberStep(x.Y, v.Y, target.Y, d, f, dt)
		return Vector2.new(nx, ny), Vector2.new(vx, vy)
	end,
}

--[[
Datatypes.Axes = {
	step = function(x, v, target, d, f, dt)
		local nx, vx = numberStep(x.X, v.X, target.X, d, f, dt)
		local ny, vy = numberStep(x.Y, v.Y, target.Y, d, f, dt)
		local nz, vz = numberStep(x.Z, v.Z, target.Z, d, f, dt)
		return Axes.new(nx ~= 0, ny ~= 0, nz ~= 0), Axes.new(vx ~= 0, vy ~= 0, vz ~= 0)
	end,
}
--]]

Datatypes.Ray = {
	step = function(x, v, target, d, f, dt)
		local origin, oVel = Datatypes.Vector3.step(x.Origin, v.Origin, target.Origin, d, f, dt)
		local dir, dirVel = Datatypes.Vector3.step(x.Direction, v.Direction, target.Direction, d, f, dt)
		return Ray.new(origin, dir), Ray.new(oVel, dirVel)
	end,
}

function Spring.new(damping, frequency, typeName, initialValue)
	typeName = typeName or "Number"
	assert(Datatypes[typeName], "Unsupported type: " .. tostring(typeName))
	local init = initialValue or 0
	return setmetatable({
		d = damping or 1,
		f = frequency or 6,
		value = init,
		velocity = zeroLike(init, typeName),
		target = init,
		running = false,
		typeName = typeName,
		type = Datatypes[typeName],
	}, Spring)
end

local activeTargets: { [Instance]: { [string]: typeof(Spring.new()) } } = {}

function Spring:Play()
	self.running = true
end
function Spring:Pause()
	self.running = false
end
function Spring:Stop()
	self.running = false
	self.velocity = zeroLike(self.value, self.typeName)
end

function Spring:set(value)
	self.target = value
end

function Spring:setValue(value)
	self.value = value
	self.target = value
	self.velocity = zeroLike(value, self.typeName)
end

function Spring:shove(force)
	self.velocity = self.type.add and self.type.add(self.velocity, force) or force
end

function Spring:step(dt)
	if not self.running then
		return self.value
	end
	self.value, self.velocity = self.type.step(self.value, self.velocity, self.target, self.d, self.f, dt)
	return self.value
end

function Spring:ToTable()
	return {
		type = "Spring",
		d = self.d,
		f = self.f,
		value = serializeValue(self.value),
		velocity = serializeValue(self.velocity),
		target = serializeValue(self.target),
		running = self.running,
		typeName = self.typeName,
	}
end

function Spring.FromTable(tbl)
	assert(tbl.type == "Spring")
	local spring = Spring.new(tbl.d, tbl.f, tbl.typeName, tbl.value)
	spring.velocity = tbl.velocity
	spring.target = tbl.target
	spring.running = tbl.running
	return spring
end

function Spring.target(object: Instance, damping: number, frequency: number, props: { [string]: any })
	for prop, targetValue in props do
		local cache = activeTargets[object]
		if not cache then
			cache = {}
			activeTargets[object] = cache
		end

		local spring = cache[prop]
		if not spring then
			local currentValue = (object :: any)[prop]
			local typeName = inferTypeName(targetValue) or inferTypeName(currentValue)
			assert(typeName and Datatypes[typeName], "Unsupported spring target type for property " .. tostring(prop))
			spring = Spring.new(damping, frequency, typeName, currentValue)
			spring:Play()
			cache[prop] = spring
		else
			spring.d = damping
			spring.f = frequency
		end

		spring:set(targetValue)
	end
end

function Spring.stepTargets(dt: number)
	for object, cache in activeTargets do
		if not object.Parent then
			activeTargets[object] = nil
			continue
		end
		for prop, spring in cache do
			local success, val = pcall(spring.step, spring, dt)
			if success then
				(object :: any)[prop] = val
			else
				cache[prop] = nil
			end
		end
	end
end

return Spring
