local Vector3 = require("@Vector3")
local Color3 = require("@Color3")
local CFrame = require("@CFrame")
local Enum = require("@EnumMap")
local signal = require("@Kinemium.signal")

local propTable = {
	Position = Vector3.new(0, 10, 0),
	Size = Vector3.new(4, 4, 4),
	Color = Color3.new(1, 1, 1),
	Material = Enum.Material.debug,
	Transparency = 0,
	Anchored = false,
	NeonEnergy = 5.0,
	CanCollide = true,
	Velocity = Vector3.new(0, 0, 0),
	MeshScale = 1,
	Mass = 1,
	Restitution = 0.5,
	Elasticity = 0.5,
	Friction = 0.3,
	Shape = Enum.PartType.Block,
	CastsShadow = true,
	Reflectance = 0,
	Locked = false,
	Orientation = Vector3.new(0, 0, 0),
	Rotation = Vector3.new(0, 0, 0),
	MouseOverObject = false,
	CFrame = CFrame.new(0, 10, 0),
	ElapsedTime = 0,
	Name = "Part",
	BaseClass = "BasePart",
	_mesh = nil,

	Touched = signal.new(),

	-- Velocity
	AssemblyAngularVelocity = Vector3.new(0, 0, 0),
	AssemblyCenterOfMass = Vector3.new(0, 0, 0),
	AssemblyLinearVelocity = Vector3.new(0, 0, 0),
	AssemblyMass = 0,
	AssemblyRootPart = nil,

	-- Network
	NetworkOwnerType = Enum.MachineNetworkOwner.Server,
}

return {
	class = "Part",

	callback = function(instance, renderer, game)
		instance:SetMetadata("IsMovable", true)

		local PhysicsService = game:GetService("PhysicsService")

		propTable.ApplyImpulse = function(self, v)
			PhysicsService.ApplyImpulse(instance, v)
		end

		renderer.EventBus:Fire("UpdatePart", instance)
		instance:SetProperties(propTable)

		return instance
	end,

	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
