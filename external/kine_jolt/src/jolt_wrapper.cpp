
#include "jph_api.h"

#include <Jolt/Jolt.h>
#include <Jolt/RegisterTypes.h>
#include <Jolt/Core/Factory.h>
#include <Jolt/Core/TempAllocator.h>
#include <Jolt/Core/JobSystemThreadPool.h>
#include <Jolt/Physics/PhysicsSettings.h>
#include <Jolt/Physics/PhysicsSystem.h>
#include <Jolt/Physics/Collision/Shape/BoxShape.h>
#include <Jolt/Physics/Collision/Shape/SphereShape.h>
#include <Jolt/Physics/Body/Body.h>
#include <Jolt/Physics/Body/BodyCreationSettings.h>
#include <Jolt/Physics/Body/BodyInterface.h>
#include <Jolt/Physics/Body/MotionProperties.h>
#include <Jolt/Physics/Collision/ContactListener.h>

#include <vector>
#include <deque>
#include <mutex>
#include <algorithm>
#include <cstring>

namespace
{

inline JPH::Vec3 ToJPH(const JPH_Vec3& v)
{
    return JPH::Vec3(v.x, v.y, v.z);
}

inline JPH::RVec3 ToJPH(const JPH_RVec3& v)
{
    return JPH::RVec3(
        static_cast<JPH::Real>(v.x),
        static_cast<JPH::Real>(v.y),
        static_cast<JPH::Real>(v.z)
    );
}

inline JPH::Quat ToJPH(const JPH_Quat& q)
{
    return JPH::Quat(q.x, q.y, q.z, q.w);
}

inline JPH_Vec3 FromJPH(JPH::Vec3Arg v)
{
    return JPH_Vec3{ v.GetX(), v.GetY(), v.GetZ() };
}

inline JPH_RVec3 FromJPH(JPH::RVec3Arg v)
{
    return JPH_RVec3{
        static_cast<double>(v.GetX()),
        static_cast<double>(v.GetY()),
        static_cast<double>(v.GetZ())
    };
}

inline JPH_Quat FromJPH(JPH::QuatArg q)
{
    return JPH_Quat{ q.GetX(), q.GetY(), q.GetZ(), q.GetW() };
}

inline JPH::EMotionType ToMotionType(int32_t motionType)
{
    switch (motionType)
    {
    case 0:  return JPH::EMotionType::Static;
    case 1:  return JPH::EMotionType::Kinematic;
    default: return JPH::EMotionType::Dynamic;
    }
}

inline JPH::EActivation ToActivation(int32_t activationMode)
{
    return activationMode == 0
        ? JPH::EActivation::Activate
        : JPH::EActivation::DontActivate;
}

inline JPH::BodyID ToBodyID(JPH_BodyID id)
{
    return JPH::BodyID(id);
}

inline JPH::Body* ToBody(JPH_BodyRef body)
{
    return reinterpret_cast<JPH::Body*>(body);
}

inline JPH::BodyInterface* ToBodyInterface(JPH_BodyInterfaceRef bi)
{
    return reinterpret_cast<JPH::BodyInterface*>(bi);
}

inline JPH::PhysicsSystem* ToPhysicsSystem(JPH_PhysicsSystemRef ps)
{
    return reinterpret_cast<JPH::PhysicsSystem*>(ps);
}

inline JPH::Shape* ToShape(JPH_ShapeRef shape)
{
    return reinterpret_cast<JPH::Shape*>(shape);
}

inline JPH::BodyCreationSettings* ToBCS(JPH_BodyCreationSettingsRef s)
{
    return reinterpret_cast<JPH::BodyCreationSettings*>(s);
}

inline JPH::MotionProperties* ToMotionProperties(JPH_MotionPropertiesRef mp)
{
    return reinterpret_cast<JPH::MotionProperties*>(mp);
}
class BPLayerInterfaceTable final : public JPH::BroadPhaseLayerInterface
{
public:
    BPLayerInterfaceTable(uint32_t numObjectLayers, uint32_t numBroadPhaseLayers)
        : mNumBroadPhaseLayers(numBroadPhaseLayers)
    {
        mObjectToBroadPhase.assign(numObjectLayers, JPH::BroadPhaseLayer(0));
    }

    void MapObjectToBroadPhaseLayer(uint32_t objectLayer, uint32_t broadPhaseLayer)
    {
        if (objectLayer < mObjectToBroadPhase.size())
            mObjectToBroadPhase[objectLayer] = JPH::BroadPhaseLayer(static_cast<JPH::uint8>(broadPhaseLayer));
    }

