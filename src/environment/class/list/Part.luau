-- description: "A basic 3D primitive used for physics, collision, and world building."
local Vector3 = require("@Vector3")
local Color3 = require("@Color3")
local CFrame = require("@CFrame")
local Enum = require("@EnumMap")
local signal = require("@Kinemium.signal")
local manifold = require("@manifold")
local PhysicalProperties = require("@PhysicalProperties")

local propTable = {
	Position = Vector3.new(0, 10, 0),
	Size = Vector3.new(2, 1, 4),
	Color = Color3.new(1, 1, 1),
	Material = Enum.Material.SmoothPlastic,
	Transparency = 0,
	Anchored = true,
	NeonEnergy = 5.0,
	CanCollide = true,
	CollisionGroup = "Default",
	Velocity = Vector3.new(0, 0, 0),
	CustomPhysicalProperties = PhysicalProperties.new(1, 1, 0, 1, 0),
	CurrentPhysicalProperties = PhysicalProperties.new(1, 1, 0, 1, 0),
	MeshScale = 1,
	Mass = 1,
	AudioCanCollide = true,
	EnableFluidForces = false,
	Restitution = 0.5,
	Elasticity = 0.5,
	Friction = 0.3,
	Shape = Enum.PartType.Block,
	CastsShadow = true,
	Reflectance = 0,
	Roughness = 0,
	Metallic = 0,
	Locked = false,
	Orientation = Vector3.new(0, 0, 0),
	Rotation = Vector3.new(0, 0, 0),
	MouseOverObject = false,
	CFrame = CFrame.new(0, 10, 0),
	ElapsedTime = 0,
	Name = "Part",
	BaseClass = "BasePart",
	IsKinematic = false,

	_mesh = nil,
	_manifoldptr = nil,

	Touched = signal.new(),
	TouchEnded = signal.new(),

	-- Velocity
	AssemblyAngularVelocity = Vector3.new(0, 0, 0),
	AssemblyCenterOfMass = Vector3.new(0, 0, 0),
	AssemblyLinearVelocity = Vector3.new(0, 0, 0),
	AssemblyMass = 0,
	AssemblyRootPart = nil,

	-- Network
	NetworkOwnerType = Enum.MachineNetworkOwner.Server,
}

local function UpdateManifoldPointer(instance)
	if instance.Shape == Enum.PartType.Block then
		manifold.gen.free(instance._manifoldptr)
		instance._manifoldptr = manifold.gen.box(instance.Size.X, instance.Size.Y, instance.Size.Z)
	elseif instance.Shape == Enum.PartType.Ball then
		local radius = instance.Size.X * 0.5
		manifold.gen.free(instance._manifoldptr)
		instance._manifoldptr = manifold.gen.sphere(radius, 32)
	elseif instance.Shape == Enum.PartType.Cylinder then
		local radius = instance.Size.X * 0.5
		local height = instance.Size.Y
		local segments = 24

		manifold.gen.free(instance._manifoldptr)
		instance._manifoldptr = manifold.gen.cylinder(radius, height, segments, true, radius)
	end
end

local function syncFromCFrame(instance, cf)
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

local function syncFromPosition(instance, position)
	if not position then
		return
	end

	local props = rawget(instance, "_props")
	if not props or not props.CFrame then
		return
	end

	props.CFrame = props.CFrame:WithPosition(position)
end

return {
	class = "Part",

	callback = function(instance, renderer, game)
		instance:SetMetadata("IsMovable", true)

		local KinemiumPhysicsService = game:GetService("UnifiedPhysicsService")
		local syncingTransform = false

		instance:SetProperties(propTable)
		syncFromCFrame(instance, instance.CFrame)
		if renderer and renderer.EventBus then
			renderer.EventBus:Fire("UpdatePart", instance)
		end

		-- api

		-- description: "Applies physics impulse."
		-- args: "self: table, v: Vector3"
		function instance:ApplyImpulse(v)
			if KinemiumPhysicsService then
				KinemiumPhysicsService.ApplyImpulse(instance, v)
			end
		end

		-- description: "Applies physics impulse at a specified position."
		-- args: "self: table, v: Vector3"
		function instance:ApplyImpulseAtPosition(v)
			-- add impulse at position feature
			if KinemiumPhysicsService then
				KinemiumPhysicsService.ApplyImpulse(instance, v)
			end
		end

		-- description: "Returns whether the parts can collide with each other."
		-- args: "self: table, part: Part"
		function instance:CanCollideWith(part)
			-- add support
		end

		UpdateManifoldPointer(instance)

		instance.Destroying:Connect(function()
			instance.Touched = nil
			instance.TouchEnded = nil
			instance._mesh = nil

			manifold.gen.free(instance._manifoldptr)
		end)

		instance.Changed:Connect(function(property, value)
			if syncingTransform then
				return
			end

			if property == "CFrame" then
				syncingTransform = true
				syncFromCFrame(instance, value)
				syncingTransform = false
			elseif property == "Position" then
				syncingTransform = true
				syncFromPosition(instance, value)
				syncingTransform = false
			elseif property == "Parent" then
				if renderer and renderer.EventBus then
					renderer.EventBus:Fire("UpdatePart", instance)
				end
			elseif property == "Size" then
				UpdateManifoldPointer(instance)
			end
		end)

		return instance
	end,

	inherit = function(tble)
		for prop, val in pairs(propTable) do
			if not tble[prop] then
				tble[prop] = val
			end
		end
	end,
}
