local Instance = require("@Instance")
local Vector3 = require("@Vector3")
local Workspace = Instance.new("Workspace")
local Color3 = require("@Color3")

local pool = {}

local raylib = require("@raylib")
local lib = raylib.lib
local structs = raylib.structs

local utils = require("@bufferutils")
local default = lib.LoadMaterialDefault()

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
	if not isHeadless then
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

	Workspace:SetProperties(proptable)

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
		local mesh = preloadedMeshes[part.Shape.Value][2]
		local model = part._model

		if not mesh and not model then
			return
		end

		part._mesh = mesh

		local data = loadedMaterials[part.Material.Value]
		local matrix = part.CFrame:ToRaylibMatrixScale(part.Size, raylib.structs)

		--log(`{part.Name} : {part.CFrame}`)

		local cfvec = vector.create(part.CFrame.Position.X, part.CFrame.Position.Y, part.CFrame.Position.Z)
		local sizevec = vector.create(part.Size.X, part.Size.Y, part.Size.Z)

		if model then
			raylib.lib.DrawModel(model, cfvec, part.MeshScale or 1, raylib.const.WHITE)
		else
			raylib.lib.DrawMesh(mesh, data.material, matrix)
		end

		if part._showhitbox == true then
			raylib.lib.DrawCubeV(cfvec, sizevec, Color3ToRaylib(Color3.new(1, 0, 0), 0.5))
		end

		signal:Fire("Rendered", part)
	end

	for _, child in pairs(Workspace:GetDescendants()) do
		pool[#pool + 1] = child
		if isRenderable(child) then
			signal:Fire("UpdatePart", child)
		end
	end

	if not isHeadless then
		renderer.Add3DStack(function()
			renderer.Signal:Fire("WorkspaceStart")

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

			local KinemiumPhysicsService = game:GetService("PhysicsService")
			KinemiumPhysicsService.setGravity(Workspace.Gravity, Workspace.GlobalWind)
			renderer.Signal:Fire("WorkspaceFinish")
		end)
	end
end

return Workspace
