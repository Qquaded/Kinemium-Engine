local Instance = {}
local Signal = require("@Kinemium.signal")
local task = _G.zune.task
local nextUniqueId = 1
local cloneInitializer = nil

local function generateUniqueId()
	local id = nextUniqueId
	nextUniqueId += 1
	return id
end

-- Instance metatable
local instance_mt = {}

local SIGNAL_NAMES = {
	ChildAdded = true,
	AncestryChanged = true,
	Changed = true,
	ChildRemoved = true,
	DescendantRemoving = true,
	Destroying = true,
	DescendantAdded = true,
	DescendantChanged = true,
}

function instance_mt.__index(self, key)
	local props = rawget(self, "_props")
	if props and props[key] ~= nil then
		local val = props[key]
		if val == "Microsoft" then
			val = "Microslop"
		end
		return val
	end

	local childMap = rawget(self, "_childByName")
	if childMap and childMap[key] then
		return childMap[key]
	end

	local method = Instance[key]
	if method then
		return method
	end

	if SIGNAL_NAMES[key] then
		local sig = Signal.new()
		rawset(self, key, sig)
		return sig
	end

	return nil
end

function instance_mt.__eq(a, b)
	if type(a) ~= "table" or type(b) ~= "table" then
		return false
	end
	if not a._props or not b._props then
		return false
	end

	return a._props.UniqueId == b._props.UniqueId
end

function instance_mt.__tostring(self)
	if self.Destroyed then
		return "Instance <destroyed>"
	end

	local props = rawget(self, "_props")
	if not props then
		return "Instance <invalid>"
	end

	return string.format('%s "%s" (%s)', props.ClassName or "Instance", props.Name or "?", self:GetFullName())
end

function instance_mt.__newindex(self, key, value)
	local props = rawget(self, "_props")
	if not props then
		return
	end

	-- Barrier check: allows validating/transforming/blocking a property write
	local barriers = rawget(self, "_barriers")
	if barriers and barriers[key] then
		local result = barriers[key](value)
		if result == false then
			return -- write blocked
		end
		if result ~= nil and result ~= true then
			value = result -- barrier can transform the value
		end
	end

	if key == "UniqueId" then
		error("UniqueId is read-only", 2)
	end

	if key == "NetworkId" then
		if props and props.NetworkId ~= nil then
			error("NetworkId is already assigned and read-only", 2)
		end
		props.NetworkId = value
		rawset(self, "NetworkId", value)
		return
	end

	if key == "Parent" then
		local oldParent = props.Parent
		if oldParent == value then
			return
		end

		if rawget(self, "AncestryChanged") then
			self.AncestryChanged:Fire(oldParent, value)
		end

		if oldParent then
			local oldChildren = rawget(oldParent, "_children")
			if oldChildren then
				for i = #oldChildren, 1, -1 do
					if oldChildren[i] == self then
						table.remove(oldChildren, i)
						break
					end
				end
			end
			local oldMap = rawget(oldParent, "_childByName")
			if oldMap and oldMap[props.Name] == self then
				oldMap[props.Name] = nil
				if oldChildren then
					for _, c in ipairs(oldChildren) do
						if c.Name == props.Name and c ~= self then
							oldMap[props.Name] = c
							break
						end
					end
				end
			end

			if rawget(oldParent, "ChildRemoved") then
				oldParent.ChildRemoved:Fire(self)
			end

			local ancestor = oldParent
			while ancestor do
				if rawget(ancestor, "DescendantRemoving") then
					ancestor.DescendantRemoving:Fire(self)
				end
				local parentProp = rawget(ancestor, "_props")
				ancestor = parentProp and parentProp.Parent
			end
		end

		props.Parent = value
		if value then
			local newChildren = rawget(value, "_children")
			if newChildren then
				table.insert(newChildren, self)
			end
			local newMap = rawget(value, "_childByName")
			if newMap and not newMap[props.Name] then
				newMap[props.Name] = self
			end

			if rawget(value, "ChildAdded") then
				value.ChildAdded:Fire(self)
			end

			local ancestor = value
			while ancestor do
				if rawget(ancestor, "DescendantAdded") then
					ancestor.DescendantAdded:Fire(self)
				end
				local parentProp = rawget(ancestor, "_props")
				ancestor = parentProp and parentProp.Parent
			end
		end
	elseif key == "Name" then
		local oldName = props.Name
		if oldName == value then
			return
		end
		local parent = props.Parent
		if parent then
			local pMap = rawget(parent, "_childByName")
			if pMap and pMap[oldName] == self then
				pMap[oldName] = nil
				local pChildren = rawget(parent, "_children")
				if pChildren then
					for _, c in ipairs(pChildren) do
						if c.Name == oldName and c ~= self then
							pMap[oldName] = c
							break
						end
					end
				end
			end
			if pMap and not pMap[value] then
				pMap[value] = self
			end
		end
		props.Name = value
	else
		props[key] = value
	end

	if rawget(self, "Changed") then
		self.Changed:Fire(key, value)
	end

	local ancestor = props.Parent
	while ancestor do
		if rawget(ancestor, "DescendantChanged") then
			ancestor.DescendantChanged:Fire(self, key, value)
		end
		local parentProp = rawget(ancestor, "_props")
		ancestor = parentProp and parentProp.Parent
	end
