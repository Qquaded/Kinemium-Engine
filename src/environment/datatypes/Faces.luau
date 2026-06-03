local Faces = {}
Faces.__index = Faces

-- Bit flags
Faces.Face = {
	Top = 1,
	Bottom = 2,
	Left = 4,
	Right = 8,
	Front = 16,
	Back = 32,
}

Faces.All = Faces.Face.Top + Faces.Face.Bottom + Faces.Face.Left + Faces.Face.Right + Faces.Face.Front + Faces.Face.Back

local function new(mask)
	return setmetatable({
		Mask = mask or 0,
	}, Faces)
end

-- Constructors
function Faces.new(...)
	local mask = 0
	for _, face in ipairs({ ... }) do
		mask = mask + face
	end
	return new(mask)
end

function Faces.single(face)
	return new(face)
end

function Faces.all()
	return new(Faces.All)
end

function Faces.none()
	return new(0)
end

-- Operations
function Faces:Has(face)
	return bit32.band(self.Mask, face) ~= 0
end

function Faces:Add(face)
	self.Mask = bit32.bor(self.Mask, face)
	return self
end

function Faces:Remove(face)
	self.Mask = bit32.band(self.Mask, bit32.bnot(face))
	return self
end

function Faces:Clear()
	self.Mask = 0
	return self
end

-- Serialization
function Faces:ToTable()
	return {
		type = "Faces",
		Mask = self.Mask,
	}
end

function Faces.FromTable(tbl)
	assert(tbl.type == "Faces", "invalid type")
	return new(tbl.Mask or 0)
end

-- Helpers (optional convenience)
function Faces:IsEmpty()
	return self.Mask == 0
end

function Faces:ToList()
	local list = {}

	for name, value in pairs(Faces.Face) do
		if bit32.band(self.Mask, value) ~= 0 then
			table.insert(list, name)
		end
	end

	return list
end

return Faces
