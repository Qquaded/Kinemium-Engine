local NumberSequence = { __type = "NumberSequence" }
NumberSequence.__index = NumberSequence

local NumberSequenceKeypoint = require("@NumberSequenceKeypoint")

function NumberSequence.new(...)
	local args = { ... }

	-- allow
	-- NumberSequence.new(0.5)  --> constant
	-- NumberSequence.new({kp1, kp2, ...})
	-- NumberSequence.new(kp1, kp2, kp3)
	local keypoints

	if #args == 1 and type(args[1]) == "number" then
		-- constant value
		local v = args[1]
		keypoints = {
			NumberSequenceKeypoint.new(0, v),
			NumberSequenceKeypoint.new(1, v),
		}
	elseif #args == 1 and type(args[1]) == "table" and args[1][1] then
		keypoints = args[1]
	else
		keypoints = args
	end

	table.sort(keypoints, function(a, b)
		return a.Time < b.Time
	end)

	return setmetatable({
		Keypoints = keypoints,
	}, NumberSequence)
end

-- evaluates at t [0–1]
function NumberSequence:Evaluate(t)
	local kps = self.Keypoints

	if t <= kps[1].Time then
		return kps[1].Value
	end
	if t >= kps[#kps].Time then
		return kps[#kps].Value
	end

	for i = 1, #kps - 1 do
		local a = kps[i]
		local b = kps[i + 1]

		if t >= a.Time and t <= b.Time then
			local alpha = (t - a.Time) / (b.Time - a.Time)
			return a.Value + (b.Value - a.Value) * alpha
		end
	end
end

function NumberSequence:ToTable()
	local keypoints = {}
	if not self.Keypoints then
		return {}
	end
	for _, kp in ipairs(self.Keypoints) do
		table.insert(keypoints, kp:ToTable())
	end
	return {
		type = "NumberSequence",
		Keypoints = keypoints,
	}
end

function NumberSequence.FromTable(tbl)
	assert(tbl.type == "NumberSequence")
	local keypoints = {}
	for _, kp in ipairs(tbl.Keypoints) do
		table.insert(keypoints, NumberSequenceKeypoint.FromTable(kp))
	end
	return NumberSequence.new(keypoints)
end

return NumberSequence
