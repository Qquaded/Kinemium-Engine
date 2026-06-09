local Vector3 = require("@Vector3")
local Vector2 = require("@Vector2")

export type NavPolygon = {
	id: number,
	vertices: { Vector2 }, -- 2D vertices on XZ plane
	center: Vector2, -- Centroid of polygon
	neighbors: { number }, -- Adjacent polygon IDs
	flags: number, -- Walkable, jump, etc
	height: number, -- Y level of this polygon
}

export type NavMesh = {
	polygons: { [number]: NavPolygon },
	bounds: {
		min: Vector3,
		max: Vector3,
	},
	cellSize: number,
	cellHeight: number,
}

export type PathNode = {
	polygonId: number,
	g: number,
	h: number,
	f: number,
	parent: PathNode?,
}

export type PathResult = {
	success: boolean,
	path: { Vector3 },
	length: number,
}

export type RaycastResult = {
	hit: boolean,
	polygonId: number?,
	point: Vector3?,
	normal: Vector2?,
	t: number?,
}

local function pointInPolygon(p: Vector2, poly: NavPolygon): boolean
	local inside = false
	local n = #poly.vertices

	for i = 1, n do
		local j = (i % n) + 1
		local vi = poly.vertices[i]
		local vj = poly.vertices[j]

		if ((vi.Y > p.Y) ~= (vj.Y > p.Y)) and (p.X < (vj.X - vi.X) * (p.Y - vi.Y) / (vj.Y - vi.Y) + vi.X) then
			inside = not inside
		end
	end

	return inside
end

local function closestPointOnEdge(p: Vector2, poly: NavPolygon): Vector2
	local closest = poly.vertices[1]
	local minDist = math.huge
	local n = #poly.vertices

	for i = 1, n do
		local j = (i % n) + 1
		local vi = poly.vertices[i]
		local vj = poly.vertices[j]

		local edgeX = vj.X - vi.X
		local edgeY = vj.Y - vi.Y
		local edgeLenSq = edgeX * edgeX + edgeY * edgeY

		local pMinusViX = p.X - vi.X
		local pMinusViY = p.Y - vi.Y
		local dotProd = pMinusViX * edgeX + pMinusViY * edgeY
		local t = math.max(0, math.min(1, dotProd / edgeLenSq))
		local projX = vi.X + edgeX * t
		local projY = vi.Y + edgeY * t

		local distX = p.X - projX
		local distY = p.Y - projY
		local dist = math.sqrt(distX * distX + distY * distY)
		if dist < minDist then
			minDist = dist
			closest = Vector2.new(projX, projY)
		end
	end

	return closest
end

local function distanceToPolygon(p: Vector2, poly: NavPolygon): number
	if pointInPolygon(p, poly) then
		return 0
	end
	local closest = closestPointOnEdge(p, poly)
	return math.sqrt((p.X - closest.X) * (p.X - closest.X) + (p.Y - closest.Y) * (p.Y - closest.Y))
end

local NavMeshBuilder = {}
NavMeshBuilder.__index = NavMeshBuilder

function NavMeshBuilder.new()
	local self = setmetatable({}, NavMeshBuilder)
	self.polygons = {}
	self.nextId = 1
	return self
end

function NavMeshBuilder:AddPolygon(vertices: { Vector2 }, height: number, flags: number?): number
	local id = self.nextId
	self.nextId = self.nextId + 1

	local center = Vector2.new(0, 0)
	for _, v in ipairs(vertices) do
		center = center + v
	end
	center = center / #vertices

	local poly: NavPolygon = {
		id = id,
		vertices = vertices,
		center = center,
		neighbors = {},
		flags = flags or 1,
		height = height,
	}

	self.polygons[id] = poly
	return id
end

function NavMeshBuilder:ConnectPolygons(idA: number, idB: number)
	local polyA = self.polygons[idA]
	local polyB = self.polygons[idB]

	if not polyA or not polyB then
		return
	end

	local shared = false
	local tolerance = 0.01

	for _, va in ipairs(polyA.vertices) do
		for _, vb in ipairs(polyB.vertices) do
			if (va - vb):Magnitude() < tolerance then
				shared = true
				break
			end
		end
		if shared then
			break
		end
	end

	if shared and math.abs(polyA.height - polyB.height) < 0.5 then
		local hasB = false
		for _, n in ipairs(polyA.neighbors) do
			if n == idB then
				hasB = true
				break
			end
		end
		if not hasB then
			table.insert(polyA.neighbors, idB)
		end

		local hasA = false
		for _, n in ipairs(polyB.neighbors) do
			if n == idA then
				hasA = true
				break
			end
		end
		if not hasA then
			table.insert(polyB.neighbors, idA)
		end
	end
