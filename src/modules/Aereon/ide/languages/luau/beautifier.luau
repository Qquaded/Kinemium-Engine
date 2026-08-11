-- beautifier.luau
-- Built against Zune's AstSerializer output (zune/src/core/standard/luau.zig)

local Formatter = {}
local INDENT = "\t"

local function ind(level)
	return string.rep(INDENT, level)
end

local fmtExprNode, fmtBlock, fmtStmt, fmtType, fmtLocalName, fmtFunctionSig

--  HELPERS

local function tokText(t)
	if type(t) == "table" then
		return t.text or ""
	end
	return tostring(t or "")
end

-- punctuated entries are { node = X, separator? } OR bare nodes
local function unwrap(entry)
	if type(entry) == "table" then
		if entry.node ~= nil then
			return entry.node
		end
	end
	return entry
end

local function isFunc(node)
	return type(node) == "table" and node.tag == "function"
end

--  EXPRESSION NODE  (level = outer indentation, for anon functions)

function fmtExprNode(n, level)
	level = level or 0
	if type(n) ~= "table" then
		return tostring(n)
	end
	local tag = n.tag

	if tag == "number" then
		return n.text or tostring(n.value)
	end

	if tag == "boolean" then
		return n.text or tostring(n.value)
	end

	if tag == "nil" then
		return "nil"
	end
	if tag == "vararg" then
		return "..."
	end

	if tag == "string" then
		-- sourceString from Luau CST: may or may not include surrounding quotes.
		-- quoteStyle: "single" | "double" | "block" | "interp"
		local raw = n.text or ""
		local qs = n.quoteStyle or "double"
		if qs == "block" then
			return raw -- [[...]] already in raw
		end
		local q = (qs == "single") and "'" or '"'
		-- If raw already starts with a quote character it's the full literal.
		local first = raw:sub(1, 1)
		if first == '"' or first == "'" or first == "[" then
			return raw
		end
		return q .. raw .. q
	end

	if tag == "interpolatedstring" then
		local parts = {}
		local strs = n.strings or {}
		local exprs = n.expressions or {}
		for i, s in ipairs(strs) do
			table.insert(parts, tokText(s))
			if exprs[i] then
				table.insert(parts, "{" .. fmtExprNode(exprs[i], level) .. "}")
			end
		end
		return table.concat(parts)
	end

	if tag == "global" then
		return tokText(n.name)
	end

	if tag == "local" then
		-- ExprLocal: { token, local, upvalue }
		return tokText(n.token)
	end

	if tag == "indexname" then
		-- { expression, accessor (token "." or ":"), index (token) }
		return fmtExprNode(n.expression, level) .. tokText(n.accessor) .. tokText(n.index)
	end

	if tag == "index" then
		-- { expression, index }
		return fmtExprNode(n.expression, level) .. "[" .. fmtExprNode(n.index, level) .. "]"
	end

	if tag == "call" then
		-- { func, arguments (punctuated), self, ... }
		local fn_str = fmtExprNode(n.func, level)
		local args = n.arguments or {}

		-- Single anonymous-function argument → multi-line
		if #args == 1 and isFunc(unwrap(args[1])) then
			local fnode = unwrap(args[1])
			local body = fnode.body or fnode
			local sig = fmtFunctionSig("", body)
			local inner = {}
			fmtBlock(body.body, level + 1, inner)
			local lines = { fn_str .. "(" .. sig }
			for _, l in ipairs(inner) do
				table.insert(lines, l)
			end
			table.insert(lines, ind(level) .. "end)")
			return table.concat(lines, "\n")
		end

		local argStrs = {}
		for _, a in ipairs(args) do
			table.insert(argStrs, fmtExprNode(unwrap(a), level))
		end
		-- Multi-line if inline form would be long (> 80 chars) or has 3+ args
		local inline = fn_str .. "(" .. table.concat(argStrs, ", ") .. ")"
		if #argStrs >= 3 or #inline > 80 then
			local lines = { fn_str .. "(" }
			for i, s in ipairs(argStrs) do
				local comma = i < #argStrs and "," or ""
				table.insert(lines, ind(level + 1) .. s .. comma)
			end
			table.insert(lines, ind(level) .. ")")
			return table.concat(lines, "\n")
		end
		return inline
	end

	if tag == "binary" then
		-- { lhsoperand, operator (token), rhsoperand }
		return fmtExprNode(n.lhsoperand, level) .. " " .. tokText(n.operator) .. " " .. fmtExprNode(n.rhsoperand, level)
	end

	if tag == "unary" then
		-- { operator (token), operand }
		local op = tokText(n.operator)
		local sep = op:match("^%a") and " " or ""
		return op .. sep .. fmtExprNode(n.operand, level)
	end

	if tag == "cast" then
		return fmtExprNode(n.operand, level) .. " :: " .. fmtType(n.annotation)
	end

	if tag == "table" then
		-- entries: array of { kind="list"|"record"|"general", key?, value }
		local fields = {}
		for _, item in ipairs(n.entries or {}) do
			local kind = item.kind
			if kind == "list" then
				table.insert(fields, fmtExprNode(unwrap(item.value), level))
			elseif kind == "record" then
				table.insert(fields, tokText(item.key) .. " = " .. fmtExprNode(unwrap(item.value), level))
			elseif kind == "general" then
				table.insert(
					fields,
					"[" .. fmtExprNode(unwrap(item.key), level) .. "] = " .. fmtExprNode(unwrap(item.value), level)
				)
			end
		end
		if #fields == 0 then
			return "{}"
		end
		local inline = "{ " .. table.concat(fields, ", ") .. " }"
		-- Multi-line if long or has 3+ entries
		if #fields >= 3 or #inline > 80 then
			local lines = { "{" }
			for i, f in ipairs(fields) do
				local comma = i < #fields and "," or ","
				table.insert(lines, ind(level + 1) .. f .. comma)
			end
			table.insert(lines, ind(level) .. "}")
			return table.concat(lines, "\n")
		end
		return inline
	end

	if tag == "function" then
		-- ExprFunction: { body: function-body-table }
		-- body: { self?, parameters (punctuated locals), vararg?, body (StatBlock), ... }
		local body = n.body or n
		local sig = fmtFunctionSig("", body)
		local inner = {}
		fmtBlock(body.body, level + 1, inner)
		local lines = { sig }
		for _, l in ipairs(inner) do
			table.insert(lines, l)
		end
		table.insert(lines, ind(level) .. "end")
		return table.concat(lines, "\n")
	end

	if tag == "group" then
		return "(" .. fmtExprNode(n.expression, level) .. ")"
	end

	if tag == "conditional" then
		-- inline if-else expression
		local s = "if " .. fmtExprNode(n.condition, level) .. " then " .. fmtExprNode(n.consequent, level)
		for _, ei in ipairs(n.elseifs or {}) do
			s = s .. " elseif " .. fmtExprNode(ei.condition, level) .. " then " .. fmtExprNode(ei.consequent, level)
		end
		if n.antecedent then
			s = s .. " else " .. fmtExprNode(n.antecedent, level)
		end
		return s
	end

	if n.text then
		return n.text
	end
	return "<expr:" .. tostring(tag) .. ">"
