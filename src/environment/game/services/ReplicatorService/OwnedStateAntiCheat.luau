local CFrame = require("@CFrame")
local Vector3 = require("@Vector3")

local OwnedStateAntiCheat = {}

OwnedStateAntiCheat.Config = {
	MaxOwnedLinearSpeed = 350,
	MaxOwnedAngularSpeed = 120,
	MaxOwnedPositionError = 24,
	MaxOwnedStateStrikes = 6,

	MaxUpdatesPerTick = 3,
	VelocityDirectionThreshold = 0.65,
	VelocityDirectionMinSpeed = 20,
	RotationOrthogonalTolerance = 0.02,

	MaxHumanoidLinearSpeed = 32,
	HumanoidSpeedLeniency = 1.4,
}

local function isFiniteNumber(value)
	return type(value) == "number" and math.isfinite(value)
end

local function decodeVectorState(value)
	if type(value) ~= "table" then
		return nil
	end

	local ok, vector = pcall(Vector3.FromTable, value)
	if not ok then
		return nil
	end

	if not isFiniteNumber(vector.X) or not isFiniteNumber(vector.Y) or not isFiniteNumber(vector.Z) then
		return nil
	end

	return vector
end

local function decodeCFrameState(value)
	if type(value) ~= "table" then
		return nil
	end

	local ok, cframe = pcall(CFrame.FromTable, value)
	if not ok then
		return nil
	end

	local position = cframe.Position
	if
		not position
		or not isFiniteNumber(position.X)
		or not isFiniteNumber(position.Y)
		or not isFiniteNumber(position.Z)
	then
		return nil
	end

	return cframe
end

local function validateRotationMatrix(cframe)
	local rx = Vector3.new(cframe.XVector.X, cframe.XVector.Y, cframe.XVector.Z)
	local ry = Vector3.new(cframe.YVector.X, cframe.YVector.Y, cframe.YVector.Z)
	local rz = Vector3.new(cframe.ZVector.X, cframe.ZVector.Y, cframe.ZVector.Z)

	local tol = OwnedStateAntiCheat.Config.RotationOrthogonalTolerance
	if math.abs(rx:Magnitude() - 1) > tol then
		return false
	end
	if math.abs(ry:Magnitude() - 1) > tol then
		return false
	end
	if math.abs(rz:Magnitude() - 1) > tol then
		return false
	end

	if math.abs(rx:Dot(ry)) > tol then
		return false
	end
	if math.abs(rx:Dot(rz)) > tol then
		return false
	end
	if math.abs(ry:Dot(rz)) > tol then
		return false
	end

	for _, v in ipairs({ rx, ry, rz }) do
		if not isFiniteNumber(v.X) or not isFiniteNumber(v.Y) or not isFiniteNumber(v.Z) then
			return false
		end
	end

	return true
end

