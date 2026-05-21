local raylib = require("@raylib")

local structs = raylib.structs

local rect = require("@arect")

local color3 = require("@Color3")

local textButton = require("./textButton")

local effects = require("./effects")

--  modern palette

local C = {

	pageBg = color3.new(0.04, 0.04, 0.05),

	headerBg = color3.new(0.08, 0.08, 0.10),

	panelBg = color3.new(0.08, 0.08, 0.10),

	sidebarBg = color3.new(0.07, 0.07, 0.09),

	tabBarBg = color3.new(0, 0, 0),

	tabActive = color3.new(0.12, 0.75, 0.45),

	tabActiveBg = color3.new(0.08, 0.30, 0.20),

	accent = color3.new(0.12, 0.75, 0.45),

	accentDim = color3.new(0.08, 0.50, 0.30),

	accentHover = color3.new(0.15, 0.85, 0.55),

	text = color3.new(0.95, 0.95, 0.97),

	muted = color3.new(0.65, 0.65, 0.70),

	dimText = color3.new(0.50, 0.50, 0.55),

	border = color3.new(0.15, 0.15, 0.18),

	tagBg = color3.new(0.12, 0.12, 0.16),

	tagText = color3.new(0.75, 0.75, 0.80),

	iconBg = color3.new(0.14, 0.14, 0.18),

	btnHover = color3.new(0.18, 0.18, 0.22),

	white = color3.new(1, 1, 1),

	bulletDot = color3.new(0.18, 0.72, 0.50),

	sectionHead = color3.new(0.98, 0.98, 1),

	versionTag = color3.new(0.18, 0.18, 0.22),

	versionText = color3.new(0.70, 0.70, 0.76),

	platformTag = color3.new(0.10, 0.35, 0.22),

	platformTxt = color3.new(0.45, 0.92, 0.60),

	envTag = color3.new(0.14, 0.14, 0.18),

	envText = color3.new(0.65, 0.65, 0.70),

	scrollBar = color3.new(0.20, 0.20, 0.25),

	shadow = color3.new(0, 0, 0),
}

--  draw helpers

local function dt(fnt, text, x, y, size, col, spacing)
	raylib.lib.DrawTextEx(fnt, text, vector.create(x, y), size, spacing or 0.7, col)
end

local function mt(fnt, text, size, spacing)
	local v = raylib.lib.MeasureTextEx(fnt, text, size, spacing or 0.7)

	return v.x, v.y
end

local function rrect(rx, ry, rw, rh, round, col)
	raylib.lib.DrawRectangleRounded(structs.Rectangle:new({ x = rx, y = ry, width = rw, height = rh }), round, 8, col)
end

local function rrectL(rx, ry, rw, rh, round, thick, col)
	raylib.lib.DrawRectangleRoundedLinesEx(
		structs.Rectangle:new({ x = rx, y = ry, width = rw, height = rh }),
		round,
		8,
		thick,
		col
	)
end

local function clip(rx, ry, rw, rh)
	raylib.lib.BeginScissorMode(rx, ry, rw, rh)
end

local function unclip()
	raylib.lib.EndScissorMode()
end

local function mouseIn(rx, ry, rw, rh)
	local mp = raylib.lib.GetMousePosition()

	return mp.x >= rx and mp.x <= rx + rw and mp.y >= ry and mp.y <= ry + rh
end

local function drawIcon(tex, rx, ry, rw, rh)
	if not tex then
		return
	end

	raylib.lib.DrawTexturePro(
		tex.texture,
		structs.Rectangle:new({ x = 0, y = 0, width = tex.x, height = tex.y }),
		structs.Rectangle:new({
			x = rx,
			y = ry,
			width = rw,
			height = rh,
		}),
		vector.create(0, 0),
		0,
		raylib.const.WHITE
	)
end

