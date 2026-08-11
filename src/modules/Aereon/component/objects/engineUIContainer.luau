return function(objects, data, raylib)
	local structs = raylib.structs
	local rect = require("@arect")
	local UDim2 = require("@UDim2")
	local Vector2 = require("@Vector2")
	local config = {
		obj_rect = data.rect or rect.new(
			data.x or data[1] or 0,
			data.y or data[2] or 0,
			data.width or data[3] or 100,
			data.height or data[4] or 100
		),
		instance = data.instance or data.target or nil,
		datamodel = data.datamodel or data.game or nil,
		renderer = data.renderer or nil,
	}

	local wrapper = {}

	wrapper.setInstance = function(instance)
		config.instance = instance
		return wrapper
	end

	wrapper.getInstance = function()
		return config.instance
	end

	wrapper.set = function(prop, value)
		if prop == "instance" or prop == "target" then
			config.instance = value
		elseif prop == "datamodel" or prop == "game" then
			config.datamodel = value
		elseif prop == "renderer" then
			config.renderer = value
		elseif prop == "obj_rect" then
			config.obj_rect = value
		else
			config[prop] = value
		end
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

	wrapper.render = function(dt)
		if config.instance and config.instance.render then
			if config.instance.ClassName == "ScreenGui" then
				config.instance.OverrideScreenSize = true

				local guiW = config.instance.Size and config.instance.Size.X and config.instance.Size.X.Offset or config.obj_rect.width
				local guiH = config.instance.Size and config.instance.Size.Y and config.instance.Size.Y.Offset or config.obj_rect.height

				config.instance.Size = UDim2.new(0, config.obj_rect.width, 0, config.obj_rect.height)

				local offsetX = config.obj_rect.x + (config.obj_rect.width - guiW) / 2
				local offsetY = config.obj_rect.y + (config.obj_rect.height - guiH) / 2
				config.instance.RenderOffset = Vector2.new(offsetX, offsetY)
			else
				config.instance._EditorOverride = true
				config.instance.AbsolutePosition = vector.create(
					config.obj_rect.x + (config.obj_rect.width - (config.instance.AbsoluteSize and config.instance.AbsoluteSize.X or config.obj_rect.width)) / 2,
					config.obj_rect.y + (config.obj_rect.height - (config.instance.AbsoluteSize and config.instance.AbsoluteSize.Y or config.obj_rect.height)) / 2,
					0
				)
				config.instance.AbsoluteSize = vector.create(config.obj_rect.width, config.obj_rect.height, 0)
			end

			config.instance.render(
				config.renderer.Lib2d,
				config.instance,
				dt,
				structs,
				config.renderer,
				config.datamodel
			)
		end
	end

	table.insert(objects, wrapper)
	return wrapper
end
