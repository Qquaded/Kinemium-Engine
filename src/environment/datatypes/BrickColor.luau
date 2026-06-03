local BrickColor = {}
BrickColor.__index = BrickColor

local function dist(a, b)
	local dx = a.R - b.R
	local dy = a.G - b.G
	local dz = a.B - b.B
	return dx * dx + dy * dy + dz * dz
end

local BrickColorMap = require("@BrickColorMap")

-- the train of colors
-- real

BrickColor.White = function()
	return BrickColorMap.White.Color
end

BrickColor.Gray = function()
	return BrickColorMap.Grey.Color
end

BrickColor.DarkGray = function()
	return BrickColorMap["Dark grey"].Color
end

BrickColor.Black = function()
	return BrickColorMap.Black.Color
end

BrickColor.Red = function()
	return BrickColorMap["Bright red"].Color
end

BrickColor.Yellow = function()
	return BrickColorMap["Cool yellow"].Color
end

BrickColor.Green = function()
	return BrickColorMap["Bright green"].Color
end

BrickColor.Blue = function()
	return BrickColorMap.Lapis.Color
end

function BrickColor.Random()
	local keys = {}
	for name in pairs(BrickColorMap) do
		table.insert(keys, name)
	end
	local randomName = keys[math.random(1, #keys)]
	return BrickColor.new(randomName)
end

function BrickColor.new(val)
	if type(val) == "string" then
		local data = BrickColorMap[val]
		if not data then
			error("BrickColor '" .. tostring(val) .. "' does not exist")
		end

		return setmetatable({
			Name = val,
			Number = data.id,
			Color = data.Color,
		}, BrickColor)
	elseif type(val) == "table" and val.R and val.G and val.B then
		return BrickColor.fromColor3(val)
	else
		error("Invalid argument to BrickColor.new")
	end
end

function BrickColor.palette(id)
	for name, data in pairs(BrickColorMap) do
		if data.id == id then
			return BrickColor.new(name)
		end
	end
	error("BrickColor id '" .. id .. "' does not exist")
end

function BrickColor.fromColor3(c3)
	local best
	local bestDist = math.huge

	for name, data in pairs(BrickColorMap) do
		local d = dist(c3, data.Color)
		if d < bestDist then
			bestDist = d
			best = name
		end
	end

	return BrickColor.new(best)
end

function BrickColor:ToTable()
	return {
		type = "BrickColor",
		Name = self.Name,
		Number = self.Number,
		Color = self.Color:ToTable(),
	}
end

function BrickColor.FromTable(tbl)
	assert(tbl.type == "BrickColor")
	return BrickColor.new(tbl.Name)
end

return BrickColor