local function wrapText(fnt, text, maxW, size, spacing)
	spacing = spacing or 0.7

	local lines, words, cur = {}, {}, ""

	for w in text:gmatch("%S+") do
		table.insert(words, w)
	end

	for _, word in ipairs(words) do
		local test = cur == "" and word or (cur .. " " .. word)

		if mt(fnt, test, size, spacing) > maxW and cur ~= "" then
			table.insert(lines, cur)

			cur = word
		else
			cur = test
		end
	end

	if cur ~= "" then
		table.insert(lines, cur)
	end

	return lines
end

--  pill tag helper

local function drawPill(fnt, text, x, y, fs, bgCol, textCol, padH, padV)
	padH = padH or 8

	padV = padV or 4

	local tw = mt(fnt, text, fs, 0.6)

	local pw = tw + padH * 2

	local ph = fs + padV * 2

	rrect(x, y, pw, ph, 0.5, bgCol)

	dt(fnt, text, x + padH, y + padV, fs, textCol, 0.6)

	return pw + 6 -- advance width
end

local function drawSoftGlow(rx, ry, rw, rh, round, col, alpha)
	rrect(rx - 2, ry - 2, rw + 4, rh + 4, round, col:ToRaylib(alpha))
end

local function mixColor(a, b, t)
	return color3.new(a.R + (b.R - a.R) * t, a.G + (b.G - a.G) * t, a.B + (b.B - a.B) * t)
end

--  component

