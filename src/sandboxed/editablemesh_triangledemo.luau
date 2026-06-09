--[[
local myMesh = Instance.new("EditableMesh")

local v1 = myMesh:AddVertex(Vector3.new(0, 1, 0))
local v2 = myMesh:AddVertex(Vector3.new(-1, -1, 0))
local v3 = myMesh:AddVertex(Vector3.new(1, -1, 0))

local redColorId = myMesh:AddColor(Color3.new(1, 0, 0), 1)
local greenColorId = myMesh:AddColor(Color3.new(0, 1, 0), 1)
local blueColorId = myMesh:AddColor(Color3.new(0, 0, 1), 1)
local faceId = myMesh:AddTriangle(v1, v2, v3)

myMesh:SetVertexFaceColor(v1, faceId, redColorId)
myMesh:SetVertexFaceColor(v2, faceId, greenColorId)
myMesh:SetVertexFaceColor(v3, faceId, blueColorId)

myMesh:Triangulate()

local MeshPart = Instance.new("MeshPart")
MeshPart.MeshObject = myMesh
MeshPart.Parent = workspace
myMesh.Parent = MeshPart

--]]