function OwnedStateAntiCheat.new(context)
	local networkService = context.NetworkService
	local networkOwnership = context.NetworkOwnership
	local onOwnershipRevoked = context.OnOwnershipRevoked

	local getMaxSpeedForObject = context.GetMaxSpeedForObject

	local stateBySession = {}

	local function getSessionState(session)
		local state = stateBySession[session.key]
		if not state then
			state = {
				strikes = 0,
				objects = {},
				updatesThisTick = 0,
				lastTickCount = 0,
			}
			stateBySession[session.key] = state
		end
		return state
	end

	local function registerStrike(session, object, reason)
		local sessionState = getSessionState(session)
		sessionState.strikes += 1

		if sessionState.strikes == 1 or sessionState.strikes % 3 == 0 then
			warn(
				`[AntiCheat] Rejected owned state from {session.player.Name} for {object.Name}: {reason} (strikes={sessionState.strikes})`
			)
		end

		if sessionState.strikes >= OwnedStateAntiCheat.Config.MaxOwnedStateStrikes then
			local root = networkOwnership.GetAuthorityRoot(object)
			networkOwnership.ClearOwner(root)
			sessionState.strikes = 0
			sessionState.objects = {}
			if onOwnershipRevoked then
				onOwnershipRevoked(session, root, reason)
			end
			warn(`[AntiCheat] Revoked network ownership from {session.player.Name} for {root.Name}`)
		end
	end

	local function validateOwnedState(session, payload, object, state)
		if state.type ~= "BasePart" then
			return true
		end

		local sessionState = getSessionState(session)

		--  Rate limit
		local currentTick = networkService.CurrentTick or 0
		if currentTick ~= sessionState.lastTickCount then
			sessionState.updatesThisTick = 0
			sessionState.lastTickCount = currentTick
		end
		sessionState.updatesThisTick += 1
		if sessionState.updatesThisTick > OwnedStateAntiCheat.Config.MaxUpdatesPerTick then
			registerStrike(session, object, `update flood: {sessionState.updatesThisTick} updates in one tick`)
			return false
		end

		--  Decode & basic sanity
		local cframe = decodeCFrameState(state.cframe)
		if not cframe then
			registerStrike(session, object, "malformed basepart state")
			return false
		end

		if not validateRotationMatrix(cframe) then
			registerStrike(session, object, "non-orthonormal rotation matrix")
			return false
		end

		-- Anchored parts don't have velocity, skip velocity validation
		if object.Anchored == true then
			return true
		end

		local linear = decodeVectorState(state.linear)
		local angular = decodeVectorState(state.angular)
		if not linear or not angular then
			registerStrike(session, object, "malformed basepart state - missing velocity for unanchored part")
			return false
		end

		local isHumanoidPart = object.Name == "HumanoidRootPart"
		local maxLinearSpeed

		if getMaxSpeedForObject then
			maxLinearSpeed = getMaxSpeedForObject(object)
		end

		if not maxLinearSpeed then
			if isHumanoidPart then
				maxLinearSpeed = OwnedStateAntiCheat.Config.MaxHumanoidLinearSpeed
					* OwnedStateAntiCheat.Config.HumanoidSpeedLeniency
			else
				maxLinearSpeed = OwnedStateAntiCheat.Config.MaxOwnedLinearSpeed
			end
		end

		local linearSpeed = linear:Magnitude()
		if linearSpeed > maxLinearSpeed then
			registerStrike(
				session,
				object,
				`linear speed {math.floor(linearSpeed + 0.5)} > {math.floor(maxLinearSpeed + 0.5)}`
			)
			return false
		end

		local angularSpeed = angular:Magnitude()
		if angularSpeed > OwnedStateAntiCheat.Config.MaxOwnedAngularSpeed then
			registerStrike(
				session,
				object,
				`angular speed {math.floor(angularSpeed + 0.5)} > {OwnedStateAntiCheat.Config.MaxOwnedAngularSpeed}`
			)
			return false
		end

		local previous = sessionState.objects[state.id]
		local referenceCFrame = object.CFrame
		local deltaTime = 1 / math.max(networkService.TickRate or 30, 1)

		if previous and previous.cframe then
			local previousCFrame = decodeCFrameState(previous.cframe)
			if previousCFrame then
				referenceCFrame = previousCFrame
			end
			if previous.tick ~= nil and payload.tick ~= nil and payload.tick >= previous.tick then
				deltaTime =
					math.max((payload.tick - previous.tick) / math.max(networkService.TickRate or 30, 1), deltaTime)
			end
		end

		if referenceCFrame and referenceCFrame.Position then
			local allowedTravel = OwnedStateAntiCheat.Config.MaxOwnedPositionError + maxLinearSpeed * deltaTime * 1.5

			local displacement = cframe.Position - referenceCFrame.Position
			local traveled = displacement:Magnitude()

			if traveled > allowedTravel then
				registerStrike(
					session,
					object,
					`position delta {math.floor(traveled + 0.5)} > {math.floor(allowedTravel + 0.5)}`
				)
				return false
			end

			local absoluteMaxTravel = OwnedStateAntiCheat.Config.MaxOwnedPositionError
				+ maxLinearSpeed * deltaTime * 1.8 -- tighter than before (was 2×)

			if traveled > absoluteMaxTravel then
				registerStrike(
					session,
					object,
					`teleport detected: traveled {math.floor(traveled + 0.5)} studs in {string.format("%.3f", deltaTime)}s`
				)
				return false
			end

			--  Velocity direction check
			if linearSpeed > OwnedStateAntiCheat.Config.VelocityDirectionMinSpeed and traveled > 1 then
				local displacementDir = displacement:Unit()
				local velocityDir = linear:Unit()
				local dot = displacementDir:Dot(velocityDir)
				if dot < OwnedStateAntiCheat.Config.VelocityDirectionThreshold then
					registerStrike(
						session,
						object,
						`velocity direction mismatch: dot={string.format("%.2f", dot)} < {OwnedStateAntiCheat.Config.VelocityDirectionThreshold}`
					)
					return false
				end
			end
		end

		sessionState.objects[state.id] = {
			tick = payload.tick,
			cframe = state.cframe,
		}
		return true
	end

	return {
		ValidateOwnedState = validateOwnedState,
		ClearSession = function(session)
			if session and session.key then
				stateBySession[session.key] = nil
			end
		end,
	}
end

return OwnedStateAntiCheat
