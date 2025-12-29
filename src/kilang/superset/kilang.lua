return {
	{
		name = "preprocessor",
		gsub = function(code)
			code = code:gsub("#include%s*<.->\n", "")
			code = code:gsub("#define%s+([%w_]+)%s+(.-)\n", "local %1 = %2\n")

			return code
		end,
	},
	{
		name = "bitwiseOps",
		gsub = function(code)
			-- Left shift: a << b → bit32.lshift(a, b)
			code = code:gsub("([%w_]+)%s*<<%s*([%w_]+)", "bit32.lshift(%1, %2)")
			-- Right shift: a >> b → bit32.rshift(a, b)
			code = code:gsub("([%w_]+)%s*>>%s*([%w_]+)", "bit32.rshift(%1, %2)")
			-- Bitwise AND: a & b → bit32.band(a, b)
			code = code:gsub("([%w_]+)%s*&%s*([%w_]+)", "bit32.band(%1, %2)")
			-- Bitwise OR: a | b → bit32.bor(a, b)
			code = code:gsub("([%w_]+)%s*|%s*([%w_]+)", "bit32.bor(%1, %2)")
			-- Bitwise XOR: a ^ b → bit32.bxor(a, b)
			code = code:gsub("([%w_]+)%s*%^%s*([%w_]+)", "bit32.bxor(%1, %2)")
			-- Bitwise NOT: ~a → bit32.bnot(a)
			code = code:gsub("~([%w_]+)", "bit32.bnot(%1)")

			return code
		end,
	},
	{
		name = "extraOps",
		gsub = function(code)
			code = code:gsub("([%w_]+)%s*%+=%s*(.-);", "%1 = %1 + %2")
			code = code:gsub("([%w_]+)%s*%-=%s*(.-);", "%1 = %1 - %2")
			code = code:gsub("([%w_]+)%s*%*=%s*(.-);", "%1 = %1 * %2")
			code = code:gsub("([%w_]+)%s*/=%s*(.-);", "%1 = %1 / %2")
			code = code:gsub("([%w_]+)%s*%%=%s*(.-);", "%1 = %1 % %2") -- modulo
			code = code:gsub("!=", "~=")
			code = code:gsub("&&", "and")
			code = code:gsub("||", "or")
			code = code:gsub("!%s*", "not ")

			return code
		end,
	},
	{
		name = "include",
		gsub = function(code: string)
			code = code:gsub("#include", "include")

			return code
		end,
	},
	{
		name = "variables",
		gsub = function(code)
			-- int, float, double, bool, char
			code = code:gsub("%f[%w]int%s+([%w_]+)%s*=%s*(.-);", "local %1 = %2")
			code = code:gsub("%f[%w]float%s+([%w_]+)%s*=%s*(.-);", "local %1 = %2")
			code = code:gsub("%f[%w]double%s+([%w_]+)%s*=%s*(.-);", "local %1 = %2")
			code = code:gsub("%f[%w]bool%s+([%w_]+)%s*=%s*(.-);", "local %1 = %2")
			code = code:gsub("%f[%w]char%s+([%w_]+)%s*=%s*(.-);", "local %1 = %2")
			return code
		end,
	},
}
