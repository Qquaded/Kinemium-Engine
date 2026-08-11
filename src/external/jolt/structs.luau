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

local JPH_Body = ffi.types.pointer
local JPH_BodyID = ffi.types.u32
local JPH_Shape = ffi.types.pointer
local JPH_ShapeSettings = ffi.types.pointer
local JPH_BodyLockInterface = ffi.types.pointer
local JPH_BroadPhaseLayerInterface = ffi.types.pointer
local JPH_ObjectLayerPairFilter = ffi.types.pointer
local JPH_ObjectVsBroadPhaseLayerFilter = ffi.types.pointer
local JPH_SharedMutex = ffi.types.pointer
local JPH_PhysicsMaterial = ffi.types.pointer
local JPH_CharacterVirtual = ffi.types.pointer
local JPH_Character = ffi.types.pointer
local JPH_LinearCurve = ffi.types.pointer
local JPH_WheelSettings = ffi.types.pointer
local JPH_VehicleControllerSettings = ffi.types.pointer
local JPH_QueueJobCallback = ffi.types.pointer
local JPH_QueueJobsCallback = ffi.types.pointer
local JPH_GroupFilter = ffi.types.pointer
local JPH_PhysicsSystem = ffi.types.pointer
local JPH_SoftBodySharedSettings = ffi.types.pointer

local JPH_Vec3 = ffi.struct({
	{ x = float },
	{ y = float },
	{ z = float },
})
export type JPH_Vec3 = typeof(JPH_Vec3:new({}))

local JPH_Vec4 = ffi.struct({
	{ x = float },
	{ y = float },
	{ z = float },
	{ w = float },
})
export type JPH_Vec4 = typeof(JPH_Vec4:new({}))

-- JPH_CollideSettingsBase (base struct)
local JPH_CollideSettingsBase = ffi.struct({
	{ activeEdgeMode = ffi.types.u32 },
	{ collectFacesMode = ffi.types.u32 },
	{ collisionTolerance = float },
	{ penetrationTolerance = float },
	{ activeEdgeMovementDirection = JPH_Vec3 },
})
export type JPH_CollideSettingsBase = typeof(JPH_CollideSettingsBase:new({}))

-- JPH_RayCastSettings
local JPH_RayCastSettings = ffi.struct({
	{ backFaceModeTriangles = ffi.types.u32 },
	{ backFaceModeConvex = ffi.types.u32 },
	{ treatConvexAsSolid = bool },
})
export type JPH_RayCastSettings = typeof(JPH_RayCastSettings:new({}))

local JPH_Quat = ffi.struct({
	{ x = float },
	{ y = float },
	{ z = float },
	{ w = float },
})
export type JPH_Quat = typeof(JPH_Quat:new({}))

local JPH_Mat4 = ffi.struct({
	{ column = JPH_Vec4:array(4) },
})
export type JPH_Mat4 = typeof(JPH_Mat4:new({}))

local JPH_RVec3 = ffi.struct({
	{ x = double },
	{ y = double },
	{ z = double },
})
export type JPH_RVec3 = typeof(JPH_RVec3:new({}))

local JPH_RMat4 = ffi.struct({
	{ column = JPH_Vec4:array(3) }, -- still float columns
	{ column3 = JPH_RVec3 }, -- now double
})
export type JPH_RMat4 = typeof(JPH_RMat4:new({}))

local JPH_Plane = ffi.struct({
	{ normal = JPH_Vec3 },
	{ distance = float },
})
export type JPH_Plane = typeof(JPH_Plane:new({}))

local JPH_AABox = ffi.struct({
	{ min = JPH_Vec3 },
	{ max = JPH_Vec3 },
})
export type JPH_AABox = typeof(JPH_AABox:new({}))

local JPH_Point = ffi.struct({
	{ x = float },
	{ y = float },
})
export type JPH_Point = typeof(JPH_Point:new({}))

local JPH_Triangle = ffi.struct({
	{ v1 = JPH_Vec3 },
	{ v2 = JPH_Vec3 },
	{ v3 = JPH_Vec3 },
	{ materialIndex = ffi.types.u32 },
})
export type JPH_Triangle = typeof(JPH_Triangle:new({}))

local JPH_IndexedTriangle = ffi.struct({
	{ i1 = ffi.types.u32 },
	{ i2 = ffi.types.u32 },
	{ i3 = ffi.types.u32 },
	{ materialIndex = ffi.types.u32 },
	{ userData = ffi.types.u32 },
})
export type JPH_IndexedTriangle = typeof(JPH_IndexedTriangle:new({}))

