local CustomPhysicalProperties = {}
CustomPhysicalProperties.__index = CustomPhysicalProperties

export type CustomPhysicalProperties = {
	Density: number?,
	Friction: number?,
	Elasticity: number?,
	FrictionWeight: number?,
	ElasticityWeight: number?,
}

function CustomPhysicalProperties.new(
	density: number?,
	friction: number?,
	elasticity: number?,
	frictionWeight: number?,
	elasticityWeight: number?
)
	local self = setmetatable({}, CustomPhysicalProperties)

	self.Density = density or 0.7
	self.Friction = friction or 0.3
	self.Elasticity = elasticity or 0.5
	self.FrictionWeight = frictionWeight or 1.0
	self.ElasticityWeight = elasticityWeight or 1.0

	return self
end

function CustomPhysicalProperties:Clone()
	return CustomPhysicalProperties.new(
		self.Density,
		self.Friction,
		self.Elasticity,
		self.FrictionWeight,
		self.ElasticityWeight
	)
end

function CustomPhysicalProperties:Equals(other: CustomPhysicalProperties)
	return self.Density == other.Density
		and self.Friction == other.Friction
		and self.Elasticity == other.Elasticity
		and self.FrictionWeight == other.FrictionWeight
		and self.ElasticityWeight == other.ElasticityWeight
end

function CustomPhysicalProperties:ToTable()
	return {
		type = "CustomPhysicalProperties",
		Density = self.Density,
		Friction = self.Friction,
		Elasticity = self.Elasticity,
		FrictionWeight = self.FrictionWeight,
		ElasticityWeight = self.ElasticityWeight,
	}
end

function CustomPhysicalProperties.FromTable(tbl)
	assert(tbl.type == "CustomPhysicalProperties")
	return CustomPhysicalProperties.new(
		tbl.Density,
		tbl.Friction,
		tbl.Elasticity,
		tbl.FrictionWeight,
		tbl.ElasticityWeight
	)
end

return CustomPhysicalProperties
