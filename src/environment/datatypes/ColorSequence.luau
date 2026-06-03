local Color3 = require("@Color3")
local ColorSequenceKeypoint = require("@ColorSequenceKeypoint")

local ColorSequence = { __type = "ColorSequence" }
ColorSequence.__index = ColorSequence

function ColorSequence.new(keypoints)
	assert(type(keypoints) == "table", "Keypoints must be a table of ColorSequenceKeypoint")

	local sorted = {}
	for _, kp in ipairs(keypoints) do
		assert(getmetatable(kp) == ColorSequenceKeypoint, "All items must be ColorSequenceKeypoint")
		table.insert(sorted, kp)
	end

	table.sort(sorted, function(a, b)
		return a.Position < b.Position
	end)

	return setmetatable({
		Keypoints = sorted,
	}, ColorSequence)
end

function ColorSequence:Evaluate(position)
	assert(type(position) == "number" and position >= 0 and position <= 1, "Position must be between 0 and 1")

	local keypoints = self.Keypoints
	if #keypoints == 0 then
		return Color3.new(1, 1, 1)
	elseif #keypoints == 1 then
		return keypoints[1].Color
	end

	local prev, next = keypoints[1], keypoints[#keypoints]
	for i = 1, #keypoints do
		if keypoints[i].Position >= position then
			next = keypoints[i]
			prev = keypoints[math.max(i - 1, 1)]
			break
		end
	end

	if prev.Position == next.Position then
		return prev.Color
	end

	local alpha = (position - prev.Position) / (next.Position - prev.Position)
	local r = prev.Color.R + (next.Color.R - prev.Color.R) * alpha
	local g = prev.Color.G + (next.Color.G - prev.Color.G) * alpha
	local b = prev.Color.B + (next.Color.B - prev.Color.B) * alpha
	return Color3.new(r, g, b)
end

function ColorSequence:__tostring()
	local str = "ColorSequence.new({"
	for i, kp in ipairs(self.Keypoints) do
		str = str .. tostring(kp)
		if i < #self.Keypoints then
			str = str .. ", "
		end
	end
	str = str .. "})"
	return str
end

function ColorSequence:ToTable()
	local keypoints = {}
	for _, kp in ipairs(self.Keypoints) do
		table.insert(keypoints, kp:ToTable())
	end
	return {
		type = "ColorSequence",
		Keypoints = keypoints,
	}
end

function ColorSequence.FromTable(tbl)
	assert(tbl.type == "ColorSequence")
	local keypoints = {}
	for _, kp in ipairs(tbl.Keypoints) do
		table.insert(keypoints, ColorSequenceKeypoint.FromTable(kp))
	end
	return ColorSequence.new(keypoints)
end

return ColorSequence