local JPH_IndexedTriangleNoMaterial = ffi.struct({
	{ i1 = ffi.types.u32 },
	{ i2 = ffi.types.u32 },
	{ i3 = ffi.types.u32 },
})
export type JPH_IndexedTriangleNoMaterial = typeof(JPH_IndexedTriangleNoMaterial:new({}))

local JPH_MassProperties = ffi.struct({
	{ mass = float },
	{ inertia = JPH_Mat4 },
})
export type JPH_MassProperties = typeof(JPH_MassProperties:new({}))

local JPH_SpringSettings = ffi.struct({
	{ mode = ffi.types.u32 },
	{ frequencyOrStiffness = float },
	{ damping = float },
})
export type JPH_SpringSettings = typeof(JPH_SpringSettings:new({}))

local JPH_MotorSettings = ffi.struct({
	{ springSettings = JPH_SpringSettings },
	{ minForceLimit = float },
	{ maxForceLimit = float },
	{ minTorqueLimit = float },
	{ maxTorqueLimit = float },
})
export type JPH_MotorSettings = typeof(JPH_MotorSettings:new({}))

local JPH_CollideShapeSettings = ffi.struct({
	{ base = JPH_CollideSettingsBase },
})
export type JPH_CollideShapeSettings = typeof(JPH_CollideShapeSettings:new({}))

local JPH_ShapeCastSettings = ffi.struct({
	{ base = JPH_CollideSettingsBase },
})
export type JPH_ShapeCastSettings = typeof(JPH_ShapeCastSettings:new({}))

local JPH_RayCastSettings = ffi.struct({})
export type JPH_RayCastSettings = typeof(JPH_RayCastSettings:new({}))

local JPH_ConstraintSettings = ffi.struct({
	{ enabled = ffi.types.u8 },
	{ priority = ffi.types.u32 },
	{ numVelocityStepsOverride = ffi.types.u32 },
	{ numPositionStepsOverride = ffi.types.u32 },
	{ drawConstraintSize = float },
	{ userData = ffi.types.u64 },
})
export type JPH_ConstraintSettings = typeof(JPH_ConstraintSettings:new({}))

local JPH_ContactSettings = ffi.struct({
	{ combinedFriction = float },
	{ combinedRestitution = float },
	{ invMassScale1 = float },
	{ invInertiaScale1 = float },
	{ invMassScale2 = float },
	{ invInertiaScale2 = float },
	{ isSensor = ffi.types.u32 },
	{ relativeLinearSurfaceVelocity = JPH_Vec3 },
	{ relativeAngularSurfaceVelocity = JPH_Vec3 },
})
export type JPH_ContactSettings = typeof(JPH_ContactSettings:new({}))

local JPH_SubShapeIDPair = ffi.struct({
	{ Body1ID = ffi.types.u32 },
	{ subShapeID1 = ffi.types.u32 },
	{ Body2ID = ffi.types.u32 },
	{ subShapeID2 = ffi.types.u32 },
})
export type JPH_SubShapeIDPair = typeof(JPH_SubShapeIDPair:new({}))

local JPH_BroadPhaseCastResult = ffi.struct({
	{ bodyID = ffi.types.u32 },
	{ fraction = float },
})
export type JPH_BroadPhaseCastResult = typeof(JPH_BroadPhaseCastResult:new({}))

local JPH_RayCastResult = ffi.struct({
	{ bodyID = ffi.types.u32 },
	{ fraction = float },
	{ subShapeID2 = ffi.types.u32 },
})
export type JPH_RayCastResult = typeof(JPH_RayCastResult:new({}))

local JPH_CollidePointResult = ffi.struct({
	{ bodyID = ffi.types.u32 },
	{ subShapeID2 = ffi.types.u32 },
})
export type JPH_CollidePointResult = typeof(JPH_CollidePointResult:new({}))

local JPH_CollideShapeResult = ffi.struct({
	{ contactPointOn1 = JPH_Vec3 },
	{ contactPointOn2 = JPH_Vec3 },
	{ penetrationAxis = JPH_Vec3 },
	{ penetrationDepth = float },
	{ subShapeID1 = ffi.types.u32 },
	{ subShapeID2 = ffi.types.u32 },
	{ bodyID2 = ffi.types.u32 },
	{ shape1FaceCount = ffi.types.u32 },
	{ shape1Faces = JPH_Vec3 },
	{ shape2FaceCount = ffi.types.u32 },
	{ shape2Faces = JPH_Vec3 },
})
export type JPH_CollideShapeResult = typeof(JPH_CollideShapeResult:new({}))