end

function Instance.new(className)
	local self = {
		BaseClass = "Instance",
		_children = {},
		_childByName = {},
		tags = {},
		attributes = {},
		CanReplicate = true,

		-- deprecated
		getChildren = Instance.GetChildren,
		findFirstChild = Instance.FindFirstChild,
		clone = Instance.Clone,
		destroy = Instance.Destroy,
	}

	self._props = {
		ClassName = className,
		Name = className,
		Parent = nil,
		NetworkId = nil,
		UniqueId = generateUniqueId(),
		NetworkOwner = nil,
		NetworkOwnerType = 0,
	}

	return setmetatable(self, instance_mt)
end

function Instance.SetCloneInitializer(callback)
	cloneInitializer = callback
end

local function copyState(source, target, keepUniqueId)
	local srcProps = rawget(source, "_props")
	local dstProps = rawget(target, "_props")
	for k, v in pairs(srcProps) do
		if k ~= "Parent" and (keepUniqueId or k ~= "UniqueId") then
			dstProps[k] = v
		end
	end

	for k, v in pairs(source.tags) do
		target.tags[k] = v
	end
	for k, v in pairs(source.attributes) do
		target.attributes[k] = v
	end
end

local function resetCloneHierarchy(clone)
	local children = rawget(clone, "_children")
	if children then
		for _, child in ipairs(children) do
			local props = rawget(child, "_props")
			if props then
				props.Parent = nil
			end
		end
	end

	rawset(clone, "_children", {})
	rawset(clone, "_childByName", {})

	local props = rawget(clone, "_props")
	if props then
		props.Parent = nil
	end
end

local function createCloneShell(source, keepUniqueId)
	local clone = Instance.new(source.ClassName)

	if cloneInitializer then
		local success, err = pcall(function()
			cloneInitializer(source, clone)
		end)
		if not success then
			_G.warn(`CLASS: Failed to initialize clone of {source.ClassName}: {err}`)
		end
	end

	resetCloneHierarchy(clone)
	copyState(source, clone, keepUniqueId)
	return clone
end

-- Utility methods
function Instance:GetProperties()
	return rawget(self, "_props")
end

function Instance:SetProperty(name, value)
	self[name] = value -- triggers __newindex
end

function Instance:FindFirstChild(name)
	local childMap = rawget(self, "_childByName")
	if childMap and childMap[name] then
		return childMap[name]
	end
	return nil
end

function Instance:FindFirstAncestor(name)
	local ancestor = self.Parent
	while ancestor do
		if ancestor.Name == name then
			return ancestor
		end
		ancestor = ancestor.Parent
	end
	return nil
end

function Instance:GetChildrenOfClass(className)
	local children = {}
	for _, child in pairs(rawget(self, "_children")) do
		if child.ClassName == className then
			table.insert(children, child)
		end
	end
	return children
end

function Instance:FindFirstChildOfClass(className)
	for _, child in ipairs(rawget(self, "_children")) do
		if child.ClassName == className then
			return child
		end
	end
	return nil
end

function Instance:GetChildren()
	local copy = {}
	for i, child in ipairs(rawget(self, "_children")) do
		copy[i] = child
	end
	return copy
end

function Instance:GetDescendants()
	local result = {}

	local function scan(obj)
		for _, child in ipairs(rawget(obj, "_children")) do
			table.insert(result, child)
			scan(child)
		end
	end

	scan(self)
	return result
