--!strict
--!optimize 2

local constants = {
	ULWindowFlags = {
		kWindowFlags_Borderless = 0x1,
		kWindowFlags_Titled = 0x2,
		kWindowFlags_Resizable = 0x4,
		kWindowFlags_Maximizable = 0x8,
		kWindowFlags_Hidden = 0x10,
	},
}

return constants