end

function NavMeshBuilder:AutoConnectNeighbors()
	for idA, polyA in pairs(self.polygons) do
		for idB, polyB in pairs(self.polygons) do
			if idA < idB then
				local dist = (polyA.center - polyB.center):Magnitude()
				local maxEdge = 0
				for _, v in ipairs(polyA.vertices) do
					for _, w in ipairs(polyB.vertices) do
						local d = (v - w):Magnitude()
						if d > maxEdge then
							maxEdge = d
						end
					end
				end

				if dist < maxEdge * 1.5 then
					self:ConnectPolygons(idA, idB)
				end
			end
		end
	end
end

function NavMeshBuilder:Build(cellSize: number?, cellHeight: number?): NavMesh
	local minX, minZ = math.huge, math.huge
	local maxX, maxZ = -math.huge, -math.huge
	local minY = math.huge
	local maxY = -math.huge

	for _, poly in pairs(self.polygons) do
		for _, v in ipairs(poly.vertices) do
			if v.X < minX then
				minX = v.X
			end
			if v.X > maxX then
				maxX = v.X
			end
			if v.Y < minZ then
				minZ = v.Y
			end
			if v.Y > maxZ then
				maxZ = v.Y
			end
		end
		if poly.height < minY then
			minY = poly.height
		end
		if poly.height > maxY then
			maxY = poly.height
		end
	end

	return {
		polygons = self.polygons,
		bounds = {
			min = Vector3.new(minX, minY, minZ),
			max = Vector3.new(maxX, maxY, maxZ),
		},
		cellSize = cellSize or 0.5,
		cellHeight = cellHeight or 2.0,
	}
end

local NavMeshQuery = {}
NavMeshQuery.__index = NavMeshQuery

function NavMeshQuery.new(mesh: NavMesh)
	local self = setmetatable({}, NavMeshQuery)
	self.mesh = mesh
	return self
end

function NavMeshQuery:FindPolygon(point: Vector2): number?
	for id, poly in pairs(self.mesh.polygons) do
		if pointInPolygon(point, poly) then
			return id
		end
	end
	return nil
end

function NavMeshQuery:FindNearestPolygon(point: Vector2): number?
	local nearestId = nil
	local nearestDist = math.huge

	for id, poly in pairs(self.mesh.polygons) do
		local dist = distanceToPolygon(point, poly)
		if dist < nearestDist then
			nearestDist = dist
			nearestId = id
		end
	end

	return nearestId
end

function NavMeshQuery:FindPolygonAtHeight(point: Vector2, height: number, tolerance: number?): number?
	tolerance = tolerance or 1.0
	local bestId = nil
	local bestHeightDiff = math.huge

	for id, poly in pairs(self.mesh.polygons) do
		if pointInPolygon(point, poly) then
			local heightDiff = math.abs(poly.height - height)
			if heightDiff < bestHeightDiff and heightDiff <= tolerance then
				bestHeightDiff = heightDiff
				bestId = id
			end
		end
	end

	return bestId
end

