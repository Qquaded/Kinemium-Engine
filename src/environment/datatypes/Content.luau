local Content = {}
Content.__index = Content

local ContentSourceType = {
	None = "None",
	Uri = "Uri",
	Object = "Object",
	Opaque = "Opaque",
}

local function new(sourceType, value)
	return setmetatable({
		SourceType = sourceType,
		Uri = sourceType == ContentSourceType.Uri and value or nil,
		Object = sourceType == ContentSourceType.Object and value or nil,
		Opaque = sourceType == ContentSourceType.Opaque and value or nil,
	}, Content)
end

Content.none = new(ContentSourceType.None)

function Content.fromUri(uri)
	assert(type(uri) == "string", "uri must be a string")

	if uri == "" then
		return Content.none
	end

	return new(ContentSourceType.Uri, uri)
end

function Content.fromAssetId(assetId)
	assert(type(assetId) == "number", "assetId must be a number")
	assert(assetId == assetId and assetId ~= math.huge and assetId ~= -math.huge, "assetId must be finite")

	if assetId == 0 then
		return Content.none
	end

	return Content.fromUri("kineasset://" .. tostring(assetId))
end

function Content.fromObject(object)
	assert(object ~= nil, "object cannot be nil")

	return new(ContentSourceType.Object, object)
end

function Content:IsNone()
	return self.SourceType == ContentSourceType.None
end

function Content:ToTable()
	if self.SourceType == "Uri" then
		return {
			type = "Content",
			SourceType = "Uri",
			Uri = self.Uri,
		}
	elseif self.SourceType == "Object" then
		return {
			type = "Content",
			SourceType = "Object",
			-- NOTE: Object cannot be safely serialized
			Object = nil,
		}
	elseif self.SourceType == "Opaque" then
		return {
			type = "Content",
			SourceType = "Opaque",
			Opaque = self.Opaque,
		}
	end

	return {
		type = "Content",
		SourceType = "None",
	}
end

function Content.FromTable(tbl)
	assert(tbl.type == "Content", "invalid type")
	assert(tbl.SourceType ~= nil, "missing SourceType")

	if tbl.SourceType == "Uri" then
		return Content.fromUri(tbl.Uri or "")
	elseif tbl.SourceType == "Object" then
		-- can't restore real object across serialization safely
		return Content.none
	elseif tbl.SourceType == "Opaque" then
		return Content.fromOpaque and Content.fromOpaque(tbl.Opaque) or Content.none
	end

	return Content.none
end

function Content:__tostring()
	if self.SourceType == ContentSourceType.Uri then
		return self.Uri
	elseif self.SourceType == ContentSourceType.Object then
		return "<Content Object>"
	elseif self.SourceType == ContentSourceType.Opaque then
		return "<Content Opaque>"
	end

	return "<Content None>"
end

Content.ContentSourceType = ContentSourceType

return Content