local JPH_ShapeCastResult = ffi.struct({
	{ contactPointOn1 = JPH_Vec3 },
	{ contactPointOn2 = JPH_Vec3 },
	{ penetrationAxis = JPH_Vec3 },
	{ penetrationDepth = float },
	{ subShapeID1 = ffi.types.u32 },
	{ subShapeID2 = ffi.types.u32 },
	{ bodyID2 = ffi.types.u32 },
	{ fraction = float },
	{ isBackFaceHit = ffi.types.u8 },
})
export type JPH_ShapeCastResult = typeof(JPH_ShapeCastResult:new({}))

local JPH_DrawSettings = ffi.struct({
	{ drawGetSupportFunction = ffi.types.u8 },
})
export type JPH_DrawSettings = typeof(JPH_DrawSettings:new({}))

local JPH_SupportingFace = ffi.struct({
	{ count = ffi.types.u32 },
	{ vertices = JPH_Vec3:array(32) },
})
export type JPH_SupportingFace = typeof(JPH_SupportingFace:new({}))

local JPH_CollisionGroup = ffi.struct({
	{ groupFilter = JPH_GroupFilter },
	{ groupID = ffi.types.u32 },
	{ subGroupID = ffi.types.u32 },
})
export type JPH_CollisionGroup = typeof(JPH_CollisionGroup:new({}))

local JPH_CollisionEstimationResultImpulse = ffi.struct({
	{ contactImpulse = float },
	{ frictionImpulse1 = float },
	{ frictionImpulse2 = float },
})
export type JPH_CollisionEstimationResultImpulse = typeof(JPH_CollisionEstimationResultImpulse:new({}))

local JPH_CollisionEstimationResult = ffi.struct({
	{ linearVelocity1 = JPH_Vec3 },
	{ angularVelocity1 = JPH_Vec3 },
	{ linearVelocity2 = JPH_Vec3 },
	{ angularVelocity2 = JPH_Vec3 },
	{ tangent1 = JPH_Vec3 },
	{ tangent2 = JPH_Vec3 },
	{ impulseCount = ffi.types.u32 },
	{ impulses = JPH_CollisionEstimationResultImpulse },
})
export type JPH_CollisionEstimationResult = typeof(JPH_CollisionEstimationResult:new({}))

local JPH_FixedConstraintSettings = ffi.struct({
	{ base = JPH_ConstraintSettings },
	{ space = ffi.types.i32 },
	{ autoDetectPoint = ffi.types.u8 },
	{ point1 = JPH_RVec3 },
	{ axisX1 = JPH_Vec3 },
	{ axisY1 = JPH_Vec3 },
	{ point2 = JPH_RVec3 },
	{ axisX2 = JPH_Vec3 },
	{ axisY2 = JPH_Vec3 },
})
export type JPH_FixedConstraintSettings = typeof(JPH_FixedConstraintSettings:new({}))

local JPH_DistanceConstraintSettings = ffi.struct({
	{ base = JPH_ConstraintSettings },
	{ space = ffi.types.i32 },
	{ point1 = JPH_RVec3 },
	{ point2 = JPH_RVec3 },
	{ minDistance = float },
	{ maxDistance = float },
	{ limitsSpringSettings = JPH_SpringSettings },
})
export type JPH_DistanceConstraintSettings = typeof(JPH_DistanceConstraintSettings:new({}))

local JPH_PointConstraintSettings = ffi.struct({
	{ base = JPH_ConstraintSettings },
	{ space = ffi.types.i32 },
	{ point1 = JPH_RVec3 },
	{ point2 = JPH_RVec3 },
})
export type JPH_PointConstraintSettings = typeof(JPH_PointConstraintSettings:new({}))

local JPH_HingeConstraintSettings = ffi.struct({
	{ base = JPH_ConstraintSettings },
	{ space = ffi.types.i32 },
	{ point1 = JPH_RVec3 },
	{ hingeAxis1 = JPH_Vec3 },
	{ normalAxis1 = JPH_Vec3 },
	{ point2 = JPH_RVec3 },
	{ hingeAxis2 = JPH_Vec3 },
	{ normalAxis2 = JPH_Vec3 },
	{ limitsMin = float },
	{ limitsMax = float },
	{ limitsSpringSettings = JPH_SpringSettings },
	{ maxFrictionTorque = float },
	{ motorSettings = JPH_MotorSettings },
})
export type JPH_HingeConstraintSettings = typeof(JPH_HingeConstraintSettings:new({}))

