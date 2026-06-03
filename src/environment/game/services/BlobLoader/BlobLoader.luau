local Instance = require("@Instance")
local BlobLoader = Instance.new("BlobLoader")
local Enum = require("@EnumMap")

BlobLoader.ExplorerHidden = true
BlobLoader._Intents = Enum.PluginIntents.FFI

BlobLoader.InitRenderer = function(renderer, renderer_signal, datamodel)
	local function byteAt(data, index)
		if type(data) == "buffer" then
			return buffer.readu8(data, index - 1)
		elseif type(data) == "string" then
			return string.byte(data, index)
		end
		return nil
	end

	local function dataLength(data)
		if type(data) == "buffer" then
			return buffer.len(data)
		elseif type(data) == "string" then
			return #data
		end
		return 0
	end

	local function fingerprintBlob(data)
		local len = dataLength(data)
		local hash = 5381
		local step = math.max(1, math.floor(len / 4096))
		for i = 1, len, step do
			local byte = byteAt(data, i) or 0
			hash = ((hash * 33) + byte) % 2147483647
		end
		return `{len}:{hash}`
	end

	local function markBlobTree(root, fingerprint)
		if not root or root.SetMetadata == nil then
			return
		end

		root:SetMetadata("__blobFingerprint", fingerprint)
		for _, descendant in ipairs(root:GetDescendants()) do
			if descendant.SetMetadata then
				descendant:SetMetadata("__blobFingerprint", fingerprint)
			end
		end
	end

	local function assignBlobNetworkIds(instances)
		local nextBlobNetId = 100
		local reserved = {
			DataModel = 0,
			Workspace = 1,
			Players = 2,
			ReplicatedStorage = 3,
			StarterGui = 4,
			CoreGui = 5,
			InternalStorage = 6,
		}

		local function assign(object)
			if object.NetworkId ~= nil then
				if type(object.NetworkId) == "number" and object.NetworkId >= nextBlobNetId then
					nextBlobNetId = object.NetworkId + 1
				end
				return
			end

			local reservedId = reserved[object.ClassName]
			if reservedId ~= nil then
				object.NetworkId = reservedId
				return
			end

			object.NetworkId = nextBlobNetId
			nextBlobNetId += 1
		end

		for _, root in ipairs(instances or {}) do
			assign(root)
			for _, descendant in ipairs(root:GetDescendants()) do
				assign(descendant)
			end
		end
	end

	local function beginReplicationSuppression()
		if datamodel.SetMetadata == nil or IsServer ~= true then
			return
		end

		local count = datamodel:GetMetadata("__replicatorSuppressRuntimeCreate") or 0
		datamodel:SetMetadata("__replicatorSuppressRuntimeCreate", count + 1)
	end

	local function endReplicationSuppression()
		if datamodel.SetMetadata == nil or IsServer ~= true then
			return
		end

		local count = math.max((datamodel:GetMetadata("__replicatorSuppressRuntimeCreate") or 0) - 1, 0)
		datamodel:SetMetadata("__replicatorSuppressRuntimeCreate", count)
	end

	-- Classes that should never be merged or attached from a blob.
	-- Camera is client-side only; merging serialized props corrupts it.
	local SKIP_BLOB_CLASSES = {
		Camera = true,
	}

	local MERGE_SINGLETON_CHILDREN = {
		Workspace = {
			Terrain = true,
			Camera = true,
		},
	}

	local SKIP_MERGED_PROPS = {
		AncestryChanged = true,
		BaseClass = true,
		Changed = true,
		ChildAdded = true,
		ChildRemoved = true,
		Children = true,
		ClassName = true,
		DescendantAdded = true,
		DescendantChanged = true,
		DescendantRemoving = true,
		Destroying = true,
		NetworkId = true,
		Parent = true,
		UniqueId = true,
		_childByName = true,
		_parentID = true,
		attributes = true,
		tags = true,
	}

	local function mergeProps(source, target)
		local props = rawget(source, "_props")
		if not props then
			return
		end

		for key, value in pairs(props) do
			if not SKIP_MERGED_PROPS[key] then
				pcall(function()
					target[key] = value
				end)
			end
		end
	end

	local function attachChildren(sourceRoot, targetRoot)
		for _, child in ipairs(sourceRoot:GetChildren()) do
			-- Preserve singleton children that already exist in the live service.
			-- Camera is handled here so the live singleton is kept and the blob copy
			-- is discarded without destroying the real one.
			local singletonChildren = MERGE_SINGLETON_CHILDREN[targetRoot.ClassName]
			local childName = child.Name
			local existing = singletonChildren
				and singletonChildren[child.ClassName]
				and targetRoot:FindFirstChild(childName)
			if existing and existing.ClassName == child.ClassName then
				if child.ClassName ~= "Camera" then
					mergeProps(child, existing)
				end
				child:Destroy()
				print("Merged ", childName)
				continue
			end

			-- Skip classes that should never be replicated/merged (e.g. Camera outside Workspace)
			if SKIP_BLOB_CLASSES[child.ClassName] then
				child:Destroy()
				print("Skipped (non-replicable) ", child.Name)
				continue
			end

			child.Parent = targetRoot
			print("Attached ", childName)
		end
	end

	local function mergeServiceSnapshot(serviceSnapshot)
		local ok, liveService = pcall(function()
			return datamodel:GetService(serviceSnapshot.Name)
		end)
		if ok and liveService then
			attachChildren(serviceSnapshot, liveService)
			return liveService
		end
		return nil
	end

	BlobLoader:SetProperties({
		MarkBlobLoadingPending = function()
			if datamodel.SetMetadata then
				datamodel:SetMetadata("__blobLoading", true)
			end
		end,

		LoadFileAsGame = function(binary)
			task.spawn(function()
				if datamodel.SetMetadata then
					datamodel:SetMetadata("__blobLoading", true)
				end
				local SerializationService = datamodel:GetService("SerializationService")
				local instances = SerializationService.Deserialize(binary, nil, true)
				print("[DEBUG] Deserialized instances. Root count:", instances and #instances or "nil")
				if not instances then
					if datamodel.SetMetadata then
						datamodel:SetMetadata("__blobLoading", false)
					end
					return false
				end
				local blobFingerprint = fingerprintBlob(binary)
				if datamodel.SetMetadata then
					datamodel:SetMetadata("__blobFingerprint", blobFingerprint)
				end
				assignBlobNetworkIds(instances)
				for _, root in ipairs(instances) do
					markBlobTree(root, blobFingerprint)
				end
				beginReplicationSuppression()
				local ok, err = pcall(function()
					for _, root in ipairs(instances) do
						if root.ClassName == "DataModel" then
							for _, serviceSnapshot in ipairs(root:GetChildren()) do
								if not mergeServiceSnapshot(serviceSnapshot) then
									log(
										"BlobLoader: no live service found for '"
											.. tostring(serviceSnapshot.Name)
											.. "'"
									)
								end
							end
						else
							print("[DEBUG] Merging root:", root.Name)
							local liveService = mergeServiceSnapshot(root)
							if not liveService then
								print("[DEBUG] Parenting root to Workspace:", root.Name)
								root.Parent = datamodel:GetService("Workspace") or datamodel
								print("[DEBUG] Parented root to Workspace:", root.Name)
							end
						end
					end
				end)
				endReplicationSuppression()
				if not ok then
					warn("BlobLoader: failed to merge blob: " .. tostring(err))
					if datamodel.SetMetadata then
						datamodel:SetMetadata("__blobLoading", false)
					end
					return false
				end
				if datamodel.SetMetadata then
					datamodel:SetMetadata("__blobLoading", false)
				end
				print("[DEBUG] Finished parenting all roots")
			end)

			return datamodel
		end,

		LoadFileAsGameFetch = function(link)
			local _1GB = 1024 * 1024 * 1024
			local ContentService = datamodel:GetService("ContentService")
			local binary = ContentService:GetBinary(link, _1GB)
			local new = BlobLoader.LoadFileAsGame(binary)
			return new
		end,
	})
end

return BlobLoader
