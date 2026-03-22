local Vector3 = require("@Vector3")
local Vector2 = require("@Vector2")
local Color3 = require("@Color3")
local CFrame = require("@CFrame")
local _signal = require("@Kinemium.signal")
local _Enum = require("@EnumMap")
local meshgen = require("@meshgen")

local propTable = {
	FixedSize = false,
	SkinningEnabled = false,
	Name = "EditableMesh",
	BaseClass = "Instance",
}

return {
	class = "EditableMesh",

	callback = function(instance, renderer, game)
		instance:SetProperties(propTable)

		instance._nextVertexId = 1
		instance._nextNormalId = 1
		instance._nextUVId = 1
		instance._nextColorId = 1
		instance._nextFaceId = 1
		instance._nextBoneId = 1

		instance._vertices = {} -- vertexId -> Vector3
		instance._normals = {} -- normalId -> Vector3
		instance._uvs = {} -- uvId -> Vector2
		instance._colors = {} -- colorId -> {color=Color3, alpha=number}
		instance._faces = {} -- faceId -> {v0, v1, v2}
		instance._bones = {} -- boneId -> {name, cframe, parent, isVirtual}

		instance._vertexBones = {} -- vertexId -> {boneIds, boneWeights}

		instance._vertexFaceColors = {} -- vertexId -> {faceId -> colorId}
		instance._vertexFaceUVs = {} -- vertexId -> {faceId -> uvId}
		instance._vertexFaceNormals = {} -- vertexId -> {faceId -> normalId}

		instance._meshgenHandle = nil
		instance._geometryDirty = true

		local function buildRawGeometry(self)
			local rawVertices = {}
			local indices = {}
			local vMap = {} -- hash -> zero-based index
			local counter = 0

			for faceId, face in pairs(self._faces) do
				for vi = 1, 3 do
					local vid = face[vi]
					local pos = self._vertices[vid] or Vector3.new()

					local nid = self:GetVertexFaceNormal(vid, faceId)
					local nor = self._normals[nid] or Vector3.new(0, 1, 0)

					local uvid = self:GetVertexFaceUV(vid, faceId)
					local uv = self._uvs[uvid] or Vector2.new()

					local cid = self:GetVertexFaceColor(vid, faceId)
					local c = self._colors[cid]
					local col = c and c.color or Color3.new(1, 1, 1)
					local alp = c and c.alpha or 1

					local hash = vid .. "_" .. nid .. "_" .. uvid .. "_" .. cid
					if not vMap[hash] then
						table.insert(rawVertices, {
							position = pos,
							normal = nor,
							uv = uv,
							color = {
								col.R * 255,
								col.G * 255,
								col.B * 255,
								alp * 255,
							},
						})
						vMap[hash] = counter
						counter += 1
					end
					table.insert(indices, vMap[hash])
				end
			end

			return rawVertices, indices
		end

		function instance:AddVertex(p: Vector3): number
			local id = self._nextVertexId
			self._nextVertexId += 1
			self._vertices[id] = p
			self._geometryDirty = true
			return id
		end

		function instance:AddNormal(normal: Vector3?): number
			local id = self._nextNormalId
			self._nextNormalId += 1
			self._normals[id] = normal or Vector3.new(0, 1, 0)
			return id
		end

		function instance:AddUV(uv: Vector2): number
			local id = self._nextUVId
			self._nextUVId += 1
			self._uvs[id] = uv
			return id
		end

		function instance:AddColor(color: Color3, alpha: number): number
			local id = self._nextColorId
			self._nextColorId += 1
			self._colors[id] = { color = color, alpha = alpha or 1 }
			return id
		end

		function instance:AddTriangle(vertexId0: number, vertexId1: number, vertexId2: number): number
			local id = self._nextFaceId
			self._nextFaceId += 1
			self._faces[id] = { vertexId0, vertexId1, vertexId2 }
			self._geometryDirty = true
			return id
		end

		function instance:SetPosition(vertexId: number, p: Vector3)
			if self._vertices[vertexId] then
				self._vertices[vertexId] = p
				self._geometryDirty = true
			end
		end

		function instance:GetPosition(vertexId: number): Vector3
			return self._vertices[vertexId] or Vector3.new()
		end

		function instance:SetNormal(normalId: number, normal: Vector3)
			if self._normals[normalId] then
				self._normals[normalId] = normal
				self._geometryDirty = true
			end
		end

		function instance:GetNormal(normalId: number): Vector3?
			return self._normals[normalId]
		end

		function instance:SetUV(uvId: number, uv: Vector2)
			if self._uvs[uvId] then
				self._uvs[uvId] = uv
				self._geometryDirty = true
			end
		end

		function instance:GetUV(uvId: number): Vector2?
			return self._uvs[uvId]
		end

		function instance:SetColor(colorId: number, color: Color3)
			if self._colors[colorId] then
				self._colors[colorId].color = color
			end
		end

		function instance:SetColorAlpha(colorId: number, alpha: number)
			if self._colors[colorId] then
				self._colors[colorId].alpha = alpha
			end
		end

		function instance:GetColor(colorId: number): Color3?
			local c = self._colors[colorId]
			return c and c.color or nil
		end

		function instance:GetColorAlpha(colorId: number): number?
			local c = self._colors[colorId]
			return c and c.alpha or nil
		end

		function instance:SetVertexFaceColor(vertexId: number, faceId: number, colorId: number)
			if not self._vertexFaceColors[vertexId] then
				self._vertexFaceColors[vertexId] = {}
			end
			self._vertexFaceColors[vertexId][faceId] = colorId
		end

		function instance:SetVertexFaceNormal(vertexId: number, faceId: number, normalId: number)
			if not self._vertexFaceNormals[vertexId] then
				self._vertexFaceNormals[vertexId] = {}
			end
			self._vertexFaceNormals[vertexId][faceId] = normalId
			self._geometryDirty = true
		end

		function instance:SetVertexFaceUV(vertexId: number, faceId: number, uvId: number)
			if not self._vertexFaceUVs[vertexId] then
				self._vertexFaceUVs[vertexId] = {}
			end
			self._vertexFaceUVs[vertexId][faceId] = uvId
			self._geometryDirty = true
		end

		function instance:GetVertexFaceColor(vertexId: number, faceId: number): number
			return self._vertexFaceColors[vertexId] and self._vertexFaceColors[vertexId][faceId] or 0
		end

		function instance:GetVertexFaceNormal(vertexId: number, faceId: number): number
			return self._vertexFaceNormals[vertexId] and self._vertexFaceNormals[vertexId][faceId] or 0
		end

		function instance:GetVertexFaceUV(vertexId: number, faceId: number): number
			return self._vertexFaceUVs[vertexId] and self._vertexFaceUVs[vertexId][faceId] or 0
		end

		function instance:GetVertices(): { number }
			local arr = {}
			for id in pairs(self._vertices) do
				table.insert(arr, id)
			end
			return arr
		end

		function instance:GetNormals(): { number }
			local arr = {}
			for id in pairs(self._normals) do
				table.insert(arr, id)
			end
			return arr
		end

		function instance:GetUVs(): { number }
			local arr = {}
			for id in pairs(self._uvs) do
				table.insert(arr, id)
			end
			return arr
		end

		function instance:GetColors(): { number }
			local arr = {}
			for id in pairs(self._colors) do
				table.insert(arr, id)
			end
			return arr
		end

		function instance:GetFaces(): { number }
			local arr = {}
			for id in pairs(self._faces) do
				table.insert(arr, id)
			end
			return arr
		end

		function instance:GetFaceVertices(faceId: number): { number }
			local f = self._faces[faceId]
			return f and { f[1], f[2], f[3] } or {}
		end

		function instance:SetFaceColors(faceId: number, ids: { number })
			local f = self._faces[faceId]
			if f and #ids == 3 then
				self:SetVertexFaceColor(f[1], faceId, ids[1])
				self:SetVertexFaceColor(f[2], faceId, ids[2])
				self:SetVertexFaceColor(f[3], faceId, ids[3])
			end
		end

		function instance:SetFaceNormals(faceId: number, ids: { number })
			local f = self._faces[faceId]
			if f and #ids == 3 then
				self:SetVertexFaceNormal(f[1], faceId, ids[1])
				self:SetVertexFaceNormal(f[2], faceId, ids[2])
				self:SetVertexFaceNormal(f[3], faceId, ids[3])
			end
		end

		function instance:SetFaceUVs(faceId: number, ids: { number })
			local f = self._faces[faceId]
			if f and #ids == 3 then
				self:SetVertexFaceUV(f[1], faceId, ids[1])
				self:SetVertexFaceUV(f[2], faceId, ids[2])
				self:SetVertexFaceUV(f[3], faceId, ids[3])
			end
		end

		function instance:GetFaceColors(faceId: number): { number }
			local f = self._faces[faceId]
			if not f then
				return {}
			end
			return {
				self:GetVertexFaceColor(f[1], faceId),
				self:GetVertexFaceColor(f[2], faceId),
				self:GetVertexFaceColor(f[3], faceId),
			}
		end

		function instance:GetFaceNormals(faceId: number): { number }
			local f = self._faces[faceId]
			if not f then
				return {}
			end
			return {
				self:GetVertexFaceNormal(f[1], faceId),
				self:GetVertexFaceNormal(f[2], faceId),
				self:GetVertexFaceNormal(f[3], faceId),
			}
		end

		function instance:GetFaceUVs(faceId: number): { number }
			local f = self._faces[faceId]
			if not f then
				return {}
			end
			return {
				self:GetVertexFaceUV(f[1], faceId),
				self:GetVertexFaceUV(f[2], faceId),
				self:GetVertexFaceUV(f[3], faceId),
			}
		end
		function instance:RemoveFace(faceId: number)
			self._faces[faceId] = nil
			self._geometryDirty = true
		end

		function instance:RemoveUnused(): { any }
			return {}
		end

		function instance:IdDebugString(id: number): string
			return tostring(id)
		end

		function instance:FindClosestVertex(toThisPoint: Vector3): number
			local closestId = 0
			local closestDist = math.huge
			for id, pos in pairs(self._vertices) do
				local dist = (pos - toThisPoint).Magnitude
				if dist < closestDist then
					closestDist = dist
					closestId = id
				end
			end
			return closestId
		end

		function instance:FindVerticesWithinSphere(center: Vector3, radius: number): { number }
			local res = {}
			for id, pos in pairs(self._vertices) do
				if (pos - center).Magnitude <= radius then
					table.insert(res, id)
				end
			end
			return res
		end

		function instance:GetCenter(): Vector3
			local count = 0
			local sum = Vector3.new()
			for _, pos in pairs(self._vertices) do
				sum += pos
				count += 1
			end
			return count > 0 and (sum / count) or Vector3.new()
		end

		function instance:GetSize(): Vector3
			local min = Vector3.new(math.huge, math.huge, math.huge)
			local max = Vector3.new(-math.huge, -math.huge, -math.huge)
			local count = 0
			for _, pos in pairs(self._vertices) do
				count += 1
				min = Vector3.new(math.min(min.x, pos.x), math.min(min.y, pos.y), math.min(min.z, pos.z))
				max = Vector3.new(math.max(max.x, pos.x), math.max(max.y, pos.y), math.max(max.z, pos.z))
			end
			return count > 0 and (max - min) or Vector3.new()
		end

		function instance:GetAdjacentFaces(faceId: number): { number }
			local f = self._faces[faceId]
			if not f then
				return {}
			end

			local vSet = { [f[1]] = true, [f[2]] = true, [f[3]] = true }
			local res = {}

			for fid, face in pairs(self._faces) do
				if fid ~= faceId then
					local shared = 0
					if vSet[face[1]] then
						shared += 1
					end
					if vSet[face[2]] then
						shared += 1
					end
					if vSet[face[3]] then
						shared += 1
					end
					if shared >= 2 then
						table.insert(res, fid)
					end
				end
			end
			return res
		end

		function instance:GetAdjacentVertices(vertexId: number): { number }
			local adjSet = {}
			for _, face in pairs(self._faces) do
				if face[1] == vertexId or face[2] == vertexId or face[3] == vertexId then
					if face[1] ~= vertexId then
						adjSet[face[1]] = true
					end
					if face[2] ~= vertexId then
						adjSet[face[2]] = true
					end
					if face[3] ~= vertexId then
						adjSet[face[3]] = true
					end
				end
			end
			local res = {}
			for v in pairs(adjSet) do
				table.insert(res, v)
			end
			return res
		end

		function instance:GetVertexFaces(vertexId: number): { number }
			local res = {}
			for fid, face in pairs(self._faces) do
				if face[1] == vertexId or face[2] == vertexId or face[3] == vertexId then
					table.insert(res, fid)
				end
			end
			return res
		end

		function instance:AddBone(boneProperties: any): number
			local id = self._nextBoneId
			self._nextBoneId += 1
			self._bones[id] = {
				name = boneProperties.Name or ("Bone" .. tostring(id)),
				cframe = boneProperties.CFrame or CFrame.new(),
				parent = boneProperties.ParentId or 0,
				isVirtual = boneProperties.IsVirtual or false,
			}
			return id
		end

		function instance:GetBones(): { number }
			local arr = {}
			for id in pairs(self._bones) do
				table.insert(arr, id)
			end
			return arr
		end

		function instance:GetBoneName(boneId: number): string
			return self._bones[boneId] and self._bones[boneId].name or ""
		end

		function instance:GetBoneCFrame(boneId: number): CFrame
			return self._bones[boneId] and self._bones[boneId].cframe or CFrame.new()
		end

		function instance:GetBoneIsVirtual(boneId: number): boolean
			return self._bones[boneId] and self._bones[boneId].isVirtual or false
		end

		function instance:GetBoneParent(boneId: number): number
			return self._bones[boneId] and self._bones[boneId].parent or 0
		end

		function instance:GetBoneByName(boneName: string): number
			for id, b in pairs(self._bones) do
				if b.name == boneName then
					return id
				end
			end
			return 0
		end

		function instance:SetBoneName(boneId: number, name: string)
			if self._bones[boneId] then
				self._bones[boneId].name = name
			end
		end

		function instance:SetBoneCFrame(boneId: number, cframe: CFrame)
			if self._bones[boneId] then
				self._bones[boneId].cframe = cframe
			end
		end

		function instance:SetBoneIsVirtual(boneId: number, virtual: boolean)
			if self._bones[boneId] then
				self._bones[boneId].isVirtual = virtual
			end
		end

		function instance:SetBoneParent(boneId: number, parentId: number)
			if self._bones[boneId] then
				self._bones[boneId].parent = parentId
			end
		end

		function instance:RemoveBone(boneId: number)
			self._bones[boneId] = nil
		end

		function instance:SetVertexBones(vertexId: number, boneIDs: { number })
			if not self._vertexBones[vertexId] then
				self._vertexBones[vertexId] = { boneIds = {}, boneWeights = {} }
			end
			self._vertexBones[vertexId].boneIds = boneIDs
		end

		function instance:SetVertexBoneWeights(vertexId: number, boneWeights: { number })
			if not self._vertexBones[vertexId] then
				self._vertexBones[vertexId] = { boneIds = {}, boneWeights = {} }
			end
			self._vertexBones[vertexId].boneWeights = boneWeights
		end

		function instance:GetVertexBones(vertexId: number): { number }
			return self._vertexBones[vertexId] and self._vertexBones[vertexId].boneIds or {}
		end

		function instance:GetVertexBoneWeights(vertexId: number): { number }
			return self._vertexBones[vertexId] and self._vertexBones[vertexId].boneWeights or {}
		end

		-- rebuilds the GPU mesh from current geometry data.
		-- opts:
		--   smooth          boolean  – smooth normal recalculation (default: false = flat)
		--   generateTangents boolean – auto-generate tangents (default: false)
		--   weld            boolean  – deduplicate vertices (default: false)
		--   weldTolerance   number
		function instance:Triangulate(opts: any?)
			local rawVertices, indices = buildRawGeometry(self)

			if #rawVertices == 0 then
				self._meshgenHandle = nil
				self._geometryDirty = false
				return
			end

			local buildOpts = {
				usage = meshgen.Usage.Dynamic,
				indicesAreZeroBased = true,
			}

			if opts then
				if opts.smooth then
					buildOpts.smooth = true
				elseif opts.flat then
					buildOpts.flat = true
				end

				if opts.generateTangents then
					buildOpts.generateTangents = true
				end

				if opts.weld then
					buildOpts.weld = true
					buildOpts.weldTolerance = opts.weldTolerance
				end
			end

			self._meshgenHandle = meshgen.buildMesh(rawVertices, indices, buildOpts)
			self._geometryDirty = false
		end

		function instance:FlushIfDirty(opts: any?)
			if self._geometryDirty then
				self:Triangulate(opts)
			end
		end

		-- axis: 'x' | 'y' | 'z'   scale/offset: {u, v} tables (optional)
		function instance:ApplyUVProjection(axis: string?, scale: { number }?, offset: { number }?)
			local vertList = {}
			local idToIdx = {}
			for vid, pos in pairs(self._vertices) do
				local idx = #vertList + 1
				vertList[idx] = { position = pos }
				idToIdx[vid] = idx
			end

			meshgen.uvPlanar(vertList, axis, scale, offset)

			for vid, idx in pairs(idToIdx) do
				local projUV = vertList[idx].uv
				if projUV then
					local newUvId = self:AddUV(Vector2.new(projUV[1], projUV[2]))
					for fid in pairs(self._faces) do
						local f = self._faces[fid]
						if f and (f[1] == vid or f[2] == vid or f[3] == vid) then
							self:SetVertexFaceUV(vid, fid, newUvId)
						end
					end
				end
			end

			self._geometryDirty = true
		end

		function instance:RecalculateNormals(smooth: boolean?)
			local rawVertices, indices = buildRawGeometry(self)
			if #rawVertices == 0 then
				return
			end

			meshgen.recalculateNormals(rawVertices, indices, smooth)

			for i, v in ipairs(rawVertices) do
				if v.normal then
					local n = v.normal
					local nx = type(n) == "table" and (n[1] or n.x or n.X) or 0
					local ny = type(n) == "table" and (n[2] or n.y or n.Y) or 1
					local nz = type(n) == "table" and (n[3] or n.z or n.Z) or 0
					local nid = self:AddNormal(Vector3.new(nx, ny, nz))
					local triIdx = math.floor((i - 1) / 3)
					local cornerIdx = ((i - 1) % 3) + 1
					local faceId = nil
					local faceCount = 0
					for fid in pairs(self._faces) do
						if faceCount == triIdx then
							faceId = fid
							break
						end
						faceCount += 1
					end
					if faceId then
						local face = self._faces[faceId]
						self:SetVertexFaceNormal(face[cornerIdx], faceId, nid)
					end
				end
			end

			self._geometryDirty = true
		end

		function instance:MergeVertices(mergeTolerance: number): any
			local rawVertices, indices = buildRawGeometry(self)
			if #rawVertices == 0 then
				return {}
			end

			local weldedVerts, weldedIndices = meshgen.weldVertices(rawVertices, indices, mergeTolerance)

			local remap = {}
			for i, wIdx in ipairs(weldedIndices) do
				remap[i - 1] = wIdx
			end

			self._geometryDirty = true
			return remap
		end
		function instance:GetFacesWithColor(colorId: number): { number }
			local res = {}
			for faceId, face in pairs(self._faces) do
				if
					self:GetVertexFaceColor(face[1], faceId) == colorId
					or self:GetVertexFaceColor(face[2], faceId) == colorId
					or self:GetVertexFaceColor(face[3], faceId) == colorId
				then
					table.insert(res, faceId)
				end
			end
			return res
		end

		function instance:GetFacesWithNormal(normalId: number): { number }
			local res = {}
			for faceId, face in pairs(self._faces) do
				if
					self:GetVertexFaceNormal(face[1], faceId) == normalId
					or self:GetVertexFaceNormal(face[2], faceId) == normalId
					or self:GetVertexFaceNormal(face[3], faceId) == normalId
				then
					table.insert(res, faceId)
				end
			end
			return res
		end

		function instance:GetFacesWithUV(uvId: number): { number }
			local res = {}
			for faceId, face in pairs(self._faces) do
				if
					self:GetVertexFaceUV(face[1], faceId) == uvId
					or self:GetVertexFaceUV(face[2], faceId) == uvId
					or self:GetVertexFaceUV(face[3], faceId) == uvId
				then
					table.insert(res, faceId)
				end
			end
			return res
		end

		function instance:GetVerticesWithColor(colorId: number): { number }
			local res = {}
			for vid, fcs in pairs(self._vertexFaceColors) do
				for _, cid in pairs(fcs) do
					if cid == colorId then
						table.insert(res, vid)
						break
					end
				end
			end
			return res
		end

		function instance:GetVerticesWithNormal(normalId: number): { number }
			local res = {}
			for vid, fcs in pairs(self._vertexFaceNormals) do
				for _, nid in pairs(fcs) do
					if nid == normalId then
						table.insert(res, vid)
						break
					end
				end
			end
			return res
		end

		function instance:GetVerticesWithUV(uvId: number): { number }
			local res = {}
			for vid, fcs in pairs(self._vertexFaceUVs) do
				for _, uid in pairs(fcs) do
					if uid == uvId then
						table.insert(res, vid)
						break
					end
				end
			end
			return res
		end

		function instance:GetFacesWithAttribute(_id: number): { number }
			return {}
		end
		function instance:GetVerticesWithAttribute(_id: number): { number }
			return {}
		end

		function instance:RaycastLocal(origin: Vector3, direction: Vector3)
			local minT = math.huge
			local closestHit = nil
			local closestNorm = nil
			local closestFace = 0

			for fid, face in pairs(self._faces) do
				local v0 = self._vertices[face[1]]
				local v1 = self._vertices[face[2]]
				local v2 = self._vertices[face[3]]
				if v0 and v1 and v2 then
					local edge1 = v1 - v0
					local edge2 = v2 - v0
					local h = direction:Cross(edge2)
					local a = edge1:Dot(h)
					if math.abs(a) > 1e-8 then
						local f = 1.0 / a
						local s = origin - v0
						local u = f * s:Dot(h)
						if u >= 0 and u <= 1.0 then
							local q = s:Cross(edge1)
							local v = f * direction:Dot(q)
							if v >= 0 and u + v <= 1.0 then
								local t = f * edge2:Dot(q)
								if t > 0 and t < minT then
									minT = t
									closestHit = origin + direction * t
									closestNorm = edge1:Cross(edge2).Unit
									closestFace = fid
								end
							end
						end
					end
				end
			end

			if closestHit then
				return closestHit, closestNorm, closestFace, minT
			end
			return nil
		end

		function instance:FindClosestPointOnSurface(point: Vector3)
			local closestP = nil
			local closestDist = math.huge
			local closestFace = 0

			for fid, face in pairs(self._faces) do
				local v0 = self._vertices[face[1]]
				local v1 = self._vertices[face[2]]
				local v2 = self._vertices[face[3]]
				if v0 and v1 and v2 then
					local edge1 = v1 - v0
					local edge2 = v2 - v0
					local n = edge1:Cross(edge2)
					local lenSq = n:Dot(n)

					local proj
					if lenSq > 1e-12 then
						local d = n:Dot(v0)
						local t = (n:Dot(point) - d) / lenSq
						local pp = point - n * t

						-- Barycentric check
						local function bary(p, a, b, c)
							local v0b = b - a
							local v1b = c - a
							local v2b = p - a
							local d00 = v0b:Dot(v0b)
							local d01 = v0b:Dot(v1b)
							local d11 = v1b:Dot(v1b)
							local d20 = v2b:Dot(v0b)
							local d21 = v2b:Dot(v1b)
							local denom = d00 * d11 - d01 * d01
							if math.abs(denom) < 1e-12 then
								return 0, 0
							end
							local sv = (d11 * d20 - d01 * d21) / denom
							local tv = (d00 * d21 - d01 * d20) / denom
							return sv, tv
						end

						local sv, tv = bary(pp, v0, v1, v2)
						if sv >= 0 and tv >= 0 and sv + tv <= 1 then
							proj = pp
						end
					end

					if not proj then
						local d0 = (v0 - point).Magnitude
						local d1 = (v1 - point).Magnitude
						local d2 = (v2 - point).Magnitude
						if d0 <= d1 and d0 <= d2 then
							proj = v0
						elseif d1 <= d2 then
							proj = v1
						else
							proj = v2
						end
					end

					local d = (proj - point).Magnitude
					if d < closestDist then
						closestDist = d
						closestP = proj
						closestFace = fid
					end
				end
			end

			return closestP or Vector3.new(), closestDist, closestFace
		end

		return instance
	end,

	inherit = function()
		return propTable
	end,
}