local JPH_SliderConstraintSettings = ffi.struct({
	{ base = JPH_ConstraintSettings },
	{ space = ffi.types.i32 },
	{ autoDetectPoint = ffi.types.u8 },
	{ point1 = JPH_RVec3 },
	{ sliderAxis1 = JPH_Vec3 },
	{ normalAxis1 = JPH_Vec3 },
	{ point2 = JPH_RVec3 },
	{ sliderAxis2 = JPH_Vec3 },
	{ normalAxis2 = JPH_Vec3 },
	{ limitsMin = float },
	{ limitsMax = float },
	{ limitsSpringSettings = JPH_SpringSettings },
	{ maxFrictionForce = float },
	{ motorSettings = JPH_MotorSettings },
})
export type JPH_SliderConstraintSettings = typeof(JPH_SliderConstraintSettings:new({}))

local JPH_ConeConstraintSettings = ffi.struct({
	{ base = JPH_ConstraintSettings },
	{ point1 = JPH_RVec3 },
	{ twistAxis1 = JPH_Vec3 },
	{ point2 = JPH_RVec3 },
	{ twistAxis2 = JPH_Vec3 },
	{ halfConeAngle = float },
})
export type JPH_ConeConstraintSettings = typeof(JPH_ConeConstraintSettings:new({}))

local JPH_SwingTwistConstraintSettings = ffi.struct({
	{ base = JPH_ConstraintSettings },
	{ position1 = JPH_RVec3 },
	{ twistAxis1 = JPH_Vec3 },
	{ planeAxis1 = JPH_Vec3 },
	{ position2 = JPH_RVec3 },
	{ twistAxis2 = JPH_Vec3 },
	{ planeAxis2 = JPH_Vec3 },
	{ swingType = ffi.types.u32 },
	{ normalHalfConeAngle = float },
	{ planeHalfConeAngle = float },
	{ twistMinAngle = float },
	{ twistMaxAngle = float },
	{ maxFrictionTorque = float },
	{ swingMotorSettings = JPH_MotorSettings },
	{ twistMotorSettings = JPH_MotorSettings },
})
export type JPH_SwingTwistConstraintSettings = typeof(JPH_SwingTwistConstraintSettings:new({}))

local JPH_SixDOFConstraintSettings = ffi.struct({
	{ base = JPH_ConstraintSettings },
	{ space = ffi.types.i32 }, -- EConstraintSpace: 0=LocalToBodyCOM, 1=WorldSpace
	{ position1 = JPH_RVec3 },
	{ axisX1 = JPH_Vec3 },
	{ axisY1 = JPH_Vec3 },
	{ position2 = JPH_RVec3 },
	{ axisX2 = JPH_Vec3 },
	{ axisY2 = JPH_Vec3 },
	{ maxFriction = float },
	{ swingType = ffi.types.u32 },
	{ limitMin = float },
	{ limitMax = float },
	{ limitsSpringSettings = JPH_SpringSettings },
	{ motorSettings = JPH_MotorSettings },
})
export type JPH_SixDOFConstraintSettings = typeof(JPH_SixDOFConstraintSettings:new({}))

local JPH_GearConstraintSettings = ffi.struct({
	{ base = JPH_ConstraintSettings },
	{ hingeAxis1 = JPH_Vec3 },
	{ hingeAxis2 = JPH_Vec3 },
	{ ratio = float },
})
export type JPH_GearConstraintSettings = typeof(JPH_GearConstraintSettings:new({}))

local JPH_BodyLockRead = ffi.struct({
	{ lockInterface = JPH_BodyLockInterface },
	{ mutex = JPH_SharedMutex },
	{ body = JPH_Body },
})
export type JPH_BodyLockRead = typeof(JPH_BodyLockRead:new({}))

local JPH_BodyLockWrite = ffi.struct({
	{ lockInterface = JPH_BodyLockInterface },
	{ mutex = JPH_SharedMutex },
	{ body = JPH_Body },
})
export type JPH_BodyLockWrite = typeof(JPH_BodyLockWrite:new({}))

local JPH_ExtendedUpdateSettings = ffi.struct({
	{ stickToFloorStepDown = JPH_Vec3 },
	{ walkStairsStepUp = JPH_Vec3 },
	{ walkStairsMinStepForward = float },
	{ walkStairsStepForwardTest = float },
	{ walkStairsCosAngleForwardContact = float },
	{ walkStairsStepDownExtra = JPH_Vec3 },
})
export type JPH_ExtendedUpdateSettings = typeof(JPH_ExtendedUpdateSettings:new({}))

