-- Kinemium Schema made by devcell
local Schema = {}
Schema.__index = Schema

function Schema.string()
	return function(value)
		return type(value) == "string"
	end
end

function Schema.nonEmptyString()
	return function(value)
		return type(value) == "string" and #value > 0
	end
end

function Schema.stringPattern(pattern)
	return function(value)
		return type(value) == "string" and value:match(pattern)
	end
end

function Schema.number()
	return function(value)
		return type(value) == "number"
	end
end

function Schema.int()
	return function(value)
		return type(value) == "number" and math.floor(value) == value
	end
end

function Schema.u32()
	return function(value)
		return type(value) == "number" and value >= 0 and value <= 0xFFFFFFFF and math.floor(value) == value
	end
end

function Schema.float()
	return function(value)
		return type(value) == "number"
	end
end

function Schema.positive()
	return function(value)
		return type(value) == "number" and value > 0
	end
end

function Schema.negative()
	return function(value)
		return type(value) == "number" and value < 0
	end
end

function Schema.min(minValue)
	return function(value)
		return type(value) == "number" and value >= minValue
	end
end

function Schema.max(maxValue)
	return function(value)
		return type(value) == "number" and value <= maxValue
	end
end

function Schema.range(minValue, maxValue)
	return function(value)
		return type(value) == "number" and value >= minValue and value <= maxValue
	end
end

function Schema.boolean()
	return function(value)
		return type(value) == "boolean"
	end
end

function Schema.any()
	return function(_)
		return true
	end
end

function Schema.positiveInt()
	return function(value)
		return type(value) == "number" and math.floor(value) == value and value > 0
	end
end

function Schema.negativeInt()
	return function(value)
		return type(value) == "number" and math.floor(value) == value and value < 0
	end
end

function Schema.u8()
	return function(value)
		return type(value) == "number" and value >= 0 and value <= 0xFF and math.floor(value) == value
	end
end

function Schema.u16()
	return function(value)
		return type(value) == "number" and value >= 0 and value <= 0xFFFF and math.floor(value) == value
	end
end

function Schema.u64()
	return function(value)
		return type(value) == "number" and value >= 0 and value <= 9007199254740991 and math.floor(value) == value
	end
end

function Schema.i8()
	return function(value)
		return type(value) == "number" and value >= -0x80 and value <= 0x7F and math.floor(value) == value
	end
end

function Schema.i16()
	return function(value)
		return type(value) == "number" and value >= -0x8000 and value <= 0x7FFF and math.floor(value) == value
	end
end

function Schema.i32()
	return function(value)
		return type(value) == "number" and value >= -0x80000000 and value <= 0x7FFFFFFF and math.floor(value) == value
	end
end

function Schema.i64()
	return function(value)
		return type(value) == "number"
			and value >= -0x8000000000000000
			and value <= 0x7FFFFFFFFFFFFFFF
			and math.floor(value) == value
	end
end

function Schema.allOf(...)
	local validators = { ... }
	return function(value)
		for _, v in ipairs(validators) do
			if not v(value) then
				return false
			end
		end
		return true
	end
end

function Schema.anyOf(...)
	local validators = { ... }
	return function(value)
		for _, v in ipairs(validators) do
			if v(value) then
				return true
			end
		end
		return false
	end
end

function Schema.notf(validator)
	return function(value)
		return not validator(value)
	end
end

function Schema.minItems(min)
	return function(value)
		return type(value) == "table" and #value >= min
	end
end

function Schema.maxItems(max)
	return function(value)
		return type(value) == "table" and #value <= max
	end
end

function Schema.itemCount(min, max)
	return function(value)
		if type(value) ~= "table" then
			return false
		end
		local n = #value
		return n >= min and n <= max
	end
end

function Schema.exact(expected)
	return function(value)
		return value == expected
	end
end

function Schema.strictMap(definition)
	return function(value)
		if type(value) ~= "table" then
			return false
		end

		for key, validator in pairs(definition) do
			if not validator(value[key]) then
				return false
			end
		end

		for key in pairs(value) do
			if definition[key] == nil then
				return false
			end
		end

		return true
	end
end

function Schema.noExtraKeys(definition)
	return function(value)
		if type(value) ~= "table" then
			return false
		end
		for key in pairs(value) do
			if definition[key] == nil then
				return false
			end
		end
		return true
	end
end

function Schema.transform(validator, transformFn)
	return function(value)
		if not validator(value) then
			return false
		end
		return transformFn(value) ~= nil
	end
end

function Schema.coerceNumber()
	return function(value)
		if type(value) == "number" then
			return true
		end
		if type(value) == "string" then
			return tonumber(value) ~= nil
		end
		return false
	end
