--[[
╔══════════════════════════════════════════════════════════════════╗
║  Shared — replication constants and utility functions            ║
║                                                                  ║
║  Used by both _Server.luau and _Client.luau to determine which   ║
║  properties replicate, how to encode/decode property values      ║
║  (including Instance references and nil sentinels), and which    ║
║  properties are high-frequency (snapshot-only) vs patch-based.   ║
╚══════════════════════════════════════════════════════════════════╝
--]]

local Shared = {}

-- HIGH_FREQUENCY_PROPERTIES are excluded from property patches (PatchBatch)
-- and instead transmitted only via snapshots (unreliable, per-tick).
-- These are typically physics/pose properties that change every frame.
Shared.HIGH_FREQUENCY_PROPERTIES = {
	CFrame = true,
	Position = true,
	Orientation = true,
	Rotation = true,
	WorldPivot = true,
	AssemblyLinearVelocity = true,
	AssemblyAngularVelocity = true,
	AssemblyCenterOfMass = true,
	AssemblyMass = true,
	Velocity = true,
	Force = true,
	-- Humanoid state fields sent via owned-state snapshots
	State = true,
	Stance = true,
	Sprinting = true,
	Crouching = true,
	MoveVelocity = true,
	FacingDirection = true,
	FloorMaterial = true,
}

-- Humanoid properties that ARE allowed in patches (reliable).
-- All other Humanoid property changes are ignored for replication.
Shared.HUMANOID_PATCH_ALLOWLIST = {
	Character = true,
	RootPart = true,
	RigDescriptor = true,
	WalkSpeed = true,
	JumpPower = true,
	HipHeight = true,
	AutoRotate = true,
	Health = true,
	MaxHealth = true,
	DisplayName = true,
	CollisionType = true,
	CameraOffset = true,
}

-- INTERNAL_PROPERTIES are administrative fields managed by the engine,
-- never replicated as property changes. They are handled specially
-- (e.g. _parentID is set during serialization, NetworkId is assigned
-- server-side, FireServer/InvokeServer are methods injected by hooks).
Shared.INTERNAL_PROPERTIES = {
	_parentID = true,
	_networkOwnerUserId = true,
	IsPlaytesting = true,
	NetworkId = true,
	NetworkOwner = true,
	NetworkOwnerType = true,
	CanReplicate = true,
	FireServer = true,
	FireClient = true,
	FireAllClients = true,
	FireClients = true,
	InvokeServer = true,
	InvokeClient = true,
}

-- Check if a value is a live Instance object (has ClassName and GetProperties)
local function isInstanceObject(value)
	return type(value) == "table" and value.ClassName ~= nil and type(value.GetProperties) == "function"
end

-- Determine if a value is a reference to a networked Instance (has a NetworkId)
function Shared.IsInstanceReference(value)
	return isInstanceObject(value) and value.NetworkId ~= nil
end

-- Should a given property name use the patch-based replication path?
-- Returns false for high-frequency and internal properties.
function Shared.ShouldReplicateProperty(prop)
	return not Shared.HIGH_FREQUENCY_PROPERTIES[prop] and not Shared.INTERNAL_PROPERTIES[prop]
end

local function isHumanoid(object)
	return object ~= nil and (object.class == "Humanoid" or object.ClassName == "Humanoid")
end

-- Extended property filter that accounts for object-specific rules:
--   - RemoteData.Data is never patched (uses RemoteDataUpdate messages)
--   - Parts marked as __humanoidRigPart only replicate via owned-state
--   - Humanoids only replicate properties in HUMANOID_PATCH_ALLOWLIST
function Shared.ShouldReplicatePropertyForObject(object, prop)
	if object and object.ClassName == "RemoteData" and (prop == "Data" or prop == "DataChanged") then
		return false
	end

	if not Shared.ShouldReplicateProperty(prop) then
		return false
	end

	if object and object.GetAttribute and object:GetAttribute("__humanoidRigPart") == true then
		return false
	end

	if isHumanoid(object) then
		return Shared.HUMANOID_PATCH_ALLOWLIST[prop] == true
	end

	return true
end

-- Encode a property value for network transmission:
--   - nil becomes a sentinel { __networkNil = true }
--   - Instance references become { __instanceRef = <NetworkId> }
--   - Everything else goes through the serialization service's Encode
function Shared.EncodePropertyValue(userdata, value)
	if value == nil then
		return {
			__networkNil = true,
		}
	end

	if isInstanceObject(value) then
		if value.NetworkId ~= nil then
			return {
				__instanceRef = value.NetworkId,
			}
		else
			return {
				__networkNil = true,
			}
		end
	end

	return userdata.Encode(value)
end

-- Decode a property value received from the network:
--   - nil sentinel produces nil
--   - Instance reference resolves via the lookup table
--     (returns nil + false if the referenced object hasn't arrived yet)
--   - Everything else goes through the serialization service's Decode
-- Returns (value, ok) where ok=false means "needs retry" (deferred patch).
function Shared.DecodePropertyValue(userdata, lookup, value)
	if type(value) == "table" and value.__networkNil == true then
		return nil, true
	end

	if type(value) == "table" and value.__instanceRef ~= nil then
		local ref = lookup[value.__instanceRef]
		if ref == nil then
			return nil, false
		end
		return ref, true
	end

	return userdata.Decode(value), true
end

return Shared
