local thread = zune.thread
local preprocessor = require("./Transpiler")
local luau = zune.luau

while true do
	local req = thread.receive()
	if not req then
		continue
	end

	if req.action == "compile" then
		local ok, transpiledCode = pcall(preprocessor.runLang, req.code, req.superset)
		if not ok then
			thread.send({ id = req.id, error = transpiledCode })
			continue
		end

		local bytecode, compile_err = luau.compile(req.code, { optimization_level = 2 })
		if not bytecode then
			thread.send({ id = req.id, error = compile_err })
			continue
		end

		thread.send({ id = req.id, result = bytecode })
	end
end
