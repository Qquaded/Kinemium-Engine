-- description: "Groups parts and other instances so they can be moved, scaled, and queried together."
local Vector3 = require("@Vector3")
local CFrame = require("@CFrame")

return {
	class = "Model",

	callback = function(instance)
		instance:SetProperties({
			WorldPivot = CFrame.new(0, 0, 0),
			PrimaryPart = nil,
			Visible = true,
		})
		instance:SetMetadata("IsMovable", true)

		-- description: "Sets the part used as this model's primary reference part."
		-- args: "part: any"
		function instance:SetPrimaryPart(part)
			self.PrimaryPart = part
		end

		-- description: "Returns the PrimaryPart CFrame, or the WorldPivot when no PrimaryPart is set."
		-- returns: "CFrame"
		function instance:GetPrimaryPartCFrame()
			return self.PrimaryPart and self.PrimaryPart.CFrame or self.WorldPivot
		end

		-- description: "Returns the model's world pivot CFrame."
		-- returns: "CFrame"
		function instance:GetPivot()
			return self.WorldPivot
		end

		-- description: "Sets the model pivot and moves child parts by the same transform offset."
		-- args: "cf: CFrame"
		function instance:SetPivot(cf)
			local offset = cf * self.WorldPivot:Inverse()
			self.WorldPivot = cf
			for _, child in ipairs(self:GetChildren()) do
				if child.CFrame then
					child.CFrame = offset * child.CFrame
				end
			end
		end

		-- description: "Moves the model to a new pivot CFrame."
		-- args: "cf: CFrame"
		function instance:PivotTo(cf)
			self:SetPivot(cf)
		end

		-- description: "Moves the model pivot to a world position while preserving its orientation."
		-- args: "pos: Vector3"
		function instance:MoveTo(pos)
			local current = self:GetPrimaryPartCFrame()
			self:PivotTo(CFrame.new(pos) * current:ToObjectSpace(current))
		end

		-- description: "Offsets the model pivot and child parts by a world-space vector."
		-- args: "offset: Vector3"
		function instance:TranslateBy(offset)
			self:PivotTo(self.WorldPivot + offset)
		end

		-- description: "Rotates the model around its current world pivot."
		-- args: "rotCF: CFrame"
		function instance:RotateBy(rotCF)
			local pivot = self.WorldPivot
			local newPivot = pivot * rotCF
			self:SetPivot(newPivot)
		end

		-- description: "Scales BasePart descendants around the model pivot."
		-- args: "factor: number"
		function instance:ScaleTo(factor)
			for _, child in ipairs(self:GetChildren()) do
				if child.BaseClass == "BasePart" then
					child.Size = child.Size * factor
					child.CFrame = self.WorldPivot + ((child.CFrame.Position - self.WorldPivot.Position) * factor)
				end
			end
		end

		-- description: "Scales sized descendants around the model pivot."
		-- args: "factor: number"
		function instance:ScaleByFactor(factor)
			for _, child in ipairs(self:GetChildren()) do
				if child.Size then
					child.Size = child.Size * factor
					child.CFrame = self.WorldPivot + ((child.CFrame.Position - self.WorldPivot.Position) * factor)
				end
			end
		end

		-- description: "Returns the axis-aligned bounding size of all child parts."
		-- returns: "Vector3"
		function instance:GetExtentsSize()
			local minVec = Vector3.new(math.huge, math.huge, math.huge)
			local maxVec = Vector3.new(-math.huge, -math.huge, -math.huge)

			for _, child in ipairs(self:GetChildren()) do
				if child.Size and child.CFrame then
					local half = child.Size / 2
					local cf = child.CFrame

					local corners = {
						cf * Vector3.new(half.X, half.Y, half.Z),
						cf * Vector3.new(half.X, half.Y, -half.Z),
						cf * Vector3.new(half.X, -half.Y, half.Z),
						cf * Vector3.new(half.X, -half.Y, -half.Z),
						cf * Vector3.new(-half.X, half.Y, half.Z),
						cf * Vector3.new(-half.X, half.Y, -half.Z),
						cf * Vector3.new(-half.X, -half.Y, half.Z),
						cf * Vector3.new(-half.X, -half.Y, -half.Z),
					}

					for _, p in ipairs(corners) do
						minVec = Vector3.new(math.min(minVec.X, p.X), math.min(minVec.Y, p.Y), math.min(minVec.Z, p.Z))
						maxVec = Vector3.new(math.max(maxVec.X, p.X), math.max(maxVec.Y, p.Y), math.max(maxVec.Z, p.Z))
					end
				end
			end

			return maxVec - minVec
		end

		-- description: "Returns the model pivot and bounding size for all child parts."
		-- returns: "CFrame, Vector3"
		function instance:GetBoundingBox()
			local size = self:GetExtentsSize()
			local center = self.WorldPivot
			return center, size
		end

		-- description: "Returns the center point between child part positions."
		-- returns: "Vector3"
		function instance:GetCenter()
			local minVec = Vector3.new(math.huge, math.huge, math.huge)
			local maxVec = Vector3.new(-math.huge, -math.huge, -math.huge)

			for _, child in ipairs(self:GetChildren()) do
				if child.Size and child.CFrame then
					local p = child.CFrame.Position
					minVec = Vector3.new(math.min(minVec.X, p.X), math.min(minVec.Y, p.Y), math.min(minVec.Z, p.Z))
					maxVec = Vector3.new(math.max(maxVec.X, p.X), math.max(maxVec.Y, p.Y), math.max(maxVec.Z, p.Z))
				end
			end

			return (minVec + maxVec) / 2
		end

		-- description: "Returns all descendant parts with Size and CFrame properties."
		-- returns: "{ any }"
		function instance:GetAllParts()
			local parts = {}
			local function recurse(parent)
				for _, child in ipairs(parent:GetChildren()) do
					if child.Size and child.CFrame then
						table.insert(parts, child)
					end
					if child.GetChildren then
						recurse(child)
					end
				end
			end
			recurse(self)
			return parts
		end

		-- description: "Returns whether the model has no direct children."
		-- returns: "boolean"
		function instance:IsEmpty()
			return #self:GetChildren() == 0
		end

		-- description: "Sets descendant part transparency to visible or hidden."
		-- args: "visible: boolean"
		function instance:SetVisible(visible)
			for _, child in ipairs(self:GetAllParts()) do
				if child.Transparency ~= nil then
					child.Transparency = visible and 0 or 1
				end
			end
		end

		-- description: "Sets transparency on every descendant part."
		-- args: "t: number"
		function instance:SetTransparency(t)
			for _, child in ipairs(self:GetAllParts()) do
				if child.Transparency ~= nil then
					child.Transparency = t
				end
			end
		end

		return instance
	end,
}
