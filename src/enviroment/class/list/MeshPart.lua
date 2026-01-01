local Vector3 = require("@Vector3")
local Part = require("./Part")
local raylib = require("@raylib")
local Enum = require("@EnumMap")

local propTable = {
	MeshId = "./src/assets/meshes/cube.glb",
	_showhitbox = false,
	CollisionFidelity = Enum.CollisionFidelity.Default,
	RenderFidelity = Enum.RenderFidelity.Automatic,
	CollisionScale = 1,
	MeshScale = 1,
}

Part.inherit(propTable)

return {
	class = "MeshPart",
	callback = function(instance, renderer)
		instance:SetProperties(propTable)

		local function update()
			local model = raylib.lib.LoadModel(instance.MeshId)

			instance._model = model

			local boundingBox = raylib.lib.GetModelBoundingBox(model)
			local min = zune.mem.toVector3(boundingBox, 0)
			local max = zune.mem.toVector3(boundingBox, 12)
			local result = max - min

			instance.Size = Vector3.new(
				result.x * instance.CollisionScale,
				result.y * instance.CollisionScale,
				result.z * instance.CollisionScale
			)

			--local mesh = utils.extract.mesh_from_model(model)
			--instance._meshp = mesh
		end

		update()

		instance.Changed:Connect(function(propname, propvalue)
			if propname == "MeshId" then
				update()
			end
		end)

		return instance
	end,
	inherit = function()
		return propTable
	end,
}
