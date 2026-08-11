
#pragma once

#include <cstdint>

// Export/import decoration
#if defined(_WIN32) || defined(__CYGWIN__)
  #ifdef JOLT_WRAPPER_EXPORTS
    #define JPH_API __declspec(dllexport)
  #else
    #define JPH_API __declspec(dllimport)
  #endif
#else
  #define JPH_API __attribute__((visibility("default")))
#endif

#ifdef __cplusplus
extern "C" {
#endif

typedef struct JPH_Vec3
{
    float x;
    float y;
    float z;
} JPH_Vec3;

typedef struct JPH_RVec3
{
    double x;
    double y;
    double z;
} JPH_RVec3;

typedef struct JPH_Quat
{
    float x;
    float y;
    float z;
    float w;
} JPH_Quat;

typedef void* JPH_ShapeRef;
typedef void* JPH_BodyCreationSettingsRef;
typedef void* JPH_BodyRef;                 // JPH::Body*
typedef uint32_t JPH_BodyID;               // packed JPH::BodyID
typedef void* JPH_PhysicsSystemRef;
typedef void* JPH_BodyInterfaceRef;
typedef void* JPH_JobSystemRef;
typedef void* JPH_BroadPhaseLayerInterfaceRef;
typedef void* JPH_ObjectLayerPairFilterRef;
typedef void* JPH_ObjectVsBroadPhaseLayerFilterRef;
typedef void* JPH_MotionPropertiesRef;
typedef void* JPH_ContactListenerRef;

typedef struct JPH_PhysicsSystemSettings
{
    uint32_t maxBodies;
    uint32_t numBodyMutexes;               // 0 = let Jolt pick a default
    uint32_t maxBodyPairs;
    uint32_t maxContactConstraints;
    uint32_t _padding;
    JPH_BroadPhaseLayerInterfaceRef broadPhaseLayerInterface;
    JPH_ObjectLayerPairFilterRef objectLayerPairFilter;
    JPH_ObjectVsBroadPhaseLayerFilterRef objectVsBroadPhaseLayerFilter;
} JPH_PhysicsSystemSettings;

typedef void (*JPH_QueueJobFunction)(void* context, void* job);
typedef void (*JPH_QueueJobsFunction)(void* context, void** jobs, uint32_t numJobs);

typedef struct JPH_JobSystemConfig
{
    void* context;
    JPH_QueueJobFunction queueJob;
    JPH_QueueJobsFunction queueJobs;
    uint32_t maxConcurrency;
    uint32_t maxBarriers;
} JPH_JobSystemConfig;

typedef struct JPH_ContactManifoldData
{
    JPH_Vec3 normal;             // world-space contact normal, body1 -> body2
    float penetrationDepth;
    uint32_t numContactPoints;   // 0..4, number of valid entries in contactPoints
    JPH_RVec3 contactPoints[4];  // world-space points on body1's surface
} JPH_ContactManifoldData;

typedef void (*JPH_ContactAddedCallback)(
    JPH_BodyID body1,
    JPH_BodyID body2,
    const JPH_ContactManifoldData* manifold
);

typedef void (*JPH_ContactPersistedCallback)(
    JPH_BodyID body1,
    JPH_BodyID body2,
    const JPH_ContactManifoldData* manifold
);

typedef void (*JPH_ContactRemovedCallback)(
    JPH_BodyID body1,
    JPH_BodyID body2,
    uint32_t subShapeID1,
    uint32_t subShapeID2
);

typedef struct JPH_ContactListener_Procs
{
    JPH_ContactAddedCallback OnContactAdded;
    JPH_ContactPersistedCallback OnContactPersisted;
    JPH_ContactRemovedCallback OnContactRemoved;
} JPH_ContactListener_Procs;

// Returns 1 on success, 0 on failure (already initialized counts as failure).
JPH_API int32_t JPH_Init(void);
JPH_API void JPH_Shutdown(void);

JPH_API JPH_JobSystemRef JPH_JobSystemThreadPool_Create(const JPH_JobSystemConfig* config);
JPH_API void JPH_JobSystem_Destroy(JPH_JobSystemRef jobSystem);

JPH_API JPH_BroadPhaseLayerInterfaceRef JPH_BroadPhaseLayerInterfaceTable_Create(
    uint32_t numObjectLayers,
    uint32_t numBroadPhaseLayers
);

JPH_API void JPH_BroadPhaseLayerInterfaceTable_MapObjectToBroadPhaseLayer(
    JPH_BroadPhaseLayerInterfaceRef bpInterface,
    uint32_t objectLayer,
    uint32_t broadPhaseLayer
);

JPH_API JPH_ObjectLayerPairFilterRef JPH_ObjectLayerPairFilterTable_Create(uint32_t numObjectLayers);

JPH_API void JPH_ObjectLayerPairFilterTable_EnableCollision(
    JPH_ObjectLayerPairFilterRef filter,
    uint32_t layer1,
    uint32_t layer2
);

JPH_API void JPH_ObjectLayerPairFilterTable_DisableCollision(
    JPH_ObjectLayerPairFilterRef filter,
    uint32_t layer1,
    uint32_t layer2
);

JPH_API JPH_ObjectVsBroadPhaseLayerFilterRef JPH_ObjectVsBroadPhaseLayerFilterTable_Create(
    JPH_BroadPhaseLayerInterfaceRef bpInterface,
    uint32_t numBroadPhaseLayers,
    JPH_ObjectLayerPairFilterRef objectLayerPairFilter,
    uint32_t numObjectLayers
);

JPH_API JPH_ShapeRef JPH_BoxShape_Create(const JPH_Vec3* halfExtent, float convexRadius);
JPH_API JPH_ShapeRef JPH_SphereShape_Create(float radius);

JPH_API JPH_BodyCreationSettingsRef JPH_BodyCreationSettings_Create3(
    JPH_ShapeRef shape,
    const JPH_RVec3* position,
    const JPH_Quat* rotation,
    int32_t motionType,
    uint32_t objectLayer
);

JPH_API void JPH_BodyCreationSettings_Destroy(JPH_BodyCreationSettingsRef settings);

JPH_API void JPH_BodyCreationSettings_SetAllowSleeping(JPH_BodyCreationSettingsRef settings, int32_t allow);
JPH_API void JPH_BodyCreationSettings_SetAllowDynamicOrKinematic(JPH_BodyCreationSettingsRef settings, int32_t allow);
JPH_API void JPH_BodyCreationSettings_SetFriction(JPH_BodyCreationSettingsRef settings, float friction);
JPH_API void JPH_BodyCreationSettings_SetRestitution(JPH_BodyCreationSettingsRef settings, float restitution);
JPH_API void JPH_BodyCreationSettings_SetLinearDamping(JPH_BodyCreationSettingsRef settings, float damping);
JPH_API void JPH_BodyCreationSettings_SetAngularDamping(JPH_BodyCreationSettingsRef settings, float damping);
JPH_API void JPH_BodyCreationSettings_SetGravityFactor(JPH_BodyCreationSettingsRef settings, float factor);

JPH_API JPH_PhysicsSystemRef JPH_PhysicsSystem_Create(const JPH_PhysicsSystemSettings* settings);
JPH_API void JPH_PhysicsSystem_Destroy(JPH_PhysicsSystemRef system);
JPH_API JPH_BodyInterfaceRef JPH_PhysicsSystem_GetBodyInterface(JPH_PhysicsSystemRef system);
JPH_API void JPH_PhysicsSystem_SetGravity(JPH_PhysicsSystemRef system, const JPH_Vec3* gravity);
JPH_API void JPH_PhysicsSystem_Update(
    JPH_PhysicsSystemRef system,
    float deltaTime,
    int32_t collisionSteps,
    JPH_JobSystemRef jobSystem
);
JPH_API void JPH_PhysicsSystem_OptimizeBroadPhase(JPH_PhysicsSystemRef system);
JPH_API void JPH_PhysicsSystem_SetContactListener(JPH_PhysicsSystemRef system, JPH_ContactListenerRef listener);

JPH_API JPH_BodyRef JPH_BodyInterface_CreateBody(JPH_BodyInterfaceRef bodyInterface, JPH_BodyCreationSettingsRef settings);
JPH_API void JPH_BodyInterface_AddBody(JPH_BodyInterfaceRef bodyInterface, JPH_BodyID bodyID, int32_t activationMode);
JPH_API void JPH_BodyInterface_RemoveAndDestroyBody(JPH_BodyInterfaceRef bodyInterface, JPH_BodyID bodyID);

JPH_API void JPH_BodyInterface_SetShape(
    JPH_BodyInterfaceRef bodyInterface,
    JPH_BodyID bodyID,
    JPH_ShapeRef shape,
    int32_t updateMassProperties,
    int32_t activationMode
);

JPH_API void JPH_BodyInterface_SetMotionType(
    JPH_BodyInterfaceRef bodyInterface,
    JPH_BodyID bodyID,
    int32_t motionType,
    int32_t activationMode
);

JPH_API void JPH_BodyInterface_SetObjectLayer(JPH_BodyInterfaceRef bodyInterface, JPH_BodyID bodyID, uint32_t layer);

JPH_API void JPH_BodyInterface_ActivateBody(JPH_BodyInterfaceRef bodyInterface, JPH_BodyID bodyID);
JPH_API int32_t JPH_BodyInterface_IsActive(JPH_BodyInterfaceRef bodyInterface, JPH_BodyID bodyID);
JPH_API int32_t JPH_BodyInterface_IsAdded(JPH_BodyInterfaceRef bodyInterface, JPH_BodyID bodyID);

JPH_API void JPH_BodyInterface_SetPosition(
    JPH_BodyInterfaceRef bodyInterface,
    JPH_BodyID bodyID,
    const JPH_RVec3* position,
    int32_t activationMode
);

JPH_API void JPH_BodyInterface_SetPositionAndRotation(
    JPH_BodyInterfaceRef bodyInterface,
    JPH_BodyID bodyID,
    const JPH_RVec3* position,
    const JPH_Quat* rotation,
    int32_t activationMode
);

JPH_API void JPH_BodyInterface_SetRotation(
    JPH_BodyInterfaceRef bodyInterface,
    JPH_BodyID bodyID,
    const JPH_Quat* rotation,
    int32_t activationMode
);

JPH_API void JPH_BodyInterface_SetLinearVelocity(JPH_BodyInterfaceRef bodyInterface, JPH_BodyID bodyID, const JPH_Vec3* velocity);
JPH_API void JPH_BodyInterface_SetAngularVelocity(JPH_BodyInterfaceRef bodyInterface, JPH_BodyID bodyID, const JPH_Vec3* velocity);

JPH_API void JPH_BodyInterface_GetPosition(JPH_BodyInterfaceRef bodyInterface, JPH_BodyID bodyID, JPH_RVec3* outPosition);

JPH_API void JPH_BodyInterface_GetPositionAndRotation(
    JPH_BodyInterfaceRef bodyInterface,
    JPH_BodyID bodyID,
    JPH_RVec3* outPosition,
    JPH_Quat* outRotation
);

JPH_API void JPH_BodyInterface_GetRotation(JPH_BodyInterfaceRef bodyInterface, JPH_BodyID bodyID, JPH_Quat* outRotation);
JPH_API void JPH_BodyInterface_GetLinearVelocity(JPH_BodyInterfaceRef bodyInterface, JPH_BodyID bodyID, JPH_Vec3* outVelocity);
JPH_API void JPH_BodyInterface_GetAngularVelocity(JPH_BodyInterfaceRef bodyInterface, JPH_BodyID bodyID, JPH_Vec3* outVelocity);

JPH_API void JPH_BodyInterface_AddImpulse(JPH_BodyInterfaceRef bodyInterface, JPH_BodyID bodyID, const JPH_Vec3* impulse);
JPH_API void JPH_BodyInterface_AddForce(JPH_BodyInterfaceRef bodyInterface, JPH_BodyID bodyID, const JPH_Vec3* force);

JPH_API void JPH_BodyInterface_AddForce2(
    JPH_BodyInterfaceRef bodyInterface,
    JPH_BodyID bodyID,
    const JPH_Vec3* force,
    const JPH_RVec3* position
);

JPH_API void JPH_BodyInterface_AddTorque(JPH_BodyInterfaceRef bodyInterface, JPH_BodyID bodyID, const JPH_Vec3* torque);

JPH_API JPH_BodyID JPH_Body_GetID(JPH_BodyRef body);
JPH_API JPH_MotionPropertiesRef JPH_Body_GetMotionProperties(JPH_BodyRef body);
JPH_API void JPH_Body_SetFriction(JPH_BodyRef body, float friction);

JPH_API void JPH_MotionProperties_ScaleToMass(JPH_MotionPropertiesRef motionProperties, float mass);

JPH_API JPH_ContactListenerRef JPH_ContactListener_Create(void);
JPH_API void JPH_ContactListener_Destroy(JPH_ContactListenerRef listener);
JPH_API uint32_t JPH_ContactListener_PollEvents(
    JPH_ContactListenerRef listener,
    const JPH_ContactListener_Procs* procs,
    uint32_t maxEvents
);

#ifdef __cplusplus
}
#endif