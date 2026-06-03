-- description: "A rendering effect that applies a full-screen shader to the camera output."
local ffi = zune.ffi

local propTable = {
	Shader = nil,
	Enabled = true,
	Name = "SSEffect",
	BaseClass = "LightingPreprocess",
}

return {
	class = "SSEffect",

	callback = function(instance)
		local r3d = require("@r3d")
		local rlib: any = r3d.lib

		instance:SetProperties(propTable)

		-- description: "Sets a shader uniform value."
		-- args: "name: string, value: number, isFloat: boolean"
		function instance:SetUniform(name, value, isFloat)
			if instance._r3dshader then
				local valBuffer
				if type(value) == "number" then
					valBuffer = buffer.create(4)
					if isFloat then
						buffer.writef32(valBuffer, 0, value)
					else
						buffer.writei32(valBuffer, 0, value)
					end
				elseif type(value) == "table" then
					if value.__type then
						if value.__type == "Vector3" then
							valBuffer = buffer.create(12)
							buffer.writef32(valBuffer, 0, value.X)
							buffer.writef32(valBuffer, 4, value.Y)
							buffer.writef32(valBuffer, 8, value.Z)
						elseif value.__type == "CFrame" then
							valBuffer = buffer.create(12)
							buffer.writef32(valBuffer, 0, value.Position.X)
							buffer.writef32(valBuffer, 4, value.Position.Y)
							buffer.writef32(valBuffer, 8, value.Position.Z)
						elseif value.__type == "Color3" then
							valBuffer = buffer.create(12)
							buffer.writef32(valBuffer, 0, value.R)
							buffer.writef32(valBuffer, 4, value.G)
							buffer.writef32(valBuffer, 8, value.B)
						elseif value.__type == "Color4" then
							valBuffer = buffer.create(16)
							buffer.writef32(valBuffer, 0, value.R)
							buffer.writef32(valBuffer, 4, value.G)
							buffer.writef32(valBuffer, 8, value.B)
							buffer.writef32(valBuffer, 12, value.A)
						elseif value.__type == "Vector2" then
							valBuffer = buffer.create(8)
							buffer.writef32(valBuffer, 0, value.X)
							buffer.writef32(valBuffer, 4, value.Y)
						elseif value.__type == "UDim2" then
							valBuffer = buffer.create(16)
							buffer.writef32(valBuffer, 0, value.X.Scale)
							buffer.writef32(valBuffer, 4, value.X.Offset)
							buffer.writef32(valBuffer, 8, value.Y.Scale)
							buffer.writef32(valBuffer, 12, value.Y.Offset)
						elseif value.__type == "UDim" then
							valBuffer = buffer.create(8)
							buffer.writef32(valBuffer, 0, value.Scale)
							buffer.writef32(valBuffer, 4, value.Offset)
						end
					else
						local valueCount = #value
						if valueCount == 4 then
							valBuffer = buffer.create(16)
							buffer.writef32(valBuffer, 0, value[1])
							buffer.writef32(valBuffer, 4, value[2])
							buffer.writef32(valBuffer, 8, value[3])
							buffer.writef32(valBuffer, 12, value[4])
						elseif valueCount == 3 then
							valBuffer = buffer.create(12)
							buffer.writef32(valBuffer, 0, value[1])
							buffer.writef32(valBuffer, 4, value[2])
							buffer.writef32(valBuffer, 8, value[3])
						elseif valueCount == 2 then
							valBuffer = buffer.create(8)
							buffer.writef32(valBuffer, 0, value[1])
							buffer.writef32(valBuffer, 4, value[2])
						end
					end
				elseif type(value) == "vector" then
					valBuffer = buffer.create(12)
					buffer.writef32(valBuffer, 0, value.x)
					buffer.writef32(valBuffer, 4, value.y)
					buffer.writef32(valBuffer, 8, value.z)
				elseif type(value) == "boolean" then
					valBuffer = buffer.create(4)
					buffer.writei32(valBuffer, 0, value and 1 or 0)
				end

				if valBuffer then
					rlib.R3D_SetScreenShaderUniform(instance._r3dshader, name, valBuffer)
				end
			end
		end

		-- description: "Sets the Texture."
		-- args: "name: string, textureObj: any"
		function instance:SetTexture(name, textureObj)
			if instance._r3dshader then
				rlib.R3D_SetScreenShaderSampler(instance._r3dshader, name, textureObj)
			end
		end

		-- description: "Adds to pipeline."
		function instance:AddToPipeline()
			if not instance._r3dshader then
				return
			end

			local buf = buffer.create(8)
			local ptrArray = ffi.dupe(buf)
			ptrArray:writeptr(0, instance._r3dshader)

			rlib.R3D_SetScreenShaderChain(ptrArray, 1)
		end

		instance.Changed:Connect(function(property, value)
			if property == "_r3dshader" then
				return
			end
			if property == "Shader" then
				if type(value) == "table" and value.__type then
					if value._vertex and value._fragment then
						instance._r3dshader = rlib.R3D_LoadScreenShaderFromMemory(value._fragment)
					end
				end
			end
		end)

		return instance
	end,

	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