    JPH::uint GetNumBroadPhaseLayers() const override
    {
        return mNumBroadPhaseLayers;
    }

    JPH::BroadPhaseLayer GetBroadPhaseLayer(JPH::ObjectLayer inLayer) const override
    {
        return mObjectToBroadPhase[inLayer];
    }

#if defined(JPH_EXTERNAL_PROFILE) || defined(JPH_PROFILE_ENABLED)
    const char* GetBroadPhaseLayerName(JPH::BroadPhaseLayer inLayer) const override
    {
        return "Layer";
    }
#endif

private:
    std::vector<JPH::BroadPhaseLayer> mObjectToBroadPhase;
    JPH::uint mNumBroadPhaseLayers;
};

class ObjectLayerPairFilterTable final : public JPH::ObjectLayerPairFilter
{
public:
    explicit ObjectLayerPairFilterTable(uint32_t numObjectLayers)
        : mNumObjectLayers(numObjectLayers)
    {
        mTable.assign(static_cast<size_t>(numObjectLayers) * numObjectLayers, true);
    }

    void EnableCollision(uint32_t layer1, uint32_t layer2)
    {
        SetPair(layer1, layer2, true);
    }

    void DisableCollision(uint32_t layer1, uint32_t layer2)
    {
        SetPair(layer1, layer2, false);
    }

    bool ShouldCollide(JPH::ObjectLayer inObject1, JPH::ObjectLayer inObject2) const override
    {
        return mTable[Index(inObject1, inObject2)];
    }

private:
    size_t Index(uint32_t a, uint32_t b) const
    {
        return static_cast<size_t>(a) * mNumObjectLayers + b;
    }

    void SetPair(uint32_t a, uint32_t b, bool value)
    {
        if (a >= mNumObjectLayers || b >= mNumObjectLayers)
            return;

        mTable[Index(a, b)] = value;
        mTable[Index(b, a)] = value;
    }

    std::vector<bool> mTable;
    uint32_t mNumObjectLayers;
};

class ObjectVsBroadPhaseLayerFilterTable final : public JPH::ObjectVsBroadPhaseLayerFilter
{
public:
    ObjectVsBroadPhaseLayerFilterTable(
        const BPLayerInterfaceTable& bpInterface,
        uint32_t numBroadPhaseLayers,
        const ObjectLayerPairFilterTable& objectLayerPairFilter,
        uint32_t numObjectLayers
    )
        : mNumBroadPhaseLayers(numBroadPhaseLayers)
    {
        mTable.assign(static_cast<size_t>(numObjectLayers) * numBroadPhaseLayers, false);

        for (uint32_t objectLayer1 = 0; objectLayer1 < numObjectLayers; ++objectLayer1)
        {
            for (uint32_t objectLayer2 = 0; objectLayer2 < numObjectLayers; ++objectLayer2)
            {
                if (!objectLayerPairFilter.ShouldCollide(
                        static_cast<JPH::ObjectLayer>(objectLayer1),
                        static_cast<JPH::ObjectLayer>(objectLayer2)))
                    continue;

                JPH::BroadPhaseLayer bpLayer =
                    bpInterface.GetBroadPhaseLayer(static_cast<JPH::ObjectLayer>(objectLayer2));

                mTable[Index(objectLayer1, static_cast<JPH::uint8>(bpLayer))] = true;
            }
        }
    }

    bool ShouldCollide(JPH::ObjectLayer inLayer1, JPH::BroadPhaseLayer inLayer2) const override
    {
        return mTable[Index(inLayer1, static_cast<JPH::uint8>(inLayer2))];
    }

private:
    size_t Index(uint32_t objectLayer, uint32_t bpLayer) const
    {
        return static_cast<size_t>(objectLayer) * mNumBroadPhaseLayers + bpLayer;
    }

    std::vector<bool> mTable;
    uint32_t mNumBroadPhaseLayers;
};

enum class ContactEventType : uint8_t
{
    Added,
    Persisted,
    Removed,
};

struct ContactEvent
{
    ContactEventType type;
    JPH_BodyID body1;
    JPH_BodyID body2;
    uint32_t subShapeID1;               // only meaningful for Removed
    uint32_t subShapeID2;               // only meaningful for Removed
    JPH_ContactManifoldData manifold;   // only meaningful for Added/Persisted
};

class ManagedContactListener final : public JPH::ContactListener
{
public:
    static constexpr size_t kMaxQueuedEvents = 8192;

