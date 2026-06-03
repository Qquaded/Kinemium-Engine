local Instance = require("@Instance")
local signal = require("@Kinemium.signal")

local CollectionService = Instance.new("CollectionService")
CollectionService.ExplorerHidden = true

local objectTags = {} -- [object] = {tag1 = true, tag2 = true}
local tagObjects = {} -- [tag] = {object = true, ...}
local tagSignals = {} -- [tag] = {added = Signal, removed = Signal}
local allTags = {} -- [tag] = true

local function getOrCreateTagSignal(tag)
	if not tagSignals[tag] then
		tagSignals[tag] = {
			added = signal.new(),
			removed = signal.new(),
		}
	end
	return tagSignals[tag]
end

local function addTagToObject(object, tag)
	objectTags[object] = objectTags[object] or {}
	if objectTags[object][tag] then
		return
	end -- already has tag
	objectTags[object][tag] = true

	tagObjects[tag] = tagObjects[tag] or {}
	tagObjects[tag][object] = true

	allTags[tag] = true

	local signals = getOrCreateTagSignal(tag)
	signals.added:Fire(object)
end

local function removeTagFromObject(object, tag)
	if not objectTags[object] or not objectTags[object][tag] then
		return
	end
	objectTags[object][tag] = nil

	if tagObjects[tag] then
		tagObjects[tag][object] = nil
		if next(tagObjects[tag]) == nil then
			tagObjects[tag] = nil
			allTags[tag] = nil
		end
	end

	local signals = getOrCreateTagSignal(tag)
	signals.removed:Fire(object)
end

CollectionService.InitRenderer = function(renderer, renderer_signal, game)
	CollectionService:SetProperties({
		AddTag = addTagToObject,

		RemoveTag = removeTagFromObject,

		GetTags = function(object)
			local tags = {}
			if objectTags[object] then
				for tag in pairs(objectTags[object]) do
					table.insert(tags, tag)
				end
			end
			return tags
		end,

		GetAllTags = function()
			local tags = {}
			for tag in pairs(allTags) do
				table.insert(tags, tag)
			end
			return tags
		end,

		GetTagged = function(tag)
			local objs = {}
			if tagObjects[tag] then
				for obj in pairs(tagObjects[tag]) do
					table.insert(objs, obj)
				end
			end
			return objs
		end,

		HasTag = function(object, tag)
			return objectTags[object] and objectTags[object][tag] == true or false
		end,

		GetInstanceAddedSignal = function(tag)
			return getOrCreateTagSignal(tag).added
		end,

		GetInstanceRemovedSignal = function(tag)
			return getOrCreateTagSignal(tag).removed
		end,
	})
end

return CollectionService
