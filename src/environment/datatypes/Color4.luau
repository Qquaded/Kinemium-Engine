local Color4 = {}
Color4.__index = Color4

local function clamp(v)
	if v < 0 then
		return 0
	end
	if v > 1 then
		return 1
	end
	return v
end

local EPS = 1e-5

function Color4.__eq(a, b)
	return math.abs(a.R - b.R) < EPS
		and math.abs(a.G - b.G) < EPS
		and math.abs(a.B - b.B) < EPS
		and math.abs(a.A - b.A) < EPS
end

function Color4:Clamp()
	return Color4.new(clamp(self.R), clamp(self.G), clamp(self.B), clamp(self.A))
end

function Color4:PremultiplyAlpha()
	return Color4.new(self.R * self.A, self.G * self.A, self.B * self.A, self.A)
end

function Color4:BlendOver(bg)
	local a = self.A + bg.A * (1 - self.A)
	if a <= 0 then
		return Color4.new(0, 0, 0, 0)
	end

	return Color4.new(
		(self.R * self.A + bg.R * bg.A * (1 - self.A)) / a,
		(self.G * self.A + bg.G * bg.A * (1 - self.A)) / a,
		(self.B * self.A + bg.B * bg.A * (1 - self.A)) / a,
		a
	)
end

function Color4:Luminance()
	return self.R * 0.2126 + self.G * 0.7152 + self.B * 0.0722
end

function Color4:Multiply(other)
	return Color4.new(self.R * other.R, self.G * other.G, self.B * other.B, self.A * other.A)
end

function Color4:ToRaylib()
	local r, g, b, a = self:ToRGBA()
	return { r, g, b, a }
end

function Color4.new(r, g, b, a)
	return setmetatable({
		R = clamp(r or 0),
		G = clamp(g or 0),
		B = clamp(b or 0),
		A = clamp(a or 1),
	}, Color4)
end

function Color4.fromRGB(r, g, b, a)
	return Color4.new(r / 255, g / 255, b / 255, a and a / 255 or 1)
end

function Color4.fromHSV(h, s, v, a)
	h = h % 1
	s = math.max(0, math.min(1, s))
	v = math.max(0, math.min(1, v))
	a = clamp(a or 1)

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

	return Color4.new(r, g, b, a)
end

function Color4:Lerp(other, alpha)
	return Color4.new(
		self.R + (other.R - self.R) * alpha,
		self.G + (other.G - self.G) * alpha,
		self.B + (other.B - self.B) * alpha,
		self.A + (other.A - self.A) * alpha
	)
end

function Color4:ToRGBA()
	return math.floor(self.R * 255 + 0.5),
		math.floor(self.G * 255 + 0.5),
		math.floor(self.B * 255 + 0.5),
		math.floor(self.A * 255 + 0.5)
end

function Color4:__tostring()
	return string.format("Color4(%g, %g, %g, %g)", self.R, self.G, self.B, self.A)
end

function Color4.__add(a, b)
	return Color4.new(a.R + b.R, a.G + b.G, a.B + b.B, a.A + b.A)
end

function Color4.__sub(a, b)
	return Color4.new(a.R - b.R, a.G - b.G, a.B - b.B, a.A - b.A)
end

function Color4.__mul(a, b)
	if type(a) == "number" then
		return Color4.new(a * b.R, a * b.G, a * b.B, a * b.A)
	elseif type(b) == "number" then
		return Color4.new(a.R * b, a.G * b, a.B * b, a.A * b)
	end
	error("Color4 * Color4 is not supported (scalar only)")
end

function Color4.__div(a, b)
	if type(b) ~= "number" then
		error("Color4 division only supports scalar division")
	end
	return Color4.new(a.R / b, a.G / b, a.B / b, a.A / b)
end

function Color4.__unm(a)
	return Color4.new(-a.R, -a.G, -a.B, -a.A)
end

function Color4:ToTable()
	return {
		type = "Color4",
		R = self.R,
		G = self.G,
		B = self.B,
		A = self.A,
	}
end

function Color4.FromTable(tbl)
	assert(tbl.type == "Color4")
	return Color4.new(tbl.R, tbl.G, tbl.B, tbl.A)
end

return Color4
