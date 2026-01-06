--!strict
--!optimize 2
--!native

local ffi = zune.ffi

-- Basic type aliases
local int = ffi.types.i32
local uint = ffi.types.u32
local bool = ffi.types.u8
local float = ffi.types.float
local double = ffi.types.double

local b2Vec2 = ffi.struct({
	{ x = ffi.types.float },
	{ y = ffi.types.float },
})
export type b2Vec2 = typeof(b2Vec2:new({}))

local b2Rot = ffi.struct({
	{ s = ffi.types.float }, -- sin(angle)
	{ c = ffi.types.float }, -- cos(angle)
})
export type b2Rot = typeof(b2Rot:new({}))

local b2Version = ffi.struct({
	{ major = ffi.types.i32 },
	{ minor = ffi.types.i32 },
	{ revision = ffi.types.i32 },
})
export type b2Version = typeof(b2Version:new({}))

local b2RayCastInput = ffi.struct({
	{ origin = ffi.types.pointer },
	{ translation = ffi.types.pointer },
	{ maxFraction = ffi.types.float },
})
export type b2RayCastInput = typeof(b2RayCastInput:new({}))

local b2ShapeProxy = ffi.struct({
	{ points = ffi.types.pointer:array(8) },
	{ count = ffi.types.i32 },
	{ radius = ffi.types.float },
})
export type b2ShapeProxy = typeof(b2ShapeProxy:new({}))

local b2ShapeCastInput = ffi.struct({
	{ proxy = b2ShapeProxy },
	{ translation = ffi.types.pointer },
	{ maxFraction = ffi.types.float },
	{ canEncroach = ffi.types.u8 },
})
export type b2ShapeCastInput = typeof(b2ShapeCastInput:new({}))

local b2CastOutput = ffi.struct({
	{ normal = ffi.types.pointer },
	{ point = ffi.types.pointer },
	{ fraction = ffi.types.float },
	{ iterations = ffi.types.i32 },
	{ hit = ffi.types.u8 },
})
export type b2CastOutput = typeof(b2CastOutput:new({}))

local b2MassData = ffi.struct({
	{ mass = ffi.types.float },
	{ center = ffi.types.pointer },
	{ rotationalInertia = ffi.types.float },
})
export type b2MassData = typeof(b2MassData:new({}))

local b2Circle = ffi.struct({
	{ center = ffi.types.pointer },
	{ radius = ffi.types.float },
})
export type b2Circle = typeof(b2Circle:new({}))

local b2Capsule = ffi.struct({
	{ center1 = ffi.types.pointer },
	{ center2 = ffi.types.pointer },
	{ radius = ffi.types.float },
})
export type b2Capsule = typeof(b2Capsule:new({}))

local b2Polygon = ffi.struct({
	{ vertices = ffi.types.pointer:array(8) },
	{ normals = ffi.types.pointer:array(8) },
	{ centroid = ffi.types.pointer },
	{ radius = ffi.types.float },
	{ count = ffi.types.i32 },
})
export type b2Polygon = typeof(b2Polygon:new({}))

local b2Segment = ffi.struct({
	{ point1 = ffi.types.pointer },
	{ point2 = ffi.types.pointer },
})
export type b2Segment = typeof(b2Segment:new({}))

local b2ChainSegment = ffi.struct({
	{ ghost1 = ffi.types.pointer },
	{ segment = b2Segment },
	{ ghost2 = ffi.types.pointer },
	{ chainId = ffi.types.i32 },
})
export type b2ChainSegment = typeof(b2ChainSegment:new({}))

local b2Hull = ffi.struct({
	{ points = ffi.types.pointer:array(8) },
	{ count = ffi.types.i32 },
})
export type b2Hull = typeof(b2Hull:new({}))

local b2SegmentDistanceResult = ffi.struct({
	{ closest1 = ffi.types.pointer },
	{ closest2 = ffi.types.pointer },
	{ fraction1 = ffi.types.float },
	{ fraction2 = ffi.types.float },
	{ distanceSquared = ffi.types.float },
})
export type b2SegmentDistanceResult = typeof(b2SegmentDistanceResult:new({}))

local b2SimplexCache = ffi.struct({
	{ count = ffi.types.u16 },
	{ indexA = ffi.types.u8:array(3) },
	{ indexB = ffi.types.u8:array(3) },
})
export type b2SimplexCache = typeof(b2SimplexCache:new({}))

local b2DistanceInput = ffi.struct({
	{ proxyA = b2ShapeProxy },
	{ proxyB = b2ShapeProxy },
	{ transformA = ffi.types.pointer },
	{ transformB = ffi.types.pointer },
	{ useRadii = ffi.types.u8 },
})
export type b2DistanceInput = typeof(b2DistanceInput:new({}))

local b2DistanceOutput = ffi.struct({
	{ pointA = ffi.types.pointer },
	{ pointB = ffi.types.pointer },
	{ normal = ffi.types.pointer },
	{ distance = ffi.types.float },
	{ iterations = ffi.types.i32 },
	{ simplexCount = ffi.types.i32 },
})
export type b2DistanceOutput = typeof(b2DistanceOutput:new({}))

local b2SimplexVertex = ffi.struct({
	{ wA = ffi.types.pointer },
	{ wB = ffi.types.pointer },
	{ w = ffi.types.pointer },
	{ a = ffi.types.float },
	{ indexA = ffi.types.i32 },
	{ indexB = ffi.types.i32 },
})
export type b2SimplexVertex = typeof(b2SimplexVertex:new({}))

local b2Simplex = ffi.struct({
	{ count = ffi.types.i32 },
})
export type b2Simplex = typeof(b2Simplex:new({}))

local b2ShapeCastPairInput = ffi.struct({
	{ proxyA = b2ShapeProxy },
	{ proxyB = b2ShapeProxy },
	{ transformA = ffi.types.pointer },
	{ transformB = ffi.types.pointer },
	{ translationB = ffi.types.pointer },
	{ maxFraction = ffi.types.float },
	{ canEncroach = ffi.types.u8 },
})
export type b2ShapeCastPairInput = typeof(b2ShapeCastPairInput:new({}))

local b2Sweep = ffi.struct({
	{ localCenter = ffi.types.pointer },
	{ c1 = ffi.types.pointer },
	{ c2 = ffi.types.pointer },
	{ q1 = ffi.types.pointer },
	{ q2 = ffi.types.pointer },
})
export type b2Sweep = typeof(b2Sweep:new({}))

local b2TOIInput = ffi.struct({
	{ proxyA = b2ShapeProxy },
	{ proxyB = b2ShapeProxy },
	{ sweepA = b2Sweep },
	{ sweepB = b2Sweep },
	{ maxFraction = ffi.types.float },
})
export type b2TOIInput = typeof(b2TOIInput:new({}))

local b2TOIOutput = ffi.struct({
	{ state = ffi.types.pointer },
	{ fraction = ffi.types.float },
})
export type b2TOIOutput = typeof(b2TOIOutput:new({}))

local b2ManifoldPoint = ffi.struct({
	{ point = ffi.types.pointer },
	{ anchorA = ffi.types.pointer },
	{ anchorB = ffi.types.pointer },
	{ separation = ffi.types.float },
	{ normalImpulse = ffi.types.float },
	{ tangentImpulse = ffi.types.float },
	{ totalNormalImpulse = ffi.types.float },
	{ normalVelocity = ffi.types.float },
	{ id = ffi.types.u16 },
	{ persisted = ffi.types.u8 },
})
export type b2ManifoldPoint = typeof(b2ManifoldPoint:new({}))

