local Vector3 = require("@Vector3")
local Enum = require("@Enum")

local RaycastResult = {}
RaycastResult.__index = RaycastResult

function RaycastResult.new(instance, position, normal, material, distance)
	local self = setmetatable({}, RaycastResult)

	self.Instance = instance
	self.Position = position or Vector3.new()
	self.Normal = normal or Vector3.new()
	self.Material = material or Enum.Material.Plastic
	self.Distance = distance or 0

	return self
end

function RaycastResult:ToTable()
	return {
		type = "RaycastResult",
		Instance = self.Instance,
		Position = self.Position:ToTable(),
		Normal = self.Normal:ToTable(),
		Material = self.Material,
		Distance = self.Distance,
	}
end

function RaycastResult.FromTable(tbl)
	assert(tbl.type == "RaycastResult", "Table is not a RaycastResult")
	return RaycastResult.new(
		tbl.Instance,
		Vector3.FromTable(tbl.Position),
		Vector3.FromTable(tbl.Normal),
		tbl.Material,
		tbl.Distance
	)
end

return RaycastResult
