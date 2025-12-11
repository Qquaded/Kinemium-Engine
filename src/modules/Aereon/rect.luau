-- devcell
local rl = require("@raylib")

local function lerp(a, b, t)
	return a + (b - a) * t
end

return function(raylib: typeof(rl.lib))
	local rect = {}

	local structs, const = rl.structs, rl.const

	function rect.new(x, y, width, height)
		return {
			width = width,
			height = height,
			x = x,
			y = y,
			rect = structs.Rectangle:new({ x = x, y = y, width = width, height = height }),
		}
	end

	function rect.lerpPosition(object, targetX, targetY, t)
		object.x = lerp(object.x, targetX, t)
		object.y = lerp(object.y, targetY, t)

		object.rect.x = object.x
		object.rect.y = object.y
		return object
	end

	function rect.lerpSize(object, targetW, targetH, t)
		object.width = lerp(object.width, targetW, t)
		object.height = lerp(object.height, targetH, t)

		object.rect.width = object.width
		object.rect.height = object.height
		return object
	end

	function rect.lerp(object, target, t)
		object.x = lerp(object.x, target.x, t)
		object.y = lerp(object.y, target.y, t)
		object.width = lerp(object.width, target.width, t)
		object.height = lerp(object.height, target.height, t)

		object.rect.x = object.x
		object.rect.y = object.y
		object.rect.width = object.width
		object.rect.height = object.height

		return object
	end

	function rect:translate(object)
		return object.rect
	end

	function rect.read(object, prop)
		return object[prop]
	end

	function rect.move(object, dx, dy)
		object.x += dx
		object.y += dy
		object.rect.x = object.x
		object.rect.y = object.y
		return object
	end

	function rect.resize(object, newWidth, newHeight)
		object.width = newWidth
		object.height = newHeight
		object.rect.width = newWidth
		object.rect.height = newHeight
		return object
	end

	function rect.setPosition(object, x, y)
		object.x = x
		object.y = y
		object.rect.x = x
		object.rect.y = y
		return object
	end

	function rect.setSize(object, w, h)
		object.width = w
		object.height = h
		object.rect.width = w
		object.rect.height = h
		return object
	end

	function rect.intersects(a, b)
		return not (a.x + a.width < b.x or a.x > b.x + b.width or a.y + a.height < b.y or a.y > b.y + b.height)
	end

	function rect.inflate(object, amount)
		object.x -= amount
		object.y -= amount
		object.width += amount * 2
		object.height += amount * 2

		object.rect.x = object.x
		object.rect.y = object.y
		object.rect.width = object.width
		object.rect.height = object.height

		return object
	end

	function rect.deflate(object, amount)
		return rect.inflate(object, -amount)
	end

	function rect.clone(object)
		return rect.new(object.x, object.y, object.width, object.height)
	end

	function rect.centerInside(a, b)
		local newX = b.x + (b.width / 2 - a.width / 2)
		local newY = b.y + (b.height / 2 - a.height / 2)
		return rect.setPosition(a, newX, newY)
	end

	function rect.MouseIsInRect(rect)
		local mousePos = raylib.GetMousePosition()
		local function isMouseInRect(rect)
			return mousePos.x >= rect.x
				and mousePos.x <= rect.x + rect.width
				and mousePos.y >= rect.y
				and mousePos.y <= rect.y + rect.height
		end
		return isMouseInRect(rect)
	end

	function rect.MouseIsOutsideRect(rect)
		local mousePos = raylib.GetMousePosition()
		return not (
			mousePos.x >= rect.x
			and mousePos.x <= rect.x + rect.width
			and mousePos.y >= rect.y
			and mousePos.y <= rect.y + rect.height
		)
	end

	function rect.MouseOutsideSide(rect)
		local mousePos = raylib.GetMousePosition()

		if
			mousePos.x >= rect.x
			and mousePos.x <= rect.x + rect.width
			and mousePos.y >= rect.y
			and mousePos.y <= rect.y + rect.height
		then
			return "inside"
		end

		if mousePos.x < rect.x then
			return "left"
		elseif mousePos.x > rect.x + rect.width then
			return "right"
		elseif mousePos.y < rect.y then
			return "top"
		elseif mousePos.y > rect.y + rect.height then
			return "bottom"
		end
	end

	function rect.MouseOutsideSideDistance(rect)
		local mousePos = raylib.GetMousePosition()

		local left = rect.x
		local right = rect.x + rect.width
		local top = rect.y
		local bottom = rect.y + rect.height

		if mousePos.x >= left and mousePos.x <= right and mousePos.y >= top and mousePos.y <= bottom then
			return "inside", 0
		end

		if mousePos.x < left then
			return "left", left - mousePos.x
		elseif mousePos.x > right then
			return "right", mousePos.x - right
		end

		if mousePos.y < top then
			return "top", top - mousePos.y
		elseif mousePos.y > bottom then
			return "bottom", mousePos.y - bottom
		end
	end

	function rect.render(object, color)
		color = color or { r = 255, g = 255, b = 255, a = 255 }

		raylib.DrawRectangleRec(
			object.rect,
			structs.Color:new({
				r = math.floor(color.r),
				g = math.floor(color.g),
				b = math.floor(color.b),
				a = math.floor(color.a),
			})
		)
	end

	function rect.renderRounded(object, radius, segments, color)
		color = color or { r = 255, g = 255, b = 255, a = 255 }

		raylib.DrawRectangleRounded(
			object.rect,
			radius or 0.1,
			segments or 8,
			structs.Color:new({
				r = math.floor(color.r),
				g = math.floor(color.g),
				b = math.floor(color.b),
				a = math.floor(color.a),
			})
		)
	end

	function rect.NearestSide(rect)
		local mousePos = raylib.GetMousePosition()

		local left = rect.x
		local right = rect.x + rect.width
		local top = rect.y
		local bottom = rect.y + rect.height

		local dxLeft = math.abs(mousePos.x - left)
		local dxRight = math.abs(mousePos.x - right)
		local dyTop = math.abs(mousePos.y - top)
		local dyBottom = math.abs(mousePos.y - bottom)

		local minDist = math.min(dxLeft, dxRight, dyTop, dyBottom)

		if minDist == dxLeft then
			return "left", dxLeft
		elseif minDist == dxRight then
			return "right", dxRight
		elseif minDist == dyTop then
			return "top", dyTop
		else
			return "bottom", dyBottom
		end
	end

	function rect.DistanceToSides(rect)
		local mousePos = raylib.GetMousePosition()

		local left = rect.x
		local right = rect.x + rect.width
		local top = rect.y
		local bottom = rect.y + rect.height

		return {
			left = mousePos.x - left,
			right = right - mousePos.x,
			top = mousePos.y - top,
			bottom = bottom - mousePos.y,
		}
	end

	function rect.MouseCorner(rect, cornerSize)
		local mousePos = raylib.GetMousePosition()
		cornerSize = cornerSize or 10

		local left = rect.x
		local right = rect.x + rect.width
		local top = rect.y
		local bottom = rect.y + rect.height

		local inLeft = mousePos.x >= left and mousePos.x <= left + cornerSize
		local inRight = mousePos.x <= right and mousePos.x >= right - cornerSize
		local inTop = mousePos.y >= top and mousePos.y <= top + cornerSize
		local inBottom = mousePos.y <= bottom and mousePos.y >= bottom - cornerSize

		if inLeft and inTop then
			return "topleft"
		end
		if inRight and inTop then
			return "topright"
		end
		if inLeft and inBottom then
			return "bottomleft"
		end
		if inRight and inBottom then
			return "bottomright"
		end

		return "none"
	end

	function rect.Hover(object, hovered)
		if rect.MouseIsInRect(object) then
			hovered(object)
		end
	end

	function rect.HoverLeave(object, left)
		if not rect.MouseIsInRect(object) then
			left(object)
		end
	end

	function rect.Button(object, clicked)
		if raylib.IsMouseButtonReleased(0) == 1 and rect.MouseIsInRect(object) then
			clicked(object)
		end
	end

	export type RectLib = typeof(rect)

	return rect :: RectLib
end