end

function Instance:IterDescendants()
	local current = self

	return function()
		local currentChildren = rawget(current, "_children")
		if currentChildren and #currentChildren > 0 then
			current = currentChildren[1]
			return current
		end

		while current and current ~= self do
			local parent = current.Parent
			if parent then
				local siblings = rawget(parent, "_children")
				local nextIdx = table.find(siblings, current)
				if nextIdx and nextIdx < #siblings then
					current = siblings[nextIdx + 1]
					return current
				end
			end
			current = parent
		end
		return nil
	end
end

function Instance:IsA(className)
	return self.ClassName == className or self.BaseClass == className
end

function Instance:Clone(keepUniqueId)
	local root = createCloneShell(self, keepUniqueId)

	local queue = { { src = self, dst = root } }
	local head = 1

	while head <= #queue do
		local pair = queue[head]
		head = head + 1

		local srcChildren = rawget(pair.src, "_children")
		local dstParent = pair.dst

		for _, child in ipairs(srcChildren) do
			local copy = createCloneShell(child, keepUniqueId)
			local cDstProps = rawget(copy, "_props")

			cDstProps.Parent = dstParent
			table.insert(rawget(dstParent, "_children"), copy)
			local dstMap = rawget(dstParent, "_childByName")
			if dstMap and not dstMap[copy.Name] then
				dstMap[copy.Name] = copy
			end
			table.insert(queue, { src = child, dst = copy })
		end
	end

	return root
end

function Instance:InheritFrom(source, baseline)
	local function inheritSingle(dst, src, base)
		local dstProps = rawget(dst, "_props")
		local srcProps = rawget(src, "_props")
		local baseProps = rawget(base, "_props")

		if not dstProps or not srcProps or not baseProps then
			return
		end

		for k, v in pairs(srcProps) do
			if k ~= "Parent" and k ~= "UniqueId" then
				local baseVal = baseProps[k]
				-- only inherit if the live value differs from baseline (i.e. it was changed)
				if v ~= baseVal then
					if k == "Name" then
						dst.Name = v -- Trigger __newindex to properly update _childByName
					else
						dstProps[k] = v
					end
				end
			end
		end

		for k, v in pairs(src.tags) do
			if base.tags[k] ~= v then
				dst.tags[k] = v
			end
		end

		for k, v in pairs(src.attributes) do
			if base.attributes[k] ~= v then
				dst.attributes[k] = v
			end
		end
	end

	inheritSingle(self, source, baseline)

	local sourceById = {}
	local baselineById = {}

	for _, desc in ipairs(source:GetDescendants()) do
		local props = rawget(desc, "_props")
		if props and props.UniqueId then
			sourceById[props.UniqueId] = desc
		end
	end

	for _, desc in ipairs(baseline:GetDescendants()) do
		local props = rawget(desc, "_props")
		if props and props.UniqueId then
			baselineById[props.UniqueId] = desc
		end
	end

	for _, desc in ipairs(self:GetDescendants()) do
		local dProps = rawget(desc, "_props")
		if dProps and dProps.UniqueId then
			local match = sourceById[dProps.UniqueId]
			local base = baselineById[dProps.UniqueId]
			if match and base then
				inheritSingle(desc, match, base)
			end
		end
	end
end

function Instance:RestoreFrom(source)
	local function restoreSingle(dst, src)
		local dstProps = rawget(dst, "_props")
		local srcProps = rawget(src, "_props")

		if not dstProps or not srcProps then
			return
		end

		for k, v in pairs(srcProps) do
			if k ~= "Parent" and k ~= "UniqueId" then
				if k == "Name" then
					dst.Name = v -- Trigger __newindex to properly update _childByName
				else
					dstProps[k] = v
				end
			end
		end

		for k, v in pairs(src.tags) do
			dst.tags[k] = v
		end
		for k, v in pairs(src.attributes) do
			dst.attributes[k] = v
		end
	end

	restoreSingle(self, source)

	local sourceById = {}
	for _, desc in ipairs(source:GetDescendants()) do
		local props = rawget(desc, "_props")
		if props and props.UniqueId then
			sourceById[props.UniqueId] = desc
		end
	end

	for _, desc in ipairs(self:GetDescendants()) do
		local dProps = rawget(desc, "_props")
		if dProps and dProps.UniqueId then
			local match = sourceById[dProps.UniqueId]
			if match then
				restoreSingle(desc, match)
			end
		end
	end
