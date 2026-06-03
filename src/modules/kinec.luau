-- Kinemium API Frontend for C
local ffi = zune.ffi
local kinec = {}

local closures = {}

function kinec.func(name, returns, arguments, handler)
	local closure = ffi.closure({
		returns = returns,
		args = arguments,
	}, handler)
	closures[name] = closure
	return closure
end

function kinec.getclosures()
	return closures
end

function kinec.runC(code)
	local options = {
		symbols = {},
	}

	for name, closure in pairs(closures) do
		options.symbols[name] = closure
	end

	local compiled = ffi.c.compile(code, options)
	return compiled
end

return kinec
