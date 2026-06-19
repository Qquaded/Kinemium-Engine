-- description: "Stores a file from disk."
local propTable = {
	Name = "File",
	Size = 0,
	FilePath = "",

	_file = nil,
}

return {
	class = "File",
	callback = function(instance)
		instance:SetProperties(propTable)

		instance.Changed:Connect(function(prop)
			if prop == "FilePath" then
				local success, buf = pcall(function()
					return zune.fs.readFile(instance.FilePath, true)
				end)

				if success and buf then
					instance._file = buf
					instance.Size = buffer.len(buf)
				end
			end
		end)

		function instance:GetBinaryContents(returnBuffer)
			if type(returnBuffer) ~= "boolean" then
				return
			end
			if returnBuffer then
				return instance._file
			else
				return buffer.tostring(instance._file)
			end
		end

		function instance:Write(data)
			if typeof(data) == "string" then
				data = buffer.fromstring(data)
			end

			local oldBuffer = instance._file or buffer.create(0)
			local oldSize = buffer.len(oldBuffer)
			local newSize = oldSize + buffer.len(data)

			local newBuffer = buffer.create(newSize)

			buffer.copy(newBuffer, 0, oldBuffer)
			buffer.copy(newBuffer, oldSize, data)

			instance._file = newBuffer
			instance.Size = newSize

			if instance.FilePath ~= "" then
				zune.fs.writeFile(instance.FilePath, newBuffer)
			end
		end

		function instance:GetTemporaryId()
			-- compat
			return instance.FilePath
		end

		return instance
	end,

	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