    JPH::ValidateResult OnContactValidate(
        const JPH::Body& /*inBody1*/,
        const JPH::Body& /*inBody2*/,
        JPH::RVec3Arg /*inBaseOffset*/,
        const JPH::CollideShapeResult& /*inCollisionResult*/
    ) override
    {
        return JPH::ValidateResult::AcceptAllContactsForThisBodyPair;
    }

    void OnContactAdded(
        const JPH::Body& inBody1,
        const JPH::Body& inBody2,
        const JPH::ContactManifold& inManifold,
        JPH::ContactSettings& /*ioSettings*/
    ) override
    {
        Push(ContactEventType::Added, inBody1, inBody2, &inManifold, nullptr);
    }

    void OnContactPersisted(
        const JPH::Body& inBody1,
        const JPH::Body& inBody2,
        const JPH::ContactManifold& inManifold,
        JPH::ContactSettings& /*ioSettings*/
    ) override
    {
        Push(ContactEventType::Persisted, inBody1, inBody2, &inManifold, nullptr);
    }

    void OnContactRemoved(const JPH::SubShapeIDPair& inSubShapePair) override
    {
        Push(ContactEventType::Removed, inSubShapePair);
    }

    uint32_t Poll(const JPH_ContactListener_Procs& procs, uint32_t maxEvents)
    {
        std::deque<ContactEvent> drained;

        {
            std::lock_guard<std::mutex> lock(mMutex);

            size_t count = (maxEvents == 0)
                ? mQueue.size()
                : std::min<size_t>(maxEvents, mQueue.size());

            for (size_t i = 0; i < count; ++i)
            {
                drained.push_back(std::move(mQueue.front()));
                mQueue.pop_front();
            }
        }

        for (const ContactEvent& event : drained)
        {
            switch (event.type)
            {
            case ContactEventType::Added:
                if (procs.OnContactAdded != nullptr)
                    procs.OnContactAdded(event.body1, event.body2, &event.manifold);
                break;

            case ContactEventType::Persisted:
                if (procs.OnContactPersisted != nullptr)
                    procs.OnContactPersisted(event.body1, event.body2, &event.manifold);
                break;

            case ContactEventType::Removed:
                if (procs.OnContactRemoved != nullptr)
                    procs.OnContactRemoved(event.body1, event.body2, event.subShapeID1, event.subShapeID2);
                break;
            }
        }

        return static_cast<uint32_t>(drained.size());
    }

private:
    static JPH_ContactManifoldData CopyManifold(const JPH::ContactManifold& inManifold)
    {
        JPH_ContactManifoldData data{};

        data.normal = FromJPH(inManifold.mWorldSpaceNormal);
        data.penetrationDepth = inManifold.mPenetrationDepth;

        JPH::uint numPoints = std::min<JPH::uint>(
            static_cast<JPH::uint>(inManifold.mRelativeContactPointsOn1.size()),
            4
        );
        data.numContactPoints = numPoints;

        for (JPH::uint i = 0; i < numPoints; ++i)
        {
            JPH::RVec3 worldPoint = inManifold.mBaseOffset + inManifold.mRelativeContactPointsOn1[i];
            data.contactPoints[i] = FromJPH(worldPoint);
        }

        return data;
    }

    void Push(
        ContactEventType type,
        const JPH::Body& inBody1,
        const JPH::Body& inBody2,
        const JPH::ContactManifold* inManifold,
        const void* /*unused*/
    )
    {
        ContactEvent event{};
        event.type = type;
        event.body1 = inBody1.GetID().GetIndexAndSequenceNumber();
        event.body2 = inBody2.GetID().GetIndexAndSequenceNumber();
        event.subShapeID1 = 0;
        event.subShapeID2 = 0;

        if (inManifold != nullptr)
            event.manifold = CopyManifold(*inManifold);

        Enqueue(std::move(event));
    }

    void Push(ContactEventType type, const JPH::SubShapeIDPair& inSubShapePair)
    {
        ContactEvent event{};
        event.type = type;
        event.body1 = inSubShapePair.GetBody1ID().GetIndexAndSequenceNumber();
        event.body2 = inSubShapePair.GetBody2ID().GetIndexAndSequenceNumber();
        event.subShapeID1 = inSubShapePair.GetSubShapeID1().GetValue();
        event.subShapeID2 = inSubShapePair.GetSubShapeID2().GetValue();

        Enqueue(std::move(event));
    }