local b2Manifold = ffi.struct({
	{ normal = ffi.types.pointer },
	{ rollingImpulse = ffi.types.float },
	{ points = b2ManifoldPoint:array(2) },
	{ pointCount = ffi.types.i32 },
})
export type b2Manifold = typeof(b2Manifold:new({}))

local b2MotionLocks = ffi.struct({
	{ linearX = bool },
	{ linearY = bool },
	{ angularZ = bool },
})

local b2DynamicTree = ffi.struct({
	{ nodes = ffi.types.pointer },
	{ root = ffi.types.i32 },
	{ nodeCount = ffi.types.i32 },
	{ nodeCapacity = ffi.types.i32 },
	{ freeList = ffi.types.i32 },
	{ proxyCount = ffi.types.i32 },
	{ leafIndices = ffi.types.pointer },
	{ leafBoxes = ffi.types.pointer },
	{ leafCenters = ffi.types.pointer },
	{ binIndices = ffi.types.pointer },
	{ rebuildCapacity = ffi.types.i32 },
})
export type b2DynamicTree = typeof(b2DynamicTree:new({}))

local b2TreeStats = ffi.struct({
	{ nodeVisits = ffi.types.i32 },
	{ leafVisits = ffi.types.i32 },
})
export type b2TreeStats = typeof(b2TreeStats:new({}))

local b2PlaneResult = ffi.struct({
	{ plane = ffi.types.pointer },
	{ point = ffi.types.pointer },
	{ hit = ffi.types.u8 },
})
export type b2PlaneResult = typeof(b2PlaneResult:new({}))

local b2CollisionPlane = ffi.struct({
	{ plane = ffi.types.pointer },
	{ pushLimit = ffi.types.float },
	{ push = ffi.types.float },
	{ clipVelocity = ffi.types.u8 },
})
export type b2CollisionPlane = typeof(b2CollisionPlane:new({}))

local b2PlaneSolverResult = ffi.struct({
	{ translation = ffi.types.pointer },
	{ iterationCount = ffi.types.i32 },
})
export type b2PlaneSolverResult = typeof(b2PlaneSolverResult:new({}))

local b2WorldId = ffi.struct({
	{ index1 = ffi.types.u16 },
	{ generation = ffi.types.u16 },
})
export type b2WorldId = typeof(b2WorldId:new({}))

local b2BodyId = ffi.struct({
	{ index1 = ffi.types.i32 },
	{ world0 = ffi.types.u16 },
	{ generation = ffi.types.u16 },
})
export type b2BodyId = typeof(b2BodyId:new({}))

local b2ShapeId = ffi.struct({
	{ index1 = ffi.types.i32 },
	{ world0 = ffi.types.u16 },
	{ generation = ffi.types.u16 },
})
export type b2ShapeId = typeof(b2ShapeId:new({}))

local b2ChainId = ffi.struct({
	{ index1 = ffi.types.i32 },
	{ world0 = ffi.types.u16 },
	{ generation = ffi.types.u16 },
})
export type b2ChainId = typeof(b2ChainId:new({}))

local b2JointId = ffi.struct({
	{ index1 = ffi.types.i32 },
	{ world0 = ffi.types.u16 },
	{ generation = ffi.types.u16 },
})
export type b2JointId = typeof(b2JointId:new({}))

local b2CosSin = ffi.struct({
	{ cosine = ffi.types.float },
	{ sine = ffi.types.float },
})
export type b2CosSin = typeof(b2CosSin:new({}))

local b2Transform = ffi.struct({
	{ p = b2Vec2 },
	{ q = b2Rot },
})
export type b2Transform = typeof(b2Transform:new({}))

local b2AABB = ffi.struct({
	{ lowerBound = b2Vec2 },
	{ upperBound = b2Vec2 },
})
export type b2AABB = typeof(b2AABB:new({}))

local b2Plane = ffi.struct({
	{ normal = b2Vec2 },
	{ offset = ffi.types.float },
})
export type b2Plane = typeof(b2Plane:new({}))

local b2RayResult = ffi.struct({
	{ shapeId = ffi.types.pointer },
	{ point = ffi.types.pointer },
	{ normal = ffi.types.pointer },
	{ fraction = ffi.types.float },
	{ nodeVisits = ffi.types.i32 },
	{ leafVisits = ffi.types.i32 },
	{ hit = ffi.types.u8 },
})
export type b2RayResult = typeof(b2RayResult:new({}))

local b2WorldDef = ffi.struct({
	{ gravity = ffi.types.pointer },
	{ restitutionThreshold = ffi.types.float },
	{ hitEventThreshold = ffi.types.float },
	{ contactHertz = ffi.types.float },
	{ contactDampingRatio = ffi.types.float },
	{ contactSpeed = ffi.types.float },
	{ maxContactPushSpeed = ffi.types.float },
	{ maximumLinearSpeed = ffi.types.float },
	{ frictionCallback = ffi.types.pointer },
	{ restitutionCallback = ffi.types.pointer },
	{ enableSleep = ffi.types.u8 },
	{ enableContinuous = ffi.types.u8 },
	{ workerCount = ffi.types.i32 },
	{ enqueueTask = ffi.types.pointer },
	{ finishTask = ffi.types.pointer },
	{ userTaskContext = ffi.types.pointer },
	{ userData = ffi.types.pointer },
	{ internalValue = ffi.types.i32 },
})
export type b2WorldDef = typeof(b2WorldDef:new({}))

local b2BodyDef = ffi.struct({
	{ type = ffi.types.i32 },

	{ position = b2Vec2 },
	{ rotation = ffi.types.float },
	{ linearVelocity = b2Vec2 },

	{ angularVelocity = ffi.types.float },
	{ linearDamping = ffi.types.float },
	{ angularDamping = ffi.types.float },
	{ gravityScale = ffi.types.float },
	{ sleepThreshold = ffi.types.float },

	{ userData = ffi.types.pointer },
	{ motionLocks = b2MotionLocks },

	{ enableSleep = ffi.types.u8 },
	{ isAwake = ffi.types.u8 },
	{ fixedRotation = ffi.types.u8 },
	{ isBullet = ffi.types.u8 },
	{ isEnabled = ffi.types.u8 },
	{ allowFastRotation = ffi.types.u8 },

	{ internalValue = ffi.types.i32 },
})

export type b2BodyDef = typeof(b2BodyDef:new({}))

local b2Filter = ffi.struct({
	{ categoryBits = ffi.types.u64 },
	{ maskBits = ffi.types.u64 },
	{ groupIndex = ffi.types.i32 },
})
export type b2Filter = typeof(b2Filter:new({}))

local b2QueryFilter = ffi.struct({
	{ categoryBits = ffi.types.u64 },
	{ maskBits = ffi.types.u64 },
})
export type b2QueryFilter = typeof(b2QueryFilter:new({}))

local b2SurfaceMaterial = ffi.struct({
	{ friction = ffi.types.float },
	{ restitution = ffi.types.float },
	{ rollingResistance = ffi.types.float },
	{ tangentSpeed = ffi.types.float },
	{ userMaterialId = ffi.types.i32 },
	{ customColor = ffi.types.u32 },
})
export type b2SurfaceMaterial = typeof(b2SurfaceMaterial:new({}))

