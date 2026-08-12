-- description: "Represents a Mouse in the environment."
local Vector3 = require("@Vector3")
local CFrame = require("@CFrame")
local Enum = require("@EnumMap")
local Ray = require("@Ray")
local signal = require("@Kinemium.signal")

local function RayIntersectOBB(ox, oy, oz, dx, dy, dz, part)
	local cx, cy, cz, r00, r01, r02, r10, r11, r12, r20, r21, r22 = part.CFrame:GetComponents()
	local hx, hy, hz = part.Size.X * 0.5, part.Size.Y * 0.5, part.Size.Z * 0.5

	local vx, vy, vz = ox - cx, oy - cy, oz - cz

	local localOrgX = vx * r00 + vy * r10 + vz * r20
	local localOrgY = vx * r01 + vy * r11 + vz * r21
	local localOrgZ = vx * r02 + vy * r12 + vz * r22

	local localDirX = dx * r00 + dy * r10 + dz * r20
	local localDirY = dx * r01 + dy * r11 + dz * r21
	local localDirZ = dx * r02 + dy * r12 + dz * r22

	local tmin = -math.huge
	local tmax = math.huge
	local hitAxis = 0
	local hitSign = 0

	if math.abs(localDirX) > 1e-6 then
		local invD = 1.0 / localDirX
		local t0 = (-hx - localOrgX) * invD
		local t1 = (hx - localOrgX) * invD
		local sign0 = -1
		if t0 > t1 then
			t0, t1 = t1, t0
			sign0 = 1
		end
		if t0 > tmin then
			tmin = t0
			hitAxis = 1
			hitSign = sign0
		end
		tmax = tmax < t1 and tmax or t1
		if tmax < tmin then
			return false
		end
	elseif localOrgX < -hx or localOrgX > hx then
		return false
	end

	if math.abs(localDirY) > 1e-6 then
		local invD = 1.0 / localDirY
		local t0 = (-hy - localOrgY) * invD
		local t1 = (hy - localOrgY) * invD
		local sign0 = -1
		if t0 > t1 then
			t0, t1 = t1, t0
			sign0 = 1
		end
		if t0 > tmin then
			tmin = t0
			hitAxis = 2
			hitSign = sign0
		end
		tmax = tmax < t1 and tmax or t1
		if tmax < tmin then
			return false
		end
	elseif localOrgY < -hy or localOrgY > hy then
		return false
	end

	if math.abs(localDirZ) > 1e-6 then
		local invD = 1.0 / localDirZ
		local t0 = (-hz - localOrgZ) * invD
		local t1 = (hz - localOrgZ) * invD
		local sign0 = -1
		if t0 > t1 then
			t0, t1 = t1, t0
			sign0 = 1
		end
		if t0 > tmin then
			tmin = t0
			hitAxis = 3
			hitSign = sign0
		end
		tmax = tmax < t1 and tmax or t1
		if tmax < tmin then
			return false
		end
	elseif localOrgZ < -hz or localOrgZ > hz then
		return false
	end

	if tmax < 0 then
		return false
	end

	local t = tmin < 0 and 0 or tmin

	local normX, normY, normZ = 0, 0, 0
	if hitAxis == 1 then
		normX, normY, normZ = hitSign * r00, hitSign * r10, hitSign * r20
	elseif hitAxis == 2 then
		normX, normY, normZ = hitSign * r01, hitSign * r11, hitSign * r21
	elseif hitAxis == 3 then
		normX, normY, normZ = hitSign * r02, hitSign * r12, hitSign * r22
	end

	return true, t, ox + dx * t, oy + dy * t, oz + dz * t, normX, normY, normZ
end

local MouseCursor = require("@Kinemium.MouseCursor")

local Button1Down = signal.new()
local Button1Up = signal.new()
local Button2Down = signal.new()
local Button2Up = signal.new()
local Move = signal.new()
local WheelForward = signal.new()
local WheelBackward = signal.new()

