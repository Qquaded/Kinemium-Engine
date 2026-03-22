local Instance = require("@Instance")
local signal = require("@Kinemium.signal")

local OdePhysicsService = Instance.new("OdePhysicsService")
OdePhysicsService.ExplorerHidden = true

local CFrame = require("@CFrame")
local Enum = require("@EnumMap")

local odeBodies = {} -- part = ODEBodyID
local ffi = zune.ffi

--[[
dJointTypeBall	A ball-and-socket joint.
dJointTypeHinge	A hinge joint.
dJointTypeSlider	A slider joint.
dJointTypeContact	A contact joint.
dJointTypeUniversal	A universal joint.
dJointTypeHinge2	A hinge-2 joint.
dJointTypeFixed	A fixed joint.
dJointTypeAMotor	An angular motor joint.
dJointTypeLMotor	A linear motor joint.
dJointTypePlane2D	A Plane 2D joint.
dJointTypePR	A Prismatic-Rotoide joint.
dJointTypePU	A Prismatic-Universal joint.
dJointTypePiston	A Piston joint.
dJointTypeDBall	A Double Ball-And-Socket joint.
dJointTypeDHinge	A Double Hinge joint.
dJointTypeTransmission	A Transmission joint.
--]]

local function createPhysicsBody(world, space, part, lib)
	if part.BaseClass ~= "BasePart" then
		return
	end
	local cframe = part.CFrame.Position
	local rotation = part.CFrame.Rotation
	local angular, linear = part.AssemblyAngularVelocity, part.AssemblyLinearVelocity
	local sizeX, sizeY, sizeZ = part.Size.X, part.Size.Y, part.Size.Z

	local bodyId = lib.dBodyCreate(world)
	odeBodies[part] = bodyId
	lib.dBodySetPosition(bodyId, cframe.X, cframe.Y, cframe.Z)
	lib.dBodySetLinearVel(bodyId, linear.X, linear.Y, linear.Z)
	lib.dBodySetAngularVel(bodyId, angular.X, angular.Y, angular.Z)
	if part.Anchored == true then
		lib.dBodySetKinematic(bodyId)
	else
		lib.dBodySetDynamic(bodyId)
	end
	lib.dBodyEnable(bodyId)

	local geom
	if part.Shape == Enum.PartType.Block then
		geom = lib.dCreateBox(space, sizeX, sizeY, sizeZ)
	elseif part.Shape == Enum.PartType.Ball then
		local radius = math.max(sizeX, sizeY, sizeZ) / 2
		geom = lib.dCreateSphere(space, radius)
	elseif part.Shape == Enum.PartType.Cylinder then
		local radius = math.max(sizeX, sizeZ) / 2
		geom = lib.dCreateCylinder(space, radius, sizeY)
	else
		-- default to box
		geom = lib.dCreateBox(space, sizeX, sizeY, sizeZ)
	end

	lib.dGeomSetBody(geom, bodyId)
	lib.dGeomEnable(geom)

	iodebug(
		"Created ODE body for part:",
		part.Name,
		"BodyID:",
		bodyId,
		"GeomID:",
		geom,
		"Size:",
		sizeX,
		sizeY,
		sizeZ,
		"Shape:",
		part.Shape.Name
	)

	return part, bodyId
end

local function AddForce(part, force, lib)
	local bodyId = odeBodies[part]
	if bodyId then
		lib.dBodyEnable(bodyId)
		lib.dBodyAddForce(bodyId, force.X, force.Y, force.Z)
	end
end

local function AddTorque(part, torque, lib)
	local bodyId = odeBodies[part]
	if bodyId then
		lib.dBodyEnable(bodyId)
		lib.dBodyAddTorque(bodyId, torque.X, torque.Y, torque.Z)
	end
end

local function getGravity(v, wind)
	local x = 0 + (wind and wind.X or 0)
	local y = v + -(wind and wind.Y or 0)
	local z = 0 + (wind and wind.Z or 0)
	return x, y, z
end

local function applyPositions(world, lib)
	for part, bodyId in pairs(odeBodies) do
		local posPtr = lib.dBodyGetPosition(bodyId)

		local posx, posy, posz = posPtr:readf64(0), posPtr:readf64(8), posPtr:readf64(16)
		local newCF = CFrame.new(posx, posy, posz)
		part.CFrame = newCF
	end
end

OdePhysicsService.InitRenderer = function(renderer, renderer_signal, game)
	OdePhysicsService:SetProperties({})

	--[[
	local ode = require("@ode")
	local lib = ode.lib

	task.spawn(function()
		repeat
			task.wait()
		until game.Workspace
		local workspace = game.Workspace

		log("Ode init")
		lib.dInitODE()
		log("After ode")

		local worldId = lib.dWorldCreate()
		local space = lib.dHashSpaceCreate(nil)
		local contactGroup = lib.dJointGroupCreate(0)

		local compiled = ffi.closure({
			returns = ffi.types.void,
			args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
		}, function(data, geom1, geom2)
			local b1 = lib.dGeomGetBody(geom1)
			local b2 = lib.dGeomGetBody(geom2)
		end)

		local callbackData = ffi.alloc(16, 8)
		local worldPtr = ffi.ptr(worldId)
		local contactGroupPtr = ffi.ptr(contactGroup)

		local function applyGravity()
			local gravx, gravy, gravz = getGravity(workspace.Gravity, workspace.GlobalWind)
			lib.dWorldSetGravity(worldId, gravx, gravy, gravz)
		end

		for _, part in pairs(workspace:GetDescendants()) do
			if part.BaseClass == "BasePart" then
				--createPhysicsBody(worldId, space, part)
			end
		end

		workspace.DescendantAdded:Connect(function(descendant)
			if descendant.BaseClass == "BasePart" then
				--createPhysicsBody(worldId, space, descendant)
			end
		end)

		renderer_signal:Connect(function(route, dt)
			if route == "RenderStepped" then
				if workspace.PhysicsEngine ~= Enum.PhysicsEngine.Ode then
					return
				end
				if dt == 0 then
					return
				end
			end
		end)

		table.insert(game.ShutdownCallbacks, function()
			for _, bodyId in pairs(odeBodies) do
				lib.dBodyDestroy(bodyId)
			end
			lib.dWorldDestroy(worldId)
			lib.dCloseODE()
		end)
	end)
	--]]
end

return OdePhysicsService