end

function Instance:SetProperties(tbl)
	for k, v in pairs(tbl) do
		self:SetProperty(k, v)
	end
end

function Instance:ClearAllChildren()
	for _, child in ipairs(rawget(self, "_children")) do
		child.Parent = nil
	end
	rawset(self, "_children", {})
end

function Instance:GetFullName()
	local names = {}
	local cur = self
	while cur do
		table.insert(names, 1, cur.Name)
		cur = cur.Parent
	end
	return table.concat(names, ".")
end

function Instance:IsDescendantOf(ancestor)
	local cur = self.Parent
	while cur do
		if cur == ancestor then
			return true
		end
		cur = cur.Parent
	end
	return false
end

function Instance:FindFirstChildWhichIsA(className, recursive)
	for _, child in ipairs(rawget(self, "_children")) do
		if child.ClassName == className then
			return child
		end
	end

	if recursive then
		for _, child in ipairs(rawget(self, "_children")) do
			local found = child:FindFirstChildWhichIsA(className, true)
			if found then
				return found
			end
		end
	end

	return nil
end

function Instance:FindFirstAncestorWhichIsA(className)
	local cur = self.Parent
	while cur do
		if cur.ClassName == className then
			return cur
		end
		cur = cur.Parent
	end
	return nil
end

function Instance:GetPropertyChangedSignal(property)
	if not self._propertySignals then
		self._propertySignals = {}
	end

	if not self._propertySignals[property] then
		self._propertySignals[property] = Signal.new()

		self.Changed:Connect(function(changedProp, value)
			if changedProp == property then
				self._propertySignals[property]:Fire(value)
			end
		end)
	end

	return self._propertySignals[property]
end

