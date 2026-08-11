return {
	serialize = function(instances, datamodel)
		local SerializationService = datamodel:GetService("SerializationService")
		local serialized = SerializationService.SerializeInstancesAsync(instances)

		return serialized
	end,

	deserialize = function(buf, datamodel)
		local SerializationService = datamodel:GetService("SerializationService")
		if buf then
			local deserialized = SerializationService.Deserialize(buf, nil, true)
			if deserialized then
				if #deserialized == 1 then
					return deserialized[1]
				end
				return deserialized
			end
		end
		return false
	end,
}