end

--  FUNCTION SIGNATURE

function fmtFunctionSig(nameStr, body)
	-- body: { self?, parameters (punctuated locals), vararg? }
	local params = {}
	if body.self then
		table.insert(params, "self")
	end
	for _, entry in ipairs(body.parameters or {}) do
		local localNode = entry.node or entry
		table.insert(params, fmtLocalName(localNode, true))
	end
	if body.vararg then
		table.insert(params, "...")
	end
	return "function" .. nameStr .. "(" .. table.concat(params, ", ") .. ")"
end

--  LOCAL NAME

function fmtLocalName(localNode, withAnnotation)
	if type(localNode) ~= "table" then
		return "?"
	end
	local n = localNode.node or localNode
	if type(n) ~= "table" then
		return "?"
	end
	local name = tokText(n.name)
	if withAnnotation and n.annotation then
		name = name .. ": " .. fmtType(n.annotation)
	end
	return name
end

--  TYPES

function fmtType(t)
	if type(t) ~= "table" then
		return "any"
	end
	local tag = t.tag
	if tag == "reference" then
		return tokText(t.name)
	end
	if tag == "nil" then
		return "nil"
	end
	if tag == "string" then
		return t.text or '""'
	end
	if tag == "boolean" then
		return t.text or "boolean"
	end
	if tag == "optional" then
		return "?"
	end
	if tag == "typeof" then
		return "typeof(" .. fmtExprNode(t.expression) .. ")"
	end
	if tag == "union" then
		local parts = {}
		for _, e in ipairs(t.types or {}) do
			table.insert(parts, fmtType(e.node or e))
		end
		return table.concat(parts, " | ")
	end
	if tag == "intersection" then
		local parts = {}
		for _, e in ipairs(t.types or {}) do
			table.insert(parts, fmtType(e.node or e))
		end
		return table.concat(parts, " & ")
	end
	return "any"
