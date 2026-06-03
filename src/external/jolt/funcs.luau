local ffi = zune.ffi

local _structs = require("./structs")

local funcs = {
	JPH_JobSystem_Destroy = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_Init = { returns = ffi.types.u8, args = {} },
	JPH_Shutdown = { returns = ffi.types.void, args = {} },
	JPH_SetTraceHandler = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_SetAssertFailureHandler = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_CollideShapeResult_FreeMembers = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_CollisionEstimationResult_FreeMembers = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_SphereShape_Create = {
		returns = ffi.types.pointer,
		args = { ffi.types.float }, -- radius
	},
	JPH_BroadPhaseLayerInterfaceMask_ConfigureLayer = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u32, ffi.types.u32 },
	},
	JPH_BroadPhaseLayerInterfaceTable_MapObjectToBroadPhaseLayer = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.u32 },
	},
	JPH_ConvexHullShapeSettings_Create = {
		returns = ffi.types.pointer,
		args = {
			ffi.types.pointer, -- points (Vec3*)
			ffi.types.u32, -- point count
			ffi.types.float, -- convex radius
		},
	},

	JPH_ConvexHullShapeSettings_CreateShape = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer },
	},

	JPH_Quat_GetAxisAngle = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_Vec3_DotProduct = {
		returns = ffi.types.float,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_Quat_Dot = {
		returns = ffi.types.float,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_HingeConstraint_GetTotalLambdaRotation = {
		returns = ffi.types.float,
		args = { ffi.types.pointer },
	},
	JPH_SliderConstraint_GetTotalLambdaPosition = {
		returns = ffi.types.float,
		args = { ffi.types.pointer },
	},
	JPH_ObjectLayerPairFilterMask_GetObjectLayer = {
		returns = ffi.types.pointer,
		args = { ffi.types.u32, ffi.types.u32 },
	},
	JPH_PhysicsSystem_Create = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer }, -- Takes JPH_PhysicsSystemSettings*
	},

	JPH_BodyCreationSettings_Create2 = {
		returns = ffi.types.pointer,
		args = {
			ffi.types.pointer, -- shape
			ffi.types.pointer, -- position (RVec3)
			ffi.types.pointer, -- rotation (Quat)
			ffi.types.u32, -- motion type
			ffi.types.u32, -- object layer
		},
	},
	JPH_BoxShape_Create = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.float }, -- halfExtents (Vec3*), convexRadius
	},

	JPH_BodyCreationSettings_Create3 = {
		returns = ffi.types.pointer,
		args = {
			ffi.types.pointer, -- shape
			ffi.types.pointer, -- position (RVec3*)
			ffi.types.pointer, -- rotation (Quat*) - can be null
			ffi.types.u8, -- motion type
			ffi.types.u32, -- object layer
		},
	},
	JPH_BoxShapeSettings_Create = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.float },
	},

	JPH_BoxShapeSettings_CreateShape = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer },
	},
	JPH_ObjectLayerPairFilterMask_GetGroup = { returns = ffi.types.u32, args = { ffi.types.pointer } },
	JPH_ObjectLayerPairFilterMask_GetMask = { returns = ffi.types.u32, args = { ffi.types.pointer } },

	JPH_ObjectLayerPairFilterTable_DisableCollision = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.u32 },
	},
	JPH_ObjectLayerPairFilterTable_EnableCollision = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.u32 },
	},
	JPH_ObjectLayerPairFilterTable_ShouldCollide = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_DrawSettings_InitDefault = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_PhysicsSystem_Destroy = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_PhysicsSystem_SetPhysicsSettings = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_PhysicsSystem_GetPhysicsSettings = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_PhysicsSystem_OptimizeBroadPhase = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_PhysicsSystem_SetContactListener = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_PhysicsSystem_SetBodyActivationListener = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},

	JPH_PhysicsSystem_SetSimShapeFilter = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_PhysicsSystem_WereBodiesInContact = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_PhysicsSystem_GetNumBodies = { returns = ffi.types.u32, args = { ffi.types.pointer } },
	JPH_PhysicsSystem_GetNumActiveBodies = { returns = ffi.types.u32, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_PhysicsSystem_GetMaxBodies = { returns = ffi.types.u32, args = { ffi.types.pointer } },
	JPH_PhysicsSystem_GetNumConstraints = { returns = ffi.types.u32, args = { ffi.types.pointer } },
	JPH_PhysicsSystem_SetGravity = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_PhysicsSystem_GetGravity = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_PhysicsSystem_AddConstraint = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_PhysicsSystem_RemoveConstraint = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_PhysicsSystem_AddConstraints = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u32 },
	},
	JPH_PhysicsSystem_RemoveConstraints = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u32 },
	},
	JPH_PhysicsSystem_AddStepListener = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_PhysicsSystem_RemoveStepListener = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_PhysicsSystem_GetBodies = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u32 },
	},
	JPH_PhysicsSystem_GetConstraints = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u32 },
	},
	JPH_PhysicsSystem_ActivateBodiesInAABox = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_PhysicsSystem_DrawBodies = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_PhysicsSystem_DrawConstraints = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_PhysicsSystem_DrawConstraintLimits = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_PhysicsSystem_DrawConstraintReferenceFrame = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_PhysicsStepListener_SetProcs = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_PhysicsStepListener_Destroy = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_Math_Sin = { returns = ffi.types.float, args = { ffi.types.float } },
	JPH_Math_Cos = { returns = ffi.types.float, args = { ffi.types.float } },
	JPH_Quat_FromTo = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer } },
	JPH_Quat_GetEulerAngles = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_Quat_RotateAxisX = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_Quat_RotateAxisY = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_Quat_RotateAxisZ = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_Quat_Inversed = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_Quat_GetPerpendicular = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_Quat_GetRotationAngle = { returns = ffi.types.float, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_Quat_FromEulerAngles = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_Quat_Add = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer } },
	JPH_Quat_Subtract = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer } },
	JPH_Quat_Multiply = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer } },
	JPH_Quat_MultiplyScalar = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.pointer },
	},
	JPH_Quat_DivideScalar = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.pointer },
	},
	JPH_Quat_Conjugated = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_Quat_GetTwist = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer } },
	JPH_Quat_GetSwingTwist = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_Quat_Lerp = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.float, ffi.types.pointer },
	},
	JPH_Quat_Slerp = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.float, ffi.types.pointer },
	},
	JPH_Quat_Rotate = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer } },
	JPH_Quat_InverseRotate = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_Vec3_AxisX = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_Vec3_AxisY = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_Vec3_AxisZ = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_Vec3_IsClose = { returns = ffi.types.u8, args = { ffi.types.pointer, ffi.types.pointer, ffi.types.float } },
	JPH_Vec3_IsNearZero = { returns = ffi.types.u8, args = { ffi.types.pointer, ffi.types.float } },
	JPH_Vec3_IsNormalized = { returns = ffi.types.u8, args = { ffi.types.pointer, ffi.types.float } },
	JPH_Vec3_IsNaN = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	JPH_Vec3_Negate = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_Vec3_Normalized = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_Vec3_Cross = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer } },
	JPH_Vec3_Abs = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_Vec3_Length = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_Vec3_LengthSquared = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_Vec3_Normalize = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_Vec3_Add = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer } },
	JPH_Vec3_Subtract = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer } },
	JPH_Vec3_Multiply = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer } },
	JPH_Vec3_MultiplyScalar = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.pointer },
	},
	JPH_ContactListener_Create = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer }, -- userData
	},
	JPH_Vec3_MultiplyMatrix = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_Vec3_Divide = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer } },
	JPH_Vec3_DivideScalar = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.pointer },
	},
	JPH_Mat4_Add = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer } },
	JPH_Mat4_Subtract = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer } },
	JPH_Mat4_Multiply = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer } },
	JPH_Mat4_MultiplyScalar = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.pointer },
	},
	JPH_Mat4_Zero = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_Mat4_Identity = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_Mat4_Rotation = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_Mat4_Rotation2 = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer, ffi.types.float } },
	JPH_Mat4_Translation = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_Mat4_RotationTranslation = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_Mat4_InverseRotationTranslation = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_Mat4_Scale = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_Mat4_Transposed = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_Mat4_Inversed = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_Mat4_GetAxisX = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_Mat4_GetAxisY = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_Mat4_GetAxisZ = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_Mat4_GetTranslation = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_Mat4_GetQuaternion = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_PhysicsMaterial_Destroy = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_PhysicsMaterial_GetDebugColor = { returns = ffi.types.u32, args = { ffi.types.pointer } },
	JPH_GroupFilter_Destroy = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_GroupFilter_CanCollide = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_GroupFilterTable_DisableCollision = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_GroupFilterTable_EnableCollision = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_GroupFilterTable_IsCollisionEnabled = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_ShapeSettings_Destroy = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_ShapeSettings_GetUserData = { returns = ffi.types.u64, args = { ffi.types.pointer } },
	JPH_ShapeSettings_SetUserData = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u64 } },
	JPH_Shape_Draw = {
		returns = ffi.types.void,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.u8,
			ffi.types.u8,
		},
	},
	JPH_Shape_Destroy = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_Shape_GetType = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	JPH_Shape_GetSubType = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	JPH_Shape_GetUserData = { returns = ffi.types.u64, args = { ffi.types.pointer } },
	JPH_Shape_SetUserData = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u64 } },
	JPH_Shape_MustBeStatic = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	JPH_Shape_GetCenterOfMass = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_Shape_GetLocalBounds = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_Shape_GetSubShapeIDBitsRecursive = { returns = ffi.types.u32, args = { ffi.types.pointer } },
	JPH_Shape_GetWorldSpaceBounds = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_Shape_GetInnerRadius = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_Shape_GetMassProperties = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_Shape_GetSurfaceNormal = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_Shape_GetSupportingFace = {
		returns = ffi.types.void,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
		},
	},
	JPH_Shape_GetVolume = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_Shape_IsValidScale = { returns = ffi.types.u8, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_Shape_MakeScaleValid = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_Shape_CastRay = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_Shape_CastRay2 = {
		returns = ffi.types.u8,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
		},
	},
	JPH_Shape_CollidePoint = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_Shape_CollidePoint2 = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_ConvexShapeSettings_GetDensity = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_ConvexShapeSettings_SetDensity = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	JPH_ConvexShape_GetDensity = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_ConvexShape_SetDensity = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	JPH_BoxShape_GetHalfExtent = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_BoxShape_GetConvexRadius = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_SphereShapeSettings_GetRadius = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_SphereShapeSettings_SetRadius = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	JPH_SphereShape_GetRadius = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_PlaneShape_GetPlane = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_PlaneShape_GetHalfExtent = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_TriangleShape_GetConvexRadius = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_TriangleShape_GetVertex1 = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_TriangleShape_GetVertex2 = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_TriangleShape_GetVertex3 = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_CapsuleShape_GetRadius = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_CapsuleShape_GetHalfHeightOfCylinder = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_CylinderShape_GetRadius = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_CylinderShape_GetHalfHeight = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_TaperedCylinderShape_GetTopRadius = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_TaperedCylinderShape_GetBottomRadius = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_TaperedCylinderShape_GetConvexRadius = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_TaperedCylinderShape_GetHalfHeight = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_ConvexHullShape_GetNumPoints = { returns = ffi.types.u32, args = { ffi.types.pointer } },
	JPH_ConvexHullShape_GetPoint = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.pointer },
	},
	JPH_ConvexHullShape_GetNumFaces = { returns = ffi.types.u32, args = { ffi.types.pointer } },
	JPH_ConvexHullShape_GetNumVerticesInFace = { returns = ffi.types.u32, args = { ffi.types.pointer, ffi.types.u32 } },
	JPH_ConvexHullShape_GetFaceVertices = {
		returns = ffi.types.u32,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.u32, ffi.types.u32 },
	},
	JPH_MeshShapeSettings_GetMaxTrianglesPerLeaf = { returns = ffi.types.u32, args = { ffi.types.pointer } },
	JPH_MeshShapeSettings_SetMaxTrianglesPerLeaf = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32 },
	},
	JPH_MeshShapeSettings_GetActiveEdgeCosThresholdAngle = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_MeshShapeSettings_SetActiveEdgeCosThresholdAngle = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float },
	},
	JPH_MeshShapeSettings_GetPerTriangleUserData = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	JPH_MeshShapeSettings_SetPerTriangleUserData = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u8 },
	},
	JPH_MeshShapeSettings_GetBuildQuality = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	JPH_MeshShapeSettings_SetBuildQuality = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_MeshShapeSettings_Sanitize = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_MeshShape_GetTriangleUserData = { returns = ffi.types.u32, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_HeightFieldShapeSettings_DetermineMinAndMaxSample = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.float, ffi.types.float },
	},
	JPH_HeightFieldShapeSettings_CalculateBitsPerSampleForError = {
		returns = ffi.types.u32,
		args = { ffi.types.pointer, ffi.types.float },
	},
	JPH_HeightFieldShapeSettings_GetOffset = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_HeightFieldShapeSettings_SetOffset = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_HeightFieldShapeSettings_GetScale = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_HeightFieldShapeSettings_SetScale = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_HeightFieldShapeSettings_GetSampleCount = { returns = ffi.types.u32, args = { ffi.types.pointer } },
	JPH_HeightFieldShapeSettings_SetSampleCount = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32 },
	},
	JPH_HeightFieldShapeSettings_GetMinHeightValue = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_HeightFieldShapeSettings_SetMinHeightValue = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float },
	},
	JPH_HeightFieldShapeSettings_GetMaxHeightValue = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_HeightFieldShapeSettings_SetMaxHeightValue = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float },
	},
	JPH_HeightFieldShapeSettings_GetBlockSize = { returns = ffi.types.u32, args = { ffi.types.pointer } },
	JPH_HeightFieldShapeSettings_SetBlockSize = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32 },
	},
	JPH_HeightFieldShapeSettings_GetBitsPerSample = { returns = ffi.types.u32, args = { ffi.types.pointer } },
	JPH_HeightFieldShapeSettings_SetBitsPerSample = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32 },
	},
	JPH_HeightFieldShapeSettings_GetActiveEdgeCosThresholdAngle = {
		returns = ffi.types.float,
		args = { ffi.types.pointer },
	},
	JPH_HeightFieldShapeSettings_SetActiveEdgeCosThresholdAngle = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float },
	},
	JPH_HeightFieldShape_GetSampleCount = { returns = ffi.types.u32, args = { ffi.types.pointer } },
	JPH_HeightFieldShape_GetBlockSize = { returns = ffi.types.u32, args = { ffi.types.pointer } },
	JPH_HeightFieldShape_GetPosition = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.u32, ffi.types.pointer },
	},
	JPH_HeightFieldShape_IsNoCollision = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.u32 },
	},
	JPH_HeightFieldShape_ProjectOntoSurface = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_HeightFieldShape_GetMinHeightValue = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_HeightFieldShape_GetMaxHeightValue = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_TaperedCapsuleShape_GetTopRadius = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_TaperedCapsuleShape_GetBottomRadius = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_TaperedCapsuleShape_GetHalfHeight = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_CompoundShapeSettings_AddShape = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.u32 },
	},
	JPH_CompoundShapeSettings_AddShape2 = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.u32 },
	},
	JPH_CompoundShape_GetNumSubShapes = { returns = ffi.types.u32, args = { ffi.types.pointer } },
	JPH_CompoundShape_GetSubShape = {
		returns = ffi.types.void,
		args = {
			ffi.types.pointer,
			ffi.types.u32,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.u32,
		},
	},
	JPH_CompoundShape_GetSubShapeIndexFromID = {
		returns = ffi.types.u32,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_MutableCompoundShape_AddShape = {
		returns = ffi.types.u32,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
		},
	},
	JPH_MutableCompoundShape_RemoveShape = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u32 } },
	JPH_MutableCompoundShape_ModifyShape = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_MutableCompoundShape_ModifyShape2 = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_MutableCompoundShape_AdjustCenterOfMass = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_RotatedTranslatedShape_GetPosition = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_RotatedTranslatedShape_GetRotation = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_ScaledShape_GetScale = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_OffsetCenterOfMassShape_GetOffset = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_BodyCreationSettings_Destroy = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_BodyCreationSettings_GetPosition = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_BodyCreationSettings_SetPosition = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_BodyCreationSettings_GetRotation = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_BodyCreationSettings_SetRotation = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_BodyCreationSettings_GetLinearVelocity = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_BodyCreationSettings_SetLinearVelocity = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_BodyCreationSettings_GetAngularVelocity = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_BodyCreationSettings_SetAngularVelocity = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_BodyCreationSettings_GetUserData = { returns = ffi.types.u64, args = { ffi.types.pointer } },
	JPH_BodyCreationSettings_SetUserData = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u64 } },
	JPH_BodyCreationSettings_GetObjectLayer = { returns = ffi.types.u32, args = { ffi.types.pointer } },
	JPH_BodyCreationSettings_SetObjectLayer = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32 },
	},
	JPH_BodyCreationSettings_GetCollisionGroup = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_BodyCreationSettings_SetCollisionGroup = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_BodyCreationSettings_GetMotionType = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	JPH_BodyCreationSettings_SetMotionType = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_BodyCreationSettings_GetAllowedDOFs = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	JPH_BodyCreationSettings_SetAllowedDOFs = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_BodyCreationSettings_GetAllowDynamicOrKinematic = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	JPH_BodyCreationSettings_SetAllowDynamicOrKinematic = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u8 },
	},
	JPH_BodyCreationSettings_GetIsSensor = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	JPH_BodyCreationSettings_SetIsSensor = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u8 } },
	JPH_BodyCreationSettings_GetCollideKinematicVsNonDynamic = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	JPH_BodyCreationSettings_SetCollideKinematicVsNonDynamic = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u8 },
	},
	JPH_BodyCreationSettings_GetUseManifoldReduction = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	JPH_BodyCreationSettings_SetUseManifoldReduction = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u8 },
	},
	JPH_BodyCreationSettings_GetApplyGyroscopicForce = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	JPH_BodyCreationSettings_SetApplyGyroscopicForce = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u8 },
	},
	JPH_BodyCreationSettings_GetMotionQuality = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	JPH_BodyCreationSettings_SetMotionQuality = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_BodyCreationSettings_GetEnhancedInternalEdgeRemoval = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	JPH_BodyCreationSettings_SetEnhancedInternalEdgeRemoval = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u8 },
	},
	JPH_BodyCreationSettings_GetAllowSleeping = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	JPH_BodyCreationSettings_SetAllowSleeping = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u8 } },
	JPH_BodyCreationSettings_GetFriction = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_BodyCreationSettings_SetFriction = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	JPH_BodyCreationSettings_GetRestitution = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_BodyCreationSettings_SetRestitution = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float },
	},
	JPH_BodyCreationSettings_GetLinearDamping = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_BodyCreationSettings_SetLinearDamping = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float },
	},
	JPH_BodyCreationSettings_GetAngularDamping = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_BodyCreationSettings_SetAngularDamping = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float },
	},
	JPH_BodyCreationSettings_GetMaxLinearVelocity = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_BodyCreationSettings_SetMaxLinearVelocity = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float },
	},
	JPH_BodyCreationSettings_GetMaxAngularVelocity = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_BodyCreationSettings_SetMaxAngularVelocity = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float },
	},
	JPH_BodyCreationSettings_GetGravityFactor = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_BodyCreationSettings_SetGravityFactor = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float },
	},
	JPH_BodyCreationSettings_GetNumVelocityStepsOverride = { returns = ffi.types.u32, args = { ffi.types.pointer } },
	JPH_BodyCreationSettings_SetNumVelocityStepsOverride = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32 },
	},
	JPH_BodyCreationSettings_GetNumPositionStepsOverride = { returns = ffi.types.u32, args = { ffi.types.pointer } },
	JPH_BodyCreationSettings_SetNumPositionStepsOverride = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32 },
	},
	JPH_BodyCreationSettings_GetOverrideMassProperties = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	JPH_BodyCreationSettings_SetOverrideMassProperties = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_BodyCreationSettings_GetInertiaMultiplier = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_BodyCreationSettings_SetInertiaMultiplier = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float },
	},
	JPH_BodyCreationSettings_GetMassPropertiesOverride = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_BodyCreationSettings_SetMassPropertiesOverride = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_SoftBodyCreationSettings_Destroy = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_Constraint_Destroy = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_Constraint_GetType = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	JPH_Constraint_GetSubType = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	JPH_Constraint_GetConstraintPriority = { returns = ffi.types.u32, args = { ffi.types.pointer } },
	JPH_Constraint_SetConstraintPriority = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u32 } },
	JPH_Constraint_GetNumVelocityStepsOverride = { returns = ffi.types.u32, args = { ffi.types.pointer } },
	JPH_Constraint_SetNumVelocityStepsOverride = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32 },
	},
	JPH_Constraint_GetNumPositionStepsOverride = { returns = ffi.types.u32, args = { ffi.types.pointer } },
	JPH_Constraint_SetNumPositionStepsOverride = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32 },
	},
	JPH_Constraint_GetEnabled = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	JPH_Constraint_SetEnabled = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u8 } },
	JPH_Constraint_GetUserData = { returns = ffi.types.u64, args = { ffi.types.pointer } },
	JPH_Constraint_SetUserData = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u64 } },
	JPH_Constraint_NotifyShapeChanged = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_Constraint_ResetWarmStart = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_Constraint_IsActive = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	JPH_Constraint_SetupVelocityConstraint = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	JPH_Constraint_WarmStartVelocityConstraint = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float },
	},
	JPH_Constraint_SolveVelocityConstraint = { returns = ffi.types.u8, args = { ffi.types.pointer, ffi.types.float } },
	JPH_Constraint_SolvePositionConstraint = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.float },
	},
	JPH_TwoBodyConstraint_GetConstraintToBody1Matrix = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_TwoBodyConstraint_GetConstraintToBody2Matrix = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},

	JPH_FixedConstraintSettings_Init = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_FixedConstraint_GetSettings = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_FixedConstraint_GetTotalLambdaPosition = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},

	JPH_FixedConstraint_Create = {
		returns = ffi.types.pointer, -- JPH_FixedConstraint*
		args = {
			ffi.types.pointer, -- JPH_FixedConstraintSettings*
			ffi.types.pointer, -- JPH_Body*
			ffi.types.pointer, -- JPH_Body*
		},
	},

	JPH_HingeConstraint_Create = {
		returns = ffi.types.pointer, -- JPH_HingeConstraint*
		args = {
			ffi.types.pointer, -- JPH_HingeConstraintSettings*
			ffi.types.pointer, -- JPH_Body*
			ffi.types.pointer, -- JPH_Body*
		},
	},

	JPH_SliderConstraint_Create = {
		returns = ffi.types.pointer, -- JPH_SliderConstraint*
		args = {
			ffi.types.pointer, -- JPH_SliderConstraintSettings*
			ffi.types.pointer, -- JPH_Body*
			ffi.types.pointer, -- JPH_Body*
		},
	},

	JPH_SixDOFConstraint_Create = {
		returns = ffi.types.pointer, -- JPH_SixDOFConstraint*
		args = {
			ffi.types.pointer, -- JPH_SixDOFConstraintSettings*
			ffi.types.pointer, -- JPH_Body*
			ffi.types.pointer, -- JPH_Body*
		},
	},

	JPH_DistanceConstraint_Create = {
		returns = ffi.types.pointer, -- JPH_DistanceConstraint*
		args = {
			ffi.types.pointer, -- JPH_DistanceConstraintSettings*
			ffi.types.pointer, -- JPH_Body*
			ffi.types.pointer, -- JPH_Body*
		},
	},

	JPH_FixedConstraint_GetTotalLambdaRotation = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_DistanceConstraintSettings_Init = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_DistanceConstraint_GetSettings = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_DistanceConstraint_SetDistance = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.float },
	},
	JPH_DistanceConstraint_GetMinDistance = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_DistanceConstraint_GetMaxDistance = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_DistanceConstraint_GetLimitsSpringSettings = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_DistanceConstraint_SetLimitsSpringSettings = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_DistanceConstraint_GetTotalLambdaPosition = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_PointConstraintSettings_Init = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_PointConstraint_Create = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_PointConstraint_GetSettings = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_PointConstraint_SetPoint1 = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_PointConstraint_SetPoint2 = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_PointConstraint_GetLocalSpacePoint1 = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_PointConstraint_GetLocalSpacePoint2 = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_PointConstraint_GetTotalLambdaPosition = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_HingeConstraintSettings_Init = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_HingeConstraint_GetSettings = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_HingeConstraint_GetLocalSpacePoint1 = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_HingeConstraint_GetLocalSpacePoint2 = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_HingeConstraint_GetLocalSpaceHingeAxis1 = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_HingeConstraint_GetLocalSpaceHingeAxis2 = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_HingeConstraint_GetLocalSpaceNormalAxis1 = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_HingeConstraint_GetLocalSpaceNormalAxis2 = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_HingeConstraint_GetCurrentAngle = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_HingeConstraint_SetMaxFrictionTorque = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float },
	},
	JPH_HingeConstraint_GetMaxFrictionTorque = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_HingeConstraint_SetMotorSettings = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_HingeConstraint_GetMotorSettings = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_HingeConstraint_SetMotorState = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.i32 } },
	JPH_HingeConstraint_GetMotorState = { returns = ffi.types.i32, args = { ffi.types.pointer } },
	JPH_HingeConstraint_SetTargetAngularVelocity = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float },
	},
	JPH_HingeConstraint_GetTargetAngularVelocity = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_HingeConstraint_SetTargetAngle = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	JPH_HingeConstraint_GetTargetAngle = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_HingeConstraint_SetLimits = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.float },
	},
	JPH_HingeConstraint_GetLimitsMin = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_HingeConstraint_GetLimitsMax = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_HingeConstraint_HasLimits = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	JPH_HingeConstraint_GetLimitsSpringSettings = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_HingeConstraint_SetLimitsSpringSettings = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_HingeConstraint_GetTotalLambdaPosition = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_HingeConstraint_GetTotalLambdaRotationLimits = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_HingeConstraint_GetTotalLambdaMotor = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_SliderConstraintSettings_Init = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_SliderConstraintSettings_SetSliderAxis = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_SliderConstraint_GetSettings = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_SliderConstraint_GetCurrentPosition = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_SliderConstraint_SetMaxFrictionForce = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float },
	},
	JPH_SliderConstraint_GetMaxFrictionForce = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_SliderConstraint_SetMotorSettings = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_SliderConstraint_GetMotorSettings = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_SliderConstraint_SetMotorState = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.i32 } },
	JPH_SliderConstraint_GetMotorState = { returns = ffi.types.i32, args = { ffi.types.pointer } },
	JPH_SliderConstraint_SetTargetVelocity = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	JPH_SliderConstraint_GetTargetVelocity = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_SliderConstraint_SetTargetPosition = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	JPH_SliderConstraint_GetTargetPosition = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_SliderConstraint_SetLimits = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.float },
	},
	JPH_SliderConstraint_GetLimitsMin = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_SliderConstraint_GetLimitsMax = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_SliderConstraint_HasLimits = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	JPH_SliderConstraint_GetLimitsSpringSettings = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_SliderConstraint_SetLimitsSpringSettings = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_SliderConstraint_GetTotalLambdaPositionLimits = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_SliderConstraint_GetTotalLambdaRotation = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_SliderConstraint_GetTotalLambdaMotor = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_ConeConstraintSettings_Init = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_ConeConstraint_GetSettings = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_ConeConstraint_SetHalfConeAngle = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	JPH_ConeConstraint_GetCosHalfConeAngle = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_ConeConstraint_GetTotalLambdaPosition = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_ConeConstraint_GetTotalLambdaRotation = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_SwingTwistConstraintSettings_Init = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_SwingTwistConstraint_GetSettings = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_SwingTwistConstraint_GetNormalHalfConeAngle = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_SwingTwistConstraint_GetTotalLambdaPosition = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_SwingTwistConstraint_GetTotalLambdaTwist = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_SwingTwistConstraint_GetTotalLambdaSwingY = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_SwingTwistConstraint_GetTotalLambdaSwingZ = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_SwingTwistConstraint_GetTotalLambdaMotor = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_SixDOFConstraintSettings_Init = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_SixDOFConstraintSettings_MakeFreeAxis = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.i32 },
	},
	JPH_SixDOFConstraintSettings_IsFreeAxis = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.i32 },
	},
	JPH_SixDOFConstraintSettings_MakeFixedAxis = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.i32 },
	},
	JPH_SixDOFConstraintSettings_IsFixedAxis = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.i32 },
	},
	JPH_SixDOFConstraintSettings_SetLimitedAxis = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.float, ffi.types.float },
	},
	JPH_SixDOFConstraint_GetSettings = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_SixDOFConstraint_GetLimitsMin = { returns = ffi.types.float, args = { ffi.types.pointer, ffi.types.i32 } },
	JPH_SixDOFConstraint_GetLimitsMax = { returns = ffi.types.float, args = { ffi.types.pointer, ffi.types.i32 } },
	JPH_SixDOFConstraint_GetTotalLambdaPosition = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_SixDOFConstraint_GetTotalLambdaRotation = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_SixDOFConstraint_GetTotalLambdaMotorTranslation = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_SixDOFConstraint_GetTotalLambdaMotorRotation = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_SixDOFConstraint_GetTranslationLimitsMin = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_SixDOFConstraint_GetTranslationLimitsMax = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_SixDOFConstraint_GetRotationLimitsMin = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_SixDOFConstraint_GetRotationLimitsMax = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_SixDOFConstraint_IsFixedAxis = { returns = ffi.types.u8, args = { ffi.types.pointer, ffi.types.i32 } },
	JPH_SixDOFConstraint_IsFreeAxis = { returns = ffi.types.u8, args = { ffi.types.pointer, ffi.types.i32 } },
	JPH_SixDOFConstraint_GetLimitsSpringSettings = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.pointer },
	},
	JPH_SixDOFConstraint_SetLimitsSpringSettings = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.pointer },
	},
	JPH_SixDOFConstraint_SetMaxFriction = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.float },
	},
	JPH_SixDOFConstraint_GetMaxFriction = { returns = ffi.types.float, args = { ffi.types.pointer, ffi.types.i32 } },
	JPH_SixDOFConstraint_GetRotationInConstraintSpace = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_SixDOFConstraint_GetMotorSettings = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.pointer },
	},
	JPH_SixDOFConstraint_SetMotorState = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.i32, ffi.types.i32 },
	},
	JPH_SixDOFConstraint_GetMotorState = {
		returns = ffi.types.i32,
		args = { ffi.types.pointer, ffi.types.i32 },
	},
	JPH_SixDOFConstraint_SetTargetVelocityCS = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_SixDOFConstraint_GetTargetVelocityCS = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_SixDOFConstraint_SetTargetAngularVelocityCS = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_SixDOFConstraint_GetTargetAngularVelocityCS = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_SixDOFConstraint_SetTargetPositionCS = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_SixDOFConstraint_GetTargetPositionCS = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_SixDOFConstraint_SetTargetOrientationCS = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_SixDOFConstraint_GetTargetOrientationCS = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_SixDOFConstraint_SetTargetOrientationBS = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_GearConstraintSettings_Init = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_GearConstraint_GetSettings = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_GearConstraint_SetConstraints = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_GearConstraint_GetTotalLambda = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_BodyInterface_DestroyBody = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u32 } },
	JPH_BodyInterface_CreateAndAddBody = {
		returns = ffi.types.u32, -- returns JPH_BodyID
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u32 },
	},
	JPH_BodyInterface_CreateBody = {
		returns = ffi.types.pointer, -- returns JPH_Body*
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	-- Body_GetID (Removed duplicate, definition exists at line 1082)
	JPH_BodyInterface_DestroyBodyWithoutID = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_BodyInterface_AssignBodyID = { returns = ffi.types.u8, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_BodyInterface_AssignBodyID2 = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u32 },
	},
	JPH_BodyInterface_CreateAndAddSoftBody = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},

	JPH_BodyInterface_AddBody = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.u8 },
	},
	JPH_BodyInterface_RemoveBody = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u32 } },
	JPH_BodyInterface_RemoveAndDestroyBody = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32 },
	},
	JPH_ObjectLayerPairFilterTable_Create = {
		returns = ffi.types.pointer,
		args = { ffi.types.u32 }, -- number of layers
	},
	JPH_BroadPhaseLayerInterfaceTable_Create = {
		returns = ffi.types.pointer,
		args = { ffi.types.u32, ffi.types.u32 }, -- number of object layers, number of broadphase layers
	},
	-- JPH_CAPI JPH_PhysicsUpdateError JPH_PhysicsSystem_Update(JPH_PhysicsSystem* system, float deltaTime, int collisionSteps, JPH_JobSystem* jobSystem);

	JPH_PhysicsSystem_Update = {
		returns = ffi.types.void,
		args = {
			ffi.types.pointer,
			ffi.types.float,
			ffi.types.i32,
			ffi.types.pointer,
		},
	},

	JPH_ObjectVsBroadPhaseLayerFilterTable_Create = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.pointer, ffi.types.u32 },
		-- (broadPhaseInterface, numBroadPhaseLayers, objectLayerPairFilter, numObjectLayers)
	},
	JPH_JobSystemThreadPool_Create = {
		returns = ffi.types.pointer, -- JPH_JobSystem*
		args = { ffi.types.pointer }, -- number of threads
	},

	JPH_SphereShapeSettings_Create = {
		returns = ffi.types.pointer,
		args = { ffi.types.float },
	},

	-- Capsule Shape
	JPH_CapsuleShapeSettings_Create = {
		returns = ffi.types.pointer,
		args = { ffi.types.float, ffi.types.float },
	},

	JPH_CylinderShapeSettings_Create = {
		returns = ffi.types.pointer,
		args = { ffi.types.float, ffi.types.float, ffi.types.float },
	},

	-- Get Body Interface
	JPH_PhysicsSystem_GetBodyInterface = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer },
	},

	-- Body interface position and rotation getters
	JPH_BodyInterface_GetPositionAndRotation = {
		returns = ffi.types.void,
		args = {
			ffi.types.pointer, -- bodyInterface
			ffi.types.u32, -- bodyId
			ffi.types.pointer, -- position (JPH_RVec3*)
			ffi.types.pointer, -- rotation (JPH_Quat*)
		},
	},
	-- Mesh shape (for complex geometry)
	JPH_MeshShapeSettings_Create = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.u32 },
	},
	JPH_MeshShapeSettings_CreateShape = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer },
	},

	-- Convex Hull shape
	-- ConvexHullShapeSettings_Create was duplicate, removed here (keeping definition at line 25)

	-- Rotated/Translated shape (for offsetting shapes)
	JPH_RotatedTranslatedShapeSettings_Create = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},

	-- Scaled shape
	JPH_ScaledShapeSettings_Create = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},

	JPH_Character_Create = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_CharacterVirtual_Create = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_BodyInterface_IsAdded = { returns = ffi.types.u8, args = { ffi.types.pointer, ffi.types.u32 } },
	JPH_BodyInterface_GetBodyType = { returns = ffi.types.u32, args = { ffi.types.pointer, ffi.types.u32 } },
	JPH_BodyInterface_SetLinearVelocity = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.pointer },
	},
	JPH_BodyInterface_GetLinearVelocity = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.pointer },
	},
	JPH_BodyInterface_GetCenterOfMassPosition = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.pointer },
	},
	JPH_BodyInterface_GetMotionType = { returns = ffi.types.u32, args = { ffi.types.pointer, ffi.types.u32 } },
	JPH_BodyInterface_SetMotionType = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.u32, ffi.types.u32 },
	},
	JPH_BodyInterface_GetRestitution = { returns = ffi.types.float, args = { ffi.types.pointer, ffi.types.u32 } },
	JPH_BodyInterface_SetRestitution = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.float },
	},
	JPH_BodyInterface_GetFriction = { returns = ffi.types.float, args = { ffi.types.pointer, ffi.types.u32 } },
	JPH_BodyInterface_SetFriction = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.float },
	},
	JPH_BodyInterface_SetPosition = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.pointer, ffi.types.u32 },
	},
	JPH_BodyInterface_GetPosition = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.pointer },
	},
	JPH_BodyInterface_SetRotation = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.pointer, ffi.types.u32 },
	},
	JPH_BodyInterface_GetRotation = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.pointer },
	},
	JPH_BodyInterface_SetPositionAndRotation = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.pointer, ffi.types.pointer, ffi.types.u32 },
	},
	JPH_BodyInterface_SetPositionAndRotationWhenChanged = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.pointer, ffi.types.pointer, ffi.types.u32 },
	},
	JPH_BodyInterface_SetPositionRotationAndVelocity = {
		returns = ffi.types.void,
		args = {
			ffi.types.pointer,
			ffi.types.u32,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
		},
	},
	JPH_BodyInterface_GetCollisionGroup = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.pointer },
	},
	JPH_BodyInterface_SetCollisionGroup = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.pointer },
	},
	JPH_BodyInterface_SetShape = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.pointer, ffi.types.u8, ffi.types.u32 },
	},
	JPH_BodyInterface_NotifyShapeChanged = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.pointer, ffi.types.u8, ffi.types.u32 },
	},
	JPH_BodyInterface_ActivateBody = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u32 } },
	JPH_BodyInterface_ActivateBodies = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u32 },
	},
	JPH_BodyInterface_ActivateBodiesInAABox = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_BodyInterface_DeactivateBody = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u32 } },
	JPH_BodyInterface_DeactivateBodies = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u32 },
	},
	JPH_BodyInterface_IsActive = { returns = ffi.types.u8, args = { ffi.types.pointer, ffi.types.u32 } },
	JPH_BodyInterface_ResetSleepTimer = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u32 } },
	JPH_BodyInterface_GetObjectLayer = { returns = ffi.types.u32, args = { ffi.types.pointer, ffi.types.u32 } },
	JPH_BodyInterface_SetObjectLayer = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.u32 },
	},
	JPH_BodyInterface_GetWorldTransform = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.pointer },
	},
	JPH_BodyInterface_GetCenterOfMassTransform = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.pointer },
	},
	JPH_BodyInterface_MoveKinematic = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.pointer, ffi.types.pointer, ffi.types.float },
	},
	JPH_BodyInterface_ApplyBuoyancyImpulse = {
		returns = ffi.types.u8,
		args = {
			ffi.types.pointer,
			ffi.types.u32,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.float,
			ffi.types.float,
			ffi.types.float,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.float,
		},
	},
	JPH_BodyInterface_SetLinearAndAngularVelocity = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_BodyInterface_GetLinearAndAngularVelocity = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_BodyInterface_AddLinearVelocity = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.pointer },
	},
	JPH_BodyInterface_AddLinearAndAngularVelocity = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_BodyInterface_SetAngularVelocity = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.pointer },
	},
	JPH_BodyInterface_GetAngularVelocity = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.pointer },
	},
	JPH_BodyInterface_GetPointVelocity = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_BodyInterface_AddForce = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.pointer },
	},
	JPH_BodyInterface_AddForce2 = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_BodyInterface_AddTorque = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.pointer },
	},
	JPH_BodyInterface_AddForceAndTorque = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_BodyInterface_AddImpulse = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.pointer },
	},
	JPH_BodyInterface_AddImpulse2 = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_BodyInterface_AddAngularImpulse = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.pointer },
	},
	JPH_BodyInterface_SetMotionQuality = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u8 },
	},
	JPH_BodyInterface_GetMotionQuality = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_BodyInterface_GetInverseInertia = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_BodyInterface_SetGravityFactor = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.float },
	},
	JPH_BodyInterface_GetGravityFactor = { returns = ffi.types.float, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_BodyInterface_SetUseManifoldReduction = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u8 },
	},
	JPH_BodyInterface_GetUseManifoldReduction = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_BodyInterface_SetUserData = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.u64 },
	},
	JPH_BodyInterface_GetUserData = { returns = ffi.types.u64, args = { ffi.types.pointer, ffi.types.u32 } },
	JPH_BodyInterface_SetIsSensor = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.u8 },
	},
	JPH_BodyInterface_IsSensor = { returns = ffi.types.u8, args = { ffi.types.pointer, ffi.types.u32 } },
	JPH_BodyInterface_InvalidateContactCache = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32 },
	},
	JPH_BodyLockInterface_LockRead = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.pointer },
	},
	JPH_BodyLockInterface_UnlockRead = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_BodyLockInterface_LockWrite = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.pointer },
	},
	JPH_BodyLockInterface_UnlockWrite = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_BodyLockMultiRead_Destroy = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_BodyLockMultiWrite_Destroy = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_MotionProperties_GetAllowedDOFs = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	JPH_MotionProperties_SetLinearDamping = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	JPH_MotionProperties_GetLinearDamping = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_MotionProperties_SetAngularDamping = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	JPH_MotionProperties_GetAngularDamping = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_MotionProperties_SetMassProperties = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_MotionProperties_GetInverseMassUnchecked = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_MotionProperties_SetInverseMass = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	JPH_MotionProperties_GetInverseInertiaDiagonal = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_MotionProperties_GetInertiaRotation = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_MotionProperties_SetInverseInertia = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_MotionProperties_ScaleToMass = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	JPH_RayCast_GetPointOnRay = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.float, ffi.types.pointer },
	},
	JPH_RRayCast_GetPointOnRay = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.float, ffi.types.pointer },
	},
	JPH_MassProperties_DecomposePrincipalMomentsOfInertia = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_MassProperties_ScaleToMass = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	JPH_MassProperties_GetEquivalentSolidBoxSize = {
		returns = ffi.types.void,
		args = { ffi.types.float, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_CollideShapeSettings_Init = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_ShapeCastSettings_Init = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_Body_GetID = { returns = ffi.types.u32, args = { ffi.types.pointer } },
	JPH_Body_GetBodyType = { returns = ffi.types.u32, args = { ffi.types.pointer } },
	JPH_Body_IsRigidBody = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	JPH_Body_IsSoftBody = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	JPH_Body_IsActive = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	JPH_Body_IsStatic = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	JPH_Body_IsKinematic = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	JPH_Body_IsDynamic = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	JPH_Body_CanBeKinematicOrDynamic = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	JPH_Body_SetIsSensor = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u8 } },
	JPH_Body_IsSensor = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	JPH_Body_SetCollideKinematicVsNonDynamic = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u8 } },
	JPH_Body_GetCollideKinematicVsNonDynamic = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	JPH_Body_SetUseManifoldReduction = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u8 } },
	JPH_Body_GetUseManifoldReduction = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	JPH_Body_GetUseManifoldReductionWithBody = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_Body_SetApplyGyroscopicForce = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u8 } },
	JPH_Body_GetApplyGyroscopicForce = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	JPH_Body_SetEnhancedInternalEdgeRemoval = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u8 } },
	JPH_Body_GetEnhancedInternalEdgeRemoval = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	JPH_Body_GetEnhancedInternalEdgeRemovalWithBody = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_Body_GetMotionType = { returns = ffi.types.u32, args = { ffi.types.pointer } },
	JPH_Body_SetMotionType = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u32 } },
	JPH_Body_GetBroadPhaseLayer = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	JPH_Body_GetObjectLayer = { returns = ffi.types.u32, args = { ffi.types.pointer } },
	JPH_Body_GetCollisionGroup = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_Body_SetCollisionGroup = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_Body_GetAllowSleeping = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	JPH_Body_SetAllowSleeping = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u8 } },
	JPH_Body_ResetSleepTimer = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_Body_GetFriction = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_Body_SetFriction = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	JPH_Body_GetRestitution = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_Body_SetRestitution = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	JPH_Body_GetLinearVelocity = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_Body_SetLinearVelocity = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_Body_SetLinearVelocityClamped = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_Body_GetAngularVelocity = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_Body_SetAngularVelocity = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_Body_SetAngularVelocityClamped = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_Body_GetPointVelocityCOM = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_Body_GetPointVelocity = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_Body_AddForce = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_Body_AddForceAtPosition = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_Body_AddTorque = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_Body_GetAccumulatedForce = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_Body_GetAccumulatedTorque = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_Body_ResetForce = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_Body_ResetTorque = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_Body_ResetMotion = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_Body_GetInverseInertia = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_Body_AddImpulse = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_Body_AddImpulseAtPosition = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_Body_AddAngularImpulse = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_Body_MoveKinematic = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.float },
	},
	JPH_Body_ApplyBuoyancyImpulse = {
		returns = ffi.types.u8,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.float,
			ffi.types.float,
			ffi.types.float,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.float,
		},
	},
	JPH_Body_IsInBroadPhase = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	JPH_Body_IsCollisionCacheInvalid = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	JPH_Body_GetPosition = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_Body_GetRotation = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_Body_GetWorldTransform = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_Body_GetCenterOfMassPosition = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_Body_GetCenterOfMassTransform = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_Body_GetInverseCenterOfMassTransform = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_Body_GetWorldSpaceBounds = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_Body_GetWorldSpaceSurfaceNormal = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_Body_SetUserData = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u64 } },
	JPH_Body_GetUserData = { returns = ffi.types.u64, args = { ffi.types.pointer } },
	JPH_BroadPhaseLayerFilter_SetProcs = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_BroadPhaseLayerFilter_Destroy = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_ObjectLayerFilter_SetProcs = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_ObjectLayerFilter_Destroy = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_BodyFilter_SetProcs = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_BodyFilter_Destroy = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_ShapeFilter_SetProcs = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_ShapeFilter_Destroy = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_ShapeFilter_GetBodyID2 = { returns = ffi.types.u32, args = { ffi.types.pointer } },
	JPH_ShapeFilter_SetBodyID2 = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u32 } },
	JPH_SimShapeFilter_SetProcs = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_SimShapeFilter_Destroy = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_ContactListener_SetProcs = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_ContactListener_Destroy = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_BodyActivationListener_SetProcs = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_BodyActivationListener_Destroy = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_BodyDrawFilter_SetProcs = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_BodyDrawFilter_Destroy = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_ContactManifold_GetWorldSpaceNormal = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_ContactManifold_GetPenetrationDepth = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_ContactManifold_GetSubShapeID1 = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	JPH_ContactManifold_GetSubShapeID2 = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	JPH_ContactManifold_GetPointCount = { returns = ffi.types.u32, args = { ffi.types.pointer } },
	JPH_ContactManifold_GetWorldSpaceContactPointOn1 = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.pointer },
	},
	JPH_ContactManifold_GetWorldSpaceContactPointOn2 = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.pointer },
	},
	JPH_CharacterBase_Destroy = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_CharacterBase_GetCosMaxSlopeAngle = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_CharacterBase_SetMaxSlopeAngle = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	JPH_CharacterBase_GetUp = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_CharacterBase_SetUp = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_CharacterBase_IsSlopeTooSteep = { returns = ffi.types.u8, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_CharacterBase_GetGroundState = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	JPH_CharacterBase_IsSupported = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	JPH_CharacterBase_GetGroundPosition = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_CharacterBase_GetGroundNormal = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_CharacterBase_GetGroundVelocity = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_CharacterBase_GetGroundBodyId = { returns = ffi.types.u32, args = { ffi.types.pointer } },
	JPH_CharacterBase_GetGroundSubShapeId = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	JPH_CharacterBase_GetGroundUserData = { returns = ffi.types.u64, args = { ffi.types.pointer } },
	JPH_CharacterSettings_Init = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_Character_AddToPhysicsSystem = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_Character_RemoveFromPhysicsSystem = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_Character_Activate = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_Character_PostSimulation = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.pointer },
	},
	JPH_Character_SetLinearAndAngularVelocity = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_Character_GetLinearVelocity = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_Character_SetLinearVelocity = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_Character_AddLinearVelocity = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_Character_AddImpulse = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_Character_GetBodyID = { returns = ffi.types.u32, args = { ffi.types.pointer } },
	JPH_Character_GetPositionAndRotation = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_Character_SetPositionAndRotation = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_Character_GetPosition = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_Character_SetPosition = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_Character_GetRotation = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_Character_SetRotation = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_Character_GetCenterOfMassPosition = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_Character_GetWorldTransform = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_Character_GetLayer = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	JPH_Character_SetLayer = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_Character_SetShape = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.float, ffi.types.pointer },
	},
	JPH_CharacterVirtualSettings_Init = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_CharacterVirtual_GetID = { returns = ffi.types.u32, args = { ffi.types.pointer } },
	JPH_CharacterVirtual_SetListener = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_CharacterVirtual_SetCharacterVsCharacterCollision = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_CharacterVirtual_GetLinearVelocity = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_CharacterVirtual_SetLinearVelocity = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_CharacterVirtual_GetPosition = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_CharacterVirtual_SetPosition = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_CharacterVirtual_GetRotation = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_CharacterVirtual_SetRotation = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_CharacterVirtual_GetWorldTransform = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_CharacterVirtual_GetCenterOfMassTransform = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_CharacterVirtual_GetMass = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_CharacterVirtual_SetMass = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	JPH_CharacterVirtual_GetMaxStrength = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_CharacterVirtual_SetMaxStrength = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	JPH_CharacterVirtual_GetPenetrationRecoverySpeed = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_CharacterVirtual_SetPenetrationRecoverySpeed = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float },
	},
	JPH_CharacterVirtual_GetEnhancedInternalEdgeRemoval = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	JPH_CharacterVirtual_SetEnhancedInternalEdgeRemoval = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u8 },
	},
	JPH_CharacterVirtual_GetCharacterPadding = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_CharacterVirtual_GetMaxNumHits = { returns = ffi.types.u32, args = { ffi.types.pointer } },
	JPH_CharacterVirtual_SetMaxNumHits = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u32 } },
	JPH_CharacterVirtual_GetHitReductionCosMaxAngle = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_CharacterVirtual_SetHitReductionCosMaxAngle = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float },
	},
	JPH_CharacterVirtual_GetMaxHitsExceeded = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	JPH_CharacterVirtual_GetShapeOffset = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_CharacterVirtual_SetShapeOffset = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_CharacterVirtual_GetUserData = { returns = ffi.types.u64, args = { ffi.types.pointer } },
	JPH_CharacterVirtual_SetUserData = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u64 } },
	JPH_CharacterVirtual_GetInnerBodyID = { returns = ffi.types.u32, args = { ffi.types.pointer } },
	JPH_CharacterVirtual_CancelVelocityTowardsSteepSlopes = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_CharacterVirtual_StartTrackingContactChanges = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_CharacterVirtual_FinishTrackingContactChanges = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_CharacterVirtual_Update = {
		returns = ffi.types.void,
		args = {
			ffi.types.pointer,
			ffi.types.float,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
		},
	},
	JPH_CharacterVirtual_RefreshContacts = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_CharacterVirtual_CanWalkStairs = { returns = ffi.types.u8, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_CharacterVirtual_UpdateGroundVelocity = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_CharacterVirtual_SetShape = {
		returns = ffi.types.u8,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.float,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
		},
	},
	JPH_CharacterVirtual_SetInnerBodyShape = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_CharacterVirtual_GetNumActiveContacts = { returns = ffi.types.u32, args = { ffi.types.pointer } },
	JPH_CharacterVirtual_GetActiveContact = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.pointer },
	},
	JPH_CharacterVirtual_HasCollidedWithBody = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_CharacterVirtual_HasCollidedWith = { returns = ffi.types.u8, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_CharacterVirtual_HasCollidedWithCharacter = {
		returns = ffi.types.u8,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_CharacterContactListener_SetProcs = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_CharacterContactListener_Destroy = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_CharacterVsCharacterCollision_SetProcs = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_CharacterVsCharacterCollisionSimple_AddCharacter = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_CharacterVsCharacterCollisionSimple_RemoveCharacter = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_CharacterVsCharacterCollision_Destroy = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_DebugRenderer_SetProcs = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_DebugRenderer_Destroy = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_DebugRenderer_NextFrame = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_DebugRenderer_SetCameraPos = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_DebugRenderer_DrawLine = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_DebugRenderer_DrawWireBox = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_DebugRenderer_DrawWireBox2 = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_DebugRenderer_DrawMarker = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.float },
	},
	JPH_DebugRenderer_DrawArrow = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.float },
	},
	JPH_DebugRenderer_DrawCoordinateSystem = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.float },
	},
	JPH_DebugRenderer_DrawPlane = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.float },
	},
	JPH_DebugRenderer_DrawWireTriangle = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_DebugRenderer_DrawWireSphere = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.float, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_DebugRenderer_DrawWireUnitSphere = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_DebugRenderer_DrawTriangle = {
		returns = ffi.types.void,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
		},
	},
	JPH_DebugRenderer_DrawBox = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_DebugRenderer_DrawBox2 = {
		returns = ffi.types.void,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
		},
	},
	JPH_DebugRenderer_DrawSphere = {
		returns = ffi.types.void,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.float,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
		},
	},
	JPH_DebugRenderer_DrawUnitSphere = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_DebugRenderer_DrawCapsule = {
		returns = ffi.types.void,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.float,
			ffi.types.float,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
		},
	},
	JPH_DebugRenderer_DrawCylinder = {
		returns = ffi.types.void,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.float,
			ffi.types.float,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
		},
	},
	JPH_DebugRenderer_DrawOpenCone = {
		returns = ffi.types.void,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.float,
			ffi.types.float,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
		},
	},
	JPH_DebugRenderer_DrawSwingConeLimits = {
		returns = ffi.types.void,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.float,
			ffi.types.float,
			ffi.types.float,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
		},
	},
	JPH_DebugRenderer_DrawSwingPyramidLimits = {
		returns = ffi.types.void,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.float,
			ffi.types.float,
			ffi.types.float,
			ffi.types.float,
			ffi.types.float,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
		},
	},
	JPH_DebugRenderer_DrawPie = {
		returns = ffi.types.void,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.float,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.float,
			ffi.types.float,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
		},
	},
	JPH_DebugRenderer_DrawTaperedCylinder = {
		returns = ffi.types.void,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.float,
			ffi.types.float,
			ffi.types.float,
			ffi.types.float,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
		},
	},
	JPH_Skeleton_Destroy = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_Skeleton_AddJoint = { returns = ffi.types.u32, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_Skeleton_AddJoint2 = {
		returns = ffi.types.u32,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_Skeleton_AddJoint3 = {
		returns = ffi.types.u32,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_Skeleton_GetJointCount = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	JPH_Skeleton_GetJoint = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_Skeleton_GetJointIndex = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_Skeleton_CalculateParentJointIndices = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_Skeleton_AreJointsCorrectlyOrdered = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	JPH_RagdollSettings_Destroy = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_RagdollSettings_SetSkeleton = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_RagdollSettings_Stabilize = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	JPH_RagdollSettings_DisableParentChildCollisions = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_RagdollSettings_CalculateBodyIndexToConstraintIndex = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_RagdollSettings_GetConstraintIndexForBodyIndex = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_RagdollSettings_CalculateConstraintIndexToBodyIdxPair = {
		returns = ffi.types.void,
		args = { ffi.types.pointer },
	},
	JPH_Ragdoll_Destroy = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_Ragdoll_AddToPhysicsSystem = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_Ragdoll_RemoveFromPhysicsSystem = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_Ragdoll_Activate = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_Ragdoll_IsActive = { returns = ffi.types.u8, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_Ragdoll_ResetWarmStart = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_EstimateCollisionResponse = {
		returns = ffi.types.void,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.float,
			ffi.types.float,
			ffi.types.float,
			ffi.types.u32,
			ffi.types.pointer,
		},
	},
	JPH_VehicleConstraintSettings_Init = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_VehicleConstraint_SetMaxPitchRollAngle = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float },
	},
	JPH_VehicleConstraint_SetVehicleCollisionTester = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_VehicleConstraint_OverrideGravity = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_VehicleConstraint_IsGravityOverridden = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	JPH_VehicleConstraint_GetGravityOverride = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_VehicleConstraint_ResetGravityOverride = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_VehicleConstraint_GetLocalForward = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_VehicleConstraint_GetLocalUp = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_VehicleConstraint_GetWorldUp = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_VehicleConstraint_GetWheelsCount = { returns = ffi.types.u32, args = { ffi.types.pointer } },
	JPH_VehicleConstraint_GetWheelLocalBasis = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_VehicleConstraint_GetWheelLocalTransform = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_VehicleConstraint_GetWheelWorldTransform = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	JPH_WheelSettings_Destroy = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_WheelSettings_GetPosition = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_WheelSettings_SetPosition = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_WheelSettings_GetSuspensionForcePoint = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_WheelSettings_SetSuspensionForcePoint = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_WheelSettings_GetSuspensionDirection = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_WheelSettings_SetSuspensionDirection = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_WheelSettings_GetSteeringAxis = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_WheelSettings_SetSteeringAxis = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_WheelSettings_GetWheelUp = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_WheelSettings_SetWheelUp = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_WheelSettings_GetWheelForward = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_WheelSettings_SetWheelForward = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_WheelSettings_GetSuspensionMinLength = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_WheelSettings_SetSuspensionMinLength = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float },
	},
	JPH_WheelSettings_GetSuspensionMaxLength = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_WheelSettings_SetSuspensionMaxLength = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float },
	},
	JPH_WheelSettings_GetSuspensionPreloadLength = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_WheelSettings_SetSuspensionPreloadLength = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float },
	},
	JPH_WheelSettings_GetSuspensionSpring = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_WheelSettings_SetSuspensionSpring = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_WheelSettings_GetRadius = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_WheelSettings_SetRadius = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	JPH_WheelSettings_GetWidth = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_WheelSettings_SetWidth = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	JPH_WheelSettings_GetEnableSuspensionForcePoint = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	JPH_WheelSettings_SetEnableSuspensionForcePoint = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u8 },
	},
	JPH_Wheel_Destroy = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_Wheel_GetAngularVelocity = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_Wheel_SetAngularVelocity = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	JPH_Wheel_GetRotationAngle = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_Wheel_SetRotationAngle = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	JPH_Wheel_GetSteerAngle = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_Wheel_SetSteerAngle = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	JPH_Wheel_HasContact = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	JPH_Wheel_GetContactBodyID = { returns = ffi.types.u32, args = { ffi.types.pointer } },
	JPH_Wheel_GetContactSubShapeID = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	JPH_Wheel_GetContactPosition = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_Wheel_GetContactPointVelocity = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_Wheel_GetContactNormal = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_Wheel_GetContactLongitudinal = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_Wheel_GetContactLateral = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	JPH_Wheel_GetSuspensionLength = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_Wheel_GetSuspensionLambda = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_Wheel_GetLongitudinalLambda = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_Wheel_GetLateralLambda = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_Wheel_HasHitHardPoint = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	JPH_VehicleAntiRollBar_Init = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_VehicleEngineSettings_Init = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_VehicleEngine_ClampRPM = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_VehicleEngine_GetCurrentRPM = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_VehicleEngine_SetCurrentRPM = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	JPH_VehicleEngine_GetAngularVelocity = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_VehicleEngine_GetTorque = { returns = ffi.types.float, args = { ffi.types.pointer, ffi.types.float } },
	JPH_VehicleEngine_ApplyTorque = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.float },
	},
	JPH_VehicleEngine_ApplyDamping = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	JPH_VehicleEngine_AllowSleep = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	JPH_VehicleDifferentialSettings_Init = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_VehicleTransmissionSettings_Destroy = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_VehicleTransmissionSettings_GetMode = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	JPH_VehicleTransmissionSettings_SetMode = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_VehicleTransmissionSettings_GetGearRatioCount = { returns = ffi.types.u32, args = { ffi.types.pointer } },
	JPH_VehicleTransmissionSettings_GetGearRatio = {
		returns = ffi.types.float,
		args = { ffi.types.pointer, ffi.types.u32 },
	},
	JPH_VehicleTransmissionSettings_SetGearRatio = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.float },
	},
	JPH_VehicleTransmissionSettings_SetGearRatios = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u32 },
	},
	JPH_VehicleTransmissionSettings_GetReverseGearRatioCount = { returns = ffi.types.u32, args = { ffi.types.pointer } },
	JPH_VehicleTransmissionSettings_GetReverseGearRatio = {
		returns = ffi.types.float,
		args = { ffi.types.pointer, ffi.types.u32 },
	},
	JPH_VehicleTransmissionSettings_SetReverseGearRatio = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.float },
	},
	JPH_VehicleTransmissionSettings_SetReverseGearRatios = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u32 },
	},
	JPH_VehicleTransmissionSettings_GetSwitchTime = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_VehicleTransmissionSettings_SetSwitchTime = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float },
	},
	JPH_VehicleTransmissionSettings_GetClutchReleaseTime = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_VehicleTransmissionSettings_SetClutchReleaseTime = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float },
	},
	JPH_VehicleTransmissionSettings_GetSwitchLatency = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_VehicleTransmissionSettings_SetSwitchLatency = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float },
	},
	JPH_VehicleTransmissionSettings_GetShiftUpRPM = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_VehicleTransmissionSettings_SetShiftUpRPM = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float },
	},
	JPH_VehicleTransmissionSettings_GetShiftDownRPM = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_VehicleTransmissionSettings_SetShiftDownRPM = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float },
	},
	JPH_VehicleTransmissionSettings_GetClutchStrength = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_VehicleTransmissionSettings_SetClutchStrength = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float },
	},
	JPH_VehicleTransmission_Set = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.float },
	},
	JPH_VehicleTransmission_Update = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.float, ffi.types.float, ffi.types.u8 },
	},
	JPH_VehicleTransmission_GetCurrentGear = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	JPH_VehicleTransmission_GetClutchFriction = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_VehicleTransmission_IsSwitchingGear = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	JPH_VehicleTransmission_GetCurrentRatio = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_VehicleTransmission_AllowSleep = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	JPH_VehicleCollisionTester_Destroy = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_VehicleCollisionTester_GetObjectLayer = { returns = ffi.types.u32, args = { ffi.types.pointer } },
	JPH_VehicleCollisionTester_SetObjectLayer = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32 },
	},
	JPH_VehicleControllerSettings_Destroy = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_WheelSettingsWV_GetInertia = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_WheelSettingsWV_SetInertia = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	JPH_WheelSettingsWV_GetAngularDamping = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_WheelSettingsWV_SetAngularDamping = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	JPH_WheelSettingsWV_GetMaxSteerAngle = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_WheelSettingsWV_SetMaxSteerAngle = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	JPH_WheelSettingsWV_SetLongitudinalFriction = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_WheelSettingsWV_SetLateralFriction = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_WheelSettingsWV_GetMaxBrakeTorque = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_WheelSettingsWV_SetMaxBrakeTorque = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	JPH_WheelSettingsWV_GetMaxHandBrakeTorque = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_WheelSettingsWV_SetMaxHandBrakeTorque = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float },
	},
	JPH_WheelWV_ApplyTorque = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.float },
	},
	JPH_WheeledVehicleControllerSettings_GetEngine = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_WheeledVehicleControllerSettings_SetEngine = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_WheeledVehicleControllerSettings_SetTransmission = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_WheeledVehicleControllerSettings_GetDifferentialsCount = {
		returns = ffi.types.u32,
		args = { ffi.types.pointer },
	},
	JPH_WheeledVehicleControllerSettings_SetDifferentialsCount = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32 },
	},
	JPH_WheeledVehicleControllerSettings_GetDifferential = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.pointer },
	},
	JPH_WheeledVehicleControllerSettings_SetDifferential = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.pointer },
	},
	JPH_WheeledVehicleControllerSettings_SetDifferentials = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u32 },
	},
	JPH_WheeledVehicleControllerSettings_GetDifferentialLimitedSlipRatio = {
		returns = ffi.types.float,
		args = { ffi.types.pointer },
	},
	JPH_WheeledVehicleControllerSettings_SetDifferentialLimitedSlipRatio = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float },
	},
	JPH_WheeledVehicleController_SetDriverInput = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.float, ffi.types.float, ffi.types.float },
	},
	JPH_WheeledVehicleController_SetForwardInput = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float },
	},
	JPH_WheeledVehicleController_GetForwardInput = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_WheeledVehicleController_SetRightInput = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float },
	},
	JPH_WheeledVehicleController_GetRightInput = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_WheeledVehicleController_SetBrakeInput = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float },
	},
	JPH_WheeledVehicleController_GetBrakeInput = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_WheeledVehicleController_SetHandBrakeInput = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float },
	},
	JPH_WheeledVehicleController_GetHandBrakeInput = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_WheeledVehicleController_GetWheelSpeedAtClutch = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_WheeledVehicleController_SetTireMaxImpulseCallback = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_WheelSettingsTV_GetLongitudinalFriction = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_WheelSettingsTV_SetLongitudinalFriction = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float },
	},
	JPH_WheelSettingsTV_GetLateralFriction = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_WheelSettingsTV_SetLateralFriction = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	JPH_TrackedVehicleControllerSettings_GetEngine = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_TrackedVehicleControllerSettings_SetEngine = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_TrackedVehicleControllerSettings_SetTransmission = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer },
	},
	JPH_TrackedVehicleController_SetDriverInput = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.float, ffi.types.float, ffi.types.float },
	},
	JPH_TrackedVehicleController_GetForwardInput = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_TrackedVehicleController_SetForwardInput = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float },
	},
	JPH_TrackedVehicleController_GetLeftRatio = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_TrackedVehicleController_SetLeftRatio = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float },
	},
	JPH_TrackedVehicleController_GetRightRatio = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_TrackedVehicleController_SetRightRatio = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float },
	},
	JPH_TrackedVehicleController_GetBrakeInput = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_TrackedVehicleController_SetBrakeInput = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float },
	},
	JPH_MotorcycleControllerSettings_GetMaxLeanAngle = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_MotorcycleControllerSettings_SetMaxLeanAngle = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float },
	},
	JPH_MotorcycleControllerSettings_GetLeanSpringConstant = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_MotorcycleControllerSettings_SetLeanSpringConstant = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float },
	},
	JPH_MotorcycleControllerSettings_GetLeanSpringDamping = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_MotorcycleControllerSettings_SetLeanSpringDamping = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float },
	},
	JPH_MotorcycleControllerSettings_GetLeanSpringIntegrationCoefficient = {
		returns = ffi.types.float,
		args = { ffi.types.pointer },
	},
	JPH_MotorcycleControllerSettings_SetLeanSpringIntegrationCoefficient = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float },
	},
	JPH_MotorcycleControllerSettings_GetLeanSpringIntegrationCoefficientDecay = {
		returns = ffi.types.float,
		args = { ffi.types.pointer },
	},
	JPH_MotorcycleControllerSettings_SetLeanSpringIntegrationCoefficientDecay = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float },
	},
	JPH_MotorcycleControllerSettings_GetLeanSmoothingFactor = {
		returns = ffi.types.float,
		args = { ffi.types.pointer },
	},
	JPH_MotorcycleControllerSettings_SetLeanSmoothingFactor = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float },
	},
	JPH_MotorcycleController_GetWheelBase = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_MotorcycleController_IsLeanControllerEnabled = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	JPH_MotorcycleController_EnableLeanController = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u8 },
	},
	JPH_MotorcycleController_IsLeanSteeringLimitEnabled = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	JPH_MotorcycleController_EnableLeanSteeringLimit = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.u8 },
	},
	JPH_MotorcycleController_GetLeanSpringConstant = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_MotorcycleController_SetLeanSpringConstant = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float },
	},
	JPH_MotorcycleController_GetLeanSpringDamping = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_MotorcycleController_SetLeanSpringDamping = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float },
	},
	JPH_MotorcycleController_GetLeanSpringIntegrationCoefficient = {
		returns = ffi.types.float,
		args = { ffi.types.pointer },
	},
	JPH_MotorcycleController_SetLeanSpringIntegrationCoefficient = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float },
	},
	JPH_MotorcycleController_GetLeanSpringIntegrationCoefficientDecay = {
		returns = ffi.types.float,
		args = { ffi.types.pointer },
	},
	JPH_MotorcycleController_SetLeanSpringIntegrationCoefficientDecay = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float },
	},
	JPH_MotorcycleController_GetLeanSmoothingFactor = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_MotorcycleController_SetLeanSmoothingFactor = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float },
	},
	JPH_LinearCurve_Destroy = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_LinearCurve_Clear = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_LinearCurve_Reserve = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u32 } },
	JPH_LinearCurve_AddPoint = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.float, ffi.types.float },
	},
	JPH_LinearCurve_Sort = { returns = ffi.types.void, args = { ffi.types.pointer } },
	JPH_LinearCurve_GetMinX = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_LinearCurve_GetMaxX = { returns = ffi.types.float, args = { ffi.types.pointer } },
	JPH_LinearCurve_GetValue = { returns = ffi.types.float, args = { ffi.types.pointer, ffi.types.float } },
	JPH_LinearCurve_GetPointCount = { returns = ffi.types.u32, args = { ffi.types.pointer } },
	JPH_LinearCurve_GetPoint = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.u32 } },
	JPH_LinearCurve_GetPoints = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u32 },
	},
}

return funcs
