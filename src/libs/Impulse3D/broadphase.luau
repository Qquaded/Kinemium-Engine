-- Impulse3D Broadphase — Uniform Grid Spatial Hash
-- devcell
--
-- Usage per frame:
--   broadphase:clear()
--   for id, body in pairs(pool) do broadphase:insert(id, body.position, body.size or Vector3Double.new(body.radius*2, ...)) end
--   local candidates = broadphase:queryPairs()   -- returns array of {a, b} pairs (a < b guaranteed)

local Broadphase = {}
Broadphase.__index = Broadphase

local utility = require("./utility")
local Vector3Double = utility.Vector3Double

-- Constructor

function Broadphase.new(cellSize: number?)
	local self = setmetatable({}, Broadphase)
	self.cellSize = cellSize or 4 -- world-units per cell; tune for your scene
	self._cells = {} -- [cellKey] = { idA, idB, … }
	self._bodyToCells = {} -- [bodyId] = { cellKey, … }
	return self
end

-- Helpers

local function cellKey(cx, cy, cz)
	-- Cantor-style hash; keeps keys unique for typical world coords
	return cx * 1000003 + cy * 1009 + cz
end

-- API

function Broadphase:clear()
	table.clear(self._cells)
	table.clear(self._bodyToCells)
end

-- Insert body into all overlapping cells
function Broadphase:insert(id: number, pos, size)
	local cs = self.cellSize
	local hx = size.X * 0.5
	local hy = size.Y * 0.5
	local hz = size.Z * 0.5

	local minCX = math.floor((pos.X - hx) / cs)
	local maxCX = math.floor((pos.X + hx) / cs)
	local minCY = math.floor((pos.Y - hy) / cs)
	local maxCY = math.floor((pos.Y + hy) / cs)
	local minCZ = math.floor((pos.Z - hz) / cs)
	local maxCZ = math.floor((pos.Z + hz) / cs)

	local myCells = {}

	for cx = minCX, maxCX do
		for cy = minCY, maxCY do
			for cz = minCZ, maxCZ do
				local key = cellKey(cx, cy, cz)
				local cell = self._cells[key]
				if not cell then
					cell = {}
					self._cells[key] = cell
				end
				cell[#cell + 1] = id
				myCells[#myCells + 1] = key
			end
		end
	end

	self._bodyToCells[id] = myCells
end

-- Returns a deduplicated array of candidate pair tables { a, b } where a < b
function Broadphase:queryPairs(): { { number } }
	local seen = {}
	local pairs_out = {}

	for _, cell in pairs(self._cells) do
		local n = #cell
		for i = 1, n - 1 do
			for j = i + 1, n do
				local a, b = cell[i], cell[j]
				if a > b then
					a, b = b, a
				end -- canonical order
				local key = a * 1000000007 + b
				if not seen[key] then
					seen[key] = true
					pairs_out[#pairs_out + 1] = { a, b }
				end
			end
		end
	end

	return pairs_out
end

-- Query candidate neighbours for a single body (returns list of other IDs)
function Broadphase:queryNeighbours(id: number): { number }
	local myCells = self._bodyToCells[id]
	if not myCells then
		return {}
	end

	local seen = {}
	local result = {}

	for _, key in ipairs(myCells) do
		local cell = self._cells[key]
		if cell then
			for _, otherId in ipairs(cell) do
				if otherId ~= id and not seen[otherId] then
					seen[otherId] = true
					result[#result + 1] = otherId
				end
			end
		end
	end

	return result
end

return Broadphase