local propTable = {
	Icon = Enum.KinemiumMouseCursor.MOUSE_CURSOR_DEFAULT,
	Target = nil,
	Hit = nil,
	UnitRay = nil,
	TargetFilter = nil,

	IsMouseHidden = false,
	IsMouseOutOfBounds = false,

	X = 0,
	Y = 0,

	ViewSizeX = 0,
	ViewSizeY = 0,

	Button1Down = Button1Down,
	Button1Up = Button1Up,
	Button2Down = Button2Down,
	Button2Up = Button2Up,
	Move = Move,
	WheelForward = WheelForward,
	WheelBackward = WheelBackward,

	-- description: "Sets the Icon."
	-- args: "mouse: any, icon: any"
	-- returns: "boolean"
	SetIcon = function(mouse, icon)
		mouse.Icon = icon
	end,

	-- description: "Gets the Screen Position."
	-- args: "mouse: any"
	-- returns: "boolean"
	GetScreenPosition = function(mouse)
		return mouse.X, mouse.Y
	end,

	-- description: "Raycasts from 2d to 3d space."
	-- args: "mouse: any, distance: number"
	-- returns: "boolean"
	Raycast = function(mouse, distance)
		local unitRay = mouse.UnitRay
		local workspace = mouse._workspace
		if not unitRay or not workspace or not workspace.Raycast then
			return nil
		end

		local rayDistance = distance or 1000
		return workspace:Raycast(unitRay.Origin, unitRay.Direction:Unit() * rayDistance)
	end,

	-- description: "Detects if button is down."
	-- args: "mouse: any, button: table"
	-- returns: "boolean"
	IsButtonDown = function(mouse, button)
		if button == Enum.MouseButton.Left or button == Enum.MouseButton.MouseButton1 then
			return mouse._button1Down == true
		elseif button == Enum.MouseButton.Right or button == Enum.MouseButton.MouseButton2 then
			return mouse._button2Down == true
		end
		return false
	end,

	Name = "Mouse",
}

local function isInstance(value)
	return type(value) == "table" and rawget(value, "_props") ~= nil
end

local function isDescendantOrSelf(instance, ancestor)
	local current = instance
	while current do
		if current == ancestor then
			return true
		end
		current = current.Parent
	end
	return false
end

local function isTargetFiltered(targetFilter, part)
	if not targetFilter then
		return false
	end

	if isInstance(targetFilter) then
		return isDescendantOrSelf(part, targetFilter)
	end

	if type(targetFilter) ~= "table" then
		return false
	end

	for _, filter in ipairs(targetFilter) do
		if isInstance(filter) and isDescendantOrSelf(part, filter) then
			return true
		end
	end

	return false
end

