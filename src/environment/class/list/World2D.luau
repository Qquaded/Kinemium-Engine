-- description: "Represents a World2D in the environment."
local Vector2 = require("@Vector2")
local UDim2 = require("@UDim2")

local propTable = {
	-- world state
	Gravity = Vector2.new(0, 981),
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
	maximumLinearSpeed = 4000,
	maximumAngularSpeed = 4000,

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
	-- description: "Adds body."
	-- args: "self: table, body: number"
	AddBody = function(self, body) end,
	-- description: "Removes body."
	-- args: "self: table, body: number"
	RemoveBody = function(self, body) end,
	-- description: "Adds constraint."
	-- args: "self: table, constraint: any"
	AddConstraint = function(self, constraint) end,
	-- description: "Removes constraint."
	-- args: "self: table, constraint: any"
	RemoveConstraint = function(self, constraint) end,
	-- description: "Clears."
	-- args: "self: table"
	Clear = function(self) end,
	-- description: "Steps."
	-- args: "self: table, dt: number"
	Step = function(self, dt) end,
}

return {
	class = "World2D",

	-- description: "Initializes the World2D instance."
	-- args: "instance: table, renderer: number, game: table"
	-- returns: "table"
	callback = function(instance, renderer, game)
		local Box2DService = game.Box2DService

		-- description: "Instance.renders."
		-- args: "lib: number, instance: table, dt: number, structs: table"
		instance.render = function(lib, instance, dt, structs)
			local dpiScale = lib.GetWindowScaleDPI()
			instance.Size = UDim2.new(0, lib.GetRenderWidth() / dpiScale.x, 0, lib.GetRenderHeight() / dpiScale.y)

			for _, child in pairs(instance:GetChildren()) do
				if child["render"] then
					child.render(lib, child, dt, structs, renderer, game)
				end
			end
		end

		-- description: "Updates."
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

	-- description: "Inherits the properties of the World2D class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
