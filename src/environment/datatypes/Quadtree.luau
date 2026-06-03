local Quadtree = {}
Quadtree.__index = Quadtree

function Quadtree.new(x, y, w, h, capacity, maxDepth)
	return setmetatable({
		x = x,
		y = y,
		w = w,
		h = h,

		capacity = capacity or 8,
		maxDepth = maxDepth or 6,

		depth = 0,
		objects = {},
		count = 0,

		children = nil,
	}, Quadtree)
end

local function intersects(ax, ay, aw, ah, bx, by, bw, bh)
	return not (bx > ax + aw or bx + bw < ax or by > ay + ah or by + bh < ay)
end

function Quadtree:subdivide()
	local hw = self.w * 0.5
	local hh = self.h * 0.5
	local x = self.x
	local y = self.y
	local d = self.depth + 1

	self.children = {
		setmetatable(
			{ x = x, y = y, w = hw, h = hh, depth = d, capacity = self.capacity, maxDepth = self.maxDepth, objects = {}, count = 0 },
			Quadtree
		),
		setmetatable(
			{ x = x + hw, y = y, w = hw, h = hh, depth = d, capacity = self.capacity, maxDepth = self.maxDepth, objects = {}, count = 0 },
			Quadtree
		),
		setmetatable(
			{ x = x, y = y + hh, w = hw, h = hh, depth = d, capacity = self.capacity, maxDepth = self.maxDepth, objects = {}, count = 0 },
			Quadtree
		),
		setmetatable(
			{ x = x + hw, y = y + hh, w = hw, h = hh, depth = d, capacity = self.capacity, maxDepth = self.maxDepth, objects = {}, count = 0 },
			Quadtree
		),
	}
end

function Quadtree:insert(obj)
	local x, y, w, h = obj.x, obj.y, obj.w, obj.h

	if not intersects(self.x, self.y, self.w, self.h, x, y, w, h) then
		return false
	end

	if self.children then
		for i = 1, 4 do
			if self.children[i]:insert(obj) then
				return true
			end
		end
	end

	self.count += 1
	self.objects[self.count] = obj

	if self.count > self.capacity and self.depth < self.maxDepth then
		if not self.children then
			self:subdivide()
		end

		local i = 1
		while i <= self.count do
			local o = self.objects[i]
			local moved = false

			for c = 1, 4 do
				if self.children[c]:insert(o) then
					self.objects[i] = self.objects[self.count]
					self.objects[self.count] = nil
					self.count -= 1
					moved = true
					break
				end
			end

			if not moved then
				i += 1
			end
		end
	end

	return true
end

function Quadtree:query(x, y, w, h, out)
	out = out or {}

	if not intersects(self.x, self.y, self.w, self.h, x, y, w, h) then
		return out
	end

	for i = 1, self.count do
		local o = self.objects[i]
		if intersects(o.x, o.y, o.w, o.h, x, y, w, h) then
			out[#out + 1] = o
		end
	end

	if self.children then
		for i = 1, 4 do
			self.children[i]:query(x, y, w, h, out)
		end
	end

	return out
end

function Quadtree:clear()
	table.clear(self.objects)
	self.count = 0

	if self.children then
		for i = 1, 4 do
			self.children[i]:clear()
		end
	end

	self.children = nil
end

return Quadtree
