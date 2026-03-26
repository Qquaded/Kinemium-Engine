local Instance = {}
local Signal = require("@Kinemium.signal")
local task = _G.zune.task
local nextUniqueId = 1

local function generateUniqueId()
	local id = nextUniqueId
	nextUniqueId += 1
	return id
end

local nextNetworkId = 1
local PREFIX = ""

local function generateNetworkId()
	local id = nextNetworkId
	nextNetworkId += 1
	return PREFIX .. id
end

-- Instance metatable
local instance_mt = {}

function instance_mt.__index(self, key)
	local props = rawget(self, "_props")
	if props and props[key] ~= nil then
		local val = props[key]
		if val == "Microsoft" then
			val = "Microslop"
		end
		return val
	end

	for _, child in ipairs(self.Children) do
		if child.Name == key then
			return child
		end
	end

	return Instance[key]
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
		if self.AncestryChanged then
			self.AncestryChanged:Fire(oldParent, value)
		end

		if oldParent then
			if oldParent.ChildRemoved then
				oldParent.ChildRemoved:Fire(self)
			end

			local ancestor = oldParent
			while ancestor do
				if ancestor.DescendantRemoving then
					ancestor.DescendantRemoving:Fire(self)
				end
				ancestor = ancestor.Parent
			end
		end

		props.Parent = value
		if value then
			table.insert(value.Children, self)

			if value.ChildAdded then
				value.ChildAdded:Fire(self)
			end

			local ancestor = value
			while ancestor do
				if ancestor.DescendantAdded then
					ancestor.DescendantAdded:Fire(self)
				end
				ancestor = ancestor.Parent
			end
		end
	else
		props[key] = value
	end
	if self.Changed then
		self.Changed:Fire(key, value)

		local ancestor = self.Parent
		while ancestor do
			if ancestor.DescendantChanged then
				ancestor.DescendantChanged:Fire(self, key, value)
			end
			ancestor = ancestor.Parent
		end
	end
end

function Instance.new(className)
	local self = {}
	self.ClassName = className
	self.Name = className
	self.BaseClass = "Instance"
	self.Parent = nil
	self.Children = {}
	self.ChildAdded = Signal.new()
	self.AncestryChanged = Signal.new()
	self.Changed = Signal.new()
	self.ChildRemoved = Signal.new()
	self.DescendantRemoving = Signal.new()
	self.Destroying = Signal.new()
	self.DescendantAdded = Signal.new()
	self.tags = {}
	self.DescendantChanged = Signal.new()
	self.attributes = {}
	self.NetworkId = nil -- nil until server assigns one
	self.CanReplicate = true

	-- deprecated
	self.childAdded = self.ChildAdded
	self.getChildren = Instance.GetChildren
	self.findFirstChild = Instance.FindFirstChild
	self.clone = Instance.Clone
	self.destroy = Instance.Destroy

	self._props = {
		ClassName = className,
		Name = className,
		Parent = nil,
		Children = {},
		NetworkId = nil,
		UniqueId = generateUniqueId(),
	}

	return setmetatable(self, instance_mt)
end

-- Utility methods
function Instance:GetProperties()
	return rawget(self, "_props")
end

function Instance:SetProperty(name, value)
	self[name] = value -- triggers __newindex
end

function Instance:FindFirstChild(name)
	for _, child in ipairs(self.Children) do
		if child.Name == name then
			return child
		end
	end
	return nil
end

function Instance:FindFirstAncestor(className)
	local ancestor = self.Parent
	while ancestor do
		if ancestor.ClassName == className then
			return ancestor
		end
		ancestor = ancestor.Parent
	end
	return nil
end

function Instance:GetChildrenOfClass(className)
	local children = {}
	for _, child in pairs(self.Children) do
		if child.ClassName == className then
			table.insert(children, child)
		end
	end
	return children
end

function Instance:FindFirstChildOfClass(className)
	for _, child in ipairs(self.Children) do
		if child.ClassName == className then
			return child
		end
	end
	return nil
end

function Instance:GetChildren()
	local copy = {}
	for i, child in ipairs(self.Children) do
		copy[i] = child
	end
	return copy
end

function Instance:GetDescendants()
	local result = {}

	local function scan(obj)
		for _, child in ipairs(obj.Children) do
			table.insert(result, child)
			scan(child)
		end
	end

	scan(self)
	return result
end

function Instance:IsA(className)
	return self.ClassName == className or self.BaseClass == className
end

