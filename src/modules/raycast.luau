local adapter = require("@RaylibAdapter")
local raycast = {}

local lib, const, structs = adapter.lib, adapter.const, adapter.structs
local Vector3 = require("@Vector3")

local mem = zune.mem

local function readRayCollision(collisionBuffer)
	-- RayCollision struct layout:
	-- { hit = u8 }        - offset 0, size 1
	-- { distance = float } - offset 4, size 4 (padded to 4-byte alignment)
	-- { point = Vector3 }  - offset 8, size 12
	-- { normal = Vector3 } - offset 20, size 12

	local hit = buffer.readu8(collisionBuffer, 0)
	local distance = buffer.readf32(collisionBuffer, 4)

	-- Read point Vector3 (x, y, z)
	local pointX = buffer.readf32(collisionBuffer, 8)
	local pointY = buffer.readf32(collisionBuffer, 12)
	local pointZ = buffer.readf32(collisionBuffer, 16)

	-- Read normal Vector3 (x, y, z)
	local normalX = buffer.readf32(collisionBuffer, 20)
	local normalY = buffer.readf32(collisionBuffer, 24)
	local normalZ = buffer.readf32(collisionBuffer, 28)

	return {
		hit = hit,
		distance = distance,
		point = Vector3.new(pointX, pointY, pointZ),
		normal = Vector3.new(normalX, normalY, normalZ),
	}
end

local function hitAABB(ray, center, size)
	local min = vector.create(center.x - size.x / 2, center.y - size.y / 2, center.z - size.z / 2)
	local max = vector.create(center.x + size.x / 2, center.y + size.y / 2, center.z + size.z / 2)

	local collision = lib.GetRayCollisionBox(
		ray,
		structs.BoundingBox:new({
			min = min,
			max = max,
		})
	)

	if collision then
		return readRayCollision(collision)
	else
		return false
	end
end

raycast.readRayCollision = readRayCollision
raycast.hitAABB = hitAABB

function raycast:GetMouseRay(camera)
	local mouse = lib.GetMousePosition()
	local ray = lib.GetScreenToWorldRay(mouse, camera)

	local position = mem.toVector3(ray, 0)
	local direction = mem.toVector3(ray, 12)

	return { position = position, direction = direction, ray = ray }
end

return raycast