function NavMeshQuery:FindPath(startPos: Vector3, endPos: Vector3): PathResult
	local startPoint = Vector2.new(startPos.X, startPos.Z)
	local endPoint = Vector2.new(endPos.X, endPos.Z)

	local startPolyId = self:FindPolygonAtHeight(startPoint, startPos.Y)
	local endPolyId = self:FindPolygonAtHeight(endPoint, endPos.Y)

	if not startPolyId then
		startPolyId = self:FindNearestPolygon(startPoint)
	end
	if not endPolyId then
		endPolyId = self:FindNearestPolygon(endPoint)
	end

	if not startPolyId or not endPolyId then
		return { success = false, path = {}, length = 0 }
	end

	if startPolyId == endPolyId then
		local poly = self.mesh.polygons[startPolyId]
		return {
			success = true,
			path = { startPos, endPos },
			length = (startPoint - endPoint):Magnitude(),
		}
	end

	local openSet = {}
	local closedSet = {}
	local nodeMap = {}

	local function createNode(polygonId: number, g: number, h: number, parent: PathNode?): PathNode
		return {
			polygonId = polygonId,
			g = g,
			h = h,
			f = g + h,
			parent = parent,
		}
	end

	local function heuristic(a: number, b: number): number
		local polyA = self.mesh.polygons[a]
		local polyB = self.mesh.polygons[b]
		return (polyA.center - polyB.center):Magnitude()
	end

	local startNode = createNode(startPolyId, 0, heuristic(startPolyId, endPolyId), nil)
	openSet[1] = startNode
	nodeMap[startPolyId] = startNode

	while #openSet > 0 do
		local currentIdx = 1
		local currentNode = openSet[1]
		for i = 2, #openSet do
			if openSet[i].f < currentNode.f then
				currentNode = openSet[i]
				currentIdx = i
			end
		end

		if currentNode.polygonId == endPolyId then
			local path = {}
			local node: PathNode? = currentNode
			local totalLength = 0

			local prevPos = startPos
			while node do
				local poly = self.mesh.polygons[node.polygonId]
				local waypoint = Vector3.new(poly.center.X, poly.height, poly.center.Y)
				table.insert(path, waypoint)

				if node.parent then
					local parentPoly = self.mesh.polygons[node.parent.polygonId]
					totalLength = totalLength + (poly.center - parentPoly.center):Magnitude()
				end

				node = node.parent
			end

			table.insert(path, endPos)
			local endPoly = self.mesh.polygons[endPolyId]
			totalLength = totalLength + (endPoly.center - endPoint):Magnitude()

			return {
				success = true,
				path = path,
				length = totalLength,
			}
		end

		table.remove(openSet, currentIdx)
		closedSet[currentNode.polygonId] = true

		local currentPoly = self.mesh.polygons[currentNode.polygonId]
		for _, neighborId in ipairs(currentPoly.neighbors) do
			if not closedSet[neighborId] then
				local neighborPoly = self.mesh.polygons[neighborId]
				local heightPenalty = math.abs(currentPoly.height - neighborPoly.height) * 2.0
				local tentativeG = currentNode.g
					+ (currentPoly.center - neighborPoly.center):Magnitude()
					+ heightPenalty

				local existingNode = nodeMap[neighborId]
				if not existingNode or tentativeG < existingNode.g then
					local h = heuristic(neighborId, endPolyId)
					local newNode = createNode(neighborId, tentativeG, h, currentNode)
					nodeMap[neighborId] = newNode
					table.insert(openSet, newNode)
				end
			end
		end
	end

	return { success = false, path = {}, length = 0 }
end

function NavMeshQuery:Raycast(origin: Vector3, direction: Vector3, maxDistance: number): RaycastResult
	local origin2D = Vector2.new(origin.X, origin.Z)
	local dir2D = Vector2.new(direction.X, direction.Z):Unit()

	local closestHit = nil
	local closestT = maxDistance

	for id, poly in pairs(self.mesh.polygons) do
		local n = #poly.vertices
		for i = 1, n do
			local j = (i % n) + 1
			local v1 = poly.vertices[i]
			local v2 = poly.vertices[j]

			local edge = v2 - v1
			local edgeNormal = Vector2.new(-edge.Y, edge.X):Unit()

			local denom = dir2D * edgeNormal
			if math.abs(denom) > 0.0001 then
				local diff = v1 - origin2D
				local t = (diff * edgeNormal) / denom

				if t >= 0 and t < closestT then
					local intersection = origin2D + dir2D * t
					local edgeToPoint = intersection - v1
					local edgeProj = edgeToPoint * edge
					if edgeProj >= 0 and edgeProj <= edge:Magnitude() * edge:Magnitude() then
						closestHit = {
							polygonId = id,
							point = Vector3.new(intersection.X, poly.height, intersection.Y),
							normal = edgeNormal,
							t = t,
						}
						closestT = t
					end
				end
			end
		end
	end

	if closestHit then
		return {
			hit = true,
			polygonId = closestHit.polygonId,
			point = closestHit.point,
			normal = closestHit.normal,
			t = closestHit.t,
		}
	end

	return { hit = false }
end

