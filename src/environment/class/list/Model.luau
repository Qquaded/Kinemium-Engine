-- description: "Represents a Model in the environment."
local Vector3 = require("@Vector3")
local CFrame = require("@CFrame")

return {
	class = "Model",
	-- description: "Initializes the Model instance."
	-- args: "instance: table"
	-- returns: "table"
	callback = function(instance)
		instance:SetProperties({
			WorldPivot = CFrame.new(0, 0, 0),
			PrimaryPart = nil,
			Visible = true,
		})
		instance:SetMetadata("IsMovable", true)

		-- description: "Sets the PrimaryPart."
		-- args: "part: any"
		function instance:SetPrimaryPart(part)
			self.PrimaryPart = part
		end

		-- description: "Gets the PrimaryPartCFrame."
		function instance:GetPrimaryPartCFrame()
			return self.PrimaryPart and self.PrimaryPart.CFrame or self.WorldPivot
		end

		-- description: "Gets the Pivot."
		function instance:GetPivot()
			return self.WorldPivot
		end

		-- description: "Sets the Pivot."
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

		-- description: "Pivots to."
		-- args: "cf: CFrame"
		function instance:PivotTo(cf)
			self:SetPivot(cf)
		end

		-- description: "Moves to."
		-- args: "pos: Vector3"
		function instance:MoveTo(pos)
			local current = self:GetPrimaryPartCFrame()
			self:PivotTo(CFrame.new(pos) * current:ToObjectSpace(current))
		end

		-- description: "Translates by."
		-- args: "offset: number"
		function instance:TranslateBy(offset)
			self:PivotTo(self.WorldPivot + offset)
		end

		-- description: "Rotates by."
		-- args: "rotCF: any"
		function instance:RotateBy(rotCF)
			local pivot = self.WorldPivot
			local newPivot = pivot * rotCF
			self:SetPivot(newPivot)
		end

		-- description: "Scales to."
		-- args: "factor: number"
		function instance:ScaleTo(factor)
			for _, child in ipairs(self:GetChildren()) do
				if child.BaseClass == "BasePart" then
					child.Size = child.Size * factor
					child.CFrame = self.WorldPivot + ((child.CFrame.Position - self.WorldPivot.Position) * factor)
				end
			end
		end

		-- description: "Scales by factor."
		-- args: "factor: number"
		function instance:ScaleByFactor(factor)
			for _, child in ipairs(self:GetChildren()) do
				if child.Size then
					child.Size = child.Size * factor
					child.CFrame = self.WorldPivot + ((child.CFrame.Position - self.WorldPivot.Position) * factor)
				end
			end
		end

		-- description: "Gets the ExtentsSize."
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

		-- description: "Gets the BoundingBox."
		function instance:GetBoundingBox()
			local size = self:GetExtentsSize()
			local center = self.WorldPivot
			return center, size
		end

		-- description: "Gets the Center."
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

		-- description: "Gets the AllParts."
		function instance:GetAllParts()
			local parts = {}
			-- description: "Recurses."
			-- args: "parent: table"
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

		-- description: "Ises empty."
		function instance:IsEmpty()
			return #self:GetChildren() == 0
		end

		-- description: "Sets the Visible."
		-- args: "visible: any"
		function instance:SetVisible(visible)
			for _, child in ipairs(self:GetAllParts()) do
				if child.Transparency ~= nil then
					child.Transparency = visible and 0 or 1
				end
			end
		end

		-- description: "Sets the Transparency."
		-- args: "t: any"
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
