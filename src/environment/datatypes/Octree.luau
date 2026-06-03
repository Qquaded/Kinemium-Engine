--!strict
--!optimize 2

local Vector3 = require("@Vector3")

export type AABB = {
	id: number,
	position: Vector3,
	size: Vector3,
	data: any?,
}

export type SerializedNode = {
	c: { number },
	s: number,
	d: number,
	o: {
		{
			id: number,
			p: { number },
			z: { number },
		}
	}?,
	ch: { SerializedNode }?,
}

export type SerializedTree = {
	c: { number },
	s: number,
	cap: number,
	max: number,
	loose: number,
	root: SerializedNode,
}

local Octree = {}
Octree.__index = Octree

local function vecToT(v: Vector3): { number }
	return { v.X, v.Y, v.Z }
end

local function tToVec(t: { number }): Vector3
	return Vector3.new(t[1], t[2], t[3])
end

local function intersects(aPos: Vector3, aSize: Vector3, bPos: Vector3, bSize: Vector3): boolean
	return math.abs(aPos.X - bPos.X) <= (aSize.X + bSize.X)
		and math.abs(aPos.Y - bPos.Y) <= (aSize.Y + bSize.Y)
		and math.abs(aPos.Z - bPos.Z) <= (aSize.Z + bSize.Z)
end

local function containsLoose(nodeCenter: Vector3, nodeHalf: number, loose: number, pos: Vector3, size: Vector3): boolean
	local effective = nodeHalf * loose
	return math.abs(pos.X - nodeCenter.X) + size.X <= effective
		and math.abs(pos.Y - nodeCenter.Y) + size.Y <= effective
		and math.abs(pos.Z - nodeCenter.Z) + size.Z <= effective
end

type Node = {
	center: Vector3,
	size: number,
	depth: number,
	objects: { AABB },
	children: { Node }?,
}

local function createNode(center: Vector3, size: number, depth: number): Node
	return {
		center = center,
		size = size,
		depth = depth,
		objects = {},
		children = nil,
	}
end

function Octree.new(center: Vector3, size: number, capacity: number?, maxDepth: number?, looseFactor: number?)
	local self = setmetatable({}, Octree)

	self.center = center
	self.size = size
	self.capacity = capacity or 16
	self.maxDepth = maxDepth or 8
	self.loose = looseFactor or 1.5

	self.root = createNode(center, size, 0)
	self.objectMap = {} :: { [number]: Node }

	return self
end

function Octree:_subdivide(node: Node)
	local half = node.size / 2
	local quarter = half / 2

	node.children = {}

	for x = -1, 1, 2 do
		for y = -1, 1, 2 do
			for z = -1, 1, 2 do
				table.insert(
					node.children,
					createNode(node.center + Vector3.new(x * quarter, y * quarter, z * quarter), half, node.depth + 1)
				)
			end
		end
	end
end

function Octree:_insert(node: Node, obj: AABB): boolean
	if not containsLoose(node.center, node.size, self.loose, obj.position, obj.size) then
		return false
	end

	if (#node.objects < self.capacity) or (node.depth >= self.maxDepth) then
		table.insert(node.objects, obj)
		self.objectMap[obj.id] = node
		return true
	end

	if not node.children then
		self:_subdivide(node)
	end

	for _, child in node.children do
		if self:_insert(child, obj) then
			return true
		end
	end

	table.insert(node.objects, obj)
	self.objectMap[obj.id] = node
	return true
end

function Octree:Insert(obj: AABB): boolean
	return self:_insert(self.root, obj)
end

function Octree:Remove(id: number)
	local node = self.objectMap[id]
	if not node then
		return
	end

	for i, obj in ipairs(node.objects) do
		if obj.id == id then
			table.remove(node.objects, i)
			break
		end
	end

	self.objectMap[id] = nil
end

function Octree:Update(obj: AABB)
	self:Remove(obj.id)
	self:Insert(obj)
end

function Octree:_query(node: Node, center: Vector3, size: Vector3, result: { AABB })
	if not intersects(node.center, Vector3.new(node.size, node.size, node.size), center, size) then
		return
	end

	for _, obj in node.objects do
		if intersects(obj.position, obj.size, center, size) then
			table.insert(result, obj)
		end
	end

	if node.children then
		for _, child in node.children do
			self:_query(child, center, size, result)
		end
	end
end

function Octree:QueryAABB(center: Vector3, size: Vector3): { AABB }
	local result = {}
	self:_query(self.root, center, size, result)
	return result
end

function Octree:Clear()
	self.root = createNode(self.center, self.size, 0)
	table.clear(self.objectMap)
end

local function serializeNode(node: Node): SerializedNode
	local sn: SerializedNode = {
		c = vecToT(node.center),
		s = node.size,
		d = node.depth,
	}

	if #node.objects > 0 then
		sn.o = {}
		for _, obj in node.objects do
			table.insert(sn.o, {
				id = obj.id,
				p = vecToT(obj.position),
				z = vecToT(obj.size),
			})
		end
	end

	if node.children then
		sn.ch = {}
		for _, child in node.children do
			table.insert(sn.ch, serializeNode(child))
		end
	end

	return sn
end

function Octree:ToTable(): SerializedTree
	return {
		c = vecToT(self.center),
		s = self.size,
		cap = self.capacity,
		max = self.maxDepth,
		loose = self.loose,
		root = serializeNode(self.root),
	}
end

local function deserializeNode(sn: SerializedNode): Node
	local node = createNode(tToVec(sn.c), sn.s, sn.d)

	if sn.o then
		for _, obj in sn.o do
			table.insert(node.objects, {
				id = obj.id,
				position = tToVec(obj.p),
				size = tToVec(obj.z),
			})
		end
	end

	if sn.ch then
		node.children = {}
		for _, child in sn.ch do
			table.insert(node.children, deserializeNode(child))
		end
	end

	return node
end

function Octree.FromTable(tbl: SerializedTree)
	local tree = Octree.new(tToVec(tbl.c), tbl.s, tbl.cap, tbl.max, tbl.loose)

	tree.root = deserializeNode(tbl.root)

	local function rebuild(node: Node)
		for _, obj in node.objects do
			tree.objectMap[obj.id] = node
		end
		if node.children then
			for _, child in node.children do
				rebuild(child)
			end
		end
	end

	rebuild(tree.root)

	return tree
end

return Octree
