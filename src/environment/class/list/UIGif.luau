-- description: "An object that displays animated GIF images within a user interface."
local GuiObject = require("@GuiObject")
local gif = require("@gif")
local Color3 = require("@Color3")

local propTable = {
	Name = "Gif",
	AbsoluteSize = nil,
	AbsolutePosition = nil,
	ImageColor3 = Color3.new(1, 1, 1),
	ImageTransparency = 0,
	Duration = 0,
	Timestamp = 0,
	Looped = true,
	Speed = 1,
	GifPath = "",
}

GuiObject.inherit(propTable)

propTable.render = function(lib, object, dt, structs, renderer)
	if not object.Visible then
		return
	end
	if not object._gifbuffer then
		return
	end
	local pos, size = GuiObject.render(lib, object, dt, structs, renderer)

	GuiObject.renderChildren(lib, object, dt, structs, renderer)

	object.Duration = gif.GetDuration(object._gifbuffer)
	object.Timestamp = gif.GetTimestamp(object._gifbuffer)

	gif.SetLooping(object._gifbuffer, object.Looped)
	gif.SetLooping(object._gifbuffer, object.Speed)

	if object._gifbuffer then
		gif.Update(object._gifbuffer, dt)
		gif.Draw(object._gifbuffer, pos.X, pos.Y, size.X, size.Y, object.ImageColor3:ToRaylib(object.ImageTransparency))
	end

	return pos, size
end

local mainTask

return {
	class = "UIGif",
	render = propTable.render,

	callback = function(instance, renderer)
		instance:SetProperties(propTable)

		-- description: "Pauses the GIF."
		-- args: "self: UIGif"
		-- returns: "any"
		function instance:Pause()
			if not instance._gifbuffer then
				return
			end
			gif.Pause(instance._gifbuffer)
		end

		-- description: "Resumes playing the GIF."
		-- args: "self: UIGif"
		-- returns: "any"
		function instance:Resume()
			if not instance._gifbuffer then
				return
			end
			gif.Resume(instance._gifbuffer)
		end

		-- description: "Changes playback speed of the GIF."
		-- args: "self: UIGif, speed: Number"
		-- returns: "any"
		function instance:SetSpeed(speed: number)
			if not instance._gifbuffer then
				return
			end
			instance.Speed = speed
		end

		instance.Changed:Connect(function()
			if instance.GifPath ~= "" then
				if mainTask then
					return
				end
				if instance._gifbuffer then
					print("got already existing gif..")
					gif.Unload(instance._gifbuffer)
				end
				mainTask = task.spawn(function()
					instance._gifbuffer = gif.Load(instance.GifPath)
				end)
			end
		end)

		return instance
	end,

	inherit = function(tble)
		GuiObject.inherit(tble)
	end,
}
