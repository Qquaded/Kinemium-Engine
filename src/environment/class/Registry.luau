local _filesystem = require("../../modules/filesystem")
local Instance = require("../class/Instance")
local datatypes = require("../datatypes/getDatatypes")
local zembed = require("@zembed")
local Enum = require("@Enum")

local registry = {}
local listOfClasses = {}
local created = setmetatable({}, { __mode = "v" })
local kilang = require("@Kilang")
local entries = {}

if zembed.IsEmbedded() then
	entries = zembed.GetScriptsThatHas([[class\list]])
else
	entries = zune.fs.entries("./src/environment/class/list")
end

local createClassesStart = os.clock()
for _, entry in pairs(entries) do
	local createClassStart = os.clock()
	local requirePath
	local source
	if zembed.IsEmbedded() then
		local name = zune.fs.path.basename(entry)
		local full = "./list/" .. name
		requirePath = string.gsub(entry, ".luau", "")
	else
		requirePath = "./src/environment/class/list/" .. entry.name
	end
	source = zune.fs.readFile(requirePath)

	local r, s, returned = kilang:execute(source, {
		SecurityCapabilities = Enum.SecurityCapabilities.Internals,
		StackId = requirePath,
	})

	if not s then
		print(r, s)
		continue
	end

	local initTime = (os.clock() - createClassStart) * 1000

	-- returned = { class = "Part", callback = function(Part) ... end }

	if not returned then
		_G.warn(`CLASS: Failed to load {entry.name}: {s} {r}`)
	else
		if not returned then
			print("Skipped: ", returned)
			continue
		end
		listOfClasses[returned.class] = returned

		_G.log(
			string.format(
				"CLASS: Successfully created class '%s' in %.3fms from file (required in %.3fms): %s",
				returned.class,
				(os.clock() - createClassStart) * 1000,
				initTime,
				requirePath
			)
		)
	end
end
_G.log(string.format("CLASS: Created all classes in %.3fms", (os.clock() - createClassesStart) * 1000))

function registry.createclass(data)
	listOfClasses[data.class] = data
	_G.log("Created class for " .. data.class)
end

function registry.getClasses()
	return listOfClasses
end

function registry.ClassValid(class)
	if listOfClasses[class] then
		return true
	else
		return false
	end
end

local function findClass(class)
	local found

	for _, looped_class in pairs(listOfClasses) do
		if looped_class.cover_up == class then
			found = looped_class
		elseif looped_class.class == class then
			found = looped_class
		end
	end

	return found
end

local function initializeInstance(instance, class, renderer, datamodel, allowReplacement)
	local found = findClass(class)
	if not found then
		return nil, "Class not found: " .. tostring(class)
	end

	rawset(instance, "_classContext", {
		renderer = renderer,
		datamodel = datamodel,
	})

	local success, result = pcall(function()
		return found.callback(instance, renderer, datamodel)
	end)
	if not success then
		return nil, result
	end

	if allowReplacement and result ~= nil and result ~= instance then
		rawset(result, "_classContext", {
			renderer = renderer,
			datamodel = datamodel,
		})
		return result
	end

	table.insert(created, instance)
	return instance
end

function registry.GetUnparentedInstances()
	for _, v in ipairs(created) do
		if v:IsA("Instance") and v.Parent == nil then
			return v
		end
	end
	return nil
end

function registry.new(class, renderer, datamodel, force)
	local found = findClass(class)

	if not found then
		return error("Class not found: " .. tostring(class))
	end
	if found.non_creatable and not force then
		return error("Class is non-creatable: " .. tostring(class))
	end

	local instance = Instance.new(class)
	local result, err = initializeInstance(instance, class, renderer, datamodel, true)
	if not result then
		_G.warn(`CLASS: Failed to create {class}: {err}`)
		table.insert(created, instance)
		return instance
	end
	if result ~= nil and result ~= instance then
		-- callback returned an existing singleton instance; do not register the new one
		return result
	end
	return instance
end

function registry.InitCallbackClass(clone, classname, renderer, datamodel)
	return initializeInstance(clone, classname, renderer, datamodel, false)
end

Instance.SetCloneInitializer(function(source, clone)
	local context = rawget(source, "_classContext")
	if not context then
		return
	end

	local _, err = initializeInstance(clone, source.ClassName, context.renderer, context.datamodel, false)
	if err then
		error(err, 0)
	end
end)

function registry.GetActiveInstances()
	return created
end

return registry
