-- description: "A customizable mesh you can place on a character."
local Vector3 = require("@Vector3")
local CFrame = require("@CFrame")
local Enum = require("@EnumMap")
local Instance = require("@Instance")

-- Default attachment points per AccessoryType
local DEFAULT_ATTACHMENT_POINTS = {
	[Enum.AccessoryType.Hat] = "Head",
	[Enum.AccessoryType.Hair] = "Head",
	[Enum.AccessoryType.Face] = "Head",
	[Enum.AccessoryType.Neck] = "Torso",
	[Enum.AccessoryType.Shoulder] = "Torso",
	[Enum.AccessoryType.Front] = "Torso",
	[Enum.AccessoryType.Back] = "Torso",
	[Enum.AccessoryType.Waist] = "Torso",
	[Enum.AccessoryType.TShirt] = "Torso",
	[Enum.AccessoryType.Shirt] = "Torso",
	[Enum.AccessoryType.Pants] = "Torso",
	[Enum.AccessoryType.Jacket] = "Torso",
	[Enum.AccessoryType.Sweater] = "Torso",
	[Enum.AccessoryType.Shorts] = "Torso",
	[Enum.AccessoryType.LeftShoe] = "LeftLeg",
	[Enum.AccessoryType.RightShoe] = "RightLeg",
	[Enum.AccessoryType.DressSkirt] = "Torso",
	[Enum.AccessoryType.Eyebrow] = "Head",
	[Enum.AccessoryType.Eyelash] = "Head",
}

local propTable = {
	Name = "Accessory",
	BaseClass = "Accessory",

	-- Accessory-specific
	AccessoryType = Enum.AccessoryType.Unknown,
	AttachmentPoint = "Head",

	MeshObject = nil,
	MeshScale = 1,
	Size = Vector3.new(1, 1, 1),
	Color = nil,
	Transparency = 0,
	TextureId = "",
	CollisionFidelity = Enum.CollisionFidelity.Default,
	RenderFidelity = Enum.RenderFidelity.Automatic,
}

return {
	class = "Accessory",

	callback = function(instance, renderer, game)
		instance:SetProperties(propTable)

		-- Auto-create the Attachment child that describes the offset
		-- relative to the parent body Part
		local attachment = Instance.new("Attachment")
		attachment.Name = "Attachment"
		attachment.CFrame = CFrame.new(0, 0, 0)
		attachment.Parent = instance

		-- Helper: get the attachment child
		-- description: "Gets the Attachment."
		function instance:GetAttachment()
			local att = self:FindFirstChild("Attachment")
			if att and att.ClassName == "Attachment" then
				return att
			end
			return nil
		end

		-- Helper: set the attachment offset CFrame
		-- description: "Sets the attachment's offset"
		-- args: "cf: CFrame"
		function instance:SetAttachmentOffset(cf)
			local att = self:GetAttachment()
			if att then
				att.CFrame = cf
			end
		end

		-- Helper: get the attachment offset CFrame
		-- description: "Gets the attachment's offset."
		function instance:GetAttachmentOffset()
			local att = self:GetAttachment()
			if att then
				return att.CFrame
			end
			return CFrame.new(0, 0, 0)
		end

		instance.Changed:Connect(function(prop, value)
			if prop == "AccessoryType" then
				local defaultPoint = DEFAULT_ATTACHMENT_POINTS[value]
				if defaultPoint then
					instance.AttachmentPoint = defaultPoint
				end
			end
		end)

		return instance
	end,

	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,

	DEFAULT_ATTACHMENT_POINTS = DEFAULT_ATTACHMENT_POINTS,
}