end

--  BLOCK

-- Tags that are "block-level" — they get a blank line before and after them
-- when adjacent to anything that isn't the same simple-assignment run.
local BLOCK_TAGS = {
	["conditional"] = true,
	["while"] = true,
	["repeat"] = true,
	["for"] = true,
	["forin"] = true,
	["do"] = true,
	["function"] = true,
	["localfunction"] = true,
	["return"] = true,
}

local function isBlockTag(stmt)
	return stmt and BLOCK_TAGS[stmt.tag] == true
end

-- A "simple" statement is a local/assign/expression that isn't a block.
-- We group runs of simples together; blocks always get blank lines around them.
-- Additionally, within a run of simples we insert a blank line when the
-- "category" changes (e.g. going from locals to calls, or a natural gap in
-- the original source lines).
local function stmtLineStart(stmt)
	local loc = stmt and stmt.location
	if loc then
		return loc.begin.line
	end
	return nil
end

function fmtBlock(node, level, out)
	out = out or {}
	if type(node) ~= "table" then
		return out
	end
	local stmts = node.statements or {}
	local n = #stmts
	if n == 0 then
		return out
	end

	for i = 1, n do
		local stmt = stmts[i]
		local prev = stmts[i - 1]

		if i > 1 then
			local needBlank = false

			-- always blank before/after block-level statements
			if isBlockTag(stmt) or isBlockTag(prev) then
				needBlank = true
			else
				-- blank when category changes within simple statements:
				-- local → call, call → local, etc.
				local prevTag = prev and prev.tag
				local curTag = stmt.tag
				local prevSimple = prevTag == "local" or prevTag == "assign" or prevTag == "compoundassign"
				local curSimple = curTag == "local" or curTag == "assign" or curTag == "compoundassign"
				local prevCall = prevTag == "expression"
				local curCall = curTag == "expression"

				if prevSimple and curCall then
					needBlank = true
				elseif prevCall and curSimple then
					needBlank = true
				else
					-- blank when original source had a gap of more than 1 line
					local prevLine = stmtLineStart(prev)
					local curLine = stmtLineStart(stmt)
					if prevLine and curLine and curLine - prevLine > 1 then
						needBlank = true
					end
				end
			end

			if needBlank then
				table.insert(out, "")
			end
		end

		fmtStmt(stmt, level, out)
	end

	return out
end

--  STATEMENTS

