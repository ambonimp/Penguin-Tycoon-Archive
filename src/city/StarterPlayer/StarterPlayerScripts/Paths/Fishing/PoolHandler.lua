local runService = game:GetService("RunService")
local physicsService = game:GetService("PhysicsService")
local rs = game:GetService("ReplicatedStorage")
local players = game:GetService("Players")

-- variables
local localPlayer = players.LocalPlayer
local activePools = workspace:WaitForChild("ActivePools")

local PoolHandler = {}

function PoolHandler.SetCollisionGroup(model, collisionGroup)
	for _, object in pairs(model:GetDescendants()) do
		if object:IsA("BasePart") then
			physicsService:SetPartCollisionGroup(object, collisionGroup)
		end
	end
end

function PoolHandler.Main()
	for _, pool: Model in pairs(activePools:GetChildren()) do
		local character = localPlayer.Character
		if not character or pool:GetAttribute("AddedCollision") then continue end
		local magnitude = (character:GetPivot().Position - pool:GetPivot().Position).Magnitude
		
		if magnitude < 180 then
			pool:SetAttribute("AddedCollision", true)
			PoolHandler.SetCollisionGroup(pool, "Pool")
		end		
	end
end

return PoolHandler
