-- Filament adapter
local filament = require("./filament")
local filamentAdapter = {}
local typedefs = require("../../typedefs")

local filamentPixelsPtr = nil

function filamentAdapter:Init(window: typedefs.Window)
	filamentPixelsPtr = zune.ffi.alloc(window.Width * window.Height * 4)

	window._3dhandle = filament.lib.Kine_Filament_Create(window.Width, window.Height)
	filament.lib.Kine_Filament_CreateSky(window._3dhandle, 102 / 255, 191 / 255, 255 / 255, 1)
end

function filamentAdapter:SetCameraPosition(window: typedefs.Window, position: typedefs.Vector3)
	local handle = window._3dhandle
	filament.lib.Kine_Filament_SetCameraPosition(handle, position.X, position.Y, position.Z)
end

function filamentAdapter:Resize3D(window: typedefs.Window, width, height)
	local handle = window._3dhandle
	filament.lib.Kine_Filament_Resize(handle, width, height)
end

function filamentAdapter:Render3D(window: typedefs.Window, dt: number)
	local handle = window._3dhandle
	filament.lib.Kine_Filament_RenderFrame(handle, dt)
end

function filamentAdapter:ResizePixelBuffer(window, width, height)
	if filamentPixelsPtr then
		zune.ffi.free(filamentPixelsPtr)
	end
	filamentPixelsPtr = zune.ffi.alloc(width * height * 4)
	filamentAdapter:Resize3D(window, width, height)
end

function filamentAdapter:BlitToScreen(
	window: typedefs.Window,
	dstX: number,
	dstY: number,
	dstWidth: number,
	dstHeight: number
)
	filament.lib.Kine_Filament_BlitToScreen(window._3dhandle, dstX, dstY, dstWidth, dstHeight)
end

function filamentAdapter:CreateMesh(window: typedefs.Window, meshType: "cube" | "sphere" | "pyramid"): typedefs.Mesh
	local map = {
		["cube"] = 1,
		["sphere"] = 2,
		["pyramid"] = 3,
	}

	return { _handle = filament.lib.Kine_Filament_CreateMesh(window._3dhandle, map[meshType]) }
end

function filamentAdapter:GetPixels(window: typedefs.Window)
	if not filamentPixelsPtr then
		filamentPixelsPtr = zune.ffi.alloc(window.Width * window.Height * 4)
	end
	filament.lib.Kine_Filament_ReadPixels(window._3dhandle, filamentPixelsPtr)
	return filamentPixelsPtr
end

return filamentAdapter
