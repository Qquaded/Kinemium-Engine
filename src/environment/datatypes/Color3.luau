local Color3 = { __type = "Color3" }
Color3.__index = Color3

local function c3tr(c, transparency)
	local r, g, b = c:ToRGB()
	return {
		r = r,
		g = g,
		b = b,
		a = math.floor(255 * (1 - transparency)),
	}
end

local function srgbToLinearChannel(c)
	if c <= 0.04045 then
		return c / 12.92
	else
		return ((c + 0.055) / 1.055) ^ 2.4
	end
end

local function linearToSrgbChannel(c)
	if c <= 0.0031308 then
		return 12.92 * c
	else
		return 1.055 * (c ^ (1 / 2.4)) - 0.055
	end
end

local function clamp(v)
	if v < 0 then
		return 0
	end
	if v > 1 then
		return 1
	end
	return v
end

function Color3.new(r, g, b)
	r = r or 0
	g = g or 0
	b = b or 0
	return setmetatable({ R = r, G = g, B = b, __type = "Color3" }, Color3)
end

function Color3:ToHSV()
	local r, g, b = self.R, self.G, self.B
	local max = math.max(r, g, b)
	local min = math.min(r, g, b)
	local delta = max - min

	local h, s, v

	-- Value
	v = max

	-- Saturation
	if max == 0 then
		s = 0
	else
		s = delta / max
	end

	-- Hue
	if delta == 0 then
		h = 0
	else
		if max == r then
			h = ((g - b) / delta) % 6
		elseif max == g then
			h = ((b - r) / delta) + 2
		else
			h = ((r - g) / delta) + 4
		end
		h = h / 6
	end

	if h < 0 then
		h = h + 1
	end

	return h, s, v
end

function Color3.fromRGB(r, g, b)
	return Color3.new(r / 255, g / 255, b / 255)
end

function Color3.fromHSV(h, s, v)
	h = h % 1
	s = math.max(0, math.min(1, s))
	v = math.max(0, math.min(1, v))

	local i = math.floor(h * 6)
	local f = h * 6 - i
	local p = v * (1 - s)
	local q = v * (1 - f * s)
	local t = v * (1 - (1 - f) * s)

	local r, g, b
	i = i % 6
	if i == 0 then
		r, g, b = v, t, p
	elseif i == 1 then
		r, g, b = q, v, p
	elseif i == 2 then
		r, g, b = p, v, t
	elseif i == 3 then
		r, g, b = p, q, v
	elseif i == 4 then
		r, g, b = t, p, v
	elseif i == 5 then
		r, g, b = v, p, q
	end

	return Color3.new(r, g, b)
end

function Color3:ToRGB()
	if self.R == nil or self.G == nil or self.B == nil then
		print(
			("Color3:ToRGB called on incomplete Color3 (R=%s, G=%s, B=%s)"):format(
				tostring(self.R),
				tostring(self.G),
				tostring(self.B)
			),
			2
		)
		return 0, 0, 0
	end
	return math.floor(self.R * 255 + 0.5), math.floor(self.G * 255 + 0.5), math.floor(self.B * 255 + 0.5)
end

function Color3:Lerp(other, alpha)
	return Color3.new(
		self.R + (other.R - self.R) * alpha,
		self.G + (other.G - self.G) * alpha,
		self.B + (other.B - self.B) * alpha
	)
end

function Color3:lerp(other, alpha)
	return Color3.new(
		self.R + (other.R - self.R) * alpha,
		self.G + (other.G - self.G) * alpha,
		self.B + (other.B - self.B) * alpha
	)
end

function Color3:__tostring()
	return string.format("Color3(%g, %g, %g)", self.R, self.G, self.B)
end

function Color3.__add(a, b)
	return Color3.new(a.R + b.R, a.G + b.G, a.B + b.B)
end

function Color3.__sub(a, b)
	return Color3.new(a.R - b.R, a.G - b.G, a.B - b.B)
end

function Color3.__mul(a, b)
	if type(a) == "number" then
		if type(b) ~= "table" or b.R == nil or b.G == nil or b.B == nil then
			error(("Color3.__mul: invalid Color3 operand (b): %s"):format(tostring(b)), 2)
		end
		return Color3.new(a * b.R, a * b.G, a * b.B)
	elseif type(b) == "number" then
		if type(a) ~= "table" or a.R == nil or a.G == nil or a.B == nil then
			error(("Color3.__mul: invalid Color3 operand (a): %s"):format(tostring(a)), 2)
		end
		return Color3.new(a.R * b, a.G * b, a.B * b)
	end
	error("Color3 * Color3 is not supported (scalar only)")
end

function Color3.__div(a, b)
	if type(b) ~= "number" then
		error("Color3 division only supports scalar division")
	end
	return Color3.new(a.R / b, a.G / b, a.B / b)
end

function Color3.__eq(a, b)
	return a.R == b.R and a.G == b.G and a.B == b.B
end

function Color3:Dot(other)
	return self.R * other.R + self.G * other.G + self.B * other.B
end

function Color3:Magnitude()
	return math.sqrt(self.R * self.R + self.G * self.G + self.B * self.B)
end

function Color3:Unit()
	local m = self:Magnitude()
	if m == 0 then
		return Color3.new(0, 0, 0)
	end
	return self / m
end

function Color3:Clamp()
	return Color3.new(clamp(self.R), clamp(self.G), clamp(self.B))
end

function Color3:Invert()
	return Color3.new(1 - self.R, 1 - self.G, 1 - self.B)
end

function Color3.fromHex(hex)
	hex = hex:gsub("#", "")
	assert(#hex == 6, "Hex must be 6 characters")

	local r = tonumber(hex:sub(1, 2), 16)
	local g = tonumber(hex:sub(3, 4), 16)
	local b = tonumber(hex:sub(5, 6), 16)

	return Color3.fromRGB(r, g, b)
end

function Color3:ToHex()
	local r, g, b = self:ToRGB()
	return string.format("#%02X%02X%02X", r, g, b)
end

function Color3:ToGrayscale()
	local l = 0.299 * self.R + 0.587 * self.G + 0.114 * self.B
	return Color3.new(l, l, l)
end

function Color3:AdjustBrightness(amount)
	return Color3.new(self.R + amount, self.G + amount, self.B + amount)
end

function Color3:AdjustContrast(amount)
	-- amount: 0 = no change, >0 increases contrast
	return Color3.new(
		(self.R - 0.5) * (1 + amount) + 0.5,
		(self.G - 0.5) * (1 + amount) + 0.5,
		(self.B - 0.5) * (1 + amount) + 0.5
	)
end

function Color3:ToLinear()
	return Color3.new(srgbToLinearChannel(self.R), srgbToLinearChannel(self.G), srgbToLinearChannel(self.B))
end

function Color3.__unm(a)
	return Color3.new(-a.R, -a.G, -a.B)
end

function Color3.fromColor4(color4)
	return Color3.new(color4.R * color4.A, color4.G * color4.A, color4.B * color4.A)
end

function Color3:ToTable()
	return {
		type = "Color3",
		R = self.R,
		G = self.G,
		B = self.B,
	}
end

function Color3:Random()
	return Color3.new(math.random(), math.random(), math.random())
end

function Color3:ToSRGB()
	return Color3.new(linearToSrgbChannel(self.R), linearToSrgbChannel(self.G), linearToSrgbChannel(self.B))
end

function Color3:ToRaylib(transparency)
	return c3tr(self, transparency or 0)
end

function Color3.FromTable(tbl)
	assert(tbl.type == "Color3")
	return Color3.new(tbl.R, tbl.G, tbl.B)
end

return Color3