local JPH_CharacterBaseSettings = ffi.struct({
	{ up = JPH_Vec3 },
	{ supportingVolume = JPH_Plane },
	{ maxSlopeAngle = float },
	{ enhancedInternalEdgeRemoval = ffi.types.u8 },
	{ shape = JPH_Shape },
})
export type JPH_CharacterBaseSettings = typeof(JPH_CharacterBaseSettings:new({}))

local JPH_CharacterSettings = ffi.struct({
	{ base = JPH_CharacterBaseSettings },
	{ mass = float },
	{ friction = float },
	{ gravityFactor = float },
	{ allowedDOFs = ffi.types.u32 },
})
export type JPH_CharacterSettings = typeof(JPH_CharacterSettings:new({}))

local JPH_CharacterVirtualSettings = ffi.struct({
	{ base = JPH_CharacterBaseSettings },
	{ mass = float },
	{ maxStrength = float },
	{ shapeOffset = JPH_Vec3 },
	{ backFaceMode = ffi.types.u32 },
	{ predictiveContactDistance = float },
	{ maxCollisionIterations = ffi.types.u32 },
	{ maxConstraintIterations = ffi.types.u32 },
	{ minTimeRemaining = float },
	{ collisionTolerance = float },
	{ characterPadding = float },
	{ maxNumHits = ffi.types.u32 },
	{ hitReductionCosMaxAngle = float },
	{ penetrationRecoverySpeed = float },
	{ innerBodyShape = JPH_Shape },
	{ innerBodyIDOverride = ffi.types.u32 },
	{ innerBodyLayer = ffi.types.u32 },
})
export type JPH_CharacterVirtualSettings = typeof(JPH_CharacterVirtualSettings:new({}))

local JPH_CharacterContactSettings = ffi.struct({
	{ canPushCharacter = ffi.types.u8 },
	{ canReceiveImpulses = ffi.types.u8 },
})
export type JPH_CharacterContactSettings = typeof(JPH_CharacterContactSettings:new({}))

local JPH_CharacterVirtualContact = ffi.struct({
	{ hash = ffi.types.u64 },
	{ bodyB = ffi.types.u32 },
	{ characterIDB = ffi.types.u32 },
	{ subShapeIDB = ffi.types.u32 },
	{ position = JPH_RVec3 },
	{ linearVelocity = JPH_Vec3 },
	{ contactNormal = JPH_Vec3 },
	{ surfaceNormal = JPH_Vec3 },
	{ distance = float },
	{ fraction = float },
	{ motionTypeB = ffi.types.u32 },
	{ isSensorB = ffi.types.u8 },
	{ characterB = JPH_CharacterVirtual },
	{ userData = ffi.types.u64 },
	{ material = JPH_PhysicsMaterial },
	{ hadCollision = ffi.types.u8 },
	{ wasDiscarded = ffi.types.u8 },
	{ canPushCharacter = ffi.types.u8 },
})
export type JPH_CharacterVirtualContact = typeof(JPH_CharacterVirtualContact:new({}))

local JPH_JobSystemConfig = ffi.struct({
	{ context = ffi.types.u32 },
	{ queueJob = JPH_QueueJobCallback },
	{ queueJobs = JPH_QueueJobsCallback },
	{ maxConcurrency = ffi.types.u32 },
	{ maxBarriers = ffi.types.u32 },
})
export type JPH_JobSystemConfig = typeof(JPH_JobSystemConfig:new({}))

local JPH_PhysicsSystemSettings = ffi.struct({
	{ maxBodies = ffi.types.u32 },
	{ numBodyMutexes = ffi.types.u32 },
	{ maxBodyPairs = ffi.types.u32 },
	{ maxContactConstraints = ffi.types.u32 },
	{ _padding = ffi.types.u32 },
	{ broadPhaseLayerInterface = ffi.types.pointer },
	{ objectLayerPairFilter = ffi.types.pointer },
	{ objectVsBroadPhaseLayerFilter = ffi.types.pointer },
})
export type JPH_PhysicsSystemSettings = typeof(JPH_PhysicsSystemSettings:new({}))

