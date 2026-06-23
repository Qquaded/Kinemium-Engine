local BlobLoader = game:GetService("BlobLoader")
local assetsaver = require("@assetsaver")

local flagValue = GetFlagValue("blob")

local path = "./exported/obj.kine"

if not IsClient and not IsServer then
	task.spawn(function()
		print("Checking if path exists")
		local ok, read = pcall(Filesystem.readFile, path, true)
		if not ok or not read then
			return
		end
		local loadOk, loadErr = pcall(BlobLoader.LoadFileAsGame, read)
		if not loadOk then
			warn("Failed to load blob: " .. tostring(loadErr))
		end
	end)
end

if flagValue then
	if BlobLoader.MarkBlobLoadingPending then
		BlobLoader:MarkBlobLoadingPending()
	end
	print("Loading blob from", flagValue)

	task.spawn(function()
		local ok, read = pcall(Filesystem.readFile, flagValue, true)
		if not ok or not read then
			warn("Failed to read blob file: " .. tostring(read or flagValue))
			return
		end
		local loadOk, loadErr = pcall(BlobLoader.LoadFileAsGame, read)
		if not loadOk then
			warn("Failed to load blob: " .. tostring(loadErr))
		end
	end)
end

task.wait(2)

if IsServer or IsClient then
	assetsaver:ResolveGame(game)
end
