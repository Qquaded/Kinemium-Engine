local raylib = require("@raylib")
local structs = raylib.structs

local rect = require("@arect")
local color3 = require("@Color3")

return function(objects, data)
	local config = {
		obj_rect = rect.new(data.x or data[1], data.y or data[2], data.width or data[3], data.height or data[4]),
		rounded = data.rounded or { 0.08, 8 },
		modifiers = {},

		-- Colors
		backgroundColor = color3.new(0.11, 0.11, 0.13),
		optionBackgroundColor = color3.new(0.16, 0.16, 0.18),
		optionHoverColor = color3.new(0.18, 0.18, 0.20),
		selectedOptionColor = color3.new(0.20, 0.35, 0.28),
		textColor = color3.new(0.90, 0.90, 0.92),
		dimTextColor = color3.new(0.60, 0.60, 0.63),
		accentColor = color3.new(0.35, 0.75, 0.55),
		progressBarColor = color3.new(0.25, 0.55, 0.40),

		-- Poll data
		question = data.question or "Poll Question?",
		options = data.options or {
			{ text = "Option 1", votes = 1, avatar = nil },
			{ text = "Option 2", votes = 0, avatar = nil },
			{ text = "Option 3", votes = 0, avatar = nil },
		},
		totalVotes = 1,
		closed = data.closed or false,
		userVoted = data.userVoted or nil, -- Index of user's vote

		-- Layout
		padding = 16,
		optionHeight = 56,
		optionSpacing = 8,
		avatarSize = 32,

		-- Interaction
		hoveredIndex = -1,

		onVote = data.onVote,
	}

	-- Calculate total votes
	local function calculateTotalVotes()
		config.totalVotes = 0
		for _, option in ipairs(config.options) do
			config.totalVotes = config.totalVotes + option.votes
		end
	end

	calculateTotalVotes()

	local wrapper = {}

	wrapper.set = function(prop, value)
		if type(config[prop]) == "function" then
			return wrapper
		end
		config[prop] = value
		if prop == "options" then
			calculateTotalVotes()
		end
		return wrapper
	end

	wrapper.addOption = function(text, votes, avatar)
		table.insert(config.options, {
			text = text,
			votes = votes or 0,
			avatar = avatar,
		})
		calculateTotalVotes()
		return wrapper
	end

	wrapper.vote = function(index)
		if config.closed or config.userVoted then
			return wrapper
		end

		config.options[index].votes = config.options[index].votes + 1
		config.userVoted = index
		calculateTotalVotes()

		if config.onVote then
			config.onVote(index, config.options[index])
		end
		return wrapper
	end

	wrapper.close = function()
		config.closed = true
		return wrapper
	end

	wrapper.render = function(dt)
		local r = config.obj_rect
		local mousePos = raylib.lib.GetMousePosition()
		local mousePressed = raylib.lib.IsMouseButtonPressed(0) == 1

		-- Background
		raylib.lib.DrawRectangleRounded(
			rect:translate(r),
			config.rounded[1],
			config.rounded[2],
			config.backgroundColor:ToRaylib(0)
		)

		local currentY = r.y + config.padding

		-- Question
		local questionLines = {}
		local words = {}
		for word in config.question:gmatch("%S+") do
			table.insert(words, word)
		end

		local currentLine = ""
		local maxWidth = r.width - config.padding * 2
		local fontSize = 16

		for _, word in ipairs(words) do
			local testLine = currentLine == "" and word or currentLine .. " " .. word
			local lineWidth = raylib.lib.MeasureText(testLine, fontSize)

			if lineWidth > maxWidth then
				table.insert(questionLines, currentLine)
				currentLine = word
			else
				currentLine = testLine
			end
		end

		if currentLine ~= "" then
			table.insert(questionLines, currentLine)
		end

		for _, line in ipairs(questionLines) do
			raylib.lib.DrawText(line, r.x + config.padding, currentY, fontSize, config.textColor:ToRaylib(0))
			currentY = currentY + 20
		end

		currentY = currentY + 8

		-- Options
		config.hoveredIndex = -1

		for i, option in ipairs(config.options) do
			local optionRect =
				rect.new(r.x + config.padding, currentY, r.width - config.padding * 2, config.optionHeight)

			local isHovered = rect.MouseIsInRect(optionRect)
			local isSelected = config.userVoted == i
			local percentage = config.totalVotes > 0 and (option.votes / config.totalVotes * 100) or 0

			if isHovered and not config.closed and not config.userVoted then
				config.hoveredIndex = i
			end

			-- Option background
			local bgColor = config.optionBackgroundColor
			if isSelected then
				bgColor = config.selectedOptionColor
			elseif isHovered and not config.closed and not config.userVoted then
				bgColor = config.optionHoverColor
			end

			raylib.lib.DrawRectangleRounded(rect:translate(optionRect), 0.1, 8, bgColor:ToRaylib(0))

			-- Progress bar if voted or closed
			if config.userVoted or config.closed then
				local progressWidth = (optionRect.width - 4) * (percentage / 100)
				if progressWidth > 0 then
					raylib.lib.DrawRectangleRounded(
						structs.Rectangle:new({
							x = optionRect.x + 2,
							y = optionRect.y + 2,
							width = progressWidth,
							height = optionRect.height - 4,
						}),
						0.1,
						8,
						config.progressBarColor:ToRaylib(0.5)
					)
				end
			end

			-- Avatar
			local contentX = optionRect.x + 12
			if option.avatar then
				raylib.lib.DrawTexturePro(
					option.avatar.texture,
					structs.Rectangle:new({ x = 0, y = 0, width = option.avatar.x, height = option.avatar.y }),
					structs.Rectangle:new({
						x = contentX,
						y = optionRect.y + (config.optionHeight - config.avatarSize) / 2,
						width = config.avatarSize,
						height = config.avatarSize,
					}),
					vector.create(0, 0),
					0,
					raylib.const.WHITE
				)
				contentX = contentX + config.avatarSize + 12
			else
				-- Placeholder avatar circle
				local avatarCenterY = optionRect.y + config.optionHeight / 2
				raylib.lib.DrawCircle(
					contentX + config.avatarSize / 2,
					avatarCenterY,
					config.avatarSize / 2,
					config.dimTextColor:ToRaylib(0.3)
				)
				contentX = contentX + config.avatarSize + 12
			end

			-- Option text
			raylib.lib.DrawText(option.text, contentX, optionRect.y + 12, 13, config.textColor:ToRaylib(0))

			-- Vote count and percentage (right side)
			if config.userVoted or config.closed then
				local voteText = string.format("%d vote%s", option.votes, option.votes == 1 and "" or "s")
				local percentText = string.format("%.0f%%", percentage)

				local percentWidth = raylib.lib.MeasureText(percentText, 16)
				raylib.lib.DrawText(
					percentText,
					optionRect.x + optionRect.width - percentWidth - 12,
					optionRect.y + 10,
					16,
					config.textColor:ToRaylib(0)
				)

				local voteWidth = raylib.lib.MeasureText(voteText, 11)
				raylib.lib.DrawText(
					voteText,
					optionRect.x + optionRect.width - voteWidth - 12,
					optionRect.y + 32,
					11,
					config.dimTextColor:ToRaylib(0)
				)
			end

			-- Click handling
			if isHovered and mousePressed and not config.closed and not config.userVoted then
				wrapper.vote(i)
			end

			currentY = currentY + config.optionHeight + config.optionSpacing
		end

		currentY = currentY + 8

		-- Footer
		local footerText = string.format("%d vote%s", config.totalVotes, config.totalVotes == 1 and "" or "s")
		if config.closed then
			footerText = footerText .. " • Poll closed"
		end

		raylib.lib.DrawText(footerText, r.x + config.padding, currentY, 12, config.dimTextColor:ToRaylib(0))

		for _, m in pairs(config.modifiers) do
			m()
		end
	end

	table.insert(objects, wrapper)
	return wrapper
end
