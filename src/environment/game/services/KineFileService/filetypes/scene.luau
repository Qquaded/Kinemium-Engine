local function serializeInstance(root)
	local nodes = {}
	local nextId = 0

	local function visit(object, parentId)
		local id = nextId
		nextId += 1

		local node = {
			id = id,
			name = object.Name,
			class = object.ClassName,
			parent = parentId,
		}

		local properties = {}
		for property, value in pairs(object:GetProperties()) do
			if type(value) == "table" and value.ToTable then
				value = value:ToTable()
			end
			properties[property] = value
		end

		if next(properties) then
			node.properties = properties
		end

		table.insert(nodes, node)

		for _, child in ipairs(object:GetChildren()) do
			visit(child, id)
		end
	end

	visit(root, nil)

	return nodes
end

return {
	serialize = function(datamodel)
		return {
			name = datamodel.Name,
			version = 1,
			nodes = serializeInstance(datamodel),
		}
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
