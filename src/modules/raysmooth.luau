-- Smooth.lua

local Smooth = {}
local active = {}

function Smooth:Get(key)
	local d = active[key]
	return d and d.current or nil
end

function Smooth:To(key, target, speed)
	local d = active[key]
	if not d then
		active[key] = {
			current = target, -- or start at 1 if you want fade-in
			target = target,
			speed = speed or 0.05,
		}
		return
	end

	d.target = target
	d.speed = speed or d.speed
end

function Smooth.Step()
	for key, d in pairs(active) do
		local c = d.current
		local t = d.target
		local s = d.speed

		if math.abs(c - t) < 0.001 then
			d.current = t
		else
			d.current = c + (t - c) * s
		end
	end
end

return Smooth