function fmtStmt(node, level, out)
	level = level or 0
	out = out or {}
	if type(node) ~= "table" then
		return out
	end
	local tag = node.tag

	--  local variable
	if tag == "local" then
		-- { localKeyword, variables (punctuated locals), equals?, values (punctuated exprs) }
		local vars = {}
		for _, entry in ipairs(node.variables or {}) do
			local ln = entry.node or entry
			local name = fmtLocalName(ln)
			if type(ln) == "table" and ln.annotation then
				name = name .. ": " .. fmtType(ln.annotation)
			end
			table.insert(vars, name)
		end
		local vals = {}
		for _, entry in ipairs(node.values or {}) do
			local vn = unwrap(entry)
			-- anonymous function value: emit multi-line
			if isFunc(vn) then
				local body = vn.body or vn
				local sig = fmtFunctionSig("", body)
				table.insert(vals, sig)
				-- flush everything so far as the local decl line
				local rhs = " = " .. table.concat(vals, ", ")
				table.insert(out, ind(level) .. "local " .. table.concat(vars, ", ") .. rhs)
				fmtBlock(body.body, level + 1, out)
				table.insert(out, ind(level) .. "end")
				return out
			end
			table.insert(vals, fmtExprNode(vn, level))
		end
		local rhs = #vals > 0 and (" = " .. table.concat(vals, ", ")) or ""
		table.insert(out, ind(level) .. "local " .. table.concat(vars, ", ") .. rhs)
		return out
	end

	--  assignment
	if tag == "assign" then
		-- { variables (punctuated), equals, values (punctuated) }
		local lhs, rhs = {}, {}
		for _, entry in ipairs(node.variables or {}) do
			table.insert(lhs, fmtExprNode(unwrap(entry), level))
		end
		for _, entry in ipairs(node.values or {}) do
			table.insert(rhs, fmtExprNode(unwrap(entry), level))
		end
		table.insert(out, ind(level) .. table.concat(lhs, ", ") .. " = " .. table.concat(rhs, ", "))
		return out
	end

	--  compound assignment
	if tag == "compoundassign" then
		-- { variable, operand (token e.g. "+="), value }
		table.insert(
			out,
			ind(level)
				.. fmtExprNode(node.variable, level)
				.. " "
				.. tokText(node.operand)
				.. " "
				.. fmtExprNode(node.value, level)
		)
		return out
	end

	--  expression statement
	if tag == "expression" then
		-- { expression }  — the expression is a bare node (NOT punctuated)
		local expr = node.expression
		-- If it's a call with a single anonymous-function arg, format multi-line
		if type(expr) == "table" and expr.tag == "call" then
			local args = expr.arguments or {}
			if #args == 1 and isFunc(unwrap(args[1])) then
				local fn_str = fmtExprNode(expr.func, level)
				local fnode = unwrap(args[1])
				local body = fnode.body or fnode
				local sig = fmtFunctionSig("", body)
				table.insert(out, ind(level) .. fn_str .. "(" .. sig)
				fmtBlock(body.body, level + 1, out)
				table.insert(out, ind(level) .. "end)")
				return out
			end
		end
		table.insert(out, ind(level) .. fmtExprNode(expr, level))
		return out
	end

	--  local function
	if tag == "localfunction" then
		-- { localKeyword, functionKeyword, name (local-table), body (function-body) }
		local name = tokText((node.name or {}).name or node.name)
		local body = node.body or {}
		table.insert(out, ind(level) .. "local " .. fmtFunctionSig(" " .. name, body))
		fmtBlock(body.body, level + 1, out)
		table.insert(out, ind(level) .. "end")
		return out
	end

	--  function declaration
	if tag == "function" then
		-- { functionKeyword, name (expr node — indexname or global), body (function-body) }
		local nameStr = " " .. fmtExprNode(node.name, level)
		local body = node.body or {}
		table.insert(out, ind(level) .. fmtFunctionSig(nameStr, body))
		fmtBlock(body.body, level + 1, out)
		table.insert(out, ind(level) .. "end")
		return out
	end

	--  if / conditional
	if tag == "conditional" then
		-- { ifKeyword, condition, thenKeyword, consequent (StatBlock),
		--   elseifs[{ elseifKeyword, condition, thenKeyword, consequent }],
		--   elseKeyword?, antecedent (StatBlock)?, endKeyword }
		table.insert(out, ind(level) .. "if " .. fmtExprNode(node.condition, level) .. " then")
		fmtBlock(node.consequent, level + 1, out)
		for _, ei in ipairs(node.elseifs or {}) do
			table.insert(out, ind(level) .. "elseif " .. fmtExprNode(ei.condition, level) .. " then")
			fmtBlock(ei.consequent, level + 1, out)
		end
		if node.antecedent then
			table.insert(out, ind(level) .. "else")
			fmtBlock(node.antecedent, level + 1, out)
		end
		table.insert(out, ind(level) .. "end")
		return out
	end

	--  while
	if tag == "while" then
		-- { whileKeyword, condition, doKeyword?, body (StatBlock), endKeyword }
		table.insert(out, ind(level) .. "while " .. fmtExprNode(node.condition, level) .. " do")
		fmtBlock(node.body, level + 1, out)
		table.insert(out, ind(level) .. "end")
		return out
	end

	--  repeat / until
	if tag == "repeat" then
		-- { repeatKeyword, body (StatBlock), untilKeyword, condition }
		table.insert(out, ind(level) .. "repeat")
		fmtBlock(node.body, level + 1, out)
		table.insert(out, ind(level) .. "until " .. fmtExprNode(node.condition, level))
		return out
	end

	--  numeric for
	if tag == "for" then
		-- { forKeyword, variable (local-table), equals, from, toComma, to, stepComma?, step?, doKeyword?, body, endKeyword }
		local var = fmtLocalName(node.variable)
		local from = fmtExprNode(node.from, level)
		local to = fmtExprNode(node.to, level)
		local step = node.step and (", " .. fmtExprNode(node.step, level)) or ""
		table.insert(out, ind(level) .. "for " .. var .. " = " .. from .. ", " .. to .. step .. " do")
		fmtBlock(node.body, level + 1, out)
		table.insert(out, ind(level) .. "end")
		return out
	end

	--  generic for
	if tag == "forin" then
		-- { forKeyword, variables (punctuated locals), inKeyword?, values (punctuated exprs), doKeyword?, body, endKeyword }
		local vars = {}
		for _, entry in ipairs(node.variables or {}) do
			table.insert(vars, fmtLocalName(entry.node or entry))
		end
		local iters = {}
		for _, entry in ipairs(node.values or {}) do
			table.insert(iters, fmtExprNode(unwrap(entry), level))
		end
		table.insert(
			out,
			ind(level) .. "for " .. table.concat(vars, ", ") .. " in " .. table.concat(iters, ", ") .. " do"
		)
		fmtBlock(node.body, level + 1, out)
		table.insert(out, ind(level) .. "end")
		return out
	end

	--  do block
	if tag == "do" then
		table.insert(out, ind(level) .. "do")
		fmtBlock(node.body, level + 1, out)
		table.insert(out, ind(level) .. "end")
		return out
	end

	--  return
	if tag == "return" then
		-- { returnKeyword, expressions (punctuated) }
		local vals = {}
		for _, entry in ipairs(node.expressions or {}) do
			table.insert(vals, fmtExprNode(unwrap(entry), level))
		end
		if #vals > 0 then
			table.insert(out, ind(level) .. "return " .. table.concat(vals, ", "))
		else
			table.insert(out, ind(level) .. "return")
		end
		return out
	end

	--  break / continue
	if tag == "break" then
		table.insert(out, ind(level) .. "break")
		return out
	end
	if tag == "continue" then
		table.insert(out, ind(level) .. "continue")
		return out
	end

	--  type alias
	if tag == "typealias" then
		-- { export?, typeToken, name (token), equals, type }
		local exported = node["export"] and "export " or ""
		table.insert(out, ind(level) .. exported .. "type " .. tokText(node.name) .. " = " .. fmtType(node.type))
		return out
	end

	if tag == "typefunction" then
		local exported = node["export"] and "export " or ""
		table.insert(out, ind(level) .. exported .. "type function " .. tokText(node.name) .. "() end")
		return out
	end

	return out
end

--  ENTRY POINT

function Formatter.format(result)
	local out = {}
	fmtBlock(result.root, 0, out)
	return table.concat(out, "\n")
end

return Formatter
