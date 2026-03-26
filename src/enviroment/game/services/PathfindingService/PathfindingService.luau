local Instance = require("@Instance")
local NavMesh = require("@Navmesh")
local Enum = require("@EnumMap")
local task = zune.task

local PathfindingService = Instance.new("PathfindingService")
PathfindingService.ExplorerHidden = true

local currentNavMesh = nil
local _isBuilding = false

local function getOrBuildNavMesh(datamodel)
	if not currentNavMesh then
		currentNavMesh = NavMesh.new()
		currentNavMesh:CreateFromWorkspace(datamodel:GetService("Workspace"))
	end
	return currentNavMesh
end

PathfindingService.InitEnviroment = function(enviroment, datamodel)
	if not Enum.PathStatus then
		Enum.PathStatus = {
			Success = 0,
			NoPath = 1,
		}
	end
	if not Enum.PathWaypointAction then
		Enum.PathWaypointAction = {
			Walk = 0,
			Jump = 1,
		}
	end

	PathfindingService:SetProperties({
		CreatePath = function(self, agentParameters)
			agentParameters = agentParameters or {}
			local agentRadius = agentParameters.AgentRadius or 2
			local agentHeight = agentParameters.AgentHeight or 5

			local pathObj = {}
			pathObj.Status = Enum.PathStatus.NoPath
			pathObj._waypoints = {}

			function pathObj:ComputeAsync(startPos, endPos)
				local nav = getOrBuildNavMesh(datamodel)
				local result = nav:FindPath(startPos, endPos)

				if result.success then
					local smoothed = nav:SmoothPath(result.path)
					local waypoints = {}
					for i, point in ipairs(smoothed) do
						table.insert(waypoints, {
							Position = point,
							Action = Enum.PathWaypointAction.Walk,
						})
					end
					self._waypoints = waypoints
					self.Status = Enum.PathStatus.Success
				else
					self._waypoints = {}
					self.Status = Enum.PathStatus.NoPath
				end
			end

			function pathObj:GetWaypoints()
				return self._waypoints
			end

			return pathObj
		end,

		FindPathAsync = function(self, startPos, endPos)
			local nav = getOrBuildNavMesh(datamodel)
			local result = nav:FindPath(startPos, endPos)
			return result.success, nav:SmoothPath(result.path)
		end,

		InvalidateNavMesh = function(self)
			currentNavMesh = nil
		end,
	})

	return PathfindingService
end

return PathfindingService