local JPH_PhysicsSettings = ffi.struct({
	{ maxInFlightBodyPairs = ffi.types.i32 },
	{ stepListenersBatchSize = ffi.types.i32 },
	{ stepListenerBatchesPerJob = ffi.types.i32 },
	{ baumgarte = float },
	{ speculativeContactDistance = float },
	{ penetrationSlop = float },
	{ linearCastThreshold = float },
	{ linearCastMaxPenetration = float },
	{ manifoldTolerance = float },
	{ maxPenetrationDistance = float },
	{ bodyPairCacheMaxDeltaPositionSq = float },
	{ bodyPairCacheCosMaxDeltaRotationDiv2 = float },
	{ contactNormalCosMaxDeltaRotation = float },
	{ contactPointPreserveLambdaMaxDistSq = float },
	{ numVelocitySteps = ffi.types.u32 },
	{ numPositionSteps = ffi.types.u32 },
	{ minVelocityForRestitution = float },
	{ timeBeforeSleep = float },
	{ pointVelocitySleepThreshold = float },
	{ deterministicSimulation = ffi.types.u8 },
	{ constraintWarmStart = ffi.types.u8 },
	{ useBodyPairContactCache = ffi.types.u8 },
	{ useManifoldReduction = ffi.types.u8 },
	{ useLargeIslandSplitter = ffi.types.u8 },
	{ allowSleeping = ffi.types.u8 },
	{ checkActiveEdges = ffi.types.u8 },
})
export type JPH_PhysicsSettings = typeof(JPH_PhysicsSettings:new({}))

local JPH_PhysicsStepListenerContext = ffi.struct({
	{ deltaTime = float },
	{ isFirstStep = ffi.types.u32 },
	{ isLastStep = ffi.types.u32 },
	{ physicsSystem = JPH_PhysicsSystem },
})
export type JPH_PhysicsStepListenerContext = typeof(JPH_PhysicsStepListenerContext:new({}))

local JPH_PhysicsStepListener_Procs = ffi.struct({
	{ context = ffi.types.pointer },
})
export type JPH_PhysicsStepListener_Procs = typeof(JPH_PhysicsStepListener_Procs:new({}))

local JPH_BroadPhaseLayerFilter_Procs = ffi.struct({
	{ layer = ffi.types.pointer },
})
export type JPH_BroadPhaseLayerFilter_Procs = typeof(JPH_BroadPhaseLayerFilter_Procs:new({}))

local JPH_ObjectLayerFilter_Procs = ffi.struct({
	{ layer = ffi.types.pointer },
})
export type JPH_ObjectLayerFilter_Procs = typeof(JPH_ObjectLayerFilter_Procs:new({}))

local JPH_BodyFilter_Procs = ffi.struct({
	{ bodyID = ffi.types.pointer },
})
export type JPH_BodyFilter_Procs = typeof(JPH_BodyFilter_Procs:new({}))

local JPH_ShapeFilter_Procs = ffi.struct({
	{ subShapeIDOfShape2 = ffi.types.pointer },
})
export type JPH_ShapeFilter_Procs = typeof(JPH_ShapeFilter_Procs:new({}))

local JPH_SimShapeFilter_Procs = ffi.struct({
	{ subShapeIDOfShape2 = ffi.types.pointer },
})
export type JPH_SimShapeFilter_Procs = typeof(JPH_SimShapeFilter_Procs:new({}))

local JPH_ContactListener_Procs = ffi.struct({
	{ OnContactValidate = ffi.types.pointer },
	{ OnContactAdded = ffi.types.pointer },
	{ OnContactPersisted = ffi.types.pointer },
	{ OnContactRemoved = ffi.types.pointer },
})
export type JPH_ContactListener_Procs = typeof(JPH_ContactListener_Procs:new({}))

local JPH_BodyActivationListener_Procs = ffi.struct({
	{ bodyUserData = ffi.types.pointer },
})
export type JPH_BodyActivationListener_Procs = typeof(JPH_BodyActivationListener_Procs:new({}))

local JPH_BodyDrawFilter_Procs = ffi.struct({
	{ body = ffi.types.pointer },
})
export type JPH_BodyDrawFilter_Procs = typeof(JPH_BodyDrawFilter_Procs:new({}))

local JPH_CharacterContactListener_Procs = ffi.struct({
	{ ioAngularVelocity = ffi.types.pointer },
	{ subShapeID2 = ffi.types.pointer },
	{ ioSettings = ffi.types.pointer },
	{ newCharacterVelocity = ffi.types.pointer },
})
export type JPH_CharacterContactListener_Procs = typeof(JPH_CharacterContactListener_Procs:new({}))

local JPH_CharacterVsCharacterCollision_Procs = ffi.struct({
	{ baseOffset = ffi.types.pointer },
})
export type JPH_CharacterVsCharacterCollision_Procs = typeof(JPH_CharacterVsCharacterCollision_Procs:new({}))

