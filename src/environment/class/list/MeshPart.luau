-- description: "Renders a 3D Mesh in 3D Space."
local Vector3 = require("@Vector3")
local Part = require("@Part")
local Enum = require("@EnumMap")

local propTable = {
	MeshObject = nil,
	_showhitbox = false,
	CollisionFidelity = Enum.CollisionFidelity.Default,
	RenderFidelity = Enum.RenderFidelity.Automatic,
	CollisionScale = 1,
	Anchored = true,
	Name = "MeshPart",
	BaseClass = "BasePart",
	MeshScale = 1,
	Transparency = 0,
	Size = Vector3.new(1, 1, 1),
}

Part.inherit(propTable)

return {
	class = "MeshPart",

	callback = function(instance, renderer, game)
		instance:SetProperties(propTable)
		instance:SetMetadata("IsMovable", true)

		local KinemiumPhysicsService = game and game:GetService("UnifiedPhysicsService") or nil
		-- description: "Applies an impulse to the part."
		-- args: "self: table, v: Vector3"
		instance.ApplyImpulse = function(self, v)
			if KinemiumPhysicsService then
				KinemiumPhysicsService.ApplyImpulse(instance, v)
			end
		end

		renderer.EventBus:Fire("UpdatePart", instance)

		local syncingTransform = false

		local function syncMeshObject(meshObject)
			instance._mesh = meshObject and (meshObject._mesh or meshObject._meshgenHandle) or nil
			instance._cpuMeshData = meshObject and meshObject._cpuMeshData or nil
			instance._materialHandle = meshObject and meshObject._materialHandle or nil
		end

		local function syncFromCFrame(cf)
			if not cf or not cf.Position then
				return
			end
			local rx, ry, rz = cf:ToOrientation()
			local props = rawget(instance, "_props")
			if not props then
				return
			end
			props.Position = cf.Position
			props.Orientation = Vector3.new(rx, ry, rz)
			props.Rotation = props.Orientation
		end

		local function syncFromPosition(position)
			if not position then
				return
			end
			local props = rawget(instance, "_props")
			if not props or not props.CFrame then
				return
			end
			props.CFrame = props.CFrame:WithPosition(position)
		end

		syncMeshObject(instance.MeshObject)

		instance.Changed:Connect(function(property, value)
			if syncingTransform then
				return
			end
			if property == "CFrame" then
				syncingTransform = true
				syncFromCFrame(value)
				syncingTransform = false
			elseif property == "Position" then
				syncingTransform = true
				syncFromPosition(value)
				syncingTransform = false
			elseif property == "MeshObject" then
				syncMeshObject(value)
				renderer.EventBus:Fire("UpdatePart", instance)
			elseif property == "_mesh" or property == "_cpuMeshData" or property == "Material" then
				renderer.EventBus:Fire("UpdatePart", instance)
			elseif property == "Parent" then
				renderer.EventBus:Fire("UpdatePart", instance)
			end
		end)

		return instance
	end,
	inherit = function()
		return propTable
	end,
}
