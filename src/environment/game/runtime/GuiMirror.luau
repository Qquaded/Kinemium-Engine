local GuiMirror = {}
GuiMirror.__index = GuiMirror

local BLOCKED_PROPERTIES = {
	Parent = true,
	Children = true,
	UniqueId = true,
	NetworkId = true,
	CanReplicate = true,
	_GuiMirrorScope = true,
	_GuiMirrorSourceId = true,
}

local function isLiveInstance(value)
	return type(value) == "table" and value.ClassName ~= nil and value.Destroyed ~= true and rawget(value, "_props") ~= nil
end

local function markTreeLocalOnly(root)
	if not isLiveInstance(root) then
		return
	end

	root.CanReplicate = false

	for _, descendant in ipairs(root:GetDescendants()) do
		descendant.CanReplicate = false
	end
end

local function getBindingSourceId(binding, sourceObject)
	return binding.sourceIdPrefix .. tostring(sourceObject.UniqueId)
end

local function getTargetSourceId(targetObject)
	return targetObject and targetObject._GuiMirrorSourceId or nil
end

local function getChildrenArray(object)
	return rawget(object, "Children") or {}
end

local function tagMirroredTree(binding, sourceRoot, cloneRoot)
	local queue = {
		{ source = sourceRoot, clone = cloneRoot },
	}
	local head = 1

	while head <= #queue do
		local current = queue[head]
		head += 1

		local sourceNode = current.source
		local cloneNode = current.clone

		cloneNode._GuiMirrorScope = binding.scope
		cloneNode._GuiMirrorSourceId = getBindingSourceId(binding, sourceNode)
		binding.bySourceId[cloneNode._GuiMirrorSourceId] = cloneNode

		local sourceChildren = getChildrenArray(sourceNode)
		local cloneChildren = getChildrenArray(cloneNode)
		local childCount = math.min(#sourceChildren, #cloneChildren)

		for index = 1, childCount do
			queue[#queue + 1] = {
				source = sourceChildren[index],
				clone = cloneChildren[index],
			}
		end
	end
end

local function disconnectTreeDestroyHooks(binding, sourceRoot)
	local queue = { sourceRoot }
	local head = 1

	while head <= #queue do
		local sourceNode = queue[head]
		head += 1

		local sourceId = getBindingSourceId(binding, sourceNode)
		local connection = binding.destroyConnections[sourceId]
		if connection then
			connection:Disconnect()
			binding.destroyConnections[sourceId] = nil
		end

		for _, child in ipairs(getChildrenArray(sourceNode)) do
			queue[#queue + 1] = child
		end
	end
end

function GuiMirror.new(targetRoot)
	local self = setmetatable({
		targetRoot = targetRoot,
		bindings = {},
	}, GuiMirror)

	markTreeLocalOnly(targetRoot)
	return self
end

function GuiMirror:_isTrackedValue(binding, value)
	return isLiveInstance(value) and (value == binding.sourceContainer or value:IsDescendantOf(binding.sourceContainer))
end

function GuiMirror:_findMirroredObject(binding, sourceObject)
	local mirrored = binding.bySourceId[getBindingSourceId(binding, sourceObject)]
	if mirrored and not isLiveInstance(mirrored) then
		binding.bySourceId[getBindingSourceId(binding, sourceObject)] = nil
		return nil
	end

	return mirrored
end

function GuiMirror:_disconnectCloneTree(binding, cloneRoot)
	if not isLiveInstance(cloneRoot) then
		return
	end

	local sourceId = getTargetSourceId(cloneRoot)
	if sourceId then
		binding.bySourceId[sourceId] = nil
	end

	for _, descendant in ipairs(cloneRoot:GetDescendants()) do
		local descendantSourceId = getTargetSourceId(descendant)
		if descendantSourceId then
			binding.bySourceId[descendantSourceId] = nil
		end
	end
end

function GuiMirror:_translateValue(binding, value)
	if not self:_isTrackedValue(binding, value) then
		return value
	end

	if value == binding.sourceContainer then
		return self.targetRoot
	end

	return self:_ensureMirroredObject(binding, value) or value
end

function GuiMirror:_resolveCloneParent(binding, sourceObject)
	local sourceParent = sourceObject and sourceObject.Parent
	if not isLiveInstance(sourceParent) then
		return nil
	end

	if sourceParent == binding.sourceContainer then
		return self.targetRoot
	end

	return self:_ensureMirroredObject(binding, sourceParent)
end

function GuiMirror:_connectDestroyHooks(binding, sourceRoot)
	local queue = { sourceRoot }
	local head = 1

	while head <= #queue do
		local sourceNode = queue[head]
		head += 1

		local sourceId = getBindingSourceId(binding, sourceNode)
		if not binding.destroyConnections[sourceId] then
			binding.destroyConnections[sourceId] = sourceNode.Destroying:Connect(function()
				self:_removeMirroredObject(binding, sourceNode)
			end)
		end

		for _, child in ipairs(getChildrenArray(sourceNode)) do
			queue[#queue + 1] = child
		end
	end
end

function GuiMirror:_ensureMirroredObject(binding, sourceObject)
	if not self:_isTrackedValue(binding, sourceObject) or sourceObject == binding.sourceContainer then
		return nil
	end

	local existing = self:_findMirroredObject(binding, sourceObject)
	if existing then
		return existing
	end

	local cloneParent = self:_resolveCloneParent(binding, sourceObject)
	if not cloneParent then
		return nil
	end

	local clone = sourceObject:Clone()
	tagMirroredTree(binding, sourceObject, clone)
	self:_connectDestroyHooks(binding, sourceObject)
	markTreeLocalOnly(clone)
	clone.Parent = cloneParent
	return clone
end

function GuiMirror:_removeMirroredObject(binding, sourceObject)
	local clone = self:_findMirroredObject(binding, sourceObject)
	disconnectTreeDestroyHooks(binding, sourceObject)

	if not clone then
		return
	end

	self:_disconnectCloneTree(binding, clone)
	clone:Destroy()
end

function GuiMirror:_syncMirroredProperty(binding, sourceObject, property, value)
	if BLOCKED_PROPERTIES[property] then
		return
	end

	local clone = self:_ensureMirroredObject(binding, sourceObject)
	if not clone then
		return
	end

	local translatedValue = self:_translateValue(binding, value)
	clone[property] = translatedValue
end

function GuiMirror:BindContainer(sourceContainer, scope)
	if not isLiveInstance(sourceContainer) then
		return nil
	end

	if self.bindings[scope] then
		self.bindings[scope]:Destroy()
	end

	local binding = {
		scope = scope,
		sourceContainer = sourceContainer,
		sourceIdPrefix = `{scope}:`,
		bySourceId = {},
		destroyConnections = {},
		connections = {},
	}

	self.bindings[scope] = binding

	for _, child in ipairs(sourceContainer:GetChildren()) do
		self:_ensureMirroredObject(binding, child)
	end

	binding.connections[#binding.connections + 1] = sourceContainer.DescendantAdded:Connect(function(descendant)
		self:_ensureMirroredObject(binding, descendant)
	end)

	binding.connections[#binding.connections + 1] = sourceContainer.DescendantRemoving:Connect(function(descendant)
		self:_removeMirroredObject(binding, descendant)
	end)

	binding.connections[#binding.connections + 1] = sourceContainer.DescendantChanged:Connect(function(descendant, property, value)
		self:_syncMirroredProperty(binding, descendant, property, value)
	end)

	function binding:Destroy()
		for _, connection in ipairs(self.connections) do
			connection:Disconnect()
		end
		self.connections = {}

		for _, connection in pairs(self.destroyConnections) do
			connection:Disconnect()
		end
		self.destroyConnections = {}
		self.bySourceId = {}
	end

	return binding
end

function GuiMirror:Destroy()
	for scope, binding in pairs(self.bindings) do
		binding:Destroy()
		self.bindings[scope] = nil
	end
end

GuiMirror.MarkTreeLocalOnly = markTreeLocalOnly

return GuiMirror