    void Enqueue(ContactEvent&& event)
    {
        std::lock_guard<std::mutex> lock(mMutex);

        if (mQueue.size() >= kMaxQueuedEvents)
            mQueue.pop_front(); // drop oldest rather than grow unboundedly

        mQueue.push_back(std::move(event));
    }

    std::mutex mMutex;
    std::deque<ContactEvent> mQueue;
};

JPH::TempAllocatorImpl* sJphTempAllocator = nullptr;
bool sJphInitialized = false;

}
int32_t JPH_Init(void)
{
    if (sJphInitialized)
        return 0;

    JPH::RegisterDefaultAllocator();

    JPH::Factory::sInstance = new JPH::Factory();
    JPH::RegisterTypes();

    sJphTempAllocator = new JPH::TempAllocatorImpl(10 * 1024 * 1024);

    sJphInitialized = true;
    return 1;
}

void JPH_Shutdown(void)
{
    if (!sJphInitialized)
        return;

    delete sJphTempAllocator;
    sJphTempAllocator = nullptr;

    JPH::UnregisterTypes();

    delete JPH::Factory::sInstance;
    JPH::Factory::sInstance = nullptr;

    sJphInitialized = false;
}

JPH_JobSystemRef JPH_JobSystemThreadPool_Create(const JPH_JobSystemConfig* config)
{
    if (config == nullptr)
        return nullptr;

    auto* jobSystem = new JPH::JobSystemThreadPool(
        JPH::cMaxPhysicsJobs,
        JPH::cMaxPhysicsBarriers,
        static_cast<int>(config->maxConcurrency)
    );

    return jobSystem;
}

void JPH_JobSystem_Destroy(JPH_JobSystemRef jobSystem)
{
    delete reinterpret_cast<JPH::JobSystemThreadPool*>(jobSystem);
}

JPH_BroadPhaseLayerInterfaceRef JPH_BroadPhaseLayerInterfaceTable_Create(
    uint32_t numObjectLayers,
    uint32_t numBroadPhaseLayers
)
{
    return new BPLayerInterfaceTable(numObjectLayers, numBroadPhaseLayers);
}

void JPH_BroadPhaseLayerInterfaceTable_MapObjectToBroadPhaseLayer(
    JPH_BroadPhaseLayerInterfaceRef bpInterface,
    uint32_t objectLayer,
    uint32_t broadPhaseLayer
)
{
    if (bpInterface == nullptr)
        return;

    reinterpret_cast<BPLayerInterfaceTable*>(bpInterface)
        ->MapObjectToBroadPhaseLayer(objectLayer, broadPhaseLayer);
}

JPH_ObjectLayerPairFilterRef JPH_ObjectLayerPairFilterTable_Create(uint32_t numObjectLayers)
{
    return new ObjectLayerPairFilterTable(numObjectLayers);
}

void JPH_ObjectLayerPairFilterTable_EnableCollision(
    JPH_ObjectLayerPairFilterRef filter,
    uint32_t layer1,
    uint32_t layer2
)
{
    if (filter == nullptr)
        return;

    reinterpret_cast<ObjectLayerPairFilterTable*>(filter)->EnableCollision(layer1, layer2);
}

void JPH_ObjectLayerPairFilterTable_DisableCollision(
    JPH_ObjectLayerPairFilterRef filter,
    uint32_t layer1,
    uint32_t layer2
)
{
    if (filter == nullptr)
        return;

    reinterpret_cast<ObjectLayerPairFilterTable*>(filter)->DisableCollision(layer1, layer2);
}

JPH_ObjectVsBroadPhaseLayerFilterRef JPH_ObjectVsBroadPhaseLayerFilterTable_Create(
    JPH_BroadPhaseLayerInterfaceRef bpInterface,
    uint32_t numBroadPhaseLayers,
    JPH_ObjectLayerPairFilterRef objectLayerPairFilter,
    uint32_t numObjectLayers
)
{
    if (bpInterface == nullptr || objectLayerPairFilter == nullptr)
        return nullptr;

    return new ObjectVsBroadPhaseLayerFilterTable(
        *reinterpret_cast<BPLayerInterfaceTable*>(bpInterface),
        numBroadPhaseLayers,
        *reinterpret_cast<ObjectLayerPairFilterTable*>(objectLayerPairFilter),
        numObjectLayers
    );
}