local JPH_DebugRenderer_Procs = ffi.struct({
	{ color = ffi.types.pointer },
	{ castShadow = ffi.types.pointer },
	{ height = ffi.types.pointer },
})
export type JPH_DebugRenderer_Procs = typeof(JPH_DebugRenderer_Procs:new({}))

local JPH_SkeletonJoint = ffi.struct({
	{ name = ffi.types.u32 },
	{ parentName = ffi.types.u32 },
	{ parentJointIndex = ffi.types.i32 },
})
export type JPH_SkeletonJoint = typeof(JPH_SkeletonJoint:new({}))

local JPH_VehicleAntiRollBar = ffi.struct({
	{ leftWheel = ffi.types.i32 },
	{ rightWheel = ffi.types.i32 },
	{ stiffness = float },
})
export type JPH_VehicleAntiRollBar = typeof(JPH_VehicleAntiRollBar:new({}))

local JPH_VehicleConstraintSettings = ffi.struct({
	{ base = JPH_ConstraintSettings },
	{ forward = JPH_Vec3 },
	{ maxPitchRollAngle = float },
	{ wheelsCount = ffi.types.u32 },
	{ wheels = JPH_WheelSettings },
	{ antiRollBarsCount = ffi.types.u32 },
	{ antiRollBars = JPH_VehicleAntiRollBar },
	{ controller = JPH_VehicleControllerSettings },
})
export type JPH_VehicleConstraintSettings = typeof(JPH_VehicleConstraintSettings:new({}))

local JPH_VehicleEngineSettings = ffi.struct({
	{ maxTorque = float },
	{ minRPM = float },
	{ maxRPM = float },
	{ normalizedTorque = JPH_LinearCurve },
	{ inertia = float },
	{ angularDamping = float },
})
export type JPH_VehicleEngineSettings = typeof(JPH_VehicleEngineSettings:new({}))

local JPH_VehicleDifferentialSettings = ffi.struct({
	{ leftWheel = ffi.types.i32 },
	{ rightWheel = ffi.types.i32 },
	{ differentialRatio = float },
	{ leftRightSplit = float },
	{ limitedSlipRatio = float },
	{ engineTorqueRatio = float },
})
export type JPH_VehicleDifferentialSettings = typeof(JPH_VehicleDifferentialSettings:new({}))

-- JPH_BodyCreationSettings
local JPH_BodyCreationSettings = ffi.struct({
	{ shape = JPH_Shape },
	{ position = JPH_RVec3 },
	{ rotation = JPH_Quat },
	{ motionType = ffi.types.u32 },
	{ bodyID = ffi.types.u32 },
	{ layer = ffi.types.u32 },
	{ userData = ffi.types.u64 },
})
export type JPH_BodyCreationSettings = typeof(JPH_BodyCreationSettings:new({}))

local JPH_SoftBodyCreationSettings = ffi.struct({
	{ sharedSettings = JPH_SoftBodySharedSettings },
	{ position = JPH_RVec3 },
	{ rotation = JPH_Quat },
	{ layer = ffi.types.u32 },
	{ userData = ffi.types.u64 },
})
export type JPH_SoftBodyCreationSettings = typeof(JPH_SoftBodyCreationSettings:new({}))

local JPH_SoftBodyVertex = ffi.struct({
	{ position = JPH_Vec3 },
	{ velocity = JPH_Vec3 },
	{ invMass = float },
})
export type JPH_SoftBodyVertex = typeof(JPH_SoftBodyVertex:new({}))

