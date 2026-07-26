--!optimize 2
--!native
local blurmod = {}
local adapter = require("@RaylibAdapter")
local zembed = require("@zembed")
local lib, structs, const = adapter.lib, adapter.structs, adapter.const

local function extract_texture(v)
	if type(v) == "table" and v.id then
		return v
	end
	local texture = zune.mem.slice(v, structs.RenderTexture:offset("texture"), structs.Texture:size())
	return texture
end

local function f32(value)
	local buf = buffer.create(4)
	buffer.writef32(buf, 0, value)
	return buf
end

function blurmod.Init(width, height)
	local wrapper = {}
	width = width or lib.GetRenderWidth()
	height = height or lib.GetRenderHeight()

	local blurShader = lib.LoadShader(nil, zembed.AssetPath("kineasset://shaders/blur3d.frag"))
	local resolutionLoc = lib.GetShaderLocation(blurShader, "resolution")
	local directionLoc = lib.GetShaderLocation(blurShader, "direction")
	local radiusLoc = lib.GetShaderLocation(blurShader, "blurRadius")

	local WorkspaceCapture
	local blurH
	local blurV

	local function rebuildTargets(targetWidth, targetHeight)
		width = math.max(1, math.floor(targetWidth))
		height = math.max(1, math.floor(targetHeight))

		WorkspaceCapture = lib.LoadRenderTexture(width, height)
		blurH = lib.LoadRenderTexture(width, height)
		blurV = lib.LoadRenderTexture(width, height)

		wrapper.WorkspaceCapture = WorkspaceCapture
		wrapper.blurV = blurV
	end

	rebuildTargets(width, height)

	wrapper.enabled = true
	wrapper.WorkspaceCapture = WorkspaceCapture
	wrapper.blurRadius = 15.0
	wrapper.blurV = blurV

	function wrapper:SetBlurRadius(radius)
		self.blurRadius = radius
	end

	function wrapper:Resize(targetWidth, targetHeight)
		targetWidth = targetWidth or width
		targetHeight = targetHeight or height

		if targetWidth == width and targetHeight == height then
			return
		end

		lib.UnloadRenderTexture(WorkspaceCapture)
		lib.UnloadRenderTexture(blurH)
		lib.UnloadRenderTexture(blurV)

		rebuildTargets(targetWidth, targetHeight)
	end

	function wrapper:BeginCapture()
		lib.BeginTextureMode(WorkspaceCapture)
		lib.ClearBackground(const.BLANK)
	end

	function wrapper:EndCapture()
		lib.EndTextureMode()
	end

	function wrapper:ApplyBlur()
		if not self.enabled then
			return
		end

		lib.BeginTextureMode(blurH)
		lib.ClearBackground(const.BLANK)
		lib.BeginShaderMode(blurShader)

		lib.SetShaderValue(
			blurShader,
			resolutionLoc,
			vector.create(width, height),
			const.ShaderUniformDataType.SHADER_UNIFORM_VEC2
		)
		lib.SetShaderValue(
			blurShader,
			directionLoc,
			vector.create(1.0, 0.0),
			const.ShaderUniformDataType.SHADER_UNIFORM_VEC2
		)
		lib.SetShaderValue(
			blurShader,
			radiusLoc,
			f32(self.blurRadius),
			const.ShaderUniformDataType.SHADER_UNIFORM_FLOAT
		)

		lib.DrawTextureRec(
			extract_texture(WorkspaceCapture),
			structs.Rectangle:new({ x = 0, y = 0, width = width, height = -height }),
			vector.create(0, 0),
			const.WHITE
		)
		lib.EndShaderMode()
		lib.EndTextureMode()

		lib.BeginTextureMode(blurV)
		lib.ClearBackground(const.BLANK)
		lib.BeginShaderMode(blurShader)

		lib.SetShaderValue(
			blurShader,
			directionLoc,
			vector.create(0.0, 1.0),
			const.ShaderUniformDataType.SHADER_UNIFORM_VEC2
		)
		lib.SetShaderValue(
			blurShader,
			radiusLoc,
			f32(self.blurRadius),
			const.ShaderUniformDataType.SHADER_UNIFORM_FLOAT
		)

		lib.DrawTextureRec(
			extract_texture(blurH),
			structs.Rectangle:new({ x = 0, y = 0, width = width, height = -height }),
			vector.create(0, 0),
			const.WHITE
		)
		lib.EndShaderMode()
		lib.EndTextureMode()
	end

	function wrapper:DrawFullBlur(tint)
		if not self.enabled then
			return
		end
		tint = tint or const.WHITE
		lib.DrawTextureRec(
			extract_texture(blurV),
			structs.Rectangle:new({ x = 0, y = 0, width = width, height = -height }),
			vector.create(0, 0),
			tint
		)
	end

	function wrapper:DrawMixed(regions, tint)
		if not self.enabled then
			return
		end
		tint = tint or const.WHITE

		lib.DrawTextureRec(
			extract_texture(WorkspaceCapture),
			structs.Rectangle:new({ x = 0, y = 0, width = width, height = -height }),
			vector.create(0, 0),
			tint
		)

		for _, region in ipairs(regions) do
			local x, y, w, h = region.x, region.y, region.width, region.height
			local regionTint = region.tint or tint

			wrapper:DrawBlurredRegion(x, y, w, h, regionTint)
		end
	end

	function wrapper:DrawBlurredRegion(x, y, w, h, tint)
		if not self.enabled then
			return
		end
		tint = tint or const.WHITE

		lib.DrawTextureRec(
			extract_texture(blurV),
			structs.Rectangle:new({
				x = x,
				y = height - y - h,
				width = w,
				height = -h,
			}),
			vector.create(x, y),
			tint
		)
	end

	function wrapper:DrawUnblurred(tint)
		if not self.enabled then
			return
		end
		tint = tint or const.WHITE

		-- Draw from the captured Workspace texture, not a new render
		lib.DrawTextureRec(
			extract_texture(WorkspaceCapture),
			structs.Rectangle:new({ x = 0, y = 0, width = width, height = -height }),
			vector.create(0, 0),
			tint
		)
	end

	function wrapper:Enable()
		self.enabled = true
	end

	function wrapper:Disable()
		self.enabled = false
	end

	function wrapper:Cleanup()
		lib.UnloadRenderTexture(WorkspaceCapture)
		lib.UnloadRenderTexture(blurH)
		lib.UnloadRenderTexture(blurV)
		lib.UnloadShader(blurShader)
	end

	return wrapper
end

blurmod._extract_texture = extract_texture

return blurmod
