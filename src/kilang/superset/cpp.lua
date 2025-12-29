return {
	-- Comments (convert C++ style to Lua style) - FIRST
	{
		name = "comments",
		gsub = function(code)
			code = code:gsub("//(.-)%s*\n", "--%1\n")
			code = code:gsub("/%*(.-)%*/", "--[[%1]]")
			return code
		end,
	},

	-- Preprocessor directives
	{
		name = "preprocessor",
		gsub = function(code)
			code = code:gsub("#include%s*<[^>]+>%s*\n?", "")
			code = code:gsub('#include%s*"[^"]+"%s*\n?', "")
			code = code:gsub("#define%s+([%w_]+)%s+(.-)%s*\n", "local %1 = %2\n")
			code = code:gsub("#pragma.-\n", "")
			return code
		end,
	},

	-- Namespaces
	{
		name = "namespaces",
		gsub = function(code)
			code = code:gsub("using%s+namespace%s+[%w_:]+;", "")
			code = code:gsub("namespace%s+[%w_]+%s*{", "")
			code = code:gsub("}%s*//.-namespace", "")
			return code
		end,
	},

	-- STL member functions (before other conversions)
	{
		name = "stlMemberFunctions",
		gsub = function(code)
			-- Vector operations
			code = code:gsub("([%w_]+)%.push_back%(", "table.insert(%1, ")
			code = code:gsub("([%w_]+)%.pop_back%(%)", "table.remove(%1)")
			code = code:gsub("([%w_]+)%.size%(%)", "#%1")
			code = code:gsub("([%w_]+)%.empty%(%)", "#%1 == 0")
			code = code:gsub("([%w_]+)%.clear%(%)", "%1 = {}")

			-- String operations
			code = code:gsub("([%w_]+)%.length%(%)", "#%1")
			code = code:gsub("([%w_]+)%.substr%(", "string.sub(%1, ")
			code = code:gsub("([%w_]+)%.find%(", "string.find(%1, ")

			-- Pair access
			code = code:gsub("([%w_]+)%.first", "%1[1]")
			code = code:gsub("([%w_]+)%.second", "%1[2]")

			-- Pointer/namespace access
			code = code:gsub("([%w_]+)->([%w_]+)", "%1.%2")
			code = code:gsub("std::([%w_]+)", "%1")

			-- IO
			code = code:gsub("cout%s*<<%s*(.-)%s*<<%s*endl", "print(%1)")
			code = code:gsub("cout%s*<<", "print(")
			code = code:gsub("endl", '"\\n"')

			return code
		end,
	},

	-- Control flow (before braces conversion)
	{
		name = "controlFlow",
		gsub = function(code)
			-- For loops with type and increment
			code = code:gsub(
				"for%s*%(([%w_]+)%s+([%w_]+)%s*=%s*(.-)%s*;%s*%2%s*<%s*(.-)%s*;%s*%2%+%+%s*%)",
				"for %2 = %3, (%4) - 1 do"
			)
			code = code:gsub(
				"for%s*%(([%w_]+)%s+([%w_]+)%s*=%s*(.-)%s*;%s*%2%s*<=%s*(.-)%s*;%s*%2%+%+%s*%)",
				"for %2 = %3, %4 do"
			)

			-- For loops without type
			code = code:gsub(
				"for%s*%(([%w_]+)%s*=%s*(.-)%s*;%s*%1%s*<%s*(.-)%s*;%s*%1%+%+%s*%)",
				"for %1 = %2, (%3) - 1 do"
			)
			code = code:gsub("for%s*%(([%w_]+)%s*=%s*(.-)%s*;%s*%1%s*<=%s*(.-)%s*;%s*%1%+%+%s*%)", "for %1 = %2, %3 do")

			-- Range-based for loops
			code = code:gsub("for%s*%(%s*[%w_:&%*]+%s+([%w_]+)%s*:%s*([%w_]+)%s*%)", "for _, %1 in ipairs(%2) do")
			code = code:gsub("for%s*%(%s*auto%s+([%w_]+)%s*:%s*([%w_]+)%s*%)", "for _, %1 in ipairs(%2) do")

			-- While loops
			code = code:gsub("while%s*%((.-)%)", "while %1 do")

			-- If/else statements
			code = code:gsub("else%s+if%s*%((.-)%)", "elseif %1 then")
			code = code:gsub("if%s*%((.-)%)", "if %1 then")
			code = code:gsub("else%s*{", "else")

			-- Switch statements
			code = code:gsub("switch%s*%((.-)%)", "-- switch(%1)")
			code = code:gsub("case%s+(.-):", "-- case %1:")
			code = code:gsub("default:", "-- default:")
			code = code:gsub("break;", "")

			return code
		end,
	},

	-- Operators (before variables)
	{
		name = "operators",
		gsub = function(code)
			-- Comparison and logical operators (before compound assignments)
			code = code:gsub("!=", "~=")
			code = code:gsub("&&", " and ")
			code = code:gsub("||", " or ")
			code = code:gsub("!([%w_%(])", "not %1")

			-- Compound bitwise assignments
			code = code:gsub("([%w_%.%[%]]+)%s*<<=%s*(.-)%s*;", "%1 = bit32.lshift(%1, %2)")
			code = code:gsub("([%w_%.%[%]]+)%s*>>=%s*(.-)%s*;", "%1 = bit32.rshift(%1, %2)")
			code = code:gsub("([%w_%.%[%]]+)%s*&=%s*(.-)%s*;", "%1 = bit32.band(%1, %2)")
			code = code:gsub("([%w_%.%[%]]+)%s*|=%s*(.-)%s*;", "%1 = bit32.bor(%1, %2)")
			code = code:gsub("([%w_%.%[%]]+)%s*%^=%s*(.-)%s*;", "%1 = bit32.bxor(%1, %2)")

			-- Regular compound assignments
			code = code:gsub("([%w_%.%[%]]+)%s*%+=%s*(.-)%s*;", "%1 = %1 + %2")
			code = code:gsub("([%w_%.%[%]]+)%s*%-=%s*(.-)%s*;", "%1 = %1 - %2")
			code = code:gsub("([%w_%.%[%]]+)%s*%*=%s*(.-)%s*;", "%1 = %1 * %2")
			code = code:gsub("([%w_%.%[%]]+)%s*/=%s*(.-)%s*;", "%1 = %1 / %2")
			code = code:gsub("([%w_%.%[%]]+)%s*%%=%s*(.-)%s*;", "%1 = %1 %% %2")

			-- Increment/decrement
			code = code:gsub("([%w_%.%[%]]+)%+%+%s*;", "%1 = %1 + 1")
			code = code:gsub("([%w_%.%[%]]+)%-%-%-*%s*;", "%1 = %1 - 1")

			return code
		end,
	},

	-- Bitwise operations
	{
		name = "bitwiseOps",
		gsub = function(code)
			code = code:gsub("([%w_%.%[%]%(]+)%s*<<%s*([%w_%.%[%]%(]+)", "bit32.lshift(%1, %2)")
			code = code:gsub("([%w_%.%[%]%(]+)%s*>>%s*([%w_%.%[%]%(]+)", "bit32.rshift(%1, %2)")
			code = code:gsub("([%w_%.%[%]%(]+)%s*&%s*([%w_%.%[%]%(]+)", "bit32.band(%1, %2)")
			code = code:gsub("([%w_%.%[%]%(]+)%s*|%s*([%w_%.%[%]%(]+)", "bit32.bor(%1, %2)")
			code = code:gsub("([%w_%.%[%]%(]+)%s*%^%s*([%w_%.%[%]%(]+)", "bit32.bxor(%1, %2)")
			code = code:gsub("~([%w_%.%[%]%(]+)", "bit32.bnot(%1)")
			return code
		end,
	},

	-- Structs and classes (before functions and variables)
	{
		name = "structsClasses",
		gsub = function(code)
			-- Struct/class definitions
			code = code:gsub("struct%s+([%w_]+)%s*{", "local %1 = {")
			code = code:gsub("class%s+([%w_]+)%s*{", "local %1 = {")
			code = code:gsub("class%s+([%w_]+)%s*:%s*public%s+[%w_]+%s*{", "local %1 = {")

			-- Access modifiers
			code = code:gsub("public:", "")
			code = code:gsub("private:", "")
			code = code:gsub("protected:", "")

			return code
		end,
	},

	-- Functions (before variables to handle parameters)
	{
		name = "functions",
		gsub = function(code)
			-- Function with return type and parameters with types
			code = code:gsub("([%w_:<>]+)%s+([%w_]+)%s*%(([^%)]+)%)%s*{", function(retType, funcName, params)
				-- Remove parameter types
				local cleanParams = params:gsub("[%w_:<>]+%s+([%w_]+)", "%1")
				cleanParams = cleanParams:gsub("[%w_:<>]+%s*%*%s*([%w_]+)", "%1")
				cleanParams = cleanParams:gsub("[%w_:<>]+%s*&%s*([%w_]+)", "%1")
				return "function " .. funcName .. "(" .. cleanParams .. ")"
			end)

			-- Function with no parameters
			code = code:gsub("([%w_:<>]+)%s+([%w_]+)%s*%(%)%s*{", "function %2()")

			-- Void functions
			code = code:gsub("void%s+([%w_]+)%s*%(([^%)]*)%)%s*{", function(funcName, params)
				local cleanParams = params:gsub("[%w_:<>]+%s+([%w_]+)", "%1")
				return "function " .. funcName .. "(" .. cleanParams .. ")"
			end)

			-- Template functions (simplified)
			code = code:gsub("template%s*<.->%s*[%w_:]+%s+([%w_]+)%s*%((.-)%)%s*{", "function %1(%2)")

			return code
		end,
	},

	-- Variables and declarations
	{
		name = "variables",
		gsub = function(code)
			-- STL container declarations
			code = code:gsub("vector%s*<[^>]+>%s+([%w_]+)%s*;", "local %1 = {}")
			code = code:gsub("vector%s*<[^>]+>%s+([%w_]+)%s*=%s*{(.-)}", "local %1 = {%2}")
			code = code:gsub("map%s*<[^>]+>%s+([%w_]+)%s*;", "local %1 = {}")
			code = code:gsub("unordered_map%s*<[^>]+>%s+([%w_]+)%s*;", "local %1 = {}")

			-- Multiple variable declarations on one line
			code = code:gsub(
				"([%w_:<>]+)%s+([%w_]+)%s*=%s*(.-),%s*([%w_]+)%s*=%s*(.-)%s*;",
				"local %2 = %3\nlocal %4 = %5"
			)
			code = code:gsub("([%w_:<>]+)%s+([%w_]+)%s*,%s*([%w_]+)%s*;", "local %2\nlocal %3")

			-- Basic type declarations with initialization
			code = code:gsub(
				"(int|float|double|bool|char|long|short|size_t|uint32_t|int32_t|uint64_t|int64_t|string)%s+([%w_]+)%s*=%s*(.-)%s*;",
				"local %2 = %3"
			)

			-- Uninitialized variables
			code = code:gsub(
				"(int|float|double|bool|char|long|short|size_t|uint32_t|int32_t|uint64_t|int64_t|string)%s+([%w_]+)%s*;",
				"local %2"
			)

			-- Auto keyword
			code = code:gsub("auto%s+([%w_]+)%s*=%s*(.-)%s*;", "local %1 = %2")

			-- Const variables
			code = code:gsub("const%s+[%w_:<>]+%s+([%w_]+)%s*=%s*(.-)%s*;", "local %1 = %2")

			-- Pointers and references
			code = code:gsub("[%w_:<>]+%s*%*+%s*([%w_]+)%s*=%s*(.-)%s*;", "local %1 = %2")
			code = code:gsub("[%w_:<>]+%s*&+%s*([%w_]+)%s*=%s*(.-)%s*;", "local %1 = %2")
			code = code:gsub("[%w_:<>]+%s*%*+%s*([%w_]+)%s*;", "local %1")
			code = code:gsub("[%w_:<>]+%s*&+%s*([%w_]+)%s*;", "local %1")

			-- Arrays to tables
			code = code:gsub("[%w_:<>]+%s+([%w_]+)%s*%[.-%]%s*=%s*{(.-)};", "local %1 = {%2}")
			code = code:gsub("[%w_:<>]+%s+([%w_]+)%s*%[.-%]%s*;", "local %1 = {}")

			return code
		end,
	},

	-- Memory management
	{
		name = "memory",
		gsub = function(code)
			code = code:gsub("new%s+[%w_:<>]+%s*%((.-)%)", "{}")
			code = code:gsub("new%s+[%w_:<>]+%s*%[.-%]", "{}")
			code = code:gsub("delete%s+[%w_]+%s*;", "")
			code = code:gsub("delete%[%]%s+[%w_]+%s*;", "")
			code = code:gsub("nullptr", "nil")
			code = code:gsub("NULL", "nil")
			return code
		end,
	},

	-- Miscellaneous
	{
		name = "misc",
		gsub = function(code)
			-- This pointer
			code = code:gsub("this%->", "self.")
			code = code:gsub("this%.", "self.")

			-- Static cast
			code = code:gsub("static_cast%s*<[^>]+>%s*%((.-)%)", "%1")
			code = code:gsub("reinterpret_cast%s*<[^>]+>%s*%((.-)%)", "%1")
			code = code:gsub("dynamic_cast%s*<[^>]+>%s*%((.-)%)", "%1")

			-- Ternary operator (simplified)
			code = code:gsub("%((.-)%)%s*%?%s*(.-)%s*:%s*(.-)%s*;", "if %1 then %2 else %3 end")

			-- True/false
			code = code:gsub("%f[%w]true%f[%W]", "true")
			code = code:gsub("%f[%w]false%f[%W]", "false")

			return code
		end,
	},

	-- Braces to do/end and remove semicolons (LAST)
	{
		name = "bracesAndSemicolons",
		gsub = function(code)
			-- Convert opening braces to nothing (already handled by function/if/for/while)
			code = code:gsub("%s*{%s*", "\n")

			-- Convert closing braces to end
			code = code:gsub("%s*}%s*", "\nend\n")

			-- Remove remaining semicolons
			code = code:gsub(";", "")

			return code
		end,
	},
}
