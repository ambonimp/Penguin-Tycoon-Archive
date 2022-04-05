local Collisions = {}

--- Main Variables ---
local Paths = require(script.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes



--- Collision Variables ---
local playerCollisionGroupName = "Players"
local previousCollisionGroups = {}



--- Collision Functions ---
Services.PhysicsService:CreateCollisionGroup(playerCollisionGroupName)
Services.PhysicsService:CollisionGroupSetCollidable(playerCollisionGroupName, playerCollisionGroupName, false)

local function resetCollisionGroup(object)
	local previousCollisionGroupId = previousCollisionGroups[object]
	if not previousCollisionGroupId then return end 

	local previousCollisionGroupName = Services.PhysicsService:GetCollisionGroupName(previousCollisionGroupId)
	if not previousCollisionGroupName then return end

	Services.PhysicsService:SetPartCollisionGroup(object, previousCollisionGroupName)
	previousCollisionGroups[object] = nil
end


function Collisions.SetCollision(Model, Toggle)
	Model.DescendantRemoving:Connect(resetCollisionGroup)
	
	for _, object in ipairs(Model:GetChildren()) do
		if object:IsA("BasePart") then
			if not Toggle then -- set to NO COLLISIONS
				previousCollisionGroups[object] = object.CollisionGroupId
				Services.PhysicsService:SetPartCollisionGroup(object, playerCollisionGroupName)
				
			else
				resetCollisionGroup(object)
			end
		end
	end
end


-- Permanent collision off for player-player
--game.Players.PlayerAdded:Connect(function(player)
--	player.CharacterAdded:Connect(function(character)
--		setCollisionFalse(character)

--		character.DescendantRemoving:Connect(resetCollisionGroup)
--	end)
--end)



return Collisions