end

function Schema.lazy(getValidator)
	local validator
	return function(value)
		if not validator then
			validator = getValidator()
		end
		return validator(value)
	end
end

function Schema.nullable(validator)
	return function(value)
		if value == nil then
			return true
		end
		return validator(value)
	end
end

function Schema.oneOf(values)
	return function(value)
		for _, v in ipairs(values) do
			if value == v then
				return true
			end
		end
		return false
	end
end

function Schema.instanceOf(typeName)
	return function(value)
		return type(value) == "table" and value.__type == typeName
	end
end

function Schema.tuple(...)
	local validators = { ... }
	return function(value)
		if type(value) ~= "table" or #value ~= #validators then
			return false
		end
		for i, v in ipairs(validators) do
			if not v(value[i]) then
				return false
			end
		end
		return true
	end
end

function Schema.record(valueValidator)
	return function(value)
		if type(value) ~= "table" then
			return false
		end
		for _, v in pairs(value) do
			if not valueValidator(v) then
				return false
			end
		end
		return true
	end
end

function Schema.nonEmptyArray(validator)
	return function(value)
		if type(value) ~= "table" or #value == 0 then
			return false
		end
		for _, v in ipairs(value) do
			if not validator(v) then
				return false
			end
		end
		return true
	end
end

function Schema.sortedArray(validator)
	return function(value)
		if type(value) ~= "table" then
			return false
		end
		for i = 1, #value do
			if not validator(value[i]) then
				return false
			end
			if i > 1 and value[i] < value[i - 1] then
				return false
			end
		end
		return true
	end
end

function Schema.uniqueBy(keyFn)
	return function(value)
		if type(value) ~= "table" then
			return false
		end
		local seen = {}
		for _, v in ipairs(value) do
			local k = keyFn(v)
			if seen[k] then
				return false
			end
			seen[k] = true
		end
		return true
	end
end

function Schema.custom(fn)
	return function(value)
		return fn(value) == true
	end
end

function Schema.deepEqual(expected)
	local function eq(a, b)
		if type(a) ~= type(b) then
			return false
		end
		if type(a) ~= "table" then
			return a == b
		end
		for k, v in pairs(a) do
			if not eq(v, b[k]) then
				return false
			end
		end
		for k in pairs(b) do
			if a[k] == nil then
				return false
			end
		end
		return true
	end
	return function(value)
		return eq(value, expected)
	end
end

function Schema.throttle(min, max)
	return function(value)
		return type(value) == "number" and value >= min and value <= max
	end
end

function Schema.finite()
	return function(value)
		return type(value) == "number" and value == value and value ~= math.huge and value ~= -math.huge
	end
end

function Schema.nonNaN()
	return function(value)
		return type(value) == "number" and value == value
	end
end

function Schema.trimmedString()
	return function(value)
		return type(value) == "string" and value:match("^%s*.+%s*$") ~= nil
	end
end

function Schema.lowercase()
	return function(value)
		return type(value) == "string" and value == value:lower()
	end
end

function Schema.uppercase()
	return function(value)
		return type(value) == "string" and value == value:upper()
	end
end