JPH_ShapeRef JPH_BoxShape_Create(const JPH_Vec3* halfExtent, float convexRadius)
{
    if (halfExtent == nullptr)
        return nullptr;

    JPH::BoxShapeSettings settings(ToJPH(*halfExtent), convexRadius);
    JPH::ShapeSettings::ShapeResult result = settings.Create();

    if (result.HasError())
        return nullptr;

    JPH::Shape* shape = result.Get().GetPtr();
    shape->AddRef(); // caller now owns one reference
    return shape;
}

JPH_ShapeRef JPH_SphereShape_Create(float radius)
{
    JPH::SphereShapeSettings settings(radius);
    JPH::ShapeSettings::ShapeResult result = settings.Create();

    if (result.HasError())
        return nullptr;

    JPH::Shape* shape = result.Get().GetPtr();
    shape->AddRef();
    return shape;
}

JPH_BodyCreationSettingsRef JPH_BodyCreationSettings_Create3(
    JPH_ShapeRef shape,
    const JPH_RVec3* position,
    const JPH_Quat* rotation,
    int32_t motionType,
    uint32_t objectLayer
)
{
    if (shape == nullptr || position == nullptr || rotation == nullptr)
        return nullptr;

    return new JPH::BodyCreationSettings(
        ToShape(shape),
        ToJPH(*position),
        ToJPH(*rotation),
        ToMotionType(motionType),
        static_cast<JPH::ObjectLayer>(objectLayer)
    );
}

void JPH_BodyCreationSettings_Destroy(JPH_BodyCreationSettingsRef settings)
{
    delete ToBCS(settings);
}

void JPH_BodyCreationSettings_SetAllowSleeping(JPH_BodyCreationSettingsRef settings, int32_t allow)
{
    if (settings == nullptr)
        return;

    ToBCS(settings)->mAllowSleeping = allow != 0;
}

void JPH_BodyCreationSettings_SetAllowDynamicOrKinematic(JPH_BodyCreationSettingsRef settings, int32_t allow)
{
    if (settings == nullptr)
        return;

    ToBCS(settings)->mAllowDynamicOrKinematic = allow != 0;
}

void JPH_BodyCreationSettings_SetFriction(JPH_BodyCreationSettingsRef settings, float friction)
{
    if (settings == nullptr)
        return;

    ToBCS(settings)->mFriction = friction;
}

void JPH_BodyCreationSettings_SetRestitution(JPH_BodyCreationSettingsRef settings, float restitution)
{
    if (settings == nullptr)
        return;

    ToBCS(settings)->mRestitution = restitution;
}

void JPH_BodyCreationSettings_SetLinearDamping(JPH_BodyCreationSettingsRef settings, float damping)
{
    if (settings == nullptr)
        return;

    ToBCS(settings)->mLinearDamping = damping;
}

void JPH_BodyCreationSettings_SetAngularDamping(JPH_BodyCreationSettingsRef settings, float damping)
{
    if (settings == nullptr)
        return;

    ToBCS(settings)->mAngularDamping = damping;
}

void JPH_BodyCreationSettings_SetGravityFactor(JPH_BodyCreationSettingsRef settings, float factor)
{
    if (settings == nullptr)
        return;

    ToBCS(settings)->mGravityFactor = factor;
}

JPH_PhysicsSystemRef JPH_PhysicsSystem_Create(const JPH_PhysicsSystemSettings* settings)
{
    if (settings == nullptr
        || settings->broadPhaseLayerInterface == nullptr
        || settings->objectLayerPairFilter == nullptr
        || settings->objectVsBroadPhaseLayerFilter == nullptr)
        return nullptr;

    auto* system = new JPH::PhysicsSystem();

    system->Init(
        settings->maxBodies,
        settings->numBodyMutexes,
        settings->maxBodyPairs,
        settings->maxContactConstraints,
        *reinterpret_cast<BPLayerInterfaceTable*>(settings->broadPhaseLayerInterface),
        *reinterpret_cast<ObjectVsBroadPhaseLayerFilterTable*>(settings->objectVsBroadPhaseLayerFilter),
        *reinterpret_cast<ObjectLayerPairFilterTable*>(settings->objectLayerPairFilter)
    );

    return system;
}

void JPH_PhysicsSystem_Destroy(JPH_PhysicsSystemRef system)
{
    delete ToPhysicsSystem(system);
}

