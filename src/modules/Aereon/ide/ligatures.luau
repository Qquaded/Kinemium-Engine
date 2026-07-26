local ligaturesModule = {}

-- Programming ligatures mapping (customizable)
ligaturesModule.ligatures = {
	-- Comparison operators
	["!="] = "≠",
	["<="] = "≤",
	[">="] = "≥",
	["=="] = "≡",
	["==="] = "≣",
	["!=="] = "≢",
	-- Arrow operators
	["->"] = "→",
	["<-"] = "←",
	["=>"] = "⇒",
	["<="] = "⇐",
	["-->"] = "⟶",
	["<--"] = "⟵",
	["==>"] = "⟹",
	["<=="] = "⟸",
	-- Logical operators
	["&&"] = "∧",
	["||"] = "∨",
	["!"] = "¬",
	-- Bitwise operators
	["<<"] = "≪",
	[">>"] = "≫",
	["<<<"] = "⋘",
	[">>>"] = "⋙",
	-- Increment/decrement
	["++"] = "⧺",
	["--"] = "⧻",
	-- Other operators
	["~="] = "≈",
	["~~"] = "≋",
	["..."] = "…",
	["::"] = "∷",
	[":::"] = "⋮",
	["///"] = "∕",
	["/*"] = "∗",
	["*/"] = "∗",
	["<>"] = "⟂",
	["<=>"] = "⇔",
	["<->"] = "↔",
	["<-->"] = "⟷",
}

local sortedPatterns = {}
for p in pairs(ligaturesModule.ligatures) do
	table.insert(sortedPatterns, p)
end
table.sort(sortedPatterns, function(a, b)
	return #a > #b
end)

-- Split text into segments for ligature rendering
function ligaturesModule.splitIntoSegments(text, enabled)
	if not enabled then
		return { { type = "text", content = text } }
	end
	local segments = {}
	local start = 1
	local i = 1
	while i <= #text do
		local matched = false
		for _, pattern in ipairs(sortedPatterns) do
			if text:sub(i, i + #pattern - 1) == pattern then
				if i > start then
					table.insert(segments, { type = "text", content = text:sub(start, i - 1) })
				end
				table.insert(segments, { type = "ligature", content = pattern })
				i = i + #pattern
				start = i
				matched = true
				break
			end
		end
		if not matched then
			i = i + 1
		end
	end
	if start <= #text then
		table.insert(segments, { type = "text", content = text:sub(start) })
	end
	return segments
end

function ligaturesModule.measureLigature(rl, ligature, fontSize, spacing, vend)
	local unicode = ligaturesModule.ligatures[ligature]
	if unicode then
		return adapter.MeasureTextEx(vend, unicode, fontSize, spacing).x
	end

	-- fallback: measure raw text
	return adapter.MeasureTextEx(vend, ligature, fontSize, spacing).x
end

-- Draw a ligature manually using raylib shapes
function ligaturesModule.drawLigature(rl, ligature, x, y, fontSize, spacing, color, vend)
	if ligature == "->" then
		-- Draw "-" text
		adapter.DrawTextEx(vend, "-", vector.create(x, y), fontSize, spacing, color)
		local dashWidth = adapter.MeasureTextEx(vend, "-", fontSize, spacing).x
		-- Draw > as two lines
		local arrowX = x + dashWidth
		local arrowY = y + fontSize / 2
		local arrowSize = fontSize * 0.4
		adapter.DrawLineEx(
			vector.create(arrowX, arrowY - arrowSize / 2),
			vector.create(arrowX + arrowSize, arrowY),
			1,
			color
		)
		adapter.DrawLineEx(
			vector.create(arrowX, arrowY + arrowSize / 2),
			vector.create(arrowX + arrowSize, arrowY),
			1,
			color
		)
		return dashWidth + arrowSize
	elseif ligature == "!=" then
		-- Draw "!" and "=" text
		adapter.DrawTextEx(vend, "!", vector.create(x, y), fontSize, spacing, color)
		local bangWidth = adapter.MeasureTextEx(vend, "!", fontSize, spacing).x
		adapter.DrawTextEx(vend, "=", vector.create(x + bangWidth, y), fontSize, spacing, color)
		local eqWidth = adapter.MeasureTextEx(vend, "=", fontSize, spacing).x
		-- Draw slash through =
		local slashX1 = x + bangWidth
		local slashX2 = x + bangWidth + eqWidth
		local slashY = y + fontSize / 2
		adapter.DrawLineEx(
			vector.create(slashX1, slashY - fontSize * 0.3),
			vector.create(slashX2, slashY + fontSize * 0.3),
			1,
			color
		)
		return bangWidth + eqWidth
	elseif ligature == "<=" then
		-- Draw "<" and "=" text
		adapter.DrawTextEx(vend, "<", vector.create(x, y), fontSize, spacing, color)
		local lessWidth = adapter.MeasureTextEx(vend, "<", fontSize, spacing).x
		adapter.DrawTextEx(vend, "=", vector.create(x + lessWidth, y), fontSize, spacing, color)
		local eqWidth = adapter.MeasureTextEx(vend, "=", fontSize, spacing).x
		return lessWidth + eqWidth
	elseif ligature == ">=" then
		-- Draw ">" and "=" text
		adapter.DrawTextEx(vend, ">", vector.create(x, y), fontSize, spacing, color)
		local greaterWidth = adapter.MeasureTextEx(vend, ">", fontSize, spacing).x
		adapter.DrawTextEx(vend, "=", vector.create(x + greaterWidth, y), fontSize, spacing, color)
		local eqWidth = adapter.MeasureTextEx(vend, "=", fontSize, spacing).x
		return greaterWidth + eqWidth
	else
		-- Fallback: draw as Unicode if available, else as text
		local unicode = ligaturesModule.ligatures[ligature]
		if unicode then
			adapter.DrawTextEx(vend, unicode, vector.create(x, y), fontSize, spacing, color)
			return adapter.MeasureTextEx(vend, unicode, fontSize, spacing).x
		else
			adapter.DrawTextEx(vend, ligature, vector.create(x, y), fontSize, spacing, color)
			return adapter.MeasureTextEx(vend, ligature, fontSize, spacing).x
		end
	end
end

function ligaturesModule.measureTextWidth(text, fontSize, spacing, ligaturesEnabled, rl, vend)
	if #text == 0 then
		return 0
	end
	local segments = ligaturesModule.splitIntoSegments(text, ligaturesEnabled)
	local totalWidth = 0
	for _, segment in ipairs(segments) do
		if segment.type == "text" then
			totalWidth += adapter.MeasureTextEx(vend, segment.content, fontSize, spacing).x
		elseif segment.type == "ligature" then
			totalWidth += ligaturesModule.measureLigature(rl, segment.content, fontSize, spacing, vend)
		end
	end
	return totalWidth
end

return ligaturesModule