function Schema.startsWith(prefix)
	return function(value)
		return type(value) == "string" and value:sub(1, #prefix) == prefix
	end
end

function Schema.endsWith(suffix)
	return function(value)
		return type(value) == "string" and value:sub(-#suffix) == suffix
	end
end

function Schema.contains(substr)
	return function(value)
		return type(value) == "string" and value:find(substr, 1, true) ~= nil
	end
end

function Schema.even()
	return function(value)
		return type(value) == "number" and value % 2 == 0
	end
end

function Schema.odd()
	return function(value)
		return type(value) == "number" and value % 2 == 1
	end
end

function Schema.betweenExclusive(min, max)
	return function(value)
		return type(value) == "number" and value > min and value < max
	end
end

function Schema.multipleOf(n)
	return function(value)
		return type(value) == "number" and value % n == 0
	end
end

function Schema.arrayLengthExactly(n)
	return function(value)
		return type(value) == "table" and #value == n
	end
end

function Schema.hasKeys(...)
	local keys = { ... }
	return function(value)
		if type(value) ~= "table" then
			return false
		end
		for _, k in ipairs(keys) do
			if value[k] == nil then
				return false
			end
		end
		return true
	end
end

function Schema.keyType(keyValidator)
	return function(value)
		if type(value) ~= "table" then
			return false
		end
		for k in pairs(value) do
			if not keyValidator(k) then
				return false
			end
		end
		return true
	end
end

function Schema.valueType(valueValidator)
	return function(value)
		if type(value) ~= "table" then
			return false
		end
		for _, v in pairs(value) do
			if not valueValidator(v) then
				return false
			end
		end
		return true
	end
end

function Schema.default(defaultValue, validator)
	return function(value)
		if value == nil then
			return validator(defaultValue)
		end
		return validator(value)
	end
end

function Schema.decimal(precision)
	return function(value)
		if type(value) ~= "number" then
			return false
		end
		local multiplier = 10 ^ precision
		return math.floor(value * multiplier) == value * multiplier
	end
end

function Schema.email()
	return function(value)
		return type(value) == "string" and value:match("^.+@.+%..+$")
	end
end

function Schema.noHoles()
	return function(value)
		if type(value) ~= "table" then
			return false
		end
		for i = 1, #value do
			if value[i] == nil then
				return false
			end
		end
		return true
	end
end

function Schema.readonly()
	return function(value)
		return type(value) ~= "table" or getmetatable(value) ~= nil
	end
end

function Schema.frozen()
	return function(value)
		return type(value) == "table" and table.isfrozen and table.isfrozen(value)
	end
end

function Schema.callable()
	return function(value)
		return type(value) == "function"
	end
end

function Schema.metatable(expected)
	return function(value)
		return type(value) == "table" and getmetatable(value) == expected
	end
end

function Schema.deepArray(depth, validator)
	return function(value)
		local function check(v, d)
			if d == 0 then
				return validator(v)
			end
			if type(v) ~= "table" then
				return false
			end
			for _, x in ipairs(v) do
				if not check(x, d - 1) then
					return false
				end
			end
			return true
		end
		return check(value, depth)
	end
end

function Schema.shape(shapeFn)
	return function(value)
		return shapeFn(value) == true
	end
end

function Schema.guard(predicate)
	return function(value)
		return predicate(value) == true
	end
end

function Schema.pipe(...)
	local validators = { ... }
	return function(value)
		for _, v in ipairs(validators) do
			if not v(value) then
				return false
			end
		end
		return true
	end
end

function Schema.url()
	return function(value)
		if type(value) ~= "string" then
			return false
		end
		return value:match("^https?://[%w%.%-]+%.%a+[/%%?&=%w%-_%.]*$") ~= nil
	end
end

function Schema.uuid()
	return function(value)
		return type(value) == "string" and value:match("^[%x]+%-%x+%-%x+%-%x+%-%x+$")
	end
end

function Schema.hexColor()
	return function(value)
		return type(value) == "string" and value:match("^#%x%x%x%x%x%x$")
	end
end

function Schema.length(min, max)
	return function(value)
		if type(value) ~= "string" then
			return false
		end
		local len = #value
		return (not min or len >= min) and (not max or len <= max)
	end
end

function Schema.arrayOf(validator)
	return function(value)
		if type(value) ~= "table" then
			return false
		end
		for _, v in ipairs(value) do
			if not validator(v) then
				return false
			end
		end
		return true
	end
end

function Schema.setOf(validator)
	return function(value)
		if type(value) ~= "table" then
			return false
		end
		local seen = {}
		for _, v in ipairs(value) do
			if not validator(v) or seen[v] then
				return false
			end
			seen[v] = true
		end
		return true
	end
end

function Schema.dict(keyValidator, valueValidator)
	return function(value)
		if type(value) ~= "table" then
			return false
		end
		for k, v in pairs(value) do
			if not keyValidator(k) or not valueValidator(v) then
				return false
			end
		end
		return true
	end
end

function Schema.timestamp()
	return function(value)
		return type(value) == "number" and value > 0
	end
end

function Schema.dateString()
	return function(value)
		return type(value) == "string" and value:match("^%d%d%d%d%-%d%d%-%d%d$")
	end
end

function Schema.timeString()
	return function(value)
		return type(value) == "string" and value:match("^%d%d:%d%d:%d%d$")
	end
end

function Schema.vector2()
	return function(value)
		return type(value) == "table" and type(value.X) == "number" and type(value.Y) == "number"
	end
end

function Schema.vector3()
	return function(value)
		return type(value) == "table"
			and type(value.X) == "number"
			and type(value.Y) == "number"
			and type(value.Z) == "number"
	end
end

function Schema.color3()
	return function(value)
		return type(value) == "table"
			and type(value.R) == "number"
			and type(value.G) == "number"
			and type(value.B) == "number"
	end
end

function Schema.position3D()
	return function(value)
		return type(value) == "table"
			and type(value.X) == "number"
			and type(value.Y) == "number"
			and type(value.Z) == "number"
	end
end

function Schema.enum(enumTable)
	return function(value)
		for _, v in ipairs(enumTable) do
			if v == value then
				return true
			end
		end
		return false
	end
end

function Schema.optional(validator)
	return function(value)
		if value == nil then
			return true
		end
		return validator(value)
	end
end

function Schema.emptyTable()
	return function(value)
		return type(value) == "table" and next(value) == nil
	end
end

function Schema.exactKeys(...)
	local allowed = {}
	for _, k in ipairs({ ... }) do
		allowed[k] = true
	end
	return function(value)
		if type(value) ~= "table" then
			return false
		end
		for k in pairs(value) do
			if not allowed[k] then
				return false
			end
		end
		for k in pairs(allowed) do
			if value[k] == nil then
				return false
			end
		end
		return true
	end
end

function Schema.partial(definition)
	return function(value)
		if type(value) ~= "table" then
			return false
		end
		for k, v in pairs(definition) do
			if value[k] ~= nil and not v(value[k]) then
				return false
			end
		end
		return true
	end
end

function Schema.zero()
	return function(value)
		return value == 0
	end
end

function Schema.nonZero()
	return function(value)
		return type(value) == "number" and value ~= 0
	end
end

function Schema.clamped(min, max)
	return function(value)
		return type(value) == "number" and value >= min and value <= max
	end
end

function Schema.identifier()
	return function(value)
		return type(value) == "string" and value:match("^[A-Za-z_][A-Za-z0-9_]*$") ~= nil
	end
end

function Schema.snakeCase()
	return function(value)
		return type(value) == "string" and value:match("^[a-z]+(_[a-z]+)*$") ~= nil
	end
end

function Schema.camelCase()
	return function(value)
		return type(value) == "string" and value:match("^[a-z]+[A-Za-z0-9]*$") ~= nil
	end
end

function Schema.component(definition)
	return function(value)
		if type(value) ~= "table" then
			return false
		end
		for k, v in pairs(definition) do
			if not v(value[k]) then
				return false
			end
		end
		return true
	end
end

function Schema.entityId()
	return function(value)
		return type(value) == "number" and value > 0 and math.floor(value) == value
	end
end

function Schema.xor(a, b)
	return function(value)
		return a(value) ~= b(value)
	end
end

function Schema.implies(a, b)
	return function(value)
		return not a(value) or b(value)
	end
end

function Schema.when(predicate, thenValidator, elseValidator)
	return function(value)
		if predicate(value) then
			return thenValidator(value)
		end
		return elseValidator and elseValidator(value) or true
	end
end

function Schema.noMetatable()
	return function(value)
		return type(value) ~= "table" or getmetatable(value) == nil
	end
end

function Schema.shallowImmutable()
	return function(value)
		if type(value) ~= "table" then
			return true
		end
		for k in pairs(value) do
			if type(k) == "table" then
				return false
			end
		end
		return true
	end
end

function Schema.assert(validator, message)
	return function(value)
		if not validator(value) then
			error(message or "Schema assertion failed", 2)
		end
		return true
	end
end

function Schema.debug(name, validator)
	return function(value)
		local ok = validator(value)
		if not ok then
			warn("Schema failed:", name, value)
		end
		return ok
	end
end

function Schema.kebabCase()
	return function(value)
		return type(value) == "string" and value:match("^[a-z]+(-[a-z]+)*$") ~= nil
	end
end

function Schema.table(definition)
	return function(value)
		if type(value) ~= "table" then
			return false
		end
		if #value ~= #definition then
			return false
		end
		for i, validator in ipairs(definition) do
			if not validator(value[i]) then
				return false
			end
		end
		return true
	end
end

function Schema.map(definition)
	return function(value)
		if type(value) ~= "table" then
			return false
		end
		for key, validator in pairs(definition) do
			if not validator(value[key]) then
				return false
			end
		end
		return true
	end
end

function Schema.new(definition)
	return setmetatable({ definition = definition }, Schema)
end

function Schema:validate(packet)
	if type(packet) ~= "table" then
		return false, "$", "Expected table"
	end

	local def = self.definition

	if #def > 0 then
		if #packet ~= #def then
			return false, "$", "Array length mismatch"
		end

		for i, validator in ipairs(def) do
			local ok = validator(packet[i])
			if not ok then
				return false, "[" .. i .. "]", "Validation failed"
			end
		end
	else
		for key, validator in pairs(def) do
			local ok = validator(packet[key])
			if not ok then
				return false, "." .. tostring(key), "Validation failed"
			end
		end
	end

	return true
end

return Schema
