local Vector3int16 = require("./Vector3int16")

local Region3int16 = {}
Region3int16.__index = Region3int16

function Region3int16.new(min, max)
	return setmetatable({
		Min = min,
		Max = max,
	}, Region3int16)
end

function Region3int16:ToTable()
	return {
		type = "Region3int16",
		Min = self.Min:ToTable(),
		Max = self.Max:ToTable(),
	}
end

function Region3int16.FromTable(tbl)
	assert(tbl.type == "Region3int16", "Table is not a Region3int16")
	return Region3int16.new(Vector3int16.FromTable(tbl.Min), Vector3int16.FromTable(tbl.Max))
end

return Region3int16
