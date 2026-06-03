local Enum = require("@EnumMap")

local OverlapParams = {}
OverlapParams.__index = OverlapParams

function OverlapParams.new()
	local self = setmetatable({}, OverlapParams)
	self.FilterDescendantsInstances = {}
	self.FilterType = Enum.RaycastFilterType.Exclude
	self.MaxParts = 0
	self.CollisionGroup = "Default"
	return self
end

function OverlapParams:AddToFilter(instances)
	if type(instances) == "table" then
		for _, inst in ipairs(instances) do
			table.insert(self.FilterDescendantsInstances, inst)
		end
	else
		table.insert(self.FilterDescendantsInstances, instances)
	end
end

function OverlapParams:ToTable()
	return {
		type = "OverlapParams",
		FilterDescendantsInstances = self.FilterDescendantsInstances,
		FilterType = self.FilterType,
		MaxParts = self.MaxParts,
		CollisionGroup = self.CollisionGroup,
	}
end

function OverlapParams.FromTable(tbl)
	assert(tbl.type == "OverlapParams", "Table is not an OverlapParams")
	local op = OverlapParams.new()
	op.FilterDescendantsInstances = tbl.FilterDescendantsInstances or {}
	op.FilterType = tbl.FilterType or Enum.RaycastFilterType.Exclude
	op.MaxParts = tbl.MaxParts or 0
	op.CollisionGroup = tbl.CollisionGroup or "Default"
	return op
end

return OverlapParams