JPH_BodyInterfaceRef JPH_PhysicsSystem_GetBodyInterface(JPH_PhysicsSystemRef system)
{
    if (system == nullptr)
        return nullptr;

    return &ToPhysicsSystem(system)->GetBodyInterface();
}

void JPH_PhysicsSystem_SetGravity(JPH_PhysicsSystemRef system, const JPH_Vec3* gravity)
{
    if (system == nullptr || gravity == nullptr)
        return;

    ToPhysicsSystem(system)->SetGravity(ToJPH(*gravity));
}

void JPH_PhysicsSystem_Update(
    JPH_PhysicsSystemRef system,
    float deltaTime,
    int32_t collisionSteps,
    JPH_JobSystemRef jobSystem
)
{
    if (system == nullptr || jobSystem == nullptr || sJphTempAllocator == nullptr)
        return;

    ToPhysicsSystem(system)->Update(
        deltaTime,
        collisionSteps,
        sJphTempAllocator,
        reinterpret_cast<JPH::JobSystemThreadPool*>(jobSystem)
    );
}

void JPH_PhysicsSystem_OptimizeBroadPhase(JPH_PhysicsSystemRef system)
{
    if (system == nullptr)
        return;

    ToPhysicsSystem(system)->OptimizeBroadPhase();
}

void JPH_PhysicsSystem_SetContactListener(JPH_PhysicsSystemRef system, JPH_ContactListenerRef listener)
{
    if (system == nullptr)
        return;

    ToPhysicsSystem(system)->SetContactListener(
        reinterpret_cast<JPH::ContactListener*>(listener)
    );
}

JPH_BodyRef JPH_BodyInterface_CreateBody(JPH_BodyInterfaceRef bodyInterface, JPH_BodyCreationSettingsRef settings)
{
    if (bodyInterface == nullptr || settings == nullptr)
        return nullptr;

    return ToBodyInterface(bodyInterface)->CreateBody(*ToBCS(settings));
}

void JPH_BodyInterface_AddBody(JPH_BodyInterfaceRef bodyInterface, JPH_BodyID bodyID, int32_t activationMode)
{
    if (bodyInterface == nullptr)
        return;

    ToBodyInterface(bodyInterface)->AddBody(ToBodyID(bodyID), ToActivation(activationMode));
}

void JPH_BodyInterface_RemoveAndDestroyBody(JPH_BodyInterfaceRef bodyInterface, JPH_BodyID bodyID)
{
    if (bodyInterface == nullptr)
        return;

    ToBodyInterface(bodyInterface)->RemoveBody(ToBodyID(bodyID));
    ToBodyInterface(bodyInterface)->DestroyBody(ToBodyID(bodyID));
}

void JPH_BodyInterface_SetShape(
    JPH_BodyInterfaceRef bodyInterface,
    JPH_BodyID bodyID,
    JPH_ShapeRef shape,
    int32_t updateMassProperties,
    int32_t activationMode
)
{
    if (bodyInterface == nullptr || shape == nullptr)
        return;

    ToBodyInterface(bodyInterface)->SetShape(
        ToBodyID(bodyID),
        ToShape(shape),
        updateMassProperties != 0,
        ToActivation(activationMode)
    );
}

void JPH_BodyInterface_SetMotionType(
    JPH_BodyInterfaceRef bodyInterface,
    JPH_BodyID bodyID,
    int32_t motionType,
    int32_t activationMode
)
{
    if (bodyInterface == nullptr)
        return;

    ToBodyInterface(bodyInterface)->SetMotionType(
        ToBodyID(bodyID),
        ToMotionType(motionType),
        ToActivation(activationMode)
    );
}

void JPH_BodyInterface_SetObjectLayer(JPH_BodyInterfaceRef bodyInterface, JPH_BodyID bodyID, uint32_t layer)
{
    if (bodyInterface == nullptr)
        return;

    ToBodyInterface(bodyInterface)->SetObjectLayer(
        ToBodyID(bodyID),
        static_cast<JPH::ObjectLayer>(layer)
    );
}

void JPH_BodyInterface_ActivateBody(JPH_BodyInterfaceRef bodyInterface, JPH_BodyID bodyID)
{
    if (bodyInterface == nullptr)
        return;

    ToBodyInterface(bodyInterface)->ActivateBody(ToBodyID(bodyID));
}