function NavMeshQuery:GetRandomPoint(): Vector3?
	local polygonIds = {}
	for id, _ in pairs(self.mesh.polygons) do
		table.insert(polygonIds, id)
	end

	if #polygonIds == 0 then
		return nil
	end

	local randIndex = math.random(1, #polygonIds)
	local poly = self.mesh.polygons[polygonIds[randIndex]]

	local minX, maxX = math.huge, -math.huge
	local minY, maxY = math.huge, -math.huge

	for _, v in ipairs(poly.vertices) do
		if v.X < minX then
			minX = v.X
		end
		if v.X > maxX then
			maxX = v.X
		end
		if v.Y < minY then
			minY = v.Y
		end
		if v.Y > maxY then
			maxY = v.Y
		end
	end

	local maxAttempts = 10
	for _ = 1, maxAttempts do
		local x = minX + math.random() * (maxX - minX)
		local y = minY + math.random() * (maxY - minY)
		local testPoint = Vector2.new(x, y)

		if pointInPolygon(testPoint, poly) then
			return Vector3.new(x, poly.height, y)
		end
	end

	return Vector3.new(poly.center.X, poly.height, poly.center.Y)
end

function NavMeshQuery:GetRandomPointReachable(fromPos: Vector3): Vector3?
	local startPoint = Vector2.new(fromPos.X, fromPos.Z)
	local startPolyId = self:FindPolygonAtHeight(startPoint, fromPos.Y)

	if not startPolyId then
		startPolyId = self:FindNearestPolygon(startPoint)
	end

	if not startPolyId then
		return self:GetRandomPoint()
	end

	local reachable = {}
	local visited = {}
	local queue = { startPolyId }
	local head = 1
	visited[startPolyId] = true

	while head <= #queue do
		local current = queue[head]
		head += 1
		table.insert(reachable, current)

		local poly = self.mesh.polygons[current]
		for _, neighborId in ipairs(poly.neighbors) do
			if not visited[neighborId] then
				visited[neighborId] = true
				table.insert(queue, neighborId)
			end
		end
	end

	if #reachable == 0 then
		return nil
	end

	local poly = self.mesh.polygons[reachable[math.random(1, #reachable)]]
	return Vector3.new(poly.center.X, poly.height, poly.center.Y)
end

local NavMesh = {}
NavMesh.__index = NavMesh

function NavMesh.new()
	local self = setmetatable({}, NavMesh)
	self._builder = nil
	self._mesh = nil
	self._query = nil
	return self
end

function NavMesh:CreateFromWorkspace(workspace: Instance?, agentHeight: number?, agentRadius: number?)
	self._builder = NavMeshBuilder.new()

	if not workspace then
		local ok, ws = pcall(function()
			return game.Workspace
		end)
		if not ok or not ws then
			warn("NavMesh:CreateFromWorkspace - No workspace available")
			return self
		end
		workspace = ws
	end

	assert(workspace ~= nil, "Workspace is nil")

	local surfaces = {}

	local ok2, descendants = pcall(function()
		return workspace:GetDescendants()
	end)
	if not ok2 or not descendants then
		return self
	end

	for _, part in ipairs(descendants) do
		if part.BaseClass == "BasePart" and part.CanCollide and not part.Anchored == false then
			local size = part.Size
			local pos = part.Position

			if size.Y < size.X and size.Y < size.Z and size.Y < 2 then
				local y = pos.Y - size.Y / 2

				if not surfaces[y] then
					surfaces[y] = {}
				end
				table.insert(surfaces[y], {
					part = part,
					position = pos,
					size = size,
					bottomY = y,
				})
			end
		end
	end

	for y, surfs in pairs(surfaces) do
		for _, surf in ipairs(surfs) do
			local cf = surf.part.CFrame
			local halfX = surf.size.X / 2
			local halfZ = surf.size.Z / 2

			local localCorners = {
				Vector3.new(-halfX, 0, -halfZ),
				Vector3.new(halfX, 0, -halfZ),
				Vector3.new(halfX, 0, halfZ),
				Vector3.new(-halfX, 0, halfZ),
			}

			local worldCorners = {}
			for _, corner in ipairs(localCorners) do
				local worldPos = cf * corner
				table.insert(worldCorners, Vector2.new(worldPos.X, worldPos.Z))
			end

			self._builder:AddPolygon(worldCorners, y)
		end
	end

	self._builder:AutoConnectNeighbors()
	self._mesh = self._builder:Build()
	self._query = NavMeshQuery.new(self._mesh)

	return self
end

function NavMesh:CreateFromParts(parts: { Instance }, agentHeight: number?, agentRadius: number?)
	self._builder = NavMeshBuilder.new()

	local surfaces = {}

	for _, part in ipairs(parts) do
		if part.BaseClass == "BasePart" and part.CanCollide then
			local size = part.Size
			local pos = part.Position

			if size.Y < size.X and size.Y < size.Z and size.Y < 2 then
				local y = pos.Y - size.Y / 2

				if not surfaces[y] then
					surfaces[y] = {}
				end
				table.insert(surfaces[y], {
					part = part,
					position = pos,
					size = size,
				})
			end
		end
	end

	for y, surfs in pairs(surfaces) do
		for _, surf in ipairs(surfs) do
			local cf = surf.part.CFrame
			local halfX = surf.size.X / 2
			local halfZ = surf.size.Z / 2

			local localCorners = {
				Vector3.new(-halfX, 0, -halfZ),
				Vector3.new(halfX, 0, -halfZ),
				Vector3.new(halfX, 0, halfZ),
				Vector3.new(-halfX, 0, halfZ),
			}

			local worldCorners = {}
			for _, corner in ipairs(localCorners) do
				local worldPos = cf * corner
				table.insert(worldCorners, Vector2.new(worldPos.X, worldPos.Z))
			end

			self._builder:AddPolygon(worldCorners, y)
		end
	end

	self._builder:AutoConnectNeighbors()
	self._mesh = self._builder:Build()
	self._query = NavMeshQuery.new(self._mesh)

	return self
end

function NavMesh:CreateFromTerrain(terrain: Instance, cellSize: number?)
	warn("NavMesh:CreateFromTerrain - Not yet implemented")
	return self
end

function NavMesh:LoadFromData(data: string)
	local success, decoded = pcall(function()
		return game:GetService("HttpService"):JSONDecode(data)
	end)

	if not success or not decoded then
		error("Invalid NavMesh data")
	end

	self._mesh = decoded
	self._query = NavMeshQuery.new(self._mesh)

	return self
end

function NavMesh:SaveToData(): string
	if not self._mesh then
		return "{}"
	end

	return game:GetService("HttpService"):JSONEncode(self._mesh)
end

function NavMesh:FindPath(startPos: Vector3, endPos: Vector3): PathResult
	if not self._query then
		return { success = false, path = {}, length = 0 }
	end
	return self._query:FindPath(startPos, endPos)
end

function NavMesh:Raycast(origin: Vector3, direction: Vector3, maxDistance: number?): RaycastResult
	if not self._query then
		return { hit = false }
	end
	return self._query:Raycast(origin, direction, maxDistance or 100)
end

function NavMesh:GetRandomPoint(): Vector3?
	if not self._query then
		return nil
	end
	return self._query:GetRandomPoint()
end

function NavMesh:GetRandomPointReachable(fromPos: Vector3): Vector3?
	if not self._query then
		return nil
	end
	return self._query:GetRandomPointReachable(fromPos)
end

function NavMesh:GetNearestPosition(position: Vector3): Vector3
	if not self._query then
		return position
	end

	local point = Vector2.new(position.X, position.Z)
	local polyId = self._query:FindNearestPolygon(point)

	if polyId then
		local poly = self._mesh.polygons[polyId]
		return Vector3.new(poly.center.X, poly.height, poly.center.Y)
	end

	return position
end

function NavMesh:SmoothPath(path: { Vector3 }, iterations: number?): { Vector3 }
	local smoothIterations = iterations or 2

	if #path <= 2 then
		return path
	end

	local result = {}
	for i, v in ipairs(path) do
		result[i] = v
	end

	for _ = 1, smoothIterations do
		local newPath = { result[1] }

		for i = 2, #result - 1 do
			local prev = result[i - 1]
			local curr = result[i]
			local next = result[i + 1]

			local directDist = (prev - next):Magnitude()
			local viaDist = (prev - curr):Magnitude() + (curr - next):Magnitude()

			if viaDist - directDist > 0.5 then
				table.insert(newPath, curr)
			end
		end

		table.insert(newPath, result[#result])
		result = newPath
	end

	return result
end

function NavMesh:GetBounds(): { min: Vector3, max: Vector3 }?
	if not self._mesh then
		return nil
	end
	return self._mesh.bounds
end

function NavMesh:GetPolygonCount(): number
	if not self._mesh then
		return 0
	end
	local count = 0
	for _ in pairs(self._mesh.polygons) do
		count = count + 1
	end
	return count
end

export type NavMeshModule = typeof(NavMesh)

return {
	Builder = NavMeshBuilder,
	Query = NavMeshQuery,
	new = function()
		return NavMesh.new()
	end,
}
