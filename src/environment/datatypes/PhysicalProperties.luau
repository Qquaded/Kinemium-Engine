local PhysicalProperties = {}
PhysicalProperties.__index = PhysicalProperties

export type PhysicalProperties = {
	Density: number?,
	Friction: number?,
	Elasticity: number?,
	FrictionWeight: number?,
	ElasticityWeight: number?,
}

function PhysicalProperties.new(
	density: number?,
	friction: number?,
	elasticity: number?,
	frictionWeight: number?,
	elasticityWeight: number?
)
	local self = setmetatable({}, PhysicalProperties)

	self.Density = density or 0.7
	self.Friction = friction or 0.3
	self.Elasticity = elasticity or 0.5
	self.FrictionWeight = frictionWeight or 1.0
	self.ElasticityWeight = elasticityWeight or 1.0

	return self
end

function PhysicalProperties:Clone()
	return PhysicalProperties.new(
		self.Density,
		self.Friction,
		self.Elasticity,
		self.FrictionWeight,
		self.ElasticityWeight
	)
end

function PhysicalProperties:Equals(other: PhysicalProperties)
	return self.Density == other.Density
		and self.Friction == other.Friction
		and self.Elasticity == other.Elasticity
		and self.FrictionWeight == other.FrictionWeight
		and self.ElasticityWeight == other.ElasticityWeight
end

function PhysicalProperties:ToTable()
	return {
		type = "PhysicalProperties",
		Density = self.Density,
		Friction = self.Friction,
		Elasticity = self.Elasticity,
		FrictionWeight = self.FrictionWeight,
		ElasticityWeight = self.ElasticityWeight,
	}
end

function PhysicalProperties.FromTable(tbl)
	assert(tbl.type == "PhysicalProperties")
	return PhysicalProperties.new(tbl.Density, tbl.Friction, tbl.Elasticity, tbl.FrictionWeight, tbl.ElasticityWeight)
end

return PhysicalProperties
