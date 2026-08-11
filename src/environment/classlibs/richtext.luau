local Color3 = require("@Color3")
local Enum = require("@EnumMap")
local adapter = require("@RaylibAdapter")
local lib = adapter.lib
local arect = require("@arect")

local RichText = {}

local UTF8_CHAR_PATTERN = utf8 and utf8.charpattern or "."
local TRUNCATE_WINDOW = 20

local function clamp01(value)
	if value < 0 then
		return 0
	end
	if value > 1 then
		return 1
	end
	return value
end

local textureCache = {}

local function getTexture(path)
	if textureCache[path] then
		return textureCache[path]
	end
	local tex = lib.LoadTexture(path)
	textureCache[path] = tex

	return tex
end

-- Inline symbol tag syntax: <image:path/to/img.png,size:50,50>
local function parseInlineSymbols(text)
	-- Returns a list of "chunks": { type="text", content=str } or { type="image", path=str, w=N, h=N }
	local chunks = {}
	local pos = 1
	while pos <= #text do
		local s, e, inner = text:find("<([^<>]+)>", pos)
		if not s then
			local tail = text:sub(pos)
			if tail ~= "" then
				chunks[#chunks + 1] = { type = "text", content = tail }
			end
			break
		end
		if s > pos then
			chunks[#chunks + 1] = { type = "text", content = text:sub(pos, s - 1) }
		end
		-- Try to match known symbol types
		local path, w, h = inner:match("^image:(.+),size:(%d+),(%d+)$")
		if path then
			chunks[#chunks + 1] = { type = "image", path = path, w = tonumber(w), h = tonumber(h) }
		else
			-- Unknown tag — treat as literal text
			chunks[#chunks + 1] = { type = "text", content = "<" .. inner .. ">" }
		end
		pos = e + 1
	end
	return chunks
end

local function combineTransparency(baseTransparency, extraTransparency)
	local a = clamp01(baseTransparency or 0)
	local b = clamp01(extraTransparency or 0)
	return 1 - ((1 - a) * (1 - b))
end

local function applyTruncate(text, mode)
	if mode == Enum.TextTruncate.None then
		return text
	end
	if mode == Enum.TextTruncate.Head then
		return #text <= 3 and "..." or "..." .. text:sub(#text - TRUNCATE_WINDOW)
	elseif mode == Enum.TextTruncate.Tail then
		return #text <= 3 and "..." or text:sub(1, TRUNCATE_WINDOW) .. "..."
	end
	return text
end

local function decodeEntities(text)
	return text:gsub("&lt;", "<"):gsub("&gt;", ">"):gsub("&quot;", '"'):gsub("&apos;", "'"):gsub("&amp;", "&")
end

local function cloneStyle(style)
	return {
		color = style.color,
		transparency = style.transparency,
		size = style.size,
		fontName = style.fontName,
		bold = style.bold,
		italic = style.italic,
		underline = style.underline,
	}
end

local function resolveColor3(c, transparency)
	if c then
		if c.ToRaylib then
			return c:ToRaylib(transparency)
		elseif c.R and c.G and c.B then
			return adapter.structs.Color:new({
				r = math.clamp(math.floor(c.R * 255 + 0.5), 0, 255),
				g = math.clamp(math.floor(c.G * 255 + 0.5), 0, 255),
				b = math.clamp(math.floor(c.B * 255 + 0.5), 0, 255),
				a = math.clamp(math.floor((1 - (transparency or 0)) * 255 + 0.5), 0, 255),
			})
		end
	end
	return adapter.structs.Color:new({
		r = 255,
		g = 255,
		b = 255,
		a = math.clamp(math.floor((1 - (transparency or 0)) * 255 + 0.5), 0, 255),
	})
end

local function parseColorString(value, fallback)
	if type(value) ~= "string" then
		return fallback
	end

	local trimmed = value:match("^%s*(.-)%s*$")
	if not trimmed or trimmed == "" then
		return fallback
	end

	local stripped = trimmed:gsub("%s+", "")
	if stripped:sub(1, 1) == "#" then
		local success, parsed = pcall(Color3.fromHex, stripped)
		if success then
			return parsed
		end
	end

	local r, g, b = stripped:match("^rgb%((%d+),(%d+),(%d+)%)$")
	if r and g and b then
		return Color3.fromRGB(
			math.clamp(tonumber(r), 0, 255),
			math.clamp(tonumber(g), 0, 255),
			math.clamp(tonumber(b), 0, 255)
		)
	end

	return fallback
end

local function parseTagAttributes(text)
	local attributes = {}
	for key, _, value in text:gmatch("([%w_%-]+)%s*=%s*([\"'])(.-)%2") do
		attributes[string.lower(key)] = value
	end
	for key, value in text:gmatch("([%w_%-]+)%s*=%s*([^%s\"'>/]+)") do
		local normalized = string.lower(key)
		if attributes[normalized] == nil then
			attributes[normalized] = value
		end
	end
	return attributes
end

local function takeFirstGraphemes(text, maxCount)
	if maxCount < 0 then
		return text, 0
	end

	local graphemeCount = 0
	local output = {}
	for grapheme in text:gmatch(UTF8_CHAR_PATTERN) do
		if graphemeCount >= maxCount then
			break
		end
		graphemeCount += 1
		output[graphemeCount] = grapheme
	end
	return table.concat(output), graphemeCount
end

local function clipTextByGraphemes(text, maxCount)
	if maxCount == nil or maxCount < 0 then
		return text
	end
	local clipped = takeFirstGraphemes(text, maxCount)
	return clipped
end

local function clipRunsByGraphemes(runs, maxCount)
	if maxCount == nil or maxCount < 0 then
		return runs
	end

	local remaining = maxCount
	local output = {}
	for _, run in ipairs(runs) do
		if remaining <= 0 then
			break
		end
		local clippedText, consumed = takeFirstGraphemes(run.text, remaining)
		if clippedText ~= "" then
			table.insert(output, {
				text = clippedText,
				style = cloneStyle(run.style),
			})
		end
		remaining -= consumed
	end

	if #output == 0 then
		table.insert(output, {
			text = "",
			style = cloneStyle(runs[1].style),
		})
	end

	return output
end

local function parseRichTextRuns(rawText, baseStyle)
	local text = tostring(rawText or "")
	local runs = {}
	local stack = {
		{
			tag = "__root__",
			style = cloneStyle(baseStyle),
		},
	}

	local function currentStyle()
		return stack[#stack].style
	end

	local function pushText(chunk)
		if chunk == "" then
			return
		end
		local decoded = decodeEntities(chunk)
		if decoded == "" then
			return
		end
		table.insert(runs, {
			text = decoded,
			style = cloneStyle(currentStyle()),
		})
	end

	local cursor = 1
	while true do
		local startPos, endPos, token = text:find("<([^<>]-)>", cursor)
		if not startPos then
			break
		end

		if startPos > cursor then
			pushText(text:sub(cursor, startPos - 1))
		end

		local tagText = token:match("^%s*(.-)%s*$") or ""
		local isClosing = tagText:sub(1, 1) == "/"
		local isSelfClosing = tagText:sub(-1) == "/"

		if isClosing then
			tagText = tagText:sub(2)
		end
		if isSelfClosing then
			tagText = tagText:sub(1, -2)
		end

		tagText = tagText:match("^%s*(.-)%s*$") or ""
		local tagName, rest = tagText:match("^([%w]+)%s*(.-)$")
		tagName = tagName and string.lower(tagName) or ""

		if tagName == "br" then
			table.insert(runs, {
				text = "\n",
				style = cloneStyle(currentStyle()),
			})
		elseif isClosing then
			for index = #stack, 2, -1 do
				if stack[index].tag == tagName then
					while #stack >= index do
						table.remove(stack)
					end
					break
				end
			end
		elseif
			tagName == "b"
			or tagName == "i"
			or tagName == "u"
			or tagName == "s"
			or tagName == "strike"
			or tagName == "font"
		then
			local nextStyle = cloneStyle(currentStyle())

			if tagName == "b" then
				nextStyle.bold = true
			elseif tagName == "i" then
				nextStyle.italic = true
			elseif tagName == "u" then
				nextStyle.underline = true
			elseif tagName == "s" or tagName == "strike" then
				nextStyle.strike = true
			elseif tagName == "font" then
				local attributes = parseTagAttributes(rest or "")
				local colorValue = attributes.color
				local transparencyValue = attributes.transparency
				local sizeValue = attributes.size
				local faceValue = attributes.face or attributes.font

				if colorValue then
					nextStyle.color = parseColorString(colorValue, nextStyle.color)
				end
				if transparencyValue then
					local parsedTransparency = tonumber(transparencyValue)
					if parsedTransparency ~= nil then
						nextStyle.transparency = clamp01(parsedTransparency)
					end
				end
				if sizeValue then
					local parsedSize = tonumber(sizeValue)
					if parsedSize ~= nil and parsedSize > 0 then
						nextStyle.size = parsedSize
					end
				end
				if faceValue then
					nextStyle.fontName = faceValue
				end
			end

			table.insert(stack, {
				tag = tagName,
				style = nextStyle,
			})

			if isSelfClosing then
				table.remove(stack)
			end
		end

		cursor = endPos + 1
	end

	if cursor <= #text then
		pushText(text:sub(cursor))
	end

	if #runs == 0 then
		table.insert(runs, {
			text = "",
			style = cloneStyle(baseStyle),
		})
	end

	return runs
end

local function appendSegmentToLine(line, segment)
	local last = line.segments[#line.segments]
	if
		last
		and last.font == segment.font
		and last.size == segment.size
		and last.color == segment.color
		and last.transparency == segment.transparency
		and last.bold == segment.bold
		and last.italic == segment.italic
		and last.underline == segment.underline
		and last.strike == segment.strike
	then
		last.text = last.text .. segment.text
		last.width += segment.width
	else
		table.insert(line.segments, segment)
	end

	line.width += segment.width
	if segment.size > line.maxSize then
		line.maxSize = segment.size
	end
end

local function buildLayout(object, runs, frameSize, spacing, renderer, fallbackFont, scale)
	scale = scale or 1

	local wrapEnabled = object.TextWrapped == true and frameSize.X > 0
	local lineHeightMultiplier = object.LineHeight or 1
	local lines = {
		{
			segments = {},
			width = 0,
			maxSize = 0,
			height = 0,
		},
	}

	local fontCache = {}
	local measureCache = object._measureCache or {}
	local measureCacheCount = object._measureCacheCount or 0

	local function resolveFont(fontName)
		if not fontName or fontName == "" then
			return fallbackFont
		end
		if fontCache[fontName] ~= nil then
			return fontCache[fontName]
		end
		local resolved = renderer.Font.Get(fontName) or fallbackFont
		fontCache[fontName] = resolved
		return resolved
	end

	local function measureText(font, text, fontSize)
		if text == "" then
			return 0
		end

		local key = tostring(font) .. "|" .. tostring(fontSize) .. "|" .. tostring(spacing) .. "|" .. text
		local cached = measureCache[key]
		if cached ~= nil then
			return cached
		end

		local width = lib.MeasureTextEx(font, text, fontSize, spacing).x
		measureCache[key] = width
		measureCacheCount += 1

		if measureCacheCount > 8192 then
			table.clear(measureCache)
			measureCacheCount = 0
		end

		return width
	end

	local function pushLine()
		table.insert(lines, {
			segments = {},
			width = 0,
			maxSize = 0,
			height = 0,
		})
	end

	local function splitTokenToFit(token, style, font, fontSize)
		local currentChunk = ""
		local currentWidth = 0

		for grapheme in token:gmatch(UTF8_CHAR_PATTERN) do
			local graphemeWidth = measureText(font, grapheme, fontSize)
			local line = lines[#lines]

			if wrapEnabled and line.width > 0 and (line.width + currentWidth + graphemeWidth) > frameSize.X then
				if currentChunk ~= "" then
					appendSegmentToLine(line, {
						text = currentChunk,
						width = currentWidth,
						font = font,
						size = fontSize,
						color = style.color,
						transparency = style.transparency,
						bold = style.bold,
						italic = style.italic,
						underline = style.underline,
						strike = style.strike,
					})
					currentChunk = ""
					currentWidth = 0
				end
				pushLine()
				line = lines[#lines]
			end

			currentChunk = currentChunk .. grapheme
			currentWidth += graphemeWidth
		end

		if currentChunk ~= "" then
			appendSegmentToLine(lines[#lines], {
				text = currentChunk,
				width = currentWidth,
				font = font,
				size = fontSize,
				color = style.color,
				transparency = style.transparency,
				bold = style.bold,
				italic = style.italic,
				underline = style.underline,
				strike = style.strike,
			})
		end
	end

	local function appendTextChunk(chunk, style)
		if chunk == "" then
			return
		end

		local fontSize = math.max(1, (style.size or object.TextSize) * scale)
		local font = resolveFont(style.fontName)

		if not wrapEnabled then
			appendSegmentToLine(lines[#lines], {
				text = chunk,
				width = measureText(font, chunk, fontSize),
				font = font,
				size = fontSize,
				color = style.color,
				transparency = style.transparency,
				bold = style.bold,
				italic = style.italic,
				underline = style.underline,
				strike = style.strike,
			})
			return
		end

		local index = 1
		local chunkLength = #chunk
		while index <= chunkLength do
			local isWhitespace = chunk:sub(index, index):match("%s") ~= nil
			local nextIndex = index + 1
			while nextIndex <= chunkLength do
				local nextWhitespace = chunk:sub(nextIndex, nextIndex):match("%s") ~= nil
				if nextWhitespace ~= isWhitespace then
					break
				end
				nextIndex += 1
			end

			local token = chunk:sub(index, nextIndex - 1)
			index = nextIndex

			if token == "" then
				continue
			end

			local currentLine = lines[#lines]
			if isWhitespace and currentLine.width <= 0 then
				continue
			end

			local tokenWidth = measureText(font, token, fontSize)
			if currentLine.width > 0 and (currentLine.width + tokenWidth) > frameSize.X then
				if not isWhitespace then
					pushLine()
					currentLine = lines[#lines]
				end
			end

			if tokenWidth <= frameSize.X then
				appendSegmentToLine(currentLine, {
					text = token,
					width = tokenWidth,
					font = font,
					size = fontSize,
					color = style.color,
					transparency = style.transparency,
					bold = style.bold,
					italic = style.italic,
					underline = style.underline,
					strike = style.strike,
				})
			else
				splitTokenToFit(token, style, font, fontSize)
			end
		end
	end

	local function appendSymbolChunk(symChunk)
		local seg = {
			type = "image",
			path = symChunk.path,
			width = symChunk.w,
			size = symChunk.h, -- height stored in .size so line.maxSize math still works
		}
		local line = lines[#lines]
		if wrapEnabled and line.width > 0 and (line.width + seg.width) > frameSize.X then
			pushLine()
			line = lines[#lines]
		end
		appendSegmentToLine(line, seg)
	end

	for _, run in ipairs(runs) do
		local subChunks = parseInlineSymbols(run.text)

		for _, chunk in ipairs(subChunks) do
			if chunk.type == "image" then
				appendSymbolChunk(chunk)
			else
				local runText = chunk.content
				local startIndex = 1
				while true do
					local newlineIndex = runText:find("\n", startIndex, true)
					if newlineIndex then
						appendTextChunk(runText:sub(startIndex, newlineIndex - 1), run.style)
						pushLine()
						startIndex = newlineIndex + 1
						if startIndex > #runText then
							break
						end
					else
						appendTextChunk(runText:sub(startIndex), run.style)
						break
					end
				end
			end
		end
	end
	local maxWidth = 0
	local totalHeight = 0
	local fallbackSize = math.max(1, object.TextSize * scale)
	for _, line in ipairs(lines) do
		if line.maxSize <= 0 then
			line.maxSize = fallbackSize
		end
		line.height = line.maxSize * lineHeightMultiplier
		totalHeight += line.height
		if line.width > maxWidth then
			maxWidth = line.width
		end
	end

	object._measureCache = measureCache
	object._measureCacheCount = measureCacheCount

	return {
		lines = lines,
		totalHeight = totalHeight,
		maxWidth = maxWidth,
		scale = scale,
	}
end

function RichText.GetLayout(object, frameSize, renderer, fallbackFont)
	local spacing = object.TextSpacing or 0
	local objectFont = object.Font
	local baseFontName
	if type(objectFont) == "table" and objectFont.Name then
		baseFontName = objectFont.Name
	elseif type(objectFont) == "string" then
		baseFontName = objectFont
	else
		baseFontName = Enum.Font.DefaultEngineFont and Enum.Font.DefaultEngineFont.Name or "DefaultEngineFont"
	end
	local resolvedFont = renderer.Font.Get(baseFontName) or fallbackFont
	local baseStyle = {
		color = object.TextColor3,
		transparency = 0,
		size = object.TextSize,
		fontName = baseFontName,
		bold = false,
		italic = false,
		underline = false,
		strike = false,
	}

	object._layoutCache = object._layoutCache or {}
	local cache = object._layoutCache
	local cacheInvalid = cache.text ~= object.Text
		or cache.richText ~= object.RichText
		or cache.baseFontName ~= baseFontName
		or cache.textSize ~= object.TextSize
		or cache.textColor ~= object.TextColor3
		or cache.textTransparency ~= object.TextTransparency
		or cache.spacing ~= spacing
		or cache.lineHeight ~= object.LineHeight
		or cache.wrap ~= object.TextWrapped
		or cache.truncate ~= object.TextTruncate
		or cache.scaled ~= object.TextScaled
		or cache.maxVisibleGraphemes ~= object.MaxVisibleGraphemes
		or cache.frameWidth ~= frameSize.X
		or cache.frameHeight ~= frameSize.Y

	if cacheInvalid then
		local runs
		if object.RichText then
			runs = parseRichTextRuns(object.Text, baseStyle)
			runs = clipRunsByGraphemes(runs, object.MaxVisibleGraphemes)
		else
			local plainText = clipTextByGraphemes(tostring(object.Text or ""), object.MaxVisibleGraphemes)
			if object.TextWrapped ~= true then
				plainText = applyTruncate(plainText, object.TextTruncate)
			end
			runs = {
				{
					text = plainText,
					style = cloneStyle(baseStyle),
				},
			}
		end

		local layout = buildLayout(object, runs, frameSize, spacing, renderer, resolvedFont, 1)
		if object.TextScaled then
			local scaleX = layout.maxWidth > 0 and (frameSize.X / layout.maxWidth) or 1
			local scaleY = layout.totalHeight > 0 and (frameSize.Y / layout.totalHeight) or 1
			local scale = math.min(scaleX, scaleY)
			if scale > 0 and scale ~= 1 then
				layout = buildLayout(object, runs, frameSize, spacing, renderer, resolvedFont, scale)
			end
		end

		cache.layout = layout
		cache.text = object.Text
		cache.richText = object.RichText
		cache.baseFontName = baseFontName
		cache.textSize = object.TextSize
		cache.textColor = object.TextColor3
		cache.textTransparency = object.TextTransparency
		cache.spacing = spacing
		cache.lineHeight = object.LineHeight
		cache.wrap = object.TextWrapped
		cache.truncate = object.TextTruncate
		cache.scaled = object.TextScaled
		cache.maxVisibleGraphemes = object.MaxVisibleGraphemes
		cache.frameWidth = frameSize.X
		cache.frameHeight = frameSize.Y
	end

	return cache.layout, spacing
end

function RichText.DrawLayout(drawLib, object, framePos, frameSize, layout, spacing)
	if not layout then
		return
	end

	local offsetY = 0
	if object.TextYAlignment == Enum.TextYAlignment.Center then
		offsetY = (frameSize.Y - layout.totalHeight) * 0.5
	elseif object.TextYAlignment == Enum.TextYAlignment.Bottom then
		offsetY = frameSize.Y - layout.totalHeight
	end

	local drawY = framePos.Y + offsetY
	local drawStroke = object.TextStrokeTransparency < 1
	for _, line in ipairs(layout.lines) do
		local lineOffsetX = 0
		if object.TextXAlignment == Enum.TextXAlignment.Center then
			lineOffsetX = (frameSize.X - line.width) * 0.5
		elseif object.TextXAlignment == Enum.TextXAlignment.Right then
			lineOffsetX = frameSize.X - line.width
		end

		local drawX = framePos.X + lineOffsetX
		for _, segment in ipairs(line.segments) do
			if segment.type == "image" then
				local tex = getTexture(segment.path)
				local declaredW = segment.width
				local declaredH = segment.size

				local imgY = drawY + (line.height - declaredH) * 0.5

				-- Read texture dimensions from buffer struct
				local texW = buffer.readi32(tex, 4)
				local texH = buffer.readi32(tex, 8)

				local srcRect = arect.new(0, 0, texW, texH)
				local dstRect = arect.new(drawX, imgY, declaredW, declaredH)

				drawLib.DrawTexturePro(
					tex,
					srcRect.rect,
					dstRect.rect,
					vector.create(0, 0),
					0,
					Color3.new(1, 1, 1):ToRaylib(object.TextTransparency)
				)
				drawX += declaredW
				continue
			end

			local segmentTransparency = combineTransparency(object.TextTransparency, segment.transparency)
			if segmentTransparency < 1 then
				if not segment then
					continue
				end
				if not segment.font then
					continue
				end
				if not segment.text then
					continue
				end
				if not segment.size then
					continue
				end

				local segmentColor = resolveColor3(segment.color, segmentTransparency)

				if drawStroke then
					local strokeTransparency = combineTransparency(segmentTransparency, object.TextStrokeTransparency)
					if strokeTransparency < 1 then
						local strokeColor = resolveColor3(object.TextStrokeColor, strokeTransparency)
						drawLib.DrawTextEx(
							segment.font,
							segment.text,
							vector.create(drawX - 1, drawY),
							segment.size,
							spacing,
							strokeColor
						)
						drawLib.DrawTextEx(
							segment.font,
							segment.text,
							vector.create(drawX + 1, drawY),
							segment.size,
							spacing,
							strokeColor
						)
						drawLib.DrawTextEx(
							segment.font,
							segment.text,
							vector.create(drawX, drawY - 1),
							segment.size,
							spacing,
							strokeColor
						)
						drawLib.DrawTextEx(
							segment.font,
							segment.text,
							vector.create(drawX, drawY + 1),
							segment.size,
							spacing,
							strokeColor
						)
					end
				end

				drawLib.DrawTextEx(
					segment.font,
					segment.text,
					vector.create(drawX, drawY),
					segment.size,
					spacing,
					segmentColor
				)

				if segment.bold then
					drawLib.DrawTextEx(
						segment.font,
						segment.text,
						vector.create(drawX + 1, drawY),
						segment.size,
						spacing,
						segmentColor
					)
				end

				if segment.underline or segment.strike then
					local lineThickness = math.max(1, math.floor((segment.size * 0.08) + 0.5))
					if segment.underline then
						local underlineY = drawY + segment.size
						drawLib.DrawRectangle(
							math.floor(drawX),
							math.floor(underlineY),
							math.max(1, math.floor(segment.width + 0.5)),
							lineThickness,
							segmentColor
						)
					end
					if segment.strike then
						local strikeY = drawY + (segment.size * 0.55)
						drawLib.DrawRectangle(
							math.floor(drawX),
							math.floor(strikeY),
							math.max(1, math.floor(segment.width + 0.5)),
							lineThickness,
							segmentColor
						)
					end
				end
			end

			drawX += segment.width
		end

		drawY += line.height
	end
end

return RichText
