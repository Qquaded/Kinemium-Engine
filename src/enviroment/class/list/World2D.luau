local Vector2 = require("@Vector2")
local Enum = require("@EnumMap")
local UDim2 = require("@UDim2")
local renderpool = {}

local propTable = {
	-- world state
	Gravity = Vector2.new(0, -9.81),
	TimeScale = 1,
	Paused = false,

	ResetOnSpawn = true,
	Position = UDim2.new(0, 0, 0, 0),
	Size = UDim2.new(0, 400, 0, 400),
	RenderOffset = Vector2.new(0, 0),
	OverrideScreenSize = false,

	-- simulation
	FixedDeltaTime = 1 / 60,
	ElapsedTime = 0,
	Accumulator = 0,
	contactHertz = 60,
	contactDampingRatio = 1,
	maximumLinearSpeed = 40,
	maximumAngularSpeed = 40,

	restitutionThreshold = 1.0,
	hitEventThreshold = 0.0,
	maxContactPushSpeed = 3.0,
	enableSleep = true,
	enableContinuous = true,
	workerCount = 0,

	MotionLocks = {
		LinearX = false,
		LinearY = false,
		AngularZ = false,
	},

	--[[ 
	Credits = function()
		return "This class uses Box2D, Thank you for running this function even though it serves no purpose other than informing what the UI physics backend is, Your welcome."
	end,
	--]]

	-- storage
	Bodies = {}, -- [Body2D] = true
	Constraints = {}, -- future-proof
	CollisionLayers = {},

	-- world bounds (optional)
	UseBounds = false,
	MinBounds = Vector2.new(-math.huge, -math.huge),
	MaxBounds = Vector2.new(math.huge, math.huge),

	-- solver config
	VelocityIterations = 8,
	PositionIterations = 3,
	AllowSleep = true,

	-- debug
	DebugDraw = false,
	DebugColor = nil,

	BaseClass = "UIContainer",

	-- api (no implementation)
	AddBody = function(self, body) end,
	RemoveBody = function(self, body) end,
	AddConstraint = function(self, constraint) end,
	RemoveConstraint = function(self, constraint) end,
	Clear = function(self) end,
	Step = function(self, dt) end,
}

return {
	class = "World2D",

	callback = function(instance, renderer, game)
		local Box2DService = game.Box2DService

		instance.render = function(lib, instance, dt, structs)
			instance.Size = UDim2.new(0, lib.GetRenderWidth(), 0, lib.GetRenderHeight())

			for _, child in pairs(instance:GetChildren()) do
				if child["render"] then
					child.render(lib, child, dt, structs, renderer, game)
				end
			end
		end

		local function update()
			Box2DService.init(instance, function(object, newPosition)
				object.Position = newPosition
			end)
		end

		propTable.UpdateConfig = update

		instance:SetProperties(propTable)

		update()

		return instance
	end,

	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
