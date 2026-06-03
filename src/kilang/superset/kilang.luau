local lang = {}

function lang.process(code)
	local ProcessedDataThread = {
		variables = {},
		flags = {},
		annotations = {},
	}

	local gsubFuncs = {
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
			name = "flags",
			gsub = function(code)
				code = code:gsub("#flag:%s*([%w_%-]+)%s*\n?", function(flag)
					ProcessedDataThread.flags[flag] = true
					return ""
				end)

				return code, ProcessedDataThread
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
			name = "annotations",
			gsub = function(code)
				-- local x: Type = value
				code = code:gsub("local%s+([%w_]+)%s*:%s*([%w_%*]+)%s*=%s*(.-);?", function(name, typeExpr, value)
					local baseType = typeExpr:gsub("%*", "")
					local isPointer = typeExpr:find("%*") ~= nil

					ProcessedDataThread.annotations[name] = {
						type = baseType,
						value = value ~= "" and value or nil,
						isPointer = isPointer,
						isReference = false,
						qualifier = nil,
					}

					return "local " .. name .. " = " .. value
				end)

				-- local x: Type
				code = code:gsub("local%s+([%w_]+)%s*:%s*([%w_%*]+)%s*;?", function(name, typeExpr)
					local baseType = typeExpr:gsub("%*", "")
					local isPointer = typeExpr:find("%*") ~= nil

					ProcessedDataThread.annotations[name] = {
						type = baseType,
						value = nil,
						isPointer = isPointer,
						isReference = false,
						qualifier = nil,
					}

					return "local " .. name
				end)

				return code
			end,
		},
		{
			name = "comments",
			gsub = function(code)
				code = code:gsub("//(.-)(\n)", "--%1%2")
				code = code:gsub("/%*(.-)%*/", "--[[%1]]")
				return code
			end,
		},
		{
			name = "arrows",
			gsub = function(code)
				code = code:gsub("([%w_]+)%->([%w_]+)", "%1.%2")
				return code
			end,
		},
		{
			name = "null",
			gsub = function(code)
				code = code:gsub("NULL", "nil")
				return code
			end,
		},
		{
			name = "casting",
			gsub = function(code)
				code = code:gsub("%(int%)%s*([%w_%.%(%)]+)", "math.floor(%1)")
				code = code:gsub("%(float%)%s*([%w_%.%(%)]+)", "%1")
				code = code:gsub("%(double%)%s*([%w_%.%(%)]+)", "%1")
				code = code:gsub("static_cast%s*<%s*int%s*>%s*%((.-)%)", "math.floor(%1)")
				code = code:gsub("static_cast%s*<%s*float%s*>%s*%((.-)%)", "%1")
				code = code:gsub("static_cast%s*<%s*double%s*>%s*%((.-)%)", "%1")
				code = code:gsub("%(string%)%s*([%w_%.%(%)]+)", "tostring(%1)")
				return code
			end,
		},
		{
			name = "namespaces",
			gsub = function(code)
				code = code:gsub("#include%s*<.->\n", "")
				code = code:gsub("#define%s+([%w_]+)%s+(.-)\n", "local %1 = %2\n")
				-- #pragma once → (strip it, no-op in Lua)
				code = code:gsub("#pragma%s+once\n", "")
				-- #undef → set to nil
				code = code:gsub("#undef%s+([%w_]+)\n", "%1 = nil\n")
				-- #warning → print
				code = code:gsub('#warning%s+"(.-)"\n', 'print("[WARNING] %1")\n')
				code = code:gsub('#warning%s+(__KILANG_STR_%d+__)\n', 'print(%1)\n')
				-- #error → error()
				code = code:gsub('#error%s+"(.-)"\n', 'error("[ERROR] %1")\n')
				code = code:gsub('#error%s+(__KILANG_STR_%d+__)\n', 'error(%1)\n')
				return code
			end,
		},
		{
			name = "stdioMapping",
			gsub = function(code)
				code = code:gsub("printf%s*%((.-)%);", "print(%1)")
				code = code:gsub("std::cout%s*<<(.-)<<.-std::endl.-\n", function(expr)
					expr = expr:match("^%s*(.-)%s*$")
					return "print(" .. expr .. ")\n"
				end)
				code = code:gsub("%f[%w]NULL%f[%W]", "nil")
				code = code:gsub("std::string", "string")
				code = code:gsub("std::vector%s*<.->%s+([%w_]+)", "local %1 = {}")
				code = code:gsub("%f[%w]nullptr%f[%W]", "nil")
				code = code:gsub("%f[%w]TRUE%f[%W]", "true")
				code = code:gsub("%f[%w]FALSE%f[%W]", "false")
				return code
			end,
		},
		{
			name = "variables",
			gsub = function(code)
				ProcessedDataThread.variables = ProcessedDataThread.variables or {}

				-- detect: local x = value
				code:gsub("local%s+([%w_]+)%s*=%s*([^;\n]+)", function(name, value)
					ProcessedDataThread.variables[name] = {
						value = value ~= "" and value or nil,
						isLocal = true,
					}
				end)

				-- detect: local x (no assignment)
				code:gsub("local%s+([%w_]+)%f[%W]", function(name)
					if not ProcessedDataThread.variables[name] then
						ProcessedDataThread.variables[name] = {
							value = nil,
							isLocal = true,
						}
					end
				end)

				-- detect: x = value  (avoid matching ==, ~=, >=, <=)
				code:gsub("([%w_]+)%s*=%s*([^=;\n]+)", function(name, value)
					-- skip if it's already recorded as local in same pass
					if not ProcessedDataThread.variables[name] then
						ProcessedDataThread.variables[name] = {
							value = value ~= "" and value or nil,
							isLocal = false,
						}
					end
				end)

				return code
			end,
		},
	}

	return gsubFuncs, ProcessedDataThread
end

return lang