local b2ShapeDef = ffi.struct({
	{ userData = ffi.types.pointer },
	{ material = b2SurfaceMaterial },
	{ density = ffi.types.float },
	{ filter = b2Filter },
	{ isSensor = ffi.types.u8 },
	{ enableSensorEvents = ffi.types.u8 },
	{ enableContactEvents = ffi.types.u8 },
	{ enableHitEvents = ffi.types.u8 },
	{ enablePreSolveEvents = ffi.types.u8 },
	{ invokeContactCreation = ffi.types.u8 },
	{ updateBodyMass = ffi.types.u8 },
	{ internalValue = ffi.types.i32 },
})
export type b2ShapeDef = typeof(b2ShapeDef:new({}))

local b2ChainDef = ffi.struct({
	{ userData = ffi.types.pointer },
	{ points = ffi.types.pointer },
	{ count = ffi.types.i32 },
	{ materials = ffi.types.pointer },
	{ materialCount = ffi.types.i32 },
	{ filter = b2Filter },
	{ isLoop = ffi.types.u8 },
	{ enableSensorEvents = ffi.types.u8 },
	{ internalValue = ffi.types.i32 },
})
export type b2ChainDef = typeof(b2ChainDef:new({}))

local b2Profile = ffi.struct({
	{ step = ffi.types.float },
	{ pairs = ffi.types.float },
	{ collide = ffi.types.float },
	{ solve = ffi.types.float },
	{ mergeIslands = ffi.types.float },
	{ prepareStages = ffi.types.float },
	{ solveConstraints = ffi.types.float },
	{ prepareConstraints = ffi.types.float },
	{ integrateVelocities = ffi.types.float },
	{ warmStart = ffi.types.float },
	{ solveImpulses = ffi.types.float },
	{ integratePositions = ffi.types.float },
	{ relaxImpulses = ffi.types.float },
	{ applyRestitution = ffi.types.float },
	{ storeImpulses = ffi.types.float },
	{ splitIslands = ffi.types.float },
	{ transforms = ffi.types.float },
	{ hitEvents = ffi.types.float },
	{ refit = ffi.types.float },
	{ bullets = ffi.types.float },
	{ sleepIslands = ffi.types.float },
	{ sensors = ffi.types.float },
})
export type b2Profile = typeof(b2Profile:new({}))

local b2Counters = ffi.struct({
	{ bodyCount = ffi.types.i32 },
	{ shapeCount = ffi.types.i32 },
	{ contactCount = ffi.types.i32 },
	{ jointCount = ffi.types.i32 },
	{ islandCount = ffi.types.i32 },
	{ stackUsed = ffi.types.i32 },
	{ staticTreeHeight = ffi.types.i32 },
	{ treeHeight = ffi.types.i32 },
	{ byteCount = ffi.types.i32 },
	{ taskCount = ffi.types.i32 },
	{ colorCounts = ffi.types.i32:array(12) },
})
export type b2Counters = typeof(b2Counters:new({}))

local b2DistanceJointDef = ffi.struct({
	{ bodyIdA = ffi.types.pointer },
	{ bodyIdB = ffi.types.pointer },
	{ localAnchorA = ffi.types.pointer },
	{ localAnchorB = ffi.types.pointer },
	{ length = ffi.types.float },
	{ enableSpring = ffi.types.u8 },
	{ hertz = ffi.types.float },
	{ dampingRatio = ffi.types.float },
	{ enableLimit = ffi.types.u8 },
	{ minLength = ffi.types.float },
	{ maxLength = ffi.types.float },
	{ enableMotor = ffi.types.u8 },
	{ maxMotorForce = ffi.types.float },
	{ motorSpeed = ffi.types.float },
	{ collideConnected = ffi.types.u8 },
	{ userData = ffi.types.pointer },
	{ internalValue = ffi.types.i32 },
})
export type b2DistanceJointDef = typeof(b2DistanceJointDef:new({}))

local b2MotorJointDef = ffi.struct({
	{ bodyIdA = ffi.types.pointer },
	{ bodyIdB = ffi.types.pointer },
	{ linearOffset = ffi.types.pointer },
	{ angularOffset = ffi.types.float },
	{ maxForce = ffi.types.float },
	{ maxTorque = ffi.types.float },
	{ correctionFactor = ffi.types.float },
	{ collideConnected = ffi.types.u8 },
	{ userData = ffi.types.pointer },
	{ internalValue = ffi.types.i32 },
})
export type b2MotorJointDef = typeof(b2MotorJointDef:new({}))

local b2MouseJointDef = ffi.struct({
	{ bodyIdA = ffi.types.pointer },
	{ bodyIdB = ffi.types.pointer },
	{ target = ffi.types.pointer },
	{ hertz = ffi.types.float },
	{ dampingRatio = ffi.types.float },
	{ maxForce = ffi.types.float },
	{ collideConnected = ffi.types.u8 },
	{ userData = ffi.types.pointer },
	{ internalValue = ffi.types.i32 },
})
export type b2MouseJointDef = typeof(b2MouseJointDef:new({}))

local b2FilterJointDef = ffi.struct({
	{ bodyIdA = ffi.types.pointer },
	{ bodyIdB = ffi.types.pointer },
	{ userData = ffi.types.pointer },
	{ internalValue = ffi.types.i32 },
})
export type b2FilterJointDef = typeof(b2FilterJointDef:new({}))

local b2PrismaticJointDef = ffi.struct({
	{ bodyIdA = ffi.types.pointer },
	{ bodyIdB = ffi.types.pointer },
	{ localAnchorA = ffi.types.pointer },
	{ localAnchorB = ffi.types.pointer },
	{ localAxisA = ffi.types.pointer },
	{ referenceAngle = ffi.types.float },
	{ targetTranslation = ffi.types.float },
	{ enableSpring = ffi.types.u8 },
	{ hertz = ffi.types.float },
	{ dampingRatio = ffi.types.float },
	{ enableLimit = ffi.types.u8 },
	{ lowerTranslation = ffi.types.float },
	{ upperTranslation = ffi.types.float },
	{ enableMotor = ffi.types.u8 },
	{ maxMotorForce = ffi.types.float },
	{ motorSpeed = ffi.types.float },
	{ collideConnected = ffi.types.u8 },
	{ userData = ffi.types.pointer },
	{ internalValue = ffi.types.i32 },
})
export type b2PrismaticJointDef = typeof(b2PrismaticJointDef:new({}))

local b2RevoluteJointDef = ffi.struct({
	{ bodyIdA = ffi.types.pointer },
	{ bodyIdB = ffi.types.pointer },
	{ localAnchorA = ffi.types.pointer },
	{ localAnchorB = ffi.types.pointer },
	{ referenceAngle = ffi.types.float },
	{ targetAngle = ffi.types.float },
	{ enableSpring = ffi.types.u8 },
	{ hertz = ffi.types.float },
	{ dampingRatio = ffi.types.float },
	{ enableLimit = ffi.types.u8 },
	{ lowerAngle = ffi.types.float },
	{ upperAngle = ffi.types.float },
	{ enableMotor = ffi.types.u8 },
	{ maxMotorTorque = ffi.types.float },
	{ motorSpeed = ffi.types.float },
	{ drawSize = ffi.types.float },
	{ collideConnected = ffi.types.u8 },
	{ userData = ffi.types.pointer },
	{ internalValue = ffi.types.i32 },
})
export type b2RevoluteJointDef = typeof(b2RevoluteJointDef:new({}))

