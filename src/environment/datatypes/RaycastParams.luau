local Enum = {
	RaycastFilterType = {
		Whitelist = 0,
		Blacklist = 1,
	},
}

local RaycastParams = {}
RaycastParams.__index = RaycastParams

function RaycastParams.new()
	return setmetatable({
		FilterDescendantsInstances = {},
		FilterType = Enum.RaycastFilterType.Whitelist,
		IgnoreWater = false,
		CollisionGroup = "Default",
		RespectCanCollide = false,
		BruteForceAllSlow = false,
		VisualizeRay = false,
		ExcludeInstances = {},
		IncludeInstances = {},
	}, RaycastParams)
end

function RaycastParams:AddToFilter(instances)
	if typeof(instances) == "table" then
		for _, inst in ipairs(instances) do
			self.FilterDescendantsInstances[#self.FilterDescendantsInstances + 1] = inst
		end
	else
		self.FilterDescendantsInstances[#self.FilterDescendantsInstances + 1] = instances
	end
end

function RaycastParams:ToTable()
	local copy = {}
	for i, v in ipairs(self.FilterDescendantsInstances) do
		copy[i] = v
	end

	return {
		type = "RaycastParams",
		FilterDescendantsInstances = copy,
		FilterType = self.FilterType,
		IgnoreWater = self.IgnoreWater,
		CollisionGroup = self.CollisionGroup,
		RespectCanCollide = self.RespectCanCollide,
		BruteForceAllSlow = self.BruteForceAllSlow,
		VisualizeRay = self.VisualizeRay,
		ExcludeInstances = self.ExcludeInstances,
		IncludeInstances = self.IncludeInstances,
	}
end

function RaycastParams.FromTable(tbl)
	assert(type(tbl) == "table", "Expected table")
	assert(tbl.type == "RaycastParams", "Table is not a RaycastParams")

	local rp = RaycastParams.new()

	-- deep copy filter list
	if tbl.FilterDescendantsInstances then
		for i, v in ipairs(tbl.FilterDescendantsInstances) do
			rp.FilterDescendantsInstances[i] = v
		end
	end

	-- safe assignments
	if tbl.FilterType ~= nil then
		rp.FilterType = tbl.FilterType
	end

	if tbl.IgnoreWater ~= nil then
		rp.IgnoreWater = tbl.IgnoreWater
	end

	if tbl.CollisionGroup ~= nil then
		rp.CollisionGroup = tbl.CollisionGroup
	end

	if tbl.RespectCanCollide ~= nil then
		rp.RespectCanCollide = tbl.RespectCanCollide
	end

	if tbl.BruteForceAllSlow ~= nil then
		rp.BruteForceAllSlow = tbl.BruteForceAllSlow
	end
	if tbl.VisualizeRay ~= nil then
		rp.VisualizeRay = tbl.VisualizeRay
	end
	if tbl.ExcludeInstances ~= nil then
		rp.ExcludeInstances = tbl.ExcludeInstances
	end
	if tbl.IncludeInstances ~= nil then
		rp.IncludeInstances = tbl.IncludeInstances
	end

	return rp
end

return RaycastParams
