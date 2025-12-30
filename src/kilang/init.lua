local kilang = {}

local Kinemium_env = require("./enviroment/get")
local sandboxer = require("./modules/sandboxer")
local preprocessor = require("./kilang/preprocessor")
local threads = {}

kilang.renderer = nil
kilang.threads = threads

function kilang:init()
	sandboxer.enviroment = Kinemium_env(kilang.renderer)
	kilang.env = sandboxer.enviroment
end

function kilang:execute(code, opts)
	code = preprocessor.runLang(code, opts.superset or "kilang")

	local SecurityCapabilities = opts.SecurityCapabilities
	local id = opts.StackId

	if not id then
		id = "stack" .. math.random(0, 9999)
	end

	sandboxer.enviroment.SecurityCapabilities = SecurityCapabilities
	threads[id] = sandboxer.thread.fromCode(id, code, sandboxer.enviroment)

	return id
end

return kilang