int32_t JPH_BodyInterface_IsActive(JPH_BodyInterfaceRef bodyInterface, JPH_BodyID bodyID)
{
    if (bodyInterface == nullptr)
        return 0;

    return ToBodyInterface(bodyInterface)->IsActive(ToBodyID(bodyID)) ? 1 : 0;
}

int32_t JPH_BodyInterface_IsAdded(JPH_BodyInterfaceRef bodyInterface, JPH_BodyID bodyID)
{
    if (bodyInterface == nullptr)
        return 0;

    return ToBodyInterface(bodyInterface)->IsAdded(ToBodyID(bodyID)) ? 1 : 0;
}

void JPH_BodyInterface_SetPosition(
    JPH_BodyInterfaceRef bodyInterface,
    JPH_BodyID bodyID,
    const JPH_RVec3* position,
    int32_t activationMode
)
{
    if (bodyInterface == nullptr || position == nullptr)
        return;

    ToBodyInterface(bodyInterface)->SetPosition(
        ToBodyID(bodyID),
        ToJPH(*position),
        ToActivation(activationMode)
    );
}

void JPH_BodyInterface_SetPositionAndRotation(
    JPH_BodyInterfaceRef bodyInterface,
    JPH_BodyID bodyID,
    const JPH_RVec3* position,
    const JPH_Quat* rotation,
    int32_t activationMode
)
{
    if (bodyInterface == nullptr || position == nullptr || rotation == nullptr)
        return;

    ToBodyInterface(bodyInterface)->SetPositionAndRotation(
        ToBodyID(bodyID),
        ToJPH(*position),
        ToJPH(*rotation),
        ToActivation(activationMode)
    );
}

void JPH_BodyInterface_SetRotation(
    JPH_BodyInterfaceRef bodyInterface,
    JPH_BodyID bodyID,
    const JPH_Quat* rotation,
    int32_t activationMode
)
{
    if (bodyInterface == nullptr || rotation == nullptr)
        return;

    ToBodyInterface(bodyInterface)->SetRotation(
        ToBodyID(bodyID),
        ToJPH(*rotation),
        ToActivation(activationMode)
    );
}

void JPH_BodyInterface_SetLinearVelocity(JPH_BodyInterfaceRef bodyInterface, JPH_BodyID bodyID, const JPH_Vec3* velocity)
{
    if (bodyInterface == nullptr || velocity == nullptr)
        return;

    ToBodyInterface(bodyInterface)->SetLinearVelocity(ToBodyID(bodyID), ToJPH(*velocity));
}

void JPH_BodyInterface_SetAngularVelocity(JPH_BodyInterfaceRef bodyInterface, JPH_BodyID bodyID, const JPH_Vec3* velocity)
{
    if (bodyInterface == nullptr || velocity == nullptr)
        return;

    ToBodyInterface(bodyInterface)->SetAngularVelocity(ToBodyID(bodyID), ToJPH(*velocity));
}

void JPH_BodyInterface_GetPosition(JPH_BodyInterfaceRef bodyInterface, JPH_BodyID bodyID, JPH_RVec3* outPosition)
{
    if (bodyInterface == nullptr || outPosition == nullptr)
        return;

    *outPosition = FromJPH(ToBodyInterface(bodyInterface)->GetPosition(ToBodyID(bodyID)));
}

void JPH_BodyInterface_GetPositionAndRotation(
    JPH_BodyInterfaceRef bodyInterface,
    JPH_BodyID bodyID,
    JPH_RVec3* outPosition,
    JPH_Quat* outRotation
)
{
    if (bodyInterface == nullptr || outPosition == nullptr || outRotation == nullptr)
        return;

    JPH::RVec3 position;
    JPH::Quat rotation;
    ToBodyInterface(bodyInterface)->GetPositionAndRotation(ToBodyID(bodyID), position, rotation);

    *outPosition = FromJPH(position);
    *outRotation = FromJPH(rotation);
}

void JPH_BodyInterface_GetRotation(JPH_BodyInterfaceRef bodyInterface, JPH_BodyID bodyID, JPH_Quat* outRotation)
{
    if (bodyInterface == nullptr || outRotation == nullptr)
        return;

    *outRotation = FromJPH(ToBodyInterface(bodyInterface)->GetRotation(ToBodyID(bodyID)));
}

