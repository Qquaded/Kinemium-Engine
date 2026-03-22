-- editablemesh_demo (grass)
--[[
local PATCH_SIZE = 30 -- world-units square
local BLADE_COUNT = 100000
local BLADE_HEIGHT = 0.8
local BLADE_WIDTH = 0.06
local BLADE_SEGS = 1 -- quad rows per blade (more = smoother curve)
local RANDOM_SEED = 42
math.randomseed(RANDOM_SEED)

local function randRange(lo, hi)
	return lo + math.random() * (hi - lo)
end
local function lerp(a, b, t)
	return a + (b - a) * t
end

local myMesh = Instance.new("EditableMesh")

local upNormalId = myMesh:AddNormal(Vector3.new(0, 1, 0))

local function addBlade(ox, oz)
	local height = randRange(BLADE_HEIGHT * 0.6, BLADE_HEIGHT * 1.4)
	local width = randRange(BLADE_WIDTH * 0.7, BLADE_WIDTH * 1.3)
	local yaw = randRange(0, math.pi * 2)
	local lean = randRange(0.05, 0.35) -- forward curve
	local twist = randRange(-0.3, 0.3) -- lateral tip drift

	local cosY, sinY = math.cos(yaw), math.sin(yaw)

	-- rotate a local (x, z) by yaw
	local function rot(x, z)
		return x * cosY - z * sinY, x * sinY + z * cosY
	end

	local rowVerts = {} -- rowVerts[row][1=left, 2=right] = vertexId

	for row = 0, BLADE_SEGS do
		local t = row / BLADE_SEGS
		local y = lerp(0, height * 0.9, t)
		local halfW = lerp(width, width * 0.12, t)
		local fwd = lean * t * t * height
		local side = twist * t * t

		local lx, lz = rot(-halfW + side, fwd)
		local rx, rz = rot(halfW + side, fwd)

		local lvid = myMesh:AddVertex(Vector3.new(ox + lx, y, oz + lz))
		local rvid = myMesh:AddVertex(Vector3.new(ox + rx, y, oz + rz))
		rowVerts[row] = { lvid, rvid }
	end

	local tipFwd = lean * height
	local tipSide = twist * height
	local tx, tz = rot(tipSide, tipFwd)
	local tipVid = myMesh:AddVertex(Vector3.new(ox + tx, height, oz + tz))

	local baseColorId =
		myMesh:AddColor(Color3.fromRGB(40 + math.random(20), 110 + math.random(30), 30 + math.random(20)), 1)
	local tipColorId =
		myMesh:AddColor(Color3.fromRGB(80 + math.random(20), 190 + math.random(40), 50 + math.random(20)), 1)

	local uvLeft = {} -- uvLeft[row]  = uvId  (u=0)
	local uvRight = {} -- uvRight[row] = uvId  (u=1)
	for row = 0, BLADE_SEGS do
		local t = row / BLADE_SEGS
		uvLeft[row] = myMesh:AddUV(Vector2.new(0, t))
		uvRight[row] = myMesh:AddUV(Vector2.new(1, t))
	end
	local uvTip = myMesh:AddUV(Vector2.new(0.5, 1))

	local function blendColor(t)
		return t < 0.5 and baseColorId or tipColorId
	end

	for seg = 0, BLADE_SEGS - 1 do
		local tBot = seg / BLADE_SEGS
		local tTop = (seg + 1) / BLADE_SEGS

		local bl = rowVerts[seg][1]
		local br = rowVerts[seg][2]
		local tl = rowVerts[seg + 1][1]
		local tr = rowVerts[seg + 1][2]

		local fA = myMesh:AddTriangle(bl, br, tl)
		myMesh:SetVertexFaceNormal(bl, fA, upNormalId)
		myMesh:SetVertexFaceNormal(br, fA, upNormalId)
		myMesh:SetVertexFaceNormal(tl, fA, upNormalId)
		myMesh:SetVertexFaceColor(bl, fA, blendColor(tBot))
		myMesh:SetVertexFaceColor(br, fA, blendColor(tBot))
		myMesh:SetVertexFaceColor(tl, fA, blendColor(tTop))
		myMesh:SetVertexFaceUV(bl, fA, uvLeft[seg])
		myMesh:SetVertexFaceUV(br, fA, uvRight[seg])
		myMesh:SetVertexFaceUV(tl, fA, uvLeft[seg + 1])

		local fB = myMesh:AddTriangle(br, tr, tl)
		myMesh:SetVertexFaceNormal(br, fB, upNormalId)
		myMesh:SetVertexFaceNormal(tr, fB, upNormalId)
		myMesh:SetVertexFaceNormal(tl, fB, upNormalId)
		myMesh:SetVertexFaceColor(br, fB, blendColor(tBot))
		myMesh:SetVertexFaceColor(tr, fB, blendColor(tTop))
		myMesh:SetVertexFaceColor(tl, fB, blendColor(tTop))
		myMesh:SetVertexFaceUV(br, fB, uvRight[seg])
		myMesh:SetVertexFaceUV(tr, fB, uvRight[seg + 1])
		myMesh:SetVertexFaceUV(tl, fB, uvLeft[seg + 1])
	end

	local lastRow = rowVerts[BLADE_SEGS]
	local fTip = myMesh:AddTriangle(lastRow[1], lastRow[2], tipVid)
	myMesh:SetVertexFaceNormal(lastRow[1], fTip, upNormalId)
	myMesh:SetVertexFaceNormal(lastRow[2], fTip, upNormalId)
	myMesh:SetVertexFaceNormal(tipVid, fTip, upNormalId)
	myMesh:SetVertexFaceColor(lastRow[1], fTip, tipColorId)
	myMesh:SetVertexFaceColor(lastRow[2], fTip, tipColorId)
	myMesh:SetVertexFaceColor(tipVid, fTip, tipColorId)
	myMesh:SetVertexFaceUV(lastRow[1], fTip, uvLeft[BLADE_SEGS])
	myMesh:SetVertexFaceUV(lastRow[2], fTip, uvRight[BLADE_SEGS])
	myMesh:SetVertexFaceUV(tipVid, fTip, uvTip)
end

for _ = 1, BLADE_COUNT do
	local bx = randRange(-PATCH_SIZE / 2, PATCH_SIZE / 2)
	local bz = randRange(-PATCH_SIZE / 2, PATCH_SIZE / 2)
	addBlade(bx, bz)
end

myMesh:Triangulate()

local MeshPart = Instance.new("MeshPart")
MeshPart.MeshObject = myMesh
MeshPart.CFrame = CFrame.new(0, 2, 0)
MeshPart.Material = Enum.Material.Grass
MeshPart.Parent = workspace
myMesh.Parent = MeshPart
--]]