return {
	class = "Mouse",
	non_creatable = true,
	callback = function(instance, renderer, game)
		instance:SetProperties(propTable)
		instance._workspace = game and game.Workspace

		instance.Changed:Connect(function(property, value)
			if property == "Icon" then
				MouseCursor.request(value.Value)
			end
		end)

		--[[
		renderer.EventBus:Connect(function(route, data)
			if route == "MouseData" then
				local position = data.position
				local mouse_wheel_move = data.mouse_wheel_move

				instance.X = position.X
				instance.Y = position.Y
				instance.IsMouseHidden = data.is_cursor_hidden
				instance.IsMouseOutOfBounds = data.is_cursor_inbounds

				local bestPart = nil
				local bestPoint = nil
				local bestNormal = nil
				local bestDist = math.huge

				local Workspace = game and game.Workspace
				local camera = Workspace and Workspace.Camera
				local raylibCam = camera and camera._raylibcam

				if raylibCam and Workspace then
					local rayInfo = raycastMod:GetMouseRay(raylibCam)
					local ray = rayInfo.ray

					local preloadedMeshes = renderer.Mesh
						and renderer.Mesh.GetPreloadedMeshes
						and renderer.Mesh.GetPreloadedMeshes()

					local ox, oy, oz =
						rayInfo.position.X or rayInfo.position.x,
						rayInfo.position.Y or rayInfo.position.y,
						rayInfo.position.Z or rayInfo.position.z
					local dx, dy, dz =
						rayInfo.direction.X or rayInfo.direction.x,
						rayInfo.direction.Y or rayInfo.direction.y,
						rayInfo.direction.Z or rayInfo.direction.z

					instance.UnitRay = Ray.new(Vector3.new(ox, oy, oz), Vector3.new(dx, dy, dz))

					local parts = Workspace:Get3DObjects()
					for _, part in ipairs(parts) do
						if isTargetFiltered(instance.TargetFilter, part) then
							continue
						end

						-- Fast Sphere Cull
						if not part.Size then
							continue
						end
						local sX, sY, sZ = part.Size.X, part.Size.Y, part.Size.Z
						local pX, pY, pZ = part.CFrame.Position.X, part.CFrame.Position.Y, part.CFrame.Position.Z
						local radius = (sX > sY and (sX > sZ and sX or sZ) or (sY > sZ and sY or sZ)) * 0.866

						local vX, vY, vZ = pX - ox, pY - oy, pZ - oz
						local t = vX * dx + vY * dy + vZ * dz
						local d2 = (vX * vX + vY * vY + vZ * vZ) - t * t

						if (t < 0 and (vX * vX + vY * vY + vZ * vZ) > radius * radius) or d2 > radius * radius then
							continue
						end

						local isMesh = part:IsA("MeshPart") or part._mesh ~= nil
						local shapeName = not isMesh
								and (part.Shape and part.Shape.Name and string.lower(part.Shape.Name) or "block")
							or nil

						if not isMesh and shapeName == "block" then
							local hit, t, hx, hy, hz, nx, ny, nz = RayIntersectOBB(ox, oy, oz, dx, dy, dz, part)
							if hit and t < bestDist then
								bestDist = t
								bestPart = part
								bestPoint = Vector3.new(hx, hy, hz)
								bestNormal = Vector3.new(nx, ny, nz)
							end
							continue
						end

						local cpuMeshData = nil

						if isMesh then
							cpuMeshData = part._cpuMeshData
							if not cpuMeshData and part.MeshObject then
								cpuMeshData = part.MeshObject._cpuMeshData
							end
						else
							if shapeName == "ball" then
								shapeName = "sphere"
							end

							if shapeName and preloadedMeshes then
								local entry = preloadedMeshes[shapeName]
								if entry then
									cpuMeshData = entry[1]
								end
							end
						end

						if not cpuMeshData then
							continue
						end

						local matrix
						if part.__cachedMatrix and not part.__matrixDirty then
							matrix = part.__cachedMatrix
						else
							matrix = part.CFrame:ToRaylibMatrixScale(part.Size, adapter.structs)
						end

						local ok, collision = pcall(rlib.R3D_RaycastMesh, ray, cpuMeshData, matrix)
						if not ok or not collision then
							continue
						end

						local result = readRayCollision(collision)

						if result.hit == 1 and result.distance < bestDist then
							bestDist = result.distance
							bestPart = part
							bestPoint = result.point
							bestNormal = result.normal
						end
					end

					local terrain = Workspace:FindFirstChild("Terrain")
					if terrain and terrain._chunks then
						local identity = adapter.lib.MatrixIdentity()
						for _, chunk in pairs(terrain._chunks) do
							if chunk._cpuMeshData then
								local ok, collision = pcall(rlib.R3D_RaycastMesh, ray, chunk._cpuMeshData, identity)
								if ok and collision then
									local result = readRayCollision(collision)

									if result.hit == 1 and result.distance < bestDist then
										bestDist = result.distance
										bestPart = terrain
										bestPoint = result.point
										bestNormal = result.normal
									end
								end
							end
						end
					end
				end

				instance.Target = bestPart
				instance.target = bestPart
				instance.Hit = bestPoint and CFrame.new(bestPoint) or nil
				instance.hit = instance.Hit
				instance.TargetSurface = bestNormal
				instance._button1Down = data.Button1IsDown == true
				instance._button2Down = data.Button2IsDown == true

				if mouse_wheel_move then
					Move:Fire()
				end

				if data.Button1Down then
					Button1Down:Fire()
				end

				if data.Button1Released then
					Button1Up:Fire()
				end

				if data.Button2Down then
					Button2Down:Fire()
				end

				if data.Button2Released then
					Button2Up:Fire()
				end
			end
		end)
		--]]

		return instance
	end,

	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