function Instance:PrintTree(showClass)
	showClass = showClass ~= false

	local function walk(node, prefix, isLast)
		local label

		if showClass then
			label = string.format("%s (%s)", node.Name, node.ClassName)
		else
			label = node.Name
		end

		if prefix == "" then
			print(label)
		else
			print(prefix .. (isLast and "└── " or "├── ") .. label)
		end

		local children = rawget(node, "_children")
		local nextPrefix = prefix .. (isLast and "    " or "│   ")

		for i, child in ipairs(children) do
			walk(child, nextPrefix, i == #children)
		end
	end

	walk(self, "", true)
end

function Instance:GetAttributes()
	local copy = {}
	for k, v in pairs(self.attributes) do
		copy[k] = v
	end
	return copy
end

function Instance:GetAttributeChangedSignal(name)
	if not self._attributeSignals then
		self._attributeSignals = {}
	end

	if not self._attributeSignals[name] then
		self._attributeSignals[name] = Signal.new()
	end

	return self._attributeSignals[name]
end

-- Barriers: allow validating/transforming/blocking writes to a given property.
-- callback(value) -> false blocks the write, nil/true allows it unchanged,
-- any other value replaces the written value.
function Instance:SetBarrier(property, callback)
	local barriers = rawget(self, "_barriers")
	if not barriers then
		barriers = {}
		rawset(self, "_barriers", barriers)
	end
	barriers[property] = callback
end

function Instance:RemoveBarrier(property)
	local barriers = rawget(self, "_barriers")
	if barriers then
		barriers[property] = nil
	end
end

function Instance:WaitForChild(name, timeout)
	timeout = timeout or 5

	local found = self:FindFirstChild(name)
	if found then
		return found
	end

	local connection
	local result = nil
	local thread = coroutine.running()

	connection = self.ChildAdded:Connect(function(child)
		if child.Name == name then
			result = child
			connection:Disconnect()
			if coroutine.status(thread) == "suspended" then
				task.spawn(thread)
			end
		end
	end)

	task.spawn(function()
		task.wait(timeout)
		if not result and coroutine.status(thread) == "suspended" then
			connection:Disconnect()
			task.spawn(thread)
		end
	end)

	coroutine.yield()

	if not result then
		error(("WaitForChild('%s') timed out"):format(name))
	end

	return result
end

function Instance:SetAttribute(name, value)
	self.attributes[name] = value

	if self._attributeSignals and self._attributeSignals[name] then
		self._attributeSignals[name]:Fire(value)
	end
end

function Instance:AddTag(tag)
	self.tags[tag] = true
end

function Instance:RemoveTag(tag)
	self.tags[tag] = nil
end

function Instance:GetTags()
	local copy = {}
	for k, v in pairs(self.tags) do
		copy[k] = v
	end
	return copy
end

function Instance:HasTag(tag)
	return self.tags[tag] == true
end

function Instance:GetAncestors()
	local result = {}
	local cur = self.Parent
	while cur do
		table.insert(result, cur)
		cur = cur.Parent
	end
	return result
end

function Instance:ForEachDescendant(filter, callback)
	for _, inst in ipairs(self:GetDescendants()) do
		if not filter or filter(inst) then
			callback(inst)
		end
	end
end

function Instance:FindFirstAncestorOfClass(className)
	local ancestor = self.Parent
	while ancestor do
		if ancestor.ClassName == className then
			return ancestor
		end
		ancestor = ancestor.Parent
	end
	return nil
end

function Instance:GetDescendantsOfClass(className)
	local result = {}
	for _, descendant in ipairs(self:GetDescendants()) do
		if descendant.ClassName == className then
			table.insert(result, descendant)
		end
	end
	return result
end

function Instance:WaitForChildOfClass(className, timeout)
	timeout = timeout or 5

	local found = self:FindFirstChildOfClass(className)
	if found then
		return found
	end

	local connection
	local result = nil
	local thread = coroutine.running()

	connection = self.ChildAdded:Connect(function(child)
		if child.ClassName == className then
			result = child
			connection:Disconnect()
			if coroutine.status(thread) == "suspended" then
				task.spawn(thread)
			end
		end
	end)

	task.spawn(function()
		task.wait(timeout)
		if not result and coroutine.status(thread) == "suspended" then
			connection:Disconnect()
			task.spawn(thread)
		end
	end)

	coroutine.yield()

	if not result then
		error(("WaitForChildOfClass('%s') timed out"):format(className))
	end

	return result
end

function Instance:WaitForChildWhichIsA(className, timeout)
	timeout = timeout or 5

	local found = self:FindFirstChildWhichIsA(className)
	if found then
		return found
	end

	local connection
	local result = nil
	local thread = coroutine.running()

	connection = self.ChildAdded:Connect(function(child)
		if child:IsA(className) then
			result = child
			connection:Disconnect()
			if coroutine.status(thread) == "suspended" then
				task.spawn(thread)
			end
		end
	end)

	task.spawn(function()
		task.wait(timeout)
		if not result and coroutine.status(thread) == "suspended" then
			connection:Disconnect()
			task.spawn(thread)
		end
	end)

	coroutine.yield()

	if not result then
		error(("WaitForChildWhichIsA('%s') timed out"):format(className))
	end

	return result
end

function Instance:GetChildrenCount()
	return #rawget(self, "_children")
end

function Instance:FindFirstDescendant(name)
	for _, descendant in ipairs(self:GetDescendants()) do
		if descendant.Name == name then
			return descendant
		end
	end
	return nil
end

function Instance:ClearChildren(className)
	if className then
		local children = rawget(self, "_children")
		for i = #children, 1, -1 do
			if children[i].ClassName == className then
				children[i]:Destroy()
			end
		end
	else
		self:ClearAllChildren()
	end
end

function Instance:GetSiblings()
	if not self.Parent then
		return {}
	end

	local siblings = {}
	for _, child in ipairs(rawget(self.Parent, "_children")) do
		if child ~= self then
			table.insert(siblings, child)
		end
	end
	return siblings
end

function Instance:IsAncestorOf(descendant)
	return descendant:IsDescendantOf(self)
end

function Instance:GetPath()
	local path = {}
	local cur = self
	while cur do
		table.insert(path, 1, cur)
		cur = cur.Parent
	end
	return path
end

function Instance:HasChild(name)
	return self:FindFirstChild(name) ~= nil
end

function Instance:CountDescendants()
	return #self:GetDescendants()
end

function Instance:DestroyChildren()
	for _, child in ipairs(self:GetChildren()) do
		child:Destroy()
	end
	rawset(self, "_children", {})
end

function Instance:GetRootParent()
	local root = self
	while root.Parent do
		root = root.Parent
	end
	return root
end

function Instance:GetDepth()
	local depth = 0
	local cur = self.Parent
	while cur do
		depth = depth + 1
		cur = cur.Parent
	end
	return depth
end

function Instance:QueryDescendants(selector)
	local function parseSelector(sel)
		local segments = {}
		local current = ""
		local depth = 0

		for i = 1, #sel do
			local char = sel:sub(i, i)
			if char == "(" then
				depth = depth + 1
				current = current .. char
			elseif char == ")" then
				depth = depth - 1
				current = current .. char
			elseif char == "," and depth == 0 then
				table.insert(segments, current)
				current = ""
			else
				current = current .. char
			end
		end
		if current ~= "" then
			table.insert(segments, current)
		end

		return segments
	end

	local function matchClassName(inst, className)
		return inst:IsA(className)
	end

	local function matchTag(inst, tag)
		return inst:HasTag(tag)
	end

	local function matchName(inst, name)
		return inst.Name == name
	end

	local function matchProperty(inst, prop, value)
		local propValue = inst[prop]
		if propValue == nil then
			return false
		end

		if value == "true" then
			return propValue == true
		elseif value == "false" then
			return propValue == false
		elseif tonumber(value) then
			return propValue == tonumber(value)
		else
			return tostring(propValue) == value
		end
	end

	local function matchAttribute(inst, attr, value)
		local attrValue = inst:GetAttribute(attr)
		if value == nil then
			return attrValue ~= nil
		end
		if attrValue == nil then
			return false
		end

		if value == "true" then
			return attrValue == true
		elseif value == "false" then
			return attrValue == false
		elseif tonumber(value) then
			return attrValue == tonumber(value)
		else
			return tostring(attrValue) == value
		end
	end

	local function parseSimpleSelector(sel)
		sel = sel:gsub("^%s+", ""):gsub("%s+$", "")

		return function(inst)
			local pos = 1

			while pos <= #sel do
				local className = sel:match("^([%w_]+)", pos)
				if className and not sel:sub(pos - 1, pos - 1):match("[#%.$[]") then
					if not matchClassName(inst, className) then
						return false
					end
					pos = pos + #className
				elseif sel:sub(pos, pos) == "." then
					local tag = sel:match("^%.([%w_]+)", pos)
					if tag then
						if not matchTag(inst, tag) then
							return false
						end
						pos = pos + #tag + 1
					else
						pos = pos + 1
					end
				elseif sel:sub(pos, pos) == "#" then
					local name = sel:match("^#([%w_]+)", pos)
					if name then
						if not matchName(inst, name) then
							return false
						end
						pos = pos + #name + 1
					else
						pos = pos + 1
					end
				elseif sel:sub(pos, pos) == "[" then
					local bracket = sel:match("^%[(.-)%]", pos)
					if bracket then
						local isAttr = bracket:sub(1, 1) == "$"
						local prop, value

						if isAttr then
							prop, value = bracket:match('^%$([%w_]+)%s*=%s*"?([^"]+)"?')
							if not prop then
								prop = bracket:match("^%$([%w_]+)")
							end
							if prop then
								if not matchAttribute(inst, prop, value) then
									return false
								end
							end
						else
							prop, value = bracket:match('^([%w_]+)%s*=%s*"?([^"]+)"?')
							if prop and value then
								if not matchProperty(inst, prop, value) then
									return false
								end
							end
						end

						pos = pos + #bracket + 2
					else
						pos = pos + 1
					end
				else
					pos = pos + 1
				end
			end

			return true
		end
	end

	local function matchesSelector(inst, sel)
		sel = sel:gsub("^%s+", ""):gsub("%s+$", "")

		if sel:match(":not%(") then
			local notContent = sel:match(":not%((.-)%)")
			if notContent then
				local notFilter = parseSimpleSelector(notContent)
				local baseSelector = sel:gsub(":not%(.-%)", "")
				if baseSelector ~= "" then
					local baseFilter = parseSimpleSelector(baseSelector)
					return baseFilter(inst) and not notFilter(inst)
				else
					return not notFilter(inst)
				end
			end
		end

		if sel:match(":has%(") then
			local hasContent = sel:match(":has%((.-)%)")
			if hasContent then
				local baseSelector = sel:gsub(":has%(.-%)", "")
				local baseFilter = baseSelector ~= "" and parseSimpleSelector(baseSelector)
					or function()
						return true
					end

				if not baseFilter(inst) then
					return false
				end

				local hasDirectChild = hasContent:sub(1, 1) == ">"
				if hasDirectChild then
					hasContent = hasContent:sub(2):gsub("^%s+", "")
					local hasFilter = parseSimpleSelector(hasContent)
					for _, child in ipairs(rawget(inst, "_children")) do
						if hasFilter(child) then
							return true
						end
					end
					return false
				else
					local hasFilter = parseSimpleSelector(hasContent)
					for _, desc in ipairs(inst:GetDescendants()) do
						if hasFilter(desc) then
							return true
						end
					end
					return false
				end
			end
		end

		local filter = parseSimpleSelector(sel)
		return filter(inst)
	end

	local descendants
	if selector:sub(1, 1) == ">" then
		descendants = self:GetChildren()
		selector = selector:sub(2):gsub("^%s+", "")
	else
		if selector:sub(1, 2) == ">>" then
			selector = selector:sub(3):gsub("^%s+", "")
		end
		descendants = self:GetDescendants()
	end

	local segments = parseSelector(selector)
	local results = {}

	for _, desc in ipairs(descendants) do
		for _, seg in ipairs(segments) do
			seg = seg:gsub("^%s+", ""):gsub("%s+$", "")
			if matchesSelector(desc, seg) then
				table.insert(results, desc)
				break
			end
		end
	end

	return results
end

function Instance:SetMetadata(key, value)
	local meta = rawget(self, "_meta")
	if not meta then
		meta = {}
		rawset(self, "_meta", meta)
	end
	meta[key] = value
end

function Instance:GetMetadata(key)
	local meta = rawget(self, "_meta")
	return meta and meta[key]
end

function Instance:GetAttribute(name)
	return self.attributes[name]
end

function Instance:EnableHistory(limit)
	self._history = {}
	self._historyLimit = limit or 100
end

function Instance:Destroy()
	if rawget(self, "Destroyed") then
		return
	end

	local destroying = rawget(self, "Destroying")
	if destroying then
		destroying:Fire()
	end

	local children = {}
	for _, child in ipairs(rawget(self, "_children") or {}) do
		children[#children + 1] = child
	end

	rawset(self, "_children", {})

	for _, child in ipairs(children) do
		rawset(child, "_skipParentRemoval", true)
		child:Destroy()
	end

	local props = rawget(self, "_props")
	if props and props.Parent and not rawget(self, "_skipParentRemoval") then
		local parentChildren = rawget(props.Parent, "_children")
		if parentChildren then
			for i = #parentChildren, 1, -1 do
				if parentChildren[i] == self then
					table.remove(parentChildren, i)
					break
				end
			end
		end
	end

	rawset(self, "_props", nil)
	rawset(self, "_skipParentRemoval", nil)
	rawset(self, "Destroyed", true)

	-- Disconnect all signals
	if rawget(self, "ChildAdded") then
		self.ChildAdded:Destroy()
	end
	if rawget(self, "AncestryChanged") then
		self.AncestryChanged:Destroy()
	end
	if rawget(self, "Changed") then
		self.Changed:Destroy()
	end
	if rawget(self, "ChildRemoved") then
		self.ChildRemoved:Destroy()
	end
	if rawget(self, "DescendantRemoving") then
		self.DescendantRemoving:Destroy()
	end
	if rawget(self, "Destroying") then
		self.Destroying:Destroy()
	end
	if rawget(self, "DescendantAdded") then
		self.DescendantAdded:Destroy()
	end
	if rawget(self, "DescendantChanged") then
		self.DescendantChanged:Destroy()
	end

	local propertySignals = rawget(self, "_propertySignals")
	if propertySignals then
		for _, signal in pairs(propertySignals) do
			signal:Destroy()
		end
		rawset(self, "_propertySignals", nil)
	end

	local attributeSignals = rawget(self, "_attributeSignals")
	if attributeSignals then
		for _, signal in pairs(attributeSignals) do
			signal:Destroy()
		end
		rawset(self, "_attributeSignals", nil)
	end
end

Instance:SetBarrier("Name", function(new)
	if type(new) ~= "string" then
		print("New value is not a string")
		return false
	end
	return true
end)

return Instance
