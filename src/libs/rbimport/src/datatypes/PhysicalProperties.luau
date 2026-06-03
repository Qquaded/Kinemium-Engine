--!strict
local Helper = require("./Helper")

local PhysicalProperties = {}
PhysicalProperties.__type = "PhysicalProperties"

local isFn = Helper.DataTypeIsFn(PhysicalProperties)

PhysicalProperties.__newindex = function()
	error("Cannot change")
end

local CACHE = setmetatable({}, { __mode = "v" })

local function newPhysicalProperties(
	density: number,
	friction: number,
	elasticity: number,
	frictionWeight: number,
	elasticityWeight: number,
	acousticAbsorption: number
): PhysicalProperties
	local hash = Helper.ValuesHash(density, friction, elasticity, frictionWeight, elasticityWeight, acousticAbsorption)
	local cached = CACHE[hash]
	if cached then
		return cached
	end
	local self = setmetatable({
		Density = density,
		Friction = friction,
		Elasticity = elasticity,
		FrictionWeight = frictionWeight,
		ElasticityWeight = elasticityWeight,
		AcousticAbsorption = acousticAbsorption,
	}, PhysicalProperties)
	CACHE[hash] = self
	return self
end

function PhysicalProperties.new(...): PhysicalProperties
	local count = select("#", ...)
	if count == 1 then
		-- enum
		error("Not implemented")
	elseif count == 3 then
		local density, friction, elasticity = ...
		assert(type(density) == "number", "invalid argument #1, expected number")
		assert(type(friction) == "number", "invalid argument #2, expected number")
		assert(type(elasticity) == "number", "invalid argument #3, expected number")
		return newPhysicalProperties(density, friction, elasticity, 1, 1, 1)
	elseif count == 5 or count == 6 then
		local density, friction, elasticity, frictionWeight, elasticityWeight, acousticAbsorption = ...
		assert(type(density) == "number", "invalid argument #1, expected number")
		assert(type(friction) == "number", "invalid argument #2, expected number")
		assert(type(elasticity) == "number", "invalid argument #3, expected number")
		assert(type(frictionWeight) == "number", "invalid argument #4, expected number")
		assert(type(elasticityWeight) == "number", "invalid argument #5, expected number")
		if count == 6 then
			assert(type(acousticAbsorption) == "number", "invalid argument #6, expected number")
		else
			acousticAbsorption = 1
		end
		return newPhysicalProperties(
			density,
			friction,
			elasticity,
			frictionWeight,
			elasticityWeight,
			acousticAbsorption
		)
	end
	error("No matching 'PhysicalProperties' constructor")
end

export type PhysicalProperties = typeof(PhysicalProperties.new(0, 0))

PhysicalProperties.__tostring = function(self: PhysicalProperties): string
	return `{self.Density}, {self.Friction}, {self.Elasticity}, {self.FrictionWeight}, {self.ElasticityWeight}`
end

local function Serialize(value: PhysicalProperties): (number, number, number, number, number, number)
	return value.Density,
		value.Friction,
		value.Elasticity,
		value.FrictionWeight,
		value.ElasticityWeight,
		value.AcousticAbsorption
end

local function Deserialize(
	density: number,
	friction: number,
	elasticity: number,
	frictionWeight: number,
	elasticityWeight: number,
	acousticAbsorption: number
): PhysicalProperties
	return PhysicalProperties.new(density, friction, elasticity, frictionWeight, elasticityWeight, acousticAbsorption)
end

return {
	DataType = PhysicalProperties,
	Serialize = Serialize,
	Deserialize = Deserialize,
	Is = isFn,
}
