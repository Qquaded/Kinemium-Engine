local raylib = require("@raylib")
local structs = raylib.structs
local const = raylib.const
local rect = require("@arect")
local color3 = require("@Color3")
local shaderLib = require("./shader")

return function(objects, data)
	local config = {
		obj_rect = data.rect
			or rect.new(data.x or data[1], data.y or data[2], data.width or data[3], data.height or data[4]),
		color = data.color or color3.new(1, 1, 1),
		bgtransparency = data.bgtransparency or 0,
		shaderName = data.shaderName or nil, -- name of already-loaded shader
		shaderCode = data.shaderCode or nil, -- inline glsl string (fragment)
		shaderPath = data.shaderPath or nil, -- path to .fs file
		uniforms = data.uniforms or {}, -- { name, value, type }
		clicked = data.clicked or nil,
		hoveredCallback = data.hoveredCallback or nil,
		disabled = data.disabled or false,
		modifiers = {},
	}

	if not config.shaderName then
		if config.shaderCode then
			config.shaderName = "shaderframe_inline_" .. tostring(config.shaderCode:len())
			shaderLib.LoadShaderCode(config.shaderName, nil, config.shaderCode)
		elseif config.shaderPath then
			config.shaderName = "shaderframe_file_" .. config.shaderPath
			shaderLib.LoadShader(config.shaderName, nil, config.shaderPath)
		else
			error("ShaderFrame requires one of: shaderName, shaderCode, or shaderPath")
		end
	end

	local wrapper = {}

	wrapper.modifiers = {
		outline = function(value, color, transparency)
			table.insert(config.modifiers, function()
				raylib.lib.DrawRectangleLinesEx(
					rect:translate(config.obj_rect),
					value,
					color:ToRaylib(transparency) or raylib.const.WHITE
				)
			end)
			return wrapper
		end,
		mouseIsIn = function(callback)
			if rect.MouseIsInRect(config.obj_rect) then
				callback(wrapper)
			end
		end,
		custom = function(callback)
			callback(wrapper)
		end,
	}

	wrapper.disabled = function(value)
		config.disabled = value
		return wrapper
	end
	wrapper.clicked = function(callback)
		config.clicked = callback
		return wrapper
	end
	wrapper.hovered = function(hoverCallback)
		config.hoveredCallback = hoverCallback
		return wrapper
	end
	wrapper.setTransparency = function(t)
		config.bgtransparency = t
		return wrapper
	end
	wrapper.width = function(v)
		config.obj_rect = rect.new(config.obj_rect.x, config.obj_rect.y, v, config.obj_rect.height)
		return wrapper
	end
	wrapper.height = function(v)
		config.obj_rect = rect.new(config.obj_rect.x, config.obj_rect.y, config.obj_rect.width, v)
		return wrapper
	end
	wrapper.posx = function(v)
		config.obj_rect = rect.new(v, config.obj_rect.y, config.obj_rect.width, config.obj_rect.height)
		return wrapper
	end
	wrapper.posy = function(v)
		config.obj_rect = rect.new(config.obj_rect.x, v, config.obj_rect.width, config.obj_rect.height)
		return wrapper
	end
	wrapper.set = function(prop, value)
		if type(config[prop]) == "function" then
			return wrapper
		end
		config[prop] = value
		return wrapper
	end

	wrapper.setUniform = function(name, value, uniformType)
		config.uniforms[name] = { value = value, uniformType = uniformType }
		return wrapper
	end

	wrapper.render = function(dt)
		if config.clicked ~= nil and not config.disabled then
			rect.Button(config.obj_rect, function()
				config.clicked(wrapper)
			end)
		end
		if config.hoveredCallback ~= nil then
			rect.Hover(config.obj_rect, function()
				config.hoveredCallback(wrapper)
			end)
		end

		for name, uniform in pairs(config.uniforms) do
			shaderLib.SetShaderUniform(config.shaderName, name, uniform.value, uniform.uniformType)
		end

		local shaderObj = shaderLib.activeShaders[config.shaderName]
		raylib.lib.BeginShaderMode(shaderObj)
		raylib.lib.DrawRectangleRec(rect:translate(config.obj_rect), config.color:ToRaylib(config.bgtransparency))
		raylib.lib.EndShaderMode()

		for _, modifier in pairs(config.modifiers) do
			modifier()
		end
	end

	table.insert(objects, wrapper)
	return wrapper
end
