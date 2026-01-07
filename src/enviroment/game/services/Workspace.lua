local Instance = require("@Instance")
local Vector3 = require("@Vector3")
local Workspace = Instance.new("Workspace")
local Color3 = require("@Color3")
local pool = {}

local raylib = require("@raylib")
local lib = raylib.lib
local r3d = raylib.r3d
local structs = raylib.structs

local function Color3ToRaylib(c, transparency)
	local r, g, b = c:ToRGB()
	return structs.Color:new({
		r = r,
		g = g,
		b = b,
		a = math.floor(255 * (1 - transparency)),
	})
end

local allowed_to_render = {
	["Part"] = "Part",
	["MeshPart"] = "MeshPart",
	["BasePart"] = "BasePart",
	["Model"] = "Model",
}

Workspace.InitRenderer = function(renderer, signal, game)
	local proptable = {
		Gravity = -9.81,
		GlobalWind = Vector3.new(0, 0, 0),
		FallenPartsDestroyHeight = 90,
		AirTurbulenceIntensity = 0,
		AirDensity = 0,
		StreamingEnabled = false,

		-- debugging
		IsInPool = function(part)
			for i, v in pairs(pool) do
				if v == part then
					return true
				end
			end
			return false
		end,

		GetPoolCount = function()
			return #pool
		end,
	}

	local meshlib = renderer.meshlib
	local materialList = renderer.materialList
	local loadedMaterials = {}

	local preloadedMeshes
	if not IsHeadless then
		preloadedMeshes = meshlib.PreloadStandardMeshes()

		local material_index = 0
		for material_name, material_path in pairs(materialList) do
			local texture = lib.LoadTexture(material_path)
			local default = lib.LoadMaterialDefault()
			lib.SetMaterialTexture(default, 0, texture)

			loadedMaterials[material_name] = {
				index = material_index,
				material = default,
				texture = texture,
			}
			material_index += 1
			print(`Loaded custom material: {material_name}`)
		end
	end

	proptable.materials = loadedMaterials

	signal:Connect(function(route, data) end)

	local function isRenderable(obj)
		return obj:IsA("Part") or obj:IsA("MeshPart")
	end

	Workspace.DescendantAdded:Connect(function(v)
		pool[#pool + 1] = v
		if isRenderable(v) then
			signal:Fire("UpdatePart", v)
		end
		print(`Added {v.Name} to render pool!`)
	end)

	--[[
	Workspace.DescendantRemoving:Connect(function(v)
		for i = #pool, 1, -1 do
			if pool[i] == v then
				table.remove(pool, i)
				break
			end
		end
	end)
	--]]

	local function drawPart(part)
		local preloadedData = preloadedMeshes[part.Shape.Value]
		local mesh = preloadedData and preloadedData[2]
		local model = part._model

		if not mesh and not model then
			return
		end

		local data = loadedMaterials[part.Material.Value]
		local matrix = part.CFrame:ToRaylibMatrixScale(part.Size, raylib.structs)

		local cfvec = vector.create(part.CFrame.Position.X, part.CFrame.Position.Y, part.CFrame.Position.Z)
		local sizevec = vector.create(part.Size.X, part.Size.Y, part.Size.Z)

		if model then
			raylib.lib.DrawModel(model, cfvec, part.MeshScale or 1, raylib.const.WHITE)
		elseif mesh and data then
			--r3d.lib.R3D_DrawMesh(mesh, defaultMaterial, matrix)
			raylib.lib.DrawMesh(mesh, data.material, matrix)
		else
			print(`  ERROR: Cannot draw - mesh={mesh}, data={data}`)
		end

		signal:Fire("Rendered", part)
	end

	for _, child in pairs(Workspace:GetDescendants()) do
		pool[#pool + 1] = child
		if isRenderable(child) then
			signal:Fire("UpdatePart", child)
		end
	end

	local function drawParts()
		for i = 1, #pool do
			local object = pool[i]
			if isRenderable(pool[i]) then
				drawPart(object)

				if object.Position.Y <= 300 then
					--object:Destroy()
				end
			else
				if object.render then
					object.render(object, renderer, game)
				end
			end
		end
	end

	local function draw()
		renderer.Signal:Fire("WorkspaceStart")

		drawParts()

		local KinemiumPhysicsService = game:GetService("PhysicsService")
		KinemiumPhysicsService.setGravity(Workspace.Gravity, Workspace.GlobalWind)
		renderer.Signal:Fire("WorkspaceFinish")
	end

	local function renderShadows(shadowMaterial)
		for i = 1, #pool do
			local part = pool[i]
			if isRenderable(part) then
				local preloadedData = preloadedMeshes[part.Shape.Value]
				local mesh = preloadedData and preloadedData[2]
				local model = part._model

				if mesh or model then -- Only drawing standard meshes for now
					local matrix = part.CFrame:ToRaylibMatrixScale(part.Size, raylib.structs)

					if model then
						-- Model drawing with custom material is harder as Model has multiple materials
						-- raylib.lib.DrawModel(model, ...) uses internal materials.
						-- To force shadow material we might need to iterate model meshes or use a shader override override?
						-- For now skip models or DrawModel normally (which won't use shadow shader)
						-- Actually `DrawModel` might not support material override easily.
						-- Assuming just Parts for now.
					elseif mesh then
						raylib.lib.DrawMesh(mesh, shadowMaterial, matrix)
					end
				end
			end
		end
	end

	proptable.DrawParts = drawParts
	proptable.Draw = draw
	proptable.RenderShadows = renderShadows
	Workspace:SetProperties(proptable)

	signal:Connect(function(route, data)
		if route == "workspace.DrawParts" then
			drawParts()
		end
	end)

	if not IsHeadless then
		renderer.Add3DStack(draw)
	end
end

return Workspace