return function(objects, data)
	local defFont = raylib.lib.GetFontDefault()

	local config = {

		obj_rect = rect.new(data.x or data[1], data.y or data[2], data.width or data[3], data.height or data[4]),

		modifiers = {},

		font = data.font or defFont,

		boldFont = data.boldFont or data.font or defFont,

		fontSize = data.fontSize or 14,

		-- header

		title = data.title or "Fabric API",

		description = data.description
			or "Lightweight and modular API providing common hooks and interoperability measures utilized by mods using the Fabric toolchain.",

		downloads = data.downloads or "159.15M",

		downloadText = "Download",

		likes = data.likes or "29.7K",

		category = data.category or "Library",

		icon = data.icon,

		bannerImage = data.bannerImage,

		backgroundTransparency = data.backgroundTransparency or 0,

		-- body

		sections = data.sections
			or {

				{ type = "heading", text = "Fabric API" },

				{ type = "text", text = "Essential hooks for modding with Fabric." },

				{

					type = "text",

					text = "Fabric API is the library for essential hooks and interoperability mechanisms for Fabric mods.",
				},

				{ type = "heading", text = "Features" },

				{

					type = "bullet",

					items = {

						"Exposing functionality useful but difficult to access for many mods such as particles, biomes and dimensions.",

						"Adding events, hooks and APIs to improve interoperability between mods.",

						"Essential features such as registry synchronization and adding information to crash reports.",

						"An advanced rendering API designed for compatibility with optimization and graphics overhaul mods.",
					},
				},

				{

					type = "text",

					text = "Fabric API is a mod like any other Fabric mod which requires Fabric Loader to be installed.",
				},
			},

		-- sidebar

		compatibility = data.compatibility or {

			game = "Minecraft: Java Edition",

			versions = {

				"26.2-snapshot-3",

				"26.1.x",

				"1.21.x",

				"1.20.x",

				"1.19.x",

				"1.18.x",

				"1.17.x",

				"1.16.x",

				"1.15.x",

				"1.14.x",
			},
		},

		platforms = data.platforms or { "Fabric" },

		environments = data.environments or { "Client-side", "Server-side", "Client and server" },

		-- tabs

		tabs = data.tabs or { "Description", "Changelog", "Versions" },

		activeTab = data.activeTab or 1,

		-- callbacks

		onDownload = data.onDownload,

		onLike = data.onLike,

		onTabChange = data.onTabChange,

		-- scroll

		_scrollY = 0,

		_maxScroll = 0,

		buttonInstances = {},
	}

	C.accent = data.accent or C.accent
	C.accentDim = mixColor(C.accent, C.shadow, 0.35)
	C.accentHover = mixColor(C.accent, C.white, 0.18)
	C.tabActive = C.accent
	C.tabActiveBg = mixColor(C.accent, C.shadow, 0.72)
	C.bulletDot = mixColor(C.accent, C.white, 0.12)
	C.platformTxt = mixColor(C.accent, C.white, 0.18)
	C.platformTag = mixColor(C.accent, C.shadow, 0.68)

	C.tabBarBg = data.tabBarBg or C.tabBarBg

	C.pageBg = data.pageBg or C.pageBg

	C.headerBg = data.headerBg or C.headerBg

	C.iconBg = data.iconBg or C.iconBg

	C.text = data.text or C.text

	C.muted = data.muted or C.muted

	C.bg = data.bg or C.bg

	C.lightText = data.lightText or C.lightText

	C.sidebarBg = data.sidebarBg or C.sidebarBg

	C.buttonBg = data.buttonBg or C.buttonBg

	C.buttonBgHover = data.buttonBgHover or C.buttonBgHover

	-- Create button instances

	local btnH = 34

	local btnW = 118

	config.buttonInstances.downloadButton = textButton({}, {

		x = 0,

		y = 0,

		width = btnW,

		height = btnH,

		text = config.downloadText,

		fontSize = config.fontSize,

		font = config.font,

		backgroundColor = C.accentDim,

		hoverColor = C.accent,

		pressColor = C.accent,

		backgroundTransparency = 0.08,

		hoverTransparency = 0,

		pressTransparency = 0.04,

		textColor = C.white,

		rounded = { 0.1, 8 },

		shadowLayers = 4,

		shadowSpread = 2,

		shadowOffsetY = 3,

		onClick = function()
			if config.onDownload then
				config.onDownload()
			end
		end,
	})

	config.buttonInstances.likeButton = textButton({}, {

		x = 0,

		y = 0,

		width = btnH,

		height = btnH,

		text = "♥",

		fontSize = config.fontSize,

		font = config.font,

		backgroundColor = C.iconBg,

		hoverColor = C.btnHover,

		pressColor = C.btnHover,

		backgroundTransparency = 1,

		hoverTransparency = 0.12,

		pressTransparency = 0.18,

		textColor = C.muted,

		rounded = { 0.45, 8 },

		shadowLayers = 0,

		onClick = function()
			if config.onLike then
				config.onLike()
			end
		end,
	})

	config.buttonInstances.bookmarkButton = textButton({}, {

		x = 0,

		y = 0,

		width = btnH,

		height = btnH,

		text = "⊕",

		fontSize = config.fontSize,

		font = config.font,

		backgroundColor = C.iconBg,

		hoverColor = C.btnHover,

		pressColor = C.btnHover,

		backgroundTransparency = 1,

		hoverTransparency = 0.12,

		pressTransparency = 0.18,

		textColor = C.muted,

		rounded = { 0.45, 8 },

		shadowLayers = 0,

		onClick = function()

			-- Add bookmark callback if needed
		end,
	})

	config.buttonInstances.menuButton = textButton({}, {

		x = 0,

		y = 0,

		width = btnH,

		height = btnH,

		text = "···",

		fontSize = config.fontSize + 2,

		font = config.font,

		backgroundColor = C.iconBg,

		hoverColor = C.btnHover,

		pressColor = C.btnHover,

		backgroundTransparency = 1,

		hoverTransparency = 0.12,

		pressTransparency = 0.18,

		textColor = C.muted,

		rounded = { 0.45, 8 },

		shadowLayers = 0,

		onClick = function()

			-- Add menu callback if needed
		end,
	})

	-- Create effects instances

	config.headerEffects = effects({

		baseColor = C.headerBg,

		hoverColor = C.btnHover,

		shadowColor = C.shadow,

		shadowLayers = 4,

		shadowOffsetX = 0,

		shadowOffsetY = 4,

		shadowSpread = 3,

		enableGlow = false,

		enablePress = false,
	})

	config.panelEffects = effects({

		baseColor = C.panelBg,

		hoverColor = C.btnHover,

		shadowColor = C.shadow,

		shadowLayers = 3,

		shadowOffsetX = 0,

		shadowOffsetY = 3,

		shadowSpread = 2,

		enableGlow = false,

		enablePress = false,
	})

	config.sidebarEffects = effects({

		baseColor = C.sidebarBg,

		hoverColor = C.btnHover,

		shadowColor = C.shadow,

		shadowLayers = 3,

		shadowOffsetX = 0,

		shadowOffsetY = 3,

		shadowSpread = 2,

		enableGlow = false,

		enablePress = false,
	})

	local wrapper = {}

	wrapper.set = function(prop, value)
		if type(config[prop]) == "function" then
			return wrapper
		end

		config[prop] = value

		return wrapper
	end

	wrapper.render = function(dt_time)
		local r = config.obj_rect

		local fnt = config.font

		local bfnt = config.boldFont

		local fs = config.fontSize

		local mPress = raylib.lib.IsMouseButtonPressed(0) == 1

		local wheel = raylib.lib.GetMouseWheelMove()

		--  layout constants

		local shellPad = 30

		local outerPad = 26

		local bottomPad = 26

		local bannerHeight = 404

		local headerH = 170

		local tabBarH = 54

		local shellX = r.x + shellPad

		local shellY = r.y + shellPad

		local shellW = r.width - shellPad * 2

		local shellH = r.height - shellPad * 2

		local contentX = shellX + outerPad

		local contentY = shellY + outerPad

		local contentW = shellW - outerPad * 2

		local bodyY = shellY + headerH + tabBarH + 24

		local bodyH = shellY + shellH - bottomPad - bodyY

		local sidebarW = 286

		local gutter = 20

		local mainW = contentW - sidebarW - gutter

		local mainX = contentX

		local sidebarX = mainX + mainW + gutter

		--  page background

		raylib.lib.DrawRectangle(r.x, r.y, r.width, r.height, C.pageBg:ToRaylib(config.backgroundTransparency))

		rrect(shellX, shellY, shellW, shellH, 0.035, C.shadow:ToRaylib(0.08))
		rrectL(shellX, shellY, shellW, shellH, 0.035, 1, C.border:ToRaylib(0.08))

		--  BANNER IMAGE at top behind header card

		if config.bannerImage then
			local bannerRect = rect.new(shellX, shellY, shellW, math.min(shellH, bannerHeight))

			clip(bannerRect.x, bannerRect.y, bannerRect.width, bannerRect.height)

			raylib.lib.DrawTexturePro(
				config.bannerImage.texture,
				structs.Rectangle:new({
					x = 0,
					y = 0,
					width = config.bannerImage.x,
					height = config.bannerImage.y,
				}),
				rect:translate(bannerRect),
				vector.create(0, 0),
				0,
				raylib.const.WHITE
			)

			unclip()

			-- Black gradient overlay from top (transparent) to bottom (full black)

			local gradientHeight = bannerRect.height + 60

			for i = 0, gradientHeight - 1 do
				local alpha = i / gradientHeight * 1.0

				raylib.lib.DrawLineEx(
					vector.create(shellX, shellY + i),
					vector.create(shellX + shellW, shellY + i),
					1,
					C.shadow:ToRaylib(0.18 + (1 - alpha) * 0.68)
				)
			end
		end

		-- HEADER CARD

		local hx, hy = contentX, contentY

		local hw, hh = contentW, headerH - outerPad

		rrect(hx, hy, hw, hh, 0.05, C.headerBg:ToRaylib(0.78))
		rrectL(hx, hy, hw, hh, 0.05, 1, C.border:ToRaylib(0.14))
		raylib.lib.DrawRectangleRounded(
			structs.Rectangle:new({ x = hx, y = hy, width = hw, height = math.floor(hh * 0.42) }),
			0.05,
			8,
			C.white:ToRaylib(0.92)
		)

		local hpad = 22

		local iconSz = 76

		local iconX = hx + hpad

		local iconY = hy + hh / 2 - iconSz / 2

		-- icon box

		drawSoftGlow(iconX, iconY, iconSz, iconSz, 0.18, C.white, 0.97)
		rrect(iconX, iconY, iconSz, iconSz, 0.18, C.iconBg:ToRaylib(0.12))
		rrectL(iconX, iconY, iconSz, iconSz, 0.18, 1, C.border:ToRaylib(0.10))

		if config.icon then
			drawIcon(config.icon, iconX, iconY, iconSz, iconSz)
		else
			local letter = config.title:sub(1, 1):upper()

			local lw = mt(fnt, letter, fs + 12, 1)

			dt(
				fnt,
				letter,
				iconX + iconSz / 2 - lw / 2,
				iconY + iconSz / 2 - (fs + 12) / 2,
				fs + 12,
				C.accent:ToRaylib(0),
				1
			)
		end

		-- title + desc text

		local txtX = iconX + iconSz + hpad

		local titleFS = fs + 8

		local descFS = fs

		local smallFS = fs - 1

		-- button cluster (right side)

		local btnH = 40

		local btnW = 128

		local bClustW = btnW + 8 + btnH + 8 + btnH + 8 + btnH

		local bClustX = hx + hw - hpad - bClustW

		local bClustY = hy + hh / 2 - btnH / 2

		local txtMaxW = bClustX - txtX - hpad

		-- title

		local titleY = hy + hpad + 1

		dt(bfnt, config.title, txtX, titleY, titleFS, C.text:ToRaylib(0), 0.82)

		-- description (2-line wrap)

		local descLines = wrapText(fnt, config.description, txtMaxW, descFS, 0.65)

		for i = 1, math.min(#descLines, 2) do
			local line = descLines[i]

			if i == 2 and #descLines > 2 then
				line = line:gsub("%s*%S+$", "") .. "…"
			end

			dt(fnt, line, txtX, titleY + titleFS + 10 + (i - 1) * (descFS + 6), descFS, C.muted:ToRaylib(0), 0.62)
		end

		-- stats row

		local statsY = hy + hh - hpad - smallFS

		local sx = txtX

		local dlIcon = "↓"

		local diW = mt(fnt, dlIcon, smallFS, 0.5)

		dt(fnt, dlIcon, sx, statsY, smallFS, C.muted:ToRaylib(0), 0.5)

		dt(fnt, config.downloads, sx + diW + 4, statsY, smallFS, C.muted:ToRaylib(0), 0.65)

		sx = sx + diW + 4 + mt(fnt, config.downloads, smallFS, 0.65) + 16

		local hrtIcon = "♥"

		local hiW = mt(fnt, hrtIcon, smallFS, 0.5)

		dt(fnt, hrtIcon, sx, statsY, smallFS, C.muted:ToRaylib(0), 0.5)

		dt(fnt, config.likes, sx + hiW + 4, statsY, smallFS, C.muted:ToRaylib(0), 0.65)

		sx = sx + hiW + 4 + mt(fnt, config.likes, smallFS, 0.65) + 16

		drawPill(fnt, config.category, sx, statsY - 4, smallFS, C.tagBg:ToRaylib(0.18), C.tagText:ToRaylib(0), 10, 5)

		--  button cluster
		-- Update button positions and render

		config.buttonInstances.downloadButton.set("obj_rect", rect.new(bClustX, bClustY, btnW, btnH))
		config.buttonInstances.downloadButton.set("text", config.downloadText)
		config.buttonInstances.downloadButton.render(dt_time)

		local lkX = bClustX + btnW + 8

		rrectL(lkX, bClustY, btnH, btnH, 0.45, 1, C.border:ToRaylib(0.10))

		config.buttonInstances.likeButton.set("obj_rect", rect.new(lkX, bClustY, btnH, btnH))

		config.buttonInstances.likeButton.render(dt_time)

		local bmX = lkX + btnH + 8

		rrectL(bmX, bClustY, btnH, btnH, 0.45, 1, C.border:ToRaylib(0.10))

		config.buttonInstances.bookmarkButton.set("obj_rect", rect.new(bmX, bClustY, btnH, btnH))

		config.buttonInstances.bookmarkButton.render(dt_time)

		local mnX = bmX + btnH + 8

		rrectL(mnX, bClustY, btnH, btnH, 0.45, 1, C.border:ToRaylib(0.10))

		config.buttonInstances.menuButton.set("obj_rect", rect.new(mnX, bClustY, btnH, btnH))

		config.buttonInstances.menuButton.render(dt_time)

		--

		-- TAB BAR

		--

		local tabBarY = shellY + headerH

		raylib.lib.DrawRectangle(shellX, tabBarY, shellW, tabBarH, C.tabBarBg:ToRaylib(0.86))

		raylib.lib.DrawLineEx(
			vector.create(shellX, tabBarY + tabBarH - 1),
			vector.create(shellX + shellW, tabBarY + tabBarH - 1),
			1,
			C.border:ToRaylib(0)
		)

		local tabX = contentX

		local tabFS = fs + 1

		for i, tabName in ipairs(config.tabs) do
			local tw = mt(bfnt, tabName, tabFS, 0.85)

			local tabW = tw + 34

			local tabY = tabBarY + tabBarH / 2 - tabFS / 2 - 2

			local isActive = config.activeTab == i

			local isHov = mouseIn(tabX, tabBarY, tabW, tabBarH)

			if isActive then
				-- active pill bg

				drawSoftGlow(tabX, tabBarY + 8, tabW, tabBarH - 16, 0.5, C.accent, 0.9)
				rrect(tabX, tabBarY + 8, tabW, tabBarH - 16, 0.5, C.tabActiveBg:ToRaylib(0.04))

				dt(bfnt, tabName, tabX + 16, tabY, tabFS, C.tabActive:ToRaylib(0), 0.85)

				-- active underline

				raylib.lib.DrawRectangle(tabX + 6, tabBarY + tabBarH - 3, tabW - 12, 3, C.tabActive:ToRaylib(0))
			elseif isHov then
				rrect(tabX, tabBarY + 8, tabW, tabBarH - 16, 0.5, C.tagBg:ToRaylib(0.18))

				dt(fnt, tabName, tabX + 16, tabY, tabFS, C.text:ToRaylib(0), 0.85)
			else
				dt(fnt, tabName, tabX + 16, tabY, tabFS, C.muted:ToRaylib(0), 0.85)
			end

			if mPress and isHov then
				config.activeTab = i

				if config.onTabChange then
					config.onTabChange(i, tabName)
				end
			end

			tabX = tabX + tabW + 6
		end

		--

		-- BODY  scroll on wheel when mouse over main panel

		--

		if mouseIn(mainX, bodyY, mainW, bodyH) and wheel ~= 0 then
			config._scrollY = config._scrollY - wheel * 32

			if config._scrollY < 0 then
				config._scrollY = 0
			end

			if config._scrollY > config._maxScroll then
				config._scrollY = config._maxScroll
			end
		end

		--  MAIN CONTENT PANEL

		local mainPanelRect = rect.new(mainX, bodyY, mainW, bodyH)

		-- Update and render panel effects

		config.panelEffects.setRect(mainPanelRect)

		config.panelEffects.update(dt_time)

		config.panelEffects.renderShadows(mainPanelRect, { 0.06, 12 })

		rrect(mainX, bodyY, mainW, bodyH, 0.035, C.panelBg:ToRaylib(0.22))
		rrectL(mainX, bodyY, mainW, bodyH, 0.035, 1, C.border:ToRaylib(0.10))
		raylib.lib.DrawRectangleRounded(
			structs.Rectangle:new({ x = mainX, y = bodyY, width = mainW, height = math.floor(bodyH * 0.32) }),
			0.035,
			8,
			C.white:ToRaylib(0.985)
		)

		local cpad = 28

		local cw = mainW - cpad * 2

		local cx = mainX + cpad

		local contentFS = fs

		local headingFS = fs + 6

		local bulletFS = fs

		local lineH = contentFS + 10

		local bulletIndent = 16

		-- render sections with scissor clip

		clip(mainX + 1, bodyY + 1, mainW - 2, bodyH - 2)

		local cy = bodyY + cpad - config._scrollY

		local totalContentH = 0

		for _, section in ipairs(config.sections) do
			if section.type == "heading" then
				if cy + headingFS >= bodyY and cy <= bodyY + bodyH then
					raylib.lib.DrawRectangle(cx - 18, cy + 2, 4, headingFS - 4, C.accent:ToRaylib(0))
					dt(bfnt, section.text, cx, cy, headingFS, C.sectionHead:ToRaylib(0), 0.85)
				end

				cy = cy + headingFS + 18

				totalContentH = totalContentH + headingFS + 18
			elseif section.type == "text" then
				local wlines = wrapText(fnt, section.text, cw, contentFS, 0.7)

				for _, line in ipairs(wlines) do
					if cy + contentFS >= bodyY and cy <= bodyY + bodyH then
						dt(fnt, line, cx, cy, contentFS, C.muted:ToRaylib(0), 0.66)
					end

					cy = cy + lineH

					totalContentH = totalContentH + lineH
				end

				cy = cy + 8

				totalContentH = totalContentH + 8
			elseif section.type == "bullet" then
				for _, item in ipairs(section.items) do
					local blines = wrapText(fnt, item, cw - bulletIndent - 12, bulletFS, 0.68)

					if cy + bulletFS >= bodyY and cy <= bodyY + bodyH then
						raylib.lib.DrawCircleV(
							vector.create(cx + 5, cy + bulletFS / 2 + 1),
							3.5,
							C.bulletDot:ToRaylib(0)
						)

						dt(fnt, blines[1], cx + bulletIndent, cy, bulletFS, C.muted:ToRaylib(0), 0.68)
					end

					cy = cy + bulletFS + 8

					totalContentH = totalContentH + bulletFS + 8

					for li = 2, #blines do
						if cy + bulletFS >= bodyY and cy <= bodyY + bodyH then
							dt(fnt, blines[li], cx + bulletIndent, cy, bulletFS, C.muted:ToRaylib(0), 0.68)
						end

						cy = cy + bulletFS + 8

						totalContentH = totalContentH + bulletFS + 8
					end
				end

				cy = cy + 6

				totalContentH = totalContentH + 6
			elseif section.type == "divider" then
				if cy >= bodyY and cy <= bodyY + bodyH then
					raylib.lib.DrawLineEx(
						vector.create(cx, cy + 8),
						vector.create(cx + cw, cy + 8),
						1,
						C.border:ToRaylib(0)
					)
				end

				cy = cy + 20

				totalContentH = totalContentH + 20
			end
		end

		-- update max scroll

		config._maxScroll = math.max(0, totalContentH - bodyH + cpad * 2)

		unclip()

		-- scrollbar

		if config._maxScroll > 0 then
			local sbW = 5

			local sbX = mainX + mainW - sbW - 4

			local ratio = bodyH / (totalContentH + cpad * 2)

			local sbH = math.max(32, bodyH * ratio)

			local sbY = bodyY + (config._scrollY / config._maxScroll) * (bodyH - sbH)

			rrect(sbX, sbY, sbW, sbH, 0.5, C.scrollBar:ToRaylib(0))
		end

		--  SIDEBAR

		local sidebarRect = rect.new(sidebarX, bodyY, sidebarW, bodyH)

		-- Update and render sidebar effects

		config.sidebarEffects.setRect(sidebarRect)

		config.sidebarEffects.update(dt_time)

		config.sidebarEffects.renderShadows(sidebarRect, { 0.07, 12 })

		rrect(sidebarX, bodyY, sidebarW, bodyH, 0.035, C.sidebarBg:ToRaylib(0.18))

		rrectL(sidebarX, bodyY, sidebarW, bodyH, 0.035, 1, C.border:ToRaylib(0.10))
		raylib.lib.DrawRectangleRounded(
			structs.Rectangle:new({ x = sidebarX, y = bodyY, width = sidebarW, height = math.floor(bodyH * 0.24) }),
			0.035,
			8,
			C.white:ToRaylib(0.99)
		)

		local sp = 20

		local sfs = fs

		local ssmall = fs - 1

		local sy = bodyY + sp

		--  Compatibility section

		dt(bfnt, "Compatibility", sidebarX + sp, sy, sfs + 2, C.text:ToRaylib(0), 0.85)

		sy = sy + sfs + 2 + 12

		if config.compatibility then
			dt(fnt, config.compatibility.game, sidebarX + sp, sy, ssmall, C.muted:ToRaylib(0), 0.7)

			sy = sy + ssmall + 12

			-- version pills (wrap rows)

			local rowX = sidebarX + sp

			local rowMaxX = sidebarX + sidebarW - sp

			for _, ver in ipairs(config.compatibility.versions or {}) do
				local vw = mt(fnt, ver, ssmall, 0.65) + 16

				if rowX + vw > rowMaxX then
					rowX = sidebarX + sp

					sy = sy + ssmall + 12
				end

				rrect(rowX, sy, vw, ssmall + 10, 0.45, C.versionTag:ToRaylib(0.14))

				dt(fnt, ver, rowX + 8, sy + 5, ssmall, C.versionText:ToRaylib(0), 0.65)

				rowX = rowX + vw + 6
			end

			sy = sy + ssmall + 10 + 18
		end

		-- separator

		raylib.lib.DrawLineEx(
			vector.create(sidebarX + sp, sy),
			vector.create(sidebarX + sidebarW - sp, sy),
			1,
			C.border:ToRaylib(0)
		)

		sy = sy + 14

		--  Platforms section

		dt(bfnt, "Platforms", sidebarX + sp, sy, sfs + 2, C.text:ToRaylib(0), 0.85)

		sy = sy + sfs + 2 + 12

		local rowX = sidebarX + sp

		for _, plat in ipairs(config.platforms or {}) do
			local pw =
				drawPill(fnt, plat, rowX, sy, ssmall, C.tabActiveBg:ToRaylib(0.06), C.tabActive:ToRaylib(0), 10, 5)

			rowX = rowX + pw + 4
		end

		sy = sy + ssmall + 10 + 18

		-- separator

		raylib.lib.DrawLineEx(
			vector.create(sidebarX + sp, sy),
			vector.create(sidebarX + sidebarW - sp, sy),
			1,
			C.border:ToRaylib(0)
		)

		sy = sy + 14

		--  Supported environments

		dt(bfnt, "Supported environments", sidebarX + sp, sy, sfs + 2, C.text:ToRaylib(0), 0.85)

		sy = sy + sfs + 2 + 12

		rowX = sidebarX + sp

		local rowMaxX = sidebarX + sidebarW - sp

		for _, env in ipairs(config.environments or {}) do
			local ew = mt(fnt, env, ssmall, 0.65) + 20

			if rowX + ew > rowMaxX then
				rowX = sidebarX + sp

				sy = sy + ssmall + 14
			end

			rrect(rowX, sy, ew, ssmall + 10, 0.45, C.envTag:ToRaylib(0.18))

			rrectL(rowX, sy, ew, ssmall + 10, 0.45, 1, C.border:ToRaylib(0.12))

			dt(fnt, env, rowX + 10, sy + 5, ssmall, C.envText:ToRaylib(0), 0.65)

			rowX = rowX + ew + 6
		end

		--  modifiers

		for _, m in pairs(config.modifiers) do
			m()
		end
	end

	table.insert(objects, wrapper)

	return wrapper
end