local structs = {
	JPH_CollideSettingsBase = JPH_CollideSettingsBase,
	JPH_RayCastSettings = JPH_RayCastSettings,
	JPH_Vec3 = JPH_Vec3,
	JPH_Vec4 = JPH_Vec4,
	JPH_Quat = JPH_Quat,
	JPH_Mat4 = JPH_Mat4,
	JPH_RVec3 = JPH_RVec3,
	JPH_RMat4 = JPH_RMat4,
	JPH_Plane = JPH_Plane,
	JPH_AABox = JPH_AABox,
	JPH_Point = JPH_Point,
	JPH_Triangle = JPH_Triangle,
	JPH_IndexedTriangle = JPH_IndexedTriangle,
	JPH_IndexedTriangleNoMaterial = JPH_IndexedTriangleNoMaterial,
	JPH_MassProperties = JPH_MassProperties,
	JPH_SpringSettings = JPH_SpringSettings,
	JPH_MotorSettings = JPH_MotorSettings,
	JPH_CollideShapeSettings = JPH_CollideShapeSettings,
	JPH_ShapeCastSettings = JPH_ShapeCastSettings,
	JPH_ConstraintSettings = JPH_ConstraintSettings,
	JPH_ContactSettings = JPH_ContactSettings,
	JPH_SubShapeIDPair = JPH_SubShapeIDPair,
	JPH_BroadPhaseCastResult = JPH_BroadPhaseCastResult,
	JPH_RayCastResult = JPH_RayCastResult,
	JPH_CollidePointResult = JPH_CollidePointResult,
	JPH_CollideShapeResult = JPH_CollideShapeResult,
	JPH_ShapeCastResult = JPH_ShapeCastResult,
	JPH_DrawSettings = JPH_DrawSettings,
	JPH_SupportingFace = JPH_SupportingFace,
	JPH_CollisionGroup = JPH_CollisionGroup,
	JPH_CollisionEstimationResultImpulse = JPH_CollisionEstimationResultImpulse,
	JPH_CollisionEstimationResult = JPH_CollisionEstimationResult,
	JPH_FixedConstraintSettings = JPH_FixedConstraintSettings,
	JPH_DistanceConstraintSettings = JPH_DistanceConstraintSettings,
	JPH_PointConstraintSettings = JPH_PointConstraintSettings,
	JPH_HingeConstraintSettings = JPH_HingeConstraintSettings,
	JPH_SliderConstraintSettings = JPH_SliderConstraintSettings,
	JPH_ConeConstraintSettings = JPH_ConeConstraintSettings,
	JPH_SwingTwistConstraintSettings = JPH_SwingTwistConstraintSettings,
	JPH_SixDOFConstraintSettings = JPH_SixDOFConstraintSettings,
	JPH_GearConstraintSettings = JPH_GearConstraintSettings,
	JPH_BodyLockRead = JPH_BodyLockRead,
	JPH_BodyLockWrite = JPH_BodyLockWrite,
	JPH_ExtendedUpdateSettings = JPH_ExtendedUpdateSettings,
	JPH_CharacterBaseSettings = JPH_CharacterBaseSettings,
	JPH_CharacterSettings = JPH_CharacterSettings,
	JPH_CharacterVirtualSettings = JPH_CharacterVirtualSettings,
	JPH_CharacterContactSettings = JPH_CharacterContactSettings,
	JPH_CharacterVirtualContact = JPH_CharacterVirtualContact,
	JPH_JobSystemConfig = JPH_JobSystemConfig,
	JPH_PhysicsSystemSettings = JPH_PhysicsSystemSettings,
	JPH_PhysicsSettings = JPH_PhysicsSettings,
	JPH_PhysicsStepListenerContext = JPH_PhysicsStepListenerContext,
	JPH_PhysicsStepListener_Procs = JPH_PhysicsStepListener_Procs,
	JPH_BroadPhaseLayerFilter_Procs = JPH_BroadPhaseLayerFilter_Procs,
	JPH_ObjectLayerFilter_Procs = JPH_ObjectLayerFilter_Procs,
	JPH_BodyFilter_Procs = JPH_BodyFilter_Procs,
	JPH_ShapeFilter_Procs = JPH_ShapeFilter_Procs,
	JPH_SimShapeFilter_Procs = JPH_SimShapeFilter_Procs,
	JPH_ContactListener_Procs = JPH_ContactListener_Procs,
	JPH_BodyActivationListener_Procs = JPH_BodyActivationListener_Procs,
	JPH_BodyDrawFilter_Procs = JPH_BodyDrawFilter_Procs,
	JPH_CharacterContactListener_Procs = JPH_CharacterContactListener_Procs,
	JPH_CharacterVsCharacterCollision_Procs = JPH_CharacterVsCharacterCollision_Procs,
	JPH_DebugRenderer_Procs = JPH_DebugRenderer_Procs,
	JPH_SkeletonJoint = JPH_SkeletonJoint,
	JPH_VehicleAntiRollBar = JPH_VehicleAntiRollBar,
	JPH_VehicleConstraintSettings = JPH_VehicleConstraintSettings,
	JPH_VehicleEngineSettings = JPH_VehicleEngineSettings,
	JPH_VehicleDifferentialSettings = JPH_VehicleDifferentialSettings,
	JPH_BodyCreationSettings = JPH_BodyCreationSettings,
	JPH_SoftBodyCreationSettings = JPH_SoftBodyCreationSettings,
	JPH_SoftBodyVertex = JPH_SoftBodyVertex,
}

return structs
