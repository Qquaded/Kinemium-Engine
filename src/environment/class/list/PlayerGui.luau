-- description: "A container that holds the graphical user interface objects for a player."
--#༵༼༻══╡THE PLAYER GUI╞══༺༽#༵

local propTable = {}

-- #ོ༹ ྍྭ᳀══════༺༙༙༷ཿྎཬཱླྀ༒༙༙༙༵࿆ཪ༵࿆ ླྀ ༷ ༷ཿ༻༙༙༷࿆ ཾ═════╡⋅⋆THE CALLBACK∘⋆⋅╞═════༺༙༙༷ཿྎཬཱླྀ༒༙༙༙༵࿆ཪ༵࿆ ླྀ ༷ ༷ཿ༻༙༙༷࿆ ཾ═════᳀
return {
	class = "PlayerGui",
	callback = function(instance, starterGui)
		return instance
	end,
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
-- #ོ༹ ྭྍ᳀══════━┈༺ཿཿ༻┈━═════╡⋅⋆∘THE ENDING∘⋆⋅╞═════━┈༺ཿཿཿ༻┈━═════᳀