local b2WeldJointDef = ffi.struct({
	{ bodyIdA = ffi.types.pointer },
	{ bodyIdB = ffi.types.pointer },
	{ localAnchorA = ffi.types.pointer },
	{ localAnchorB = ffi.types.pointer },
	{ referenceAngle = ffi.types.float },
	{ linearHertz = ffi.types.float },
	{ angularHertz = ffi.types.float },
	{ linearDampingRatio = ffi.types.float },
	{ angularDampingRatio = ffi.types.float },
	{ collideConnected = ffi.types.u8 },
	{ userData = ffi.types.pointer },
	{ internalValue = ffi.types.i32 },
})
export type b2WeldJointDef = typeof(b2WeldJointDef:new({}))

local b2WheelJointDef = ffi.struct({
	{ bodyIdA = ffi.types.pointer },
	{ bodyIdB = ffi.types.pointer },
	{ localAnchorA = ffi.types.pointer },
	{ localAnchorB = ffi.types.pointer },
	{ localAxisA = ffi.types.pointer },
	{ enableSpring = ffi.types.u8 },
	{ hertz = ffi.types.float },
	{ dampingRatio = ffi.types.float },
	{ enableLimit = ffi.types.u8 },
	{ lowerTranslation = ffi.types.float },
	{ upperTranslation = ffi.types.float },
	{ enableMotor = ffi.types.u8 },
	{ maxMotorTorque = ffi.types.float },
	{ motorSpeed = ffi.types.float },
	{ collideConnected = ffi.types.u8 },
	{ userData = ffi.types.pointer },
	{ internalValue = ffi.types.i32 },
})
export type b2WheelJointDef = typeof(b2WheelJointDef:new({}))

local b2ExplosionDef = ffi.struct({
	{ maskBits = ffi.types.u64 },
	{ position = ffi.types.pointer },
	{ radius = ffi.types.float },
	{ falloff = ffi.types.float },
	{ impulsePerLength = ffi.types.float },
})
export type b2ExplosionDef = typeof(b2ExplosionDef:new({}))

local b2SensorBeginTouchEvent = ffi.struct({
	{ sensorShapeId = ffi.types.pointer },
	{ visitorShapeId = ffi.types.pointer },
})
export type b2SensorBeginTouchEvent = typeof(b2SensorBeginTouchEvent:new({}))

local b2SensorEndTouchEvent = ffi.struct({
	{ sensorShapeId = ffi.types.pointer },
	{ visitorShapeId = ffi.types.pointer },
})
export type b2SensorEndTouchEvent = typeof(b2SensorEndTouchEvent:new({}))

local b2SensorEvents = ffi.struct({
	{ beginEvents = ffi.types.pointer },
	{ endEvents = ffi.types.pointer },
	{ beginCount = ffi.types.i32 },
	{ endCount = ffi.types.i32 },
})
export type b2SensorEvents = typeof(b2SensorEvents:new({}))

local b2ContactBeginTouchEvent = ffi.struct({
	{ shapeIdA = ffi.types.pointer },
	{ shapeIdB = ffi.types.pointer },
	{ manifold = ffi.types.pointer },
})
export type b2ContactBeginTouchEvent = typeof(b2ContactBeginTouchEvent:new({}))

local b2ContactEndTouchEvent = ffi.struct({
	{ shapeIdA = ffi.types.pointer },
	{ shapeIdB = ffi.types.pointer },
})
export type b2ContactEndTouchEvent = typeof(b2ContactEndTouchEvent:new({}))

local b2ContactHitEvent = ffi.struct({
	{ shapeIdA = ffi.types.pointer },
	{ shapeIdB = ffi.types.pointer },
	{ point = ffi.types.pointer },
	{ normal = ffi.types.pointer },
	{ approachSpeed = ffi.types.float },
})
export type b2ContactHitEvent = typeof(b2ContactHitEvent:new({}))

local b2ContactEvents = ffi.struct({
	{ beginEvents = ffi.types.pointer },
	{ endEvents = ffi.types.pointer },
	{ hitEvents = ffi.types.pointer },
	{ beginCount = ffi.types.i32 },
	{ endCount = ffi.types.i32 },
	{ hitCount = ffi.types.i32 },
})
export type b2ContactEvents = typeof(b2ContactEvents:new({}))

local b2BodyMoveEvent = ffi.struct({
	{ transform = ffi.types.pointer },
	{ bodyId = ffi.types.pointer },
	{ userData = ffi.types.pointer },
	{ fellAsleep = ffi.types.u8 },
})
export type b2BodyMoveEvent = typeof(b2BodyMoveEvent:new({}))

local b2BodyEvents = ffi.struct({
	{ moveEvents = ffi.types.pointer },
	{ moveCount = ffi.types.i32 },
})
export type b2BodyEvents = typeof(b2BodyEvents:new({}))

local b2ContactData = ffi.struct({
	{ shapeIdA = ffi.types.pointer },
	{ shapeIdB = ffi.types.pointer },
	{ manifold = ffi.types.pointer },
})
export type b2ContactData = typeof(b2ContactData:new({}))

local b2DebugDraw = ffi.struct({
	{ drawingBounds = ffi.types.pointer },
	{ useDrawingBounds = ffi.types.u8 },
	{ drawShapes = ffi.types.u8 },
	{ drawJoints = ffi.types.u8 },
	{ drawJointExtras = ffi.types.u8 },
	{ drawBounds = ffi.types.u8 },
	{ drawMass = ffi.types.u8 },
	{ drawBodyNames = ffi.types.u8 },
	{ drawContacts = ffi.types.u8 },
	{ drawGraphColors = ffi.types.u8 },
	{ drawContactNormals = ffi.types.u8 },
	{ drawContactImpulses = ffi.types.u8 },
	{ drawContactFeatures = ffi.types.u8 },
	{ drawFrictionImpulses = ffi.types.u8 },
	{ drawIslands = ffi.types.u8 },
	{ context = ffi.types.pointer },
})
export type b2DebugDraw = typeof(b2DebugDraw:new({}))

