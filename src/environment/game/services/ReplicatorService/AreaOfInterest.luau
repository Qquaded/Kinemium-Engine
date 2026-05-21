local AreaOfInterest = {}

local DEFAULT_RADIUS = 256
local GLOBAL_NETWORK_IDS = {
	[0] = true, -- DataModel
	[1] = true, -- Workspace
	[2] = true, -- Players
	[3] = true, -- ReplicatedStorage
	[4] = true, -- StarterGui
	[5] = true, -- CoreGui
	[6] = true, -- InternalStorage
}

-- Classes that should always replicate regardless of distance.
local GLOBAL_CLASSES = {
	DataModel = true,
	Workspace = true,
	Players = true,
	Player = true,
	ReplicatedStorage = true,
	InternalStorage = true,
	StarterGui = true,
	CoreGui = true,
	RemoteEvent = true,
	UnreliableRemoteEvent = true,
	RemoteFunction = true,
	RemoteData = true,
	Terrain = true,
	Camera = true,
	Folder = true, -- Folders are organizational; children get their own check
	Configuration = true,
	ScreenGui = true,
	SurfaceGui = true,
	BillboardGui = true,
}

local sessionAoI = {} -- keyed by session.key

local function isCharacterEntity(object)
	local current = object
	while current do
		if current.ClassName == "DataModel" or current.ClassName == "Workspace" then
			return false
		end

		if
			current.ClassName == "Model"
			and current.GetAttribute ~= nil
			and type(current:GetAttribute("__characterUserId")) == "number"
		then
			return true
		end

		current = current.Parent
	end

	return false
end

function AreaOfInterest.Init()
	sessionAoI = {}
end

function AreaOfInterest.RegisterSession(session)
	if not session or not session.key then
		return
	end

	sessionAoI[session.key] = {
		position = nil, -- Vector3-like table {X, Y, Z} or nil
		radius = DEFAULT_RADIUS,
		radiusSq = DEFAULT_RADIUS * DEFAULT_RADIUS,
	}
end

function AreaOfInterest.UnregisterSession(session)
	if session and session.key then
		sessionAoI[session.key] = nil
	end
end

function AreaOfInterest.SetDefaultRadius(radius)
	DEFAULT_RADIUS = math.max(1, radius)
end

function AreaOfInterest.GetDefaultRadius()
	return DEFAULT_RADIUS
end

function AreaOfInterest.SetSessionRadius(session, radius)
	if not session or not session.key then
		return
	end

	local state = sessionAoI[session.key]
	if not state then
		return
	end

	local r = math.max(1, radius)
	state.radius = r
	state.radiusSq = r * r
end

function AreaOfInterest.GetSessionRadius(session)
	if not session or not session.key then
		return DEFAULT_RADIUS
	end

	local state = sessionAoI[session.key]
	return state and state.radius or DEFAULT_RADIUS
end

--- Update the position of a session's focus (typically their character).
--- `position` should be a Vector3-like table with X, Y, Z fields.
function AreaOfInterest.UpdateSessionPosition(session, position)
	if not session or not session.key then
		return
	end

	local state = sessionAoI[session.key]
	if not state then
		return
	end

	state.position = position
end

function AreaOfInterest.GetSessionPosition(session)
	if not session or not session.key then
		return nil
	end

	local state = sessionAoI[session.key]
	return state and state.position or nil
end

--- Returns true if an entity at `entityPosition` is within the AoI of `session`.
--- If the session has no position yet (e.g. still loading), returns true so
--- entities are not incorrectly culled during initial load.
function AreaOfInterest.IsInRange(session, entityPosition)
	if not session or not session.key or entityPosition == nil then
		return true
	end

	local state = sessionAoI[session.key]
	if not state or not state.position then
		-- No position tracked yet  assume everything is relevant
		return true
	end

	local dx = (entityPosition.X or 0) - (state.position.X or 0)
	local dy = (entityPosition.Y or 0) - (state.position.Y or 0)
	local dz = (entityPosition.Z or 0) - (state.position.Z or 0)
	local distSq = dx * dx + dy * dy + dz * dz

	return distSq <= state.radiusSq
end

--- Returns true if this object should always be replicated to every player
--- regardless of spatial position (global entity).
function AreaOfInterest.IsGlobalEntity(object)
	if object == nil then
		return true
	end

	-- Singleton network IDs are always global
	if object.NetworkId ~= nil and GLOBAL_NETWORK_IDS[object.NetworkId] then
		return true
	end

	-- Certain class types are always global
	if object.ClassName and GLOBAL_CLASSES[object.ClassName] then
		return true
	end

	-- Player characters must be created on every client. If a character spawns
	-- outside a session's current AoI, snapshots later cannot create that tree.
	if isCharacterEntity(object) then
		return true
	end

	-- Objects without CanReplicate are global by default
	if object.CanReplicate == false then
		return false
	end

	return false
end

--- Returns true if an object should be replicated to a specific session,
--- taking into account AoI, ownership, and global entity rules.
--- `getWorldPosition` is a function(object) -> Vector3 or nil
function AreaOfInterest.ShouldReplicateToSession(session, object, getWorldPosition, networkOwnership)
	-- Global entities always replicate
	if AreaOfInterest.IsGlobalEntity(object) then
		return true
	end

	-- Entities owned by this session's player always replicate to them
	if networkOwnership and session.player then
		if networkOwnership.IsOwnedByPlayer(object, session.player) then
			return true
		end
	end

	-- Check spatial distance
	local entityPos = getWorldPosition and getWorldPosition(object) or nil
	if entityPos == nil then
		-- No spatial position  treat as global (e.g. a Script, ModuleScript, etc.)
		return true
	end

	return AreaOfInterest.IsInRange(session, entityPos)
end

--- Returns a filtered list of sessions that should receive updates about this entity.
--- `allSessions` is an array of session tables.
--- `getWorldPosition` is a function(object) -> Vector3 or nil
function AreaOfInterest.GetRelevantSessions(object, allSessions, getWorldPosition, networkOwnership)
	-- Fast path: global entities go to everyone
	if AreaOfInterest.IsGlobalEntity(object) then
		return allSessions
	end

	local entityPos = getWorldPosition and getWorldPosition(object) or nil
	if entityPos == nil then
		-- No position  replicate to everyone
		return allSessions
	end

	local relevant = {}
	for _, session in ipairs(allSessions) do
		-- Always replicate to owner
		if networkOwnership and session.player and networkOwnership.IsOwnedByPlayer(object, session.player) then
			table.insert(relevant, session)
		elseif AreaOfInterest.IsInRange(session, entityPos) then
			table.insert(relevant, session)
		end
	end

	return relevant
end

--- Returns true if the entity at `netId` in `lookup` should be replicated to `session`.
--- Convenience wrapper that resolves position via lookup + getWorldPosition.
function AreaOfInterest.ShouldReplicateNetId(session, netId, lookup, getWorldPosition, networkOwnership)
	-- Singleton network IDs are always global
	if GLOBAL_NETWORK_IDS[netId] then
		return true
	end

	local object = lookup[netId]
	if not object then
		return true -- Object not in lookup; might be pending  don't cull
	end

	return AreaOfInterest.ShouldReplicateToSession(session, object, getWorldPosition, networkOwnership)
end

return AreaOfInterest
