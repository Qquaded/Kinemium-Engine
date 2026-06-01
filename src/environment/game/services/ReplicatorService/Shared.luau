local Shared = {}

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
	State = true,
	Stance = true,
	Sprinting = true,
	Crouching = true,
	MoveVelocity = true,
	FacingDirection = true,
	FloorMaterial = true,
}

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

local function isInstanceReference(value)
	return type(value) == "table" and value.NetworkId ~= nil and value.ClassName ~= nil
end

function Shared.IsInstanceReference(value)
	return isInstanceReference(value)
end

function Shared.ShouldReplicateProperty(prop)
	return not Shared.HIGH_FREQUENCY_PROPERTIES[prop] and not Shared.INTERNAL_PROPERTIES[prop]
end

local function isHumanoid(object)
	return object ~= nil and (object.class == "Humanoid" or object.ClassName == "Humanoid")
end

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

function Shared.EncodePropertyValue(userdata, value)
	if value == nil then
		return {
			__networkNil = true,
		}
	end

	if isInstanceReference(value) then
		return {
			__instanceRef = value.NetworkId,
		}
	end

	return userdata.Encode(value)
end

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