void JPH_BodyInterface_GetLinearVelocity(JPH_BodyInterfaceRef bodyInterface, JPH_BodyID bodyID, JPH_Vec3* outVelocity)
{
    if (bodyInterface == nullptr || outVelocity == nullptr)
        return;

    *outVelocity = FromJPH(ToBodyInterface(bodyInterface)->GetLinearVelocity(ToBodyID(bodyID)));
}

void JPH_BodyInterface_GetAngularVelocity(JPH_BodyInterfaceRef bodyInterface, JPH_BodyID bodyID, JPH_Vec3* outVelocity)
{
    if (bodyInterface == nullptr || outVelocity == nullptr)
        return;

    *outVelocity = FromJPH(ToBodyInterface(bodyInterface)->GetAngularVelocity(ToBodyID(bodyID)));
}

void JPH_BodyInterface_AddImpulse(JPH_BodyInterfaceRef bodyInterface, JPH_BodyID bodyID, const JPH_Vec3* impulse)
{
    if (bodyInterface == nullptr || impulse == nullptr)
        return;

    ToBodyInterface(bodyInterface)->AddImpulse(ToBodyID(bodyID), ToJPH(*impulse));
}

void JPH_BodyInterface_AddForce(JPH_BodyInterfaceRef bodyInterface, JPH_BodyID bodyID, const JPH_Vec3* force)
{
    if (bodyInterface == nullptr || force == nullptr)
        return;

    ToBodyInterface(bodyInterface)->AddForce(ToBodyID(bodyID), ToJPH(*force));
}

void JPH_BodyInterface_AddForce2(
    JPH_BodyInterfaceRef bodyInterface,
    JPH_BodyID bodyID,
    const JPH_Vec3* force,
    const JPH_RVec3* position
)
{
    if (bodyInterface == nullptr || force == nullptr || position == nullptr)
        return;

    ToBodyInterface(bodyInterface)->AddForce(ToBodyID(bodyID), ToJPH(*force), ToJPH(*position));
}

void JPH_BodyInterface_AddTorque(JPH_BodyInterfaceRef bodyInterface, JPH_BodyID bodyID, const JPH_Vec3* torque)
{
    if (bodyInterface == nullptr || torque == nullptr)
        return;

    ToBodyInterface(bodyInterface)->AddTorque(ToBodyID(bodyID), ToJPH(*torque));
}

JPH_BodyID JPH_Body_GetID(JPH_BodyRef body)
{
    if (body == nullptr)
        return JPH::BodyID().GetIndexAndSequenceNumber();

    return ToBody(body)->GetID().GetIndexAndSequenceNumber();
}

JPH_MotionPropertiesRef JPH_Body_GetMotionProperties(JPH_BodyRef body)
{
    if (body == nullptr)
        return nullptr;

    return ToBody(body)->GetMotionProperties();
}

void JPH_Body_SetFriction(JPH_BodyRef body, float friction)
{
    if (body == nullptr)
        return;

    ToBody(body)->SetFriction(friction);
}

void JPH_MotionProperties_ScaleToMass(JPH_MotionPropertiesRef motionProperties, float mass)
{
    if (motionProperties == nullptr || mass <= 0.0f)
        return;

    JPH::MotionProperties* mp = ToMotionProperties(motionProperties);

    float currentInvMass = mp->GetInverseMassUnchecked();
    if (currentInvMass <= 0.0f)
        return; // static/kinematic-shaped inverse mass, nothing sensible to scale

    float currentMass = 1.0f / currentInvMass;
    float scale = mass / currentMass;

    JPH::Mat44 currentInvInertia = mp->GetLocalSpaceInverseInertiaUnchecked();
    JPH::Mat44 scaledInvInertia = currentInvInertia * (1.0f / scale);

    mp->SetInverseMass(1.0f / mass);
    mp->SetInverseInertia(
        scaledInvInertia.GetDiagonal3(),
        JPH::Quat::sIdentity()
    );
}

JPH_ContactListenerRef JPH_ContactListener_Create(void)
{
    return new ManagedContactListener();
}

void JPH_ContactListener_Destroy(JPH_ContactListenerRef listener)
{
    delete reinterpret_cast<ManagedContactListener*>(listener);
}

uint32_t JPH_ContactListener_PollEvents(
    JPH_ContactListenerRef listener,
    const JPH_ContactListener_Procs* procs,
    uint32_t maxEvents
)
{
    if (listener == nullptr || procs == nullptr)
        return 0;

    return reinterpret_cast<ManagedContactListener*>(listener)->Poll(*procs, maxEvents);
}