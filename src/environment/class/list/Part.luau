-- description: "A basic 3D primitive used for physics, collision, and world building."
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
	Anchored = true,
	NeonEnergy = 5.0,
	CanCollide = true,
	CollisionGroup = "Default",
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

		local KinemiumPhysicsService = game:GetService("UnifiedPhysicsService")
		local syncingTransform = false

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

		-- description: "Applies physics impulse."
		-- args: "self: table, v: Vector3"
		propTable.ApplyImpulse = function(self, v)
			if KinemiumPhysicsService then
				KinemiumPhysicsService.ApplyImpulse(instance, v)
			end
		end

		renderer.EventBus:Fire("UpdatePart", instance)
		instance:SetProperties(propTable)
		syncFromCFrame(instance.CFrame)

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
			elseif property == "Parent" then
				renderer.EventBus:Fire("UpdatePart", instance)
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
