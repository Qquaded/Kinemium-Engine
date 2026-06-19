local Arc = {}

local registry = require("@InstanceRegistry")

function Arc:init(renderer, datamodel)
	local function createClass(class)
		return registry.new(class, renderer, datamodel, true)
	end

	local api = {}

	local function applyProperties(properties, object)
		for prop, value in pairs(properties) do
			if type(value) == "table" then
				-- check if the table is an Instance, or atleast has a valid ClassName
				if value.ClassName then
					value.Parent = object
				end
			end
			local success, result = pcall(function(...)
				object[prop] = value
			end)
			if not success then
				print(result)
				continue
			end
		end
	end

	local function createClassFunction(class)
		api[class] = function(properties)
			local new = createClass(class)
			applyProperties(properties, new)
			return new
		end
	end

	for class, data in pairs(registry.getClasses()) do
		createClassFunction(class)
	end

	return api
end

return Arc