function Instance:Clone(keepUniqueId)
	local root = Instance.new(self.ClassName)

	local srcProps = rawget(self, "_props")
	local dstProps = rawget(root, "_props")
	for k, v in pairs(srcProps) do
		if k ~= "Parent" and k ~= "Children" and (keepUniqueId or k ~= "UniqueId") then
			dstProps[k] = v
			rawset(root, k, v)
		end
	end

	for k, v in pairs(self.tags) do
		root.tags[k] = v
	end
	for k, v in pairs(self.attributes) do
		root.attributes[k] = v
	end

	local queue = { { src = self, dst = root } }
	local head = 1

	while head <= #queue do
		local pair = queue[head]
		head = head + 1

		local srcChildren = rawget(pair.src, "Children")
		local dstParent = pair.dst

		for _, child in ipairs(srcChildren) do
			local copy = Instance.new(child.ClassName)

			local cSrcProps = rawget(child, "_props")
			local cDstProps = rawget(copy, "_props")
			for k, v in pairs(cSrcProps) do
				if k ~= "Parent" and k ~= "Children" and (keepUniqueId or k ~= "UniqueId") then
					cDstProps[k] = v
					rawset(copy, k, v)
				end
			end

			for k, v in pairs(child.tags) do
				copy.tags[k] = v
			end
			for k, v in pairs(child.attributes) do
				copy.attributes[k] = v
			end

			cDstProps.Parent = dstParent
			table.insert(rawget(dstParent, "Children"), copy)
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
			if k ~= "Parent" and k ~= "Children" and k ~= "UniqueId" then
				local baseVal = baseProps[k]
				-- only inherit if the live value differs from baseline (i.e. it was changed)
				if v ~= baseVal then
					dstProps[k] = v
					rawset(dst, k, v)
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
			if k ~= "Parent" and k ~= "Children" and k ~= "UniqueId" then
				dstProps[k] = v
				rawset(dst, k, v)
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
	for _, child in ipairs(self.Children) do
		child.Parent = nil
	end
	self.Children = {}
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
	for _, child in ipairs(self.Children) do
		if child.ClassName == className then
			return child
		end
	end

	if recursive then
		for _, child in ipairs(self.Children) do
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

function Instance:WaitForChild(name, timeout)
	timeout = timeout or 5
	local start = os.clock()

	local found = self:FindFirstChild(name)
	if found then
		return found
	end

	local connection
	local result = nil

	connection = self.ChildAdded:Connect(function(child)
		if child.Name == name then
			result = child
			connection:Disconnect()
		end
	end)

	while not result and os.clock() - start < timeout do
		task.wait(0)
	end

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
	local start = os.clock()

	local found = self:FindFirstChildOfClass(className)
	if found then
		return found
	end

	local connection
	local result = nil

	connection = self.ChildAdded:Connect(function(child)
		if child.ClassName == className then
			result = child
			connection:Disconnect()
		end
	end)

	while not result and os.clock() - start < timeout do
		task.wait(0)
	end

	if not result then
		error(("WaitForChildOfClass('%s') timed out"):format(className))
	end

	return result
end

function Instance:WaitForChildWhichIsA(className, timeout)
	timeout = timeout or 5
	local start = os.clock()

	local found = self:FindFirstChildWhichIsA(className)
	if found then
		return found
	end

	local connection
	local result = nil

	connection = self.ChildAdded:Connect(function(child)
		if child.ClassName == className then
			result = child
			connection:Disconnect()
		end
	end)

	while not result and os.clock() - start < timeout do
		task.wait(0)
	end

	if not result then
		error(("WaitForChildWhichIsA('%s') timed out"):format(className))
	end

	return result
end

function Instance:GetChildrenCount()
	return #self.Children
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
		for i = #self.Children, 1, -1 do
			if self.Children[i].ClassName == className then
				self.Children[i]:Destroy()
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
	for _, child in ipairs(self.Parent.Children) do
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
	self.Children = {}
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
		local filters = {}

		-- Split by comma for multiple independent selectors
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

		-- Handle different value types
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
				-- ClassName
				local className = sel:match("^([%w_]+)", pos)
				if className and not sel:sub(pos - 1, pos - 1):match("[#%.$[]") then
					if not matchClassName(inst, className) then
						return false
					end
					pos = pos + #className

				-- .Tag
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

				-- #Name
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

				-- [property = value] or [$attribute = value]
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
					for _, child in ipairs(inst.Children) do
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
	for _, child in ipairs(rawget(self, "Children") or {}) do
		children[#children + 1] = child
	end

	rawset(self, "Children", {})

	for _, child in ipairs(children) do
		rawset(child, "_skipParentRemoval", true)
		child:Destroy()
	end

	local props = rawget(self, "_props")
	if props and props.Parent and not rawget(self, "_skipParentRemoval") then
		local parentChildren = rawget(props.Parent, "Children")
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
end

return Instance