-- Function definitions
local funcs = {
	b2SetAllocator = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	b2GetByteCount = { returns = ffi.types.i32, args = {} },
	b2SetAssertFcn = { returns = ffi.types.void, args = { ffi.types.pointer } },
	b2GetVersion = { returns = ffi.types.pointer, args = {} },
	b2GetTicks = { returns = ffi.types.u64, args = {} },
	b2GetMilliseconds = { returns = ffi.types.float, args = { ffi.types.u64 } },
	b2GetMillisecondsAndReset = { returns = ffi.types.float, args = { ffi.types.pointer } },
	b2Yield = { returns = ffi.types.void, args = {} },
	b2Hash = { returns = ffi.types.u32, args = { ffi.types.u32, ffi.types.pointer, ffi.types.i32 } },
	b2CreateWorld = { returns = b2WorldId, args = { ffi.types.pointer } },
	b2DestroyWorld = { returns = ffi.types.void, args = { b2WorldId } },
	b2World_IsValid = { returns = ffi.types.u8, args = { b2WorldId } },
	b2World_Step = { returns = ffi.types.void, args = { b2WorldId, ffi.types.float, ffi.types.i32 } },
	b2World_Draw = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	b2World_GetBodyEvents = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	b2World_GetSensorEvents = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	b2World_GetContactEvents = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	b2World_OverlapAABB = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	b2World_OverlapShape = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	b2World_CastRay = {
		returns = ffi.types.pointer,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
		},
	},
	b2World_CastRayClosest = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	b2World_CastShape = {
		returns = ffi.types.pointer,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
		},
	},
	b2World_CastMover = {
		returns = ffi.types.float,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	b2World_CollideMover = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	b2World_EnableSleeping = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u8 } },
	b2World_IsSleepingEnabled = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	b2World_EnableContinuous = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u8 } },
	b2World_IsContinuousEnabled = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	b2World_SetRestitutionThreshold = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	b2World_GetRestitutionThreshold = { returns = ffi.types.float, args = { ffi.types.pointer } },
	b2World_SetHitEventThreshold = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	b2World_GetHitEventThreshold = { returns = ffi.types.float, args = { ffi.types.pointer } },
	b2World_SetCustomFilterCallback = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	b2World_SetPreSolveCallback = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	b2World_SetGravity = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	b2World_GetGravity = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	b2World_Explode = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	b2World_SetContactTuning = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.float, ffi.types.float },
	},
	b2World_SetMaximumLinearSpeed = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	b2World_GetMaximumLinearSpeed = { returns = ffi.types.float, args = { ffi.types.pointer } },
	b2World_EnableWarmStarting = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u8 } },
	b2World_IsWarmStartingEnabled = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	b2World_GetAwakeBodyCount = { returns = ffi.types.i32, args = { ffi.types.pointer } },
	b2World_GetProfile = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	b2World_GetCounters = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	b2World_SetUserData = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	b2World_GetUserData = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	b2World_SetFrictionCallback = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	b2World_SetRestitutionCallback = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	b2World_DumpMemoryStats = { returns = ffi.types.void, args = { ffi.types.pointer } },
	b2World_RebuildStaticTree = { returns = ffi.types.void, args = { ffi.types.pointer } },
	b2World_EnableSpeculative = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u8 } },
	b2CreateBody = { returns = b2BodyId, args = { b2WorldId, ffi.types.pointer } },
	b2DestroyBody = { returns = ffi.types.void, args = { ffi.types.pointer } },
	b2Body_IsValid = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	b2Body_GetType = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	b2Body_SetType = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	b2Body_SetName = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	b2Body_GetName = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	b2Body_SetUserData = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	b2Body_GetUserData = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	b2Body_GetPosition = { returns = b2Vec2, args = { b2BodyId } },
	b2Body_GetRotation = { returns = b2Rot, args = { b2BodyId } },
	b2Body_GetTransform = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	b2Body_SetTransform = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	b2Body_GetLocalPoint = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	b2Body_GetWorldPoint = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	b2Body_GetLocalVector = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	b2Body_GetWorldVector = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	b2Body_GetLinearVelocity = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	b2Body_GetAngularVelocity = { returns = ffi.types.float, args = { ffi.types.pointer } },
	b2Body_SetLinearVelocity = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	b2Body_SetAngularVelocity = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	b2Body_SetTargetTransform = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.float },
	},
	b2Body_GetLocalPointVelocity = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	b2Body_GetWorldPointVelocity = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	b2Body_ApplyForce = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.u8 },
	},
	b2Body_ApplyForceToCenter = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u8 },
	},
	b2Body_ApplyTorque = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float, ffi.types.u8 } },
	b2Body_ApplyLinearImpulse = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.u8 },
	},
	b2Body_ApplyLinearImpulseToCenter = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u8 },
	},
	b2Body_ApplyAngularImpulse = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.u8 },
	},
	b2Body_GetMass = { returns = ffi.types.float, args = { ffi.types.pointer } },
	b2Body_GetRotationalInertia = { returns = ffi.types.float, args = { ffi.types.pointer } },
	b2Body_GetLocalCenterOfMass = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	b2Body_GetWorldCenterOfMass = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	b2Body_SetMassData = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	b2Body_GetMassData = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	b2Body_ApplyMassFromShapes = { returns = ffi.types.void, args = { ffi.types.pointer } },
	b2Body_SetLinearDamping = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	b2Body_GetLinearDamping = { returns = ffi.types.float, args = { ffi.types.pointer } },
	b2Body_SetAngularDamping = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	b2Body_GetAngularDamping = { returns = ffi.types.float, args = { ffi.types.pointer } },
	b2Body_SetGravityScale = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	b2Body_GetGravityScale = { returns = ffi.types.float, args = { ffi.types.pointer } },
	b2Body_IsAwake = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	b2Body_SetAwake = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u8 } },
	b2Body_EnableSleep = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u8 } },
	b2Body_IsSleepEnabled = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	b2Body_SetSleepThreshold = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	b2Body_GetSleepThreshold = { returns = ffi.types.float, args = { ffi.types.pointer } },
	b2Body_IsEnabled = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	b2Body_Disable = { returns = ffi.types.void, args = { ffi.types.pointer } },
	b2Body_Enable = { returns = ffi.types.void, args = { ffi.types.pointer } },
	b2Body_SetFixedRotation = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u8 } },
	b2Body_IsFixedRotation = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	b2Body_SetBullet = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u8 } },
	b2Body_IsBullet = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	b2Body_EnableContactEvents = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u8 } },
	b2Body_EnableHitEvents = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u8 } },
	b2Body_GetWorld = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	b2Body_GetShapeCount = { returns = ffi.types.i32, args = { ffi.types.pointer } },
	b2Body_GetShapes = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32 } },
	b2Body_GetJointCount = { returns = ffi.types.i32, args = { ffi.types.pointer } },
	b2Body_GetJoints = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32 } },
	b2Body_GetContactCapacity = { returns = ffi.types.i32, args = { ffi.types.pointer } },
	b2Body_GetContactData = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32 } },
	b2Body_ComputeAABB = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	b2CreateCircleShape = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	b2CreateSegmentShape = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	b2CreateCapsuleShape = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	b2CreatePolygonShape = {
		returns = b2ShapeId,
		args = { b2BodyId, ffi.types.pointer, ffi.types.pointer },
	},
	b2DestroyShape = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u8 } },
	b2Shape_IsValid = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	b2Shape_GetType = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	b2Shape_GetBody = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	b2Shape_GetWorld = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	b2Shape_IsSensor = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	b2Shape_SetUserData = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	b2Shape_GetUserData = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	b2Shape_SetDensity = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float, ffi.types.u8 } },
	b2Shape_GetDensity = { returns = ffi.types.float, args = { ffi.types.pointer } },
	b2Shape_SetFriction = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	b2Shape_GetFriction = { returns = ffi.types.float, args = { ffi.types.pointer } },
	b2Shape_SetRestitution = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	b2Shape_GetRestitution = { returns = ffi.types.float, args = { ffi.types.pointer } },
	b2Shape_SetMaterial = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.i32 } },
	b2Shape_GetMaterial = { returns = ffi.types.i32, args = { ffi.types.pointer } },
	b2Shape_SetSurfaceMaterial = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	b2Shape_GetSurfaceMaterial = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	b2Shape_GetFilter = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	b2Shape_SetFilter = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	b2Shape_EnableSensorEvents = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u8 } },
	b2Shape_AreSensorEventsEnabled = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	b2Shape_EnableContactEvents = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u8 } },
	b2Shape_AreContactEventsEnabled = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	b2Shape_EnablePreSolveEvents = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u8 } },
	b2Shape_ArePreSolveEventsEnabled = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	b2Shape_EnableHitEvents = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u8 } },
	b2Shape_AreHitEventsEnabled = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	b2Shape_TestPoint = { returns = ffi.types.u8, args = { ffi.types.pointer, ffi.types.pointer } },
	b2Shape_RayCast = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	b2Shape_GetCircle = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	b2Shape_GetSegment = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	b2Shape_GetChainSegment = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	b2Shape_GetCapsule = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	b2Shape_GetPolygon = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	b2Shape_SetCircle = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	b2Shape_SetCapsule = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	b2Shape_SetSegment = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	b2Shape_SetPolygon = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	b2Shape_GetParentChain = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	b2Shape_GetContactCapacity = { returns = ffi.types.i32, args = { ffi.types.pointer } },
	b2Shape_GetContactData = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32 } },
	b2Shape_GetSensorCapacity = { returns = ffi.types.i32, args = { ffi.types.pointer } },
	b2Shape_GetSensorOverlaps = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32 },
	},
	b2Shape_GetAABB = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	b2Shape_GetMassData = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	b2Shape_GetClosestPoint = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	b2CreateChain = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	b2DestroyChain = { returns = ffi.types.void, args = { ffi.types.pointer } },
	b2Chain_GetWorld = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	b2Chain_GetSegmentCount = { returns = ffi.types.i32, args = { ffi.types.pointer } },
	b2Chain_GetSegments = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32 } },
	b2Chain_SetFriction = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	b2Chain_GetFriction = { returns = ffi.types.float, args = { ffi.types.pointer } },
	b2Chain_SetRestitution = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	b2Chain_GetRestitution = { returns = ffi.types.float, args = { ffi.types.pointer } },
	b2Chain_SetMaterial = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.i32 } },
	b2Chain_GetMaterial = { returns = ffi.types.i32, args = { ffi.types.pointer } },
	b2Chain_IsValid = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	b2DestroyJoint = { returns = ffi.types.void, args = { ffi.types.pointer } },
	b2Joint_IsValid = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	b2Joint_GetType = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	b2Joint_GetBodyA = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	b2Joint_GetBodyB = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	b2Joint_GetWorld = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	b2Joint_SetLocalAnchorA = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	b2Joint_GetLocalAnchorA = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	b2Joint_SetLocalAnchorB = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	b2Joint_GetLocalAnchorB = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	b2Joint_GetReferenceAngle = { returns = ffi.types.float, args = { ffi.types.pointer } },
	b2Joint_SetReferenceAngle = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	b2Joint_SetLocalAxisA = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	b2Joint_GetLocalAxisA = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	b2Joint_SetCollideConnected = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u8 } },
	b2Joint_GetCollideConnected = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	b2Joint_SetUserData = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	b2Joint_GetUserData = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	b2Joint_WakeBodies = { returns = ffi.types.void, args = { ffi.types.pointer } },
	b2Joint_GetConstraintForce = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	b2Joint_GetConstraintTorque = { returns = ffi.types.float, args = { ffi.types.pointer } },
	b2Joint_GetLinearSeparation = { returns = ffi.types.float, args = { ffi.types.pointer } },
	b2Joint_GetAngularSeparation = { returns = ffi.types.float, args = { ffi.types.pointer } },
	b2Joint_GetConstraintTuning = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	b2Joint_SetConstraintTuning = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.float },
	},
	b2CreateDistanceJoint = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	b2DistanceJoint_SetLength = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	b2DistanceJoint_GetLength = { returns = ffi.types.float, args = { ffi.types.pointer } },
	b2DistanceJoint_EnableSpring = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u8 } },
	b2DistanceJoint_IsSpringEnabled = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	b2DistanceJoint_SetSpringHertz = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	b2DistanceJoint_SetSpringDampingRatio = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	b2DistanceJoint_GetSpringHertz = { returns = ffi.types.float, args = { ffi.types.pointer } },
	b2DistanceJoint_GetSpringDampingRatio = { returns = ffi.types.float, args = { ffi.types.pointer } },
	b2DistanceJoint_EnableLimit = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u8 } },
	b2DistanceJoint_IsLimitEnabled = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	b2DistanceJoint_SetLengthRange = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.float },
	},
	b2DistanceJoint_GetMinLength = { returns = ffi.types.float, args = { ffi.types.pointer } },
	b2DistanceJoint_GetMaxLength = { returns = ffi.types.float, args = { ffi.types.pointer } },
	b2DistanceJoint_GetCurrentLength = { returns = ffi.types.float, args = { ffi.types.pointer } },
	b2DistanceJoint_EnableMotor = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u8 } },
	b2DistanceJoint_IsMotorEnabled = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	b2DistanceJoint_SetMotorSpeed = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	b2DistanceJoint_GetMotorSpeed = { returns = ffi.types.float, args = { ffi.types.pointer } },
	b2DistanceJoint_SetMaxMotorForce = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	b2DistanceJoint_GetMaxMotorForce = { returns = ffi.types.float, args = { ffi.types.pointer } },
	b2DistanceJoint_GetMotorForce = { returns = ffi.types.float, args = { ffi.types.pointer } },
	b2CreateMotorJoint = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	b2MotorJoint_SetLinearOffset = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	b2MotorJoint_GetLinearOffset = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	b2MotorJoint_SetAngularOffset = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	b2MotorJoint_GetAngularOffset = { returns = ffi.types.float, args = { ffi.types.pointer } },
	b2MotorJoint_SetMaxForce = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	b2MotorJoint_GetMaxForce = { returns = ffi.types.float, args = { ffi.types.pointer } },
	b2MotorJoint_SetMaxTorque = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	b2MotorJoint_GetMaxTorque = { returns = ffi.types.float, args = { ffi.types.pointer } },
	b2MotorJoint_SetCorrectionFactor = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	b2MotorJoint_GetCorrectionFactor = { returns = ffi.types.float, args = { ffi.types.pointer } },
	b2CreateMouseJoint = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	b2MouseJoint_SetTarget = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	b2MouseJoint_GetTarget = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	b2MouseJoint_SetSpringHertz = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	b2MouseJoint_GetSpringHertz = { returns = ffi.types.float, args = { ffi.types.pointer } },
	b2MouseJoint_SetSpringDampingRatio = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	b2MouseJoint_GetSpringDampingRatio = { returns = ffi.types.float, args = { ffi.types.pointer } },
	b2MouseJoint_SetMaxForce = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	b2MouseJoint_GetMaxForce = { returns = ffi.types.float, args = { ffi.types.pointer } },
	b2CreateFilterJoint = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	b2CreatePrismaticJoint = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	b2PrismaticJoint_EnableSpring = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u8 } },
	b2PrismaticJoint_IsSpringEnabled = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	b2PrismaticJoint_SetSpringHertz = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	b2PrismaticJoint_GetSpringHertz = { returns = ffi.types.float, args = { ffi.types.pointer } },
	b2PrismaticJoint_SetSpringDampingRatio = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	b2PrismaticJoint_GetSpringDampingRatio = { returns = ffi.types.float, args = { ffi.types.pointer } },
	b2PrismaticJoint_SetTargetTranslation = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	b2PrismaticJoint_GetTargetTranslation = { returns = ffi.types.float, args = { ffi.types.pointer } },
	b2PrismaticJoint_EnableLimit = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u8 } },
	b2PrismaticJoint_IsLimitEnabled = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	b2PrismaticJoint_GetLowerLimit = { returns = ffi.types.float, args = { ffi.types.pointer } },
	b2PrismaticJoint_GetUpperLimit = { returns = ffi.types.float, args = { ffi.types.pointer } },
	b2PrismaticJoint_SetLimits = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.float },
	},
	b2PrismaticJoint_EnableMotor = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u8 } },
	b2PrismaticJoint_IsMotorEnabled = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	b2PrismaticJoint_SetMotorSpeed = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	b2PrismaticJoint_GetMotorSpeed = { returns = ffi.types.float, args = { ffi.types.pointer } },
	b2PrismaticJoint_SetMaxMotorForce = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	b2PrismaticJoint_GetMaxMotorForce = { returns = ffi.types.float, args = { ffi.types.pointer } },
	b2PrismaticJoint_GetMotorForce = { returns = ffi.types.float, args = { ffi.types.pointer } },
	b2PrismaticJoint_GetTranslation = { returns = ffi.types.float, args = { ffi.types.pointer } },
	b2PrismaticJoint_GetSpeed = { returns = ffi.types.float, args = { ffi.types.pointer } },
	b2CreateRevoluteJoint = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	b2RevoluteJoint_EnableSpring = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u8 } },
	b2RevoluteJoint_IsSpringEnabled = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	b2RevoluteJoint_SetSpringHertz = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	b2RevoluteJoint_GetSpringHertz = { returns = ffi.types.float, args = { ffi.types.pointer } },
	b2RevoluteJoint_SetSpringDampingRatio = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	b2RevoluteJoint_GetSpringDampingRatio = { returns = ffi.types.float, args = { ffi.types.pointer } },
	b2RevoluteJoint_SetTargetAngle = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	b2RevoluteJoint_GetTargetAngle = { returns = ffi.types.float, args = { ffi.types.pointer } },
	b2RevoluteJoint_GetAngle = { returns = ffi.types.float, args = { ffi.types.pointer } },
	b2RevoluteJoint_EnableLimit = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u8 } },
	b2RevoluteJoint_IsLimitEnabled = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	b2RevoluteJoint_GetLowerLimit = { returns = ffi.types.float, args = { ffi.types.pointer } },
	b2RevoluteJoint_GetUpperLimit = { returns = ffi.types.float, args = { ffi.types.pointer } },
	b2RevoluteJoint_SetLimits = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.float },
	},
	b2RevoluteJoint_EnableMotor = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u8 } },
	b2RevoluteJoint_IsMotorEnabled = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	b2RevoluteJoint_SetMotorSpeed = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	b2RevoluteJoint_GetMotorSpeed = { returns = ffi.types.float, args = { ffi.types.pointer } },
	b2RevoluteJoint_GetMotorTorque = { returns = ffi.types.float, args = { ffi.types.pointer } },
	b2RevoluteJoint_SetMaxMotorTorque = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	b2RevoluteJoint_GetMaxMotorTorque = { returns = ffi.types.float, args = { ffi.types.pointer } },
	b2CreateWeldJoint = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	b2WeldJoint_SetLinearHertz = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	b2WeldJoint_GetLinearHertz = { returns = ffi.types.float, args = { ffi.types.pointer } },
	b2WeldJoint_SetLinearDampingRatio = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	b2WeldJoint_GetLinearDampingRatio = { returns = ffi.types.float, args = { ffi.types.pointer } },
	b2WeldJoint_SetAngularHertz = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	b2WeldJoint_GetAngularHertz = { returns = ffi.types.float, args = { ffi.types.pointer } },
	b2WeldJoint_SetAngularDampingRatio = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	b2WeldJoint_GetAngularDampingRatio = { returns = ffi.types.float, args = { ffi.types.pointer } },
	b2CreateWheelJoint = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	b2WheelJoint_EnableSpring = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u8 } },
	b2WheelJoint_IsSpringEnabled = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	b2WheelJoint_SetSpringHertz = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	b2WheelJoint_GetSpringHertz = { returns = ffi.types.float, args = { ffi.types.pointer } },
	b2WheelJoint_SetSpringDampingRatio = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	b2WheelJoint_GetSpringDampingRatio = { returns = ffi.types.float, args = { ffi.types.pointer } },
	b2WheelJoint_EnableLimit = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u8 } },
	b2WheelJoint_IsLimitEnabled = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	b2WheelJoint_GetLowerLimit = { returns = ffi.types.float, args = { ffi.types.pointer } },
	b2WheelJoint_GetUpperLimit = { returns = ffi.types.float, args = { ffi.types.pointer } },
	b2WheelJoint_SetLimits = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.float },
	},
	b2WheelJoint_EnableMotor = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u8 } },
	b2WheelJoint_IsMotorEnabled = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	b2WheelJoint_SetMotorSpeed = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	b2WheelJoint_GetMotorSpeed = { returns = ffi.types.float, args = { ffi.types.pointer } },
	b2WheelJoint_SetMaxMotorTorque = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	b2WheelJoint_GetMaxMotorTorque = { returns = ffi.types.float, args = { ffi.types.pointer } },
	b2WheelJoint_GetMotorTorque = { returns = ffi.types.float, args = { ffi.types.pointer } },
	b2IsValidRay = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	b2MakePolygon = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.float } },
	b2MakeOffsetPolygon = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	b2MakeOffsetRoundedPolygon = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.float },
	},
	b2MakeSquare = { returns = ffi.types.pointer, args = { ffi.types.float } },
	b2MakeBox = { returns = b2Polygon, args = { ffi.types.float, ffi.types.float } },
	b2MakeRoundedBox = { returns = ffi.types.pointer, args = { ffi.types.float, ffi.types.float, ffi.types.float } },

	b2MakeOffsetBox = {
		returns = ffi.types.pointer,
		args = { ffi.types.float, ffi.types.float, ffi.types.pointer, ffi.types.pointer },
	},
	b2MakeOffsetRoundedBox = {
		returns = ffi.types.pointer,
		args = { ffi.types.float, ffi.types.float, ffi.types.pointer, ffi.types.pointer, ffi.types.float },
	},
	b2TransformPolygon = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	b2ComputeCircleMass = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.float } },
	b2ComputeCapsuleMass = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.float } },
	b2ComputePolygonMass = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.float } },
	b2ComputeCircleAABB = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	b2ComputeCapsuleAABB = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	b2ComputePolygonAABB = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	b2ComputeSegmentAABB = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	b2PointInCircle = { returns = ffi.types.u8, args = { ffi.types.pointer, ffi.types.pointer } },
	b2PointInCapsule = { returns = ffi.types.u8, args = { ffi.types.pointer, ffi.types.pointer } },
	b2PointInPolygon = { returns = ffi.types.u8, args = { ffi.types.pointer, ffi.types.pointer } },
	b2RayCastCircle = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	b2RayCastCapsule = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	b2RayCastSegment = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u8 } },
	b2RayCastPolygon = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	b2ShapeCastCircle = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	b2ShapeCastCapsule = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	b2ShapeCastSegment = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	b2ShapeCastPolygon = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	b2ComputeHull = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.i32 } },
	b2ValidateHull = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	b2SegmentDistance = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	b2ShapeDistance = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.i32 },
	},
	b2ShapeCast = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	b2MakeProxy = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.i32, ffi.types.float } },
	b2MakeOffsetProxy = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.float, ffi.types.pointer, ffi.types.pointer },
	},
	b2GetSweepTransform = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.float } },
	b2TimeOfImpact = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	b2CollideCircles = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	b2CollideCapsuleAndCircle = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	b2CollideSegmentAndCircle = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	b2CollidePolygonAndCircle = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	b2CollideCapsules = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	b2CollideSegmentAndCapsule = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	b2CollidePolygonAndCapsule = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	b2CollidePolygons = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	b2CollideSegmentAndPolygon = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	b2CollideChainSegmentAndCircle = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	b2CollideChainSegmentAndCapsule = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	b2CollideChainSegmentAndPolygon = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	b2DynamicTree_Create = { returns = ffi.types.pointer, args = {} },
	b2DynamicTree_Destroy = { returns = ffi.types.void, args = { ffi.types.pointer } },
	b2DynamicTree_CreateProxy = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u64, ffi.types.u64 },
	},
	b2DynamicTree_DestroyProxy = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.i32 } },
	b2DynamicTree_MoveProxy = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.pointer },
	},
	b2DynamicTree_EnlargeProxy = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.pointer },
	},
	b2DynamicTree_SetCategoryBits = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.u64 },
	},
	b2DynamicTree_GetCategoryBits = { returns = ffi.types.u64, args = { ffi.types.pointer, ffi.types.i32 } },
	b2DynamicTree_Query = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u64, ffi.types.pointer, ffi.types.pointer },
	},
	b2DynamicTree_RayCast = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u64, ffi.types.pointer, ffi.types.pointer },
	},
	b2DynamicTree_ShapeCast = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u64, ffi.types.pointer, ffi.types.pointer },
	},
	b2DynamicTree_GetHeight = { returns = ffi.types.i32, args = { ffi.types.pointer } },
	b2DynamicTree_GetAreaRatio = { returns = ffi.types.float, args = { ffi.types.pointer } },
	b2DynamicTree_GetRootBounds = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	b2DynamicTree_GetProxyCount = { returns = ffi.types.i32, args = { ffi.types.pointer } },
	b2DynamicTree_Rebuild = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.u8 } },
	b2DynamicTree_GetByteCount = { returns = ffi.types.i32, args = { ffi.types.pointer } },
	b2DynamicTree_GetUserData = { returns = ffi.types.u64, args = { ffi.types.pointer, ffi.types.i32 } },
	b2DynamicTree_GetAABB = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.i32 } },
	b2DynamicTree_Validate = { returns = ffi.types.void, args = { ffi.types.pointer } },
	b2DynamicTree_ValidateNoEnlarged = { returns = ffi.types.void, args = { ffi.types.pointer } },
	b2SolvePlanes = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32 } },
	b2ClipVector = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32 } },
	b2IsValidFloat = { returns = ffi.types.u8, args = { ffi.types.float } },
	b2IsValidVec2 = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	b2IsValidRotation = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	b2IsValidAABB = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	b2IsValidPlane = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	b2Atan2 = { returns = ffi.types.float, args = { ffi.types.float, ffi.types.float } },
	b2ComputeCosSin = { returns = ffi.types.pointer, args = { ffi.types.float } },
	b2ComputeRotationBetweenUnitVectors = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	b2SetLengthUnitsPerMeter = { returns = ffi.types.void, args = { ffi.types.float } },
	b2GetLengthUnitsPerMeter = { returns = ffi.types.float, args = {} },
	b2DefaultWorldDef = { returns = b2WorldDef, args = {} },
	b2DefaultBodyDef = { returns = b2BodyDef, args = {} },
	b2DefaultFilter = { returns = b2Filter, args = {} },
	b2DefaultQueryFilter = { returns = b2QueryFilter, args = {} },
	b2DefaultSurfaceMaterial = { returns = b2SurfaceMaterial, args = {} },
	b2DefaultShapeDef = { returns = b2ShapeDef, args = {} },
	b2DefaultChainDef = { returns = b2ChainDef, args = {} },
	b2DefaultDistanceJointDef = { returns = b2DistanceJointDef, args = {} },
	b2DefaultMotorJointDef = { returns = b2MotorJointDef, args = {} },
	b2DefaultMouseJointDef = { returns = b2MouseJointDef, args = {} },
	b2DefaultFilterJointDef = { returns = b2FilterJointDef, args = {} },
	b2DefaultPrismaticJointDef = { returns = b2PrismaticJointDef, args = {} },
	b2DefaultRevoluteJointDef = { returns = b2RevoluteJointDef, args = {} },
	b2DefaultWeldJointDef = { returns = b2WeldJointDef, args = {} },
	b2DefaultWheelJointDef = { returns = b2WheelJointDef, args = {} },
	b2DefaultExplosionDef = { returns = b2ExplosionDef, args = {} },
	b2DefaultDebugDraw = { returns = b2DebugDraw, args = {} },
}

local structs = {
	b2Version = b2Version,
	b2RayCastInput = b2RayCastInput,
	b2ShapeProxy = b2ShapeProxy,
	b2ShapeCastInput = b2ShapeCastInput,
	b2CastOutput = b2CastOutput,
	b2MassData = b2MassData,
	b2Circle = b2Circle,
	b2Capsule = b2Capsule,
	b2Rot = b2Rot,
	b2Polygon = b2Polygon,
	b2Segment = b2Segment,
	b2ChainSegment = b2ChainSegment,
	b2Hull = b2Hull,
	b2SegmentDistanceResult = b2SegmentDistanceResult,
	b2SimplexCache = b2SimplexCache,
	b2DistanceInput = b2DistanceInput,
	b2DistanceOutput = b2DistanceOutput,
	b2SimplexVertex = b2SimplexVertex,
	b2Simplex = b2Simplex,
	b2ShapeCastPairInput = b2ShapeCastPairInput,
	b2Sweep = b2Sweep,
	b2TOIInput = b2TOIInput,
	b2TOIOutput = b2TOIOutput,
	b2Vec2 = b2Vec2,
	b2ManifoldPoint = b2ManifoldPoint,
	b2Manifold = b2Manifold,
	b2DynamicTree = b2DynamicTree,
	b2TreeStats = b2TreeStats,
	b2PlaneResult = b2PlaneResult,
	b2CollisionPlane = b2CollisionPlane,
	b2PlaneSolverResult = b2PlaneSolverResult,
	b2WorldId = b2WorldId,
	b2BodyId = b2BodyId,
	b2ShapeId = b2ShapeId,
	b2ChainId = b2ChainId,
	b2JointId = b2JointId,
	b2CosSin = b2CosSin,
	b2Transform = b2Transform,
	b2AABB = b2AABB,
	b2Plane = b2Plane,
	b2RayResult = b2RayResult,
	b2WorldDef = b2WorldDef,
	b2BodyDef = b2BodyDef,
	b2Filter = b2Filter,
	b2QueryFilter = b2QueryFilter,
	b2SurfaceMaterial = b2SurfaceMaterial,
	b2ShapeDef = b2ShapeDef,
	b2ChainDef = b2ChainDef,
	b2Profile = b2Profile,
	b2Counters = b2Counters,
	b2DistanceJointDef = b2DistanceJointDef,
	b2MotorJointDef = b2MotorJointDef,
	b2MouseJointDef = b2MouseJointDef,
	b2FilterJointDef = b2FilterJointDef,
	b2PrismaticJointDef = b2PrismaticJointDef,
	b2MotionLocks = b2MotionLocks,
	b2RevoluteJointDef = b2RevoluteJointDef,
	b2WeldJointDef = b2WeldJointDef,
	b2WheelJointDef = b2WheelJointDef,
	b2ExplosionDef = b2ExplosionDef,
	b2SensorBeginTouchEvent = b2SensorBeginTouchEvent,
	b2SensorEndTouchEvent = b2SensorEndTouchEvent,
	b2SensorEvents = b2SensorEvents,
	b2ContactBeginTouchEvent = b2ContactBeginTouchEvent,
	b2ContactEndTouchEvent = b2ContactEndTouchEvent,
	b2ContactHitEvent = b2ContactHitEvent,
	b2ContactEvents = b2ContactEvents,
	b2BodyMoveEvent = b2BodyMoveEvent,
	b2BodyEvents = b2BodyEvents,
	b2ContactData = b2ContactData,
	b2DebugDraw = b2DebugDraw,
}

return { funcs = funcs, structs = structs }
