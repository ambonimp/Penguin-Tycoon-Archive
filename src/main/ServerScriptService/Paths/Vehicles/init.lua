local Vehicles = {}

--- Main Variables ---
local Paths = require(script.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes

local SailboatBuild = Remotes:WaitForChild("SailboatBuild")
local PlaneBuild = Remotes:WaitForChild("PlaneBuild")

local VehicleModules = {}
for i, v in pairs(script:GetChildren()) do
	VehicleModules[v.Name] = require(v)
end


--- Variables --
local AllVehicles = Services.RStorage.Assets.Vehicles

local SpawningDBs = {}

local function GetTruthsCount(t)
    local Length = 0
    for _, v  in pairs(t) do
        if v then
            Length+= 1
		end
    end

    return Length
end

function SailboatBuild.OnServerInvoke(Player, Item)
	local Data = Modules.PlayerData.sessionData[Player.Name]
	if Data then
		local UnlockingData = Data["BoatUnlocked"]
		Data["BoatUnlocked"][2][Item] = true

		Modules.Achievements.Progress(Player, 11)

		local Completed = true
		for _, Unlocked in pairs (UnlockingData[2]) do
			if not Unlocked then
				Completed = false
				break
			end

		end

		if Completed then
			UnlockingData[1] = true
			Modules.Badges:AwardBadge(Player.UserId, Modules.Badges.Purchases["Sailboat#1"])

			Data["Tycoon"]["Sailboat#1"] = true
			Modules.Placement:NewItem(Player, "Sailboat#1", true)

			local Tycoon = workspace.Tycoons:FindFirstChild(Player:GetAttribute("Tycoon"))

			local Dock = Tycoon.Tycoon:FindFirstChild("Dock#2")
			if Dock then
				local BrokenShip = Dock:FindFirstChild("Building")
				if BrokenShip then
					BrokenShip:Destroy()
				end
			end

		end

		return true
	end

end

function Vehicles:SetUpSailboatBuild(Player)
	local Data = Modules.PlayerData.sessionData[Player.Name]
	print("SET UP BOAT BUILD")
	if Data then
		if Data["Tycoon"]["Dock#2"] then
			local unlocked = Modules.PlayerData.sessionData[Player.Name]["BoatUnlocked"][1]
			if unlocked == false then
				local items = {}
				local Tycoon = workspace.Tycoons:FindFirstChild(Player:GetAttribute("Tycoon"))
				for i,Model in pairs (game.ReplicatedStorage.Assets.BuildA.Sailboat:GetChildren()) do
					if Modules.PlayerData.sessionData[Player.Name]["BoatUnlocked"][2][Model.Name] == false then
						if Model:GetAttribute("InTycoon") then
							local CenterPos = Paths.Template.Center.Position
							local ModelPos = Model:GetPivot().p
							local DiffPos = ModelPos - CenterPos
							
							local TycoonPos = Tycoon.Center.Position
							local Pos = TycoonPos + DiffPos
							local Rotation = Tycoon.Center.Orientation.Y
	
							local x, y, z = Model:GetPivot():ToOrientation()
							local TycoonRotation = CFrame.Angles(x, y, z)-- + math.rad(Rotation), z)
							
							local NewCFrame = CFrame.new(Pos) * TycoonRotation
	
							items[Model.Name] = NewCFrame
						else
							items[Model.Name] = Model:GetPrimaryPartCFrame()
						end
					elseif Modules.PlayerData.sessionData[Player.Name]["BoatUnlocked"][2][Model.Name] then
						items[Model.Name] = true
					end
				end
				Paths.Remotes:WaitForChild("SailboatBuild"):InvokeClient(Player,items)
			else
				local Tycoon = workspace.Tycoons:FindFirstChild(Player:GetAttribute("Tycoon"))
				if Tycoon.Tycoon:FindFirstChild("Dock#2") and Tycoon.Tycoon:FindFirstChild("Dock#2"):FindFirstChild("Building") then
					Tycoon.Tycoon:FindFirstChild("Dock#2"):FindFirstChild("Building"):Destroy()
				end
			end

		end

	end

end

function PlaneBuild.OnServerInvoke(Player,Item)
	local Data = Modules.PlayerData.sessionData[Player.Name]
	if Data then
		local UnlockingData = Data["PlaneUnlocked"]

		Data["PlaneUnlocked"][2][Item] = true
		Modules.Achievements.Progress(Player, 12)

		local Completed = true
		for _, Unlocked in pairs (UnlockingData[2]) do
			if not Unlocked then
				Completed = false
				break
			end

		end

		if Completed then
			Modules.Badges:AwardBadge(Player.UserId, Modules.Badges.Purchases["Plane#1"])

			Data["Tycoon"]["Plane#1"] = true
			Modules.Placement:NewItem(Player, "Plane#1", true)

			Data["PlaneUnlocked"][1] = true
			local Tycoon = workspace.Tycoons:FindFirstChild(Player:GetAttribute("Tycoon"))
			if Tycoon.Tycoon:FindFirstChild("Hot Springs#1") and Tycoon.Tycoon:FindFirstChild("Hot Springs#1"):FindFirstChild("BrokenPlane") then
				Tycoon.Tycoon:FindFirstChild("Hot Springs#1"):FindFirstChild("BrokenPlane"):Destroy()
			end

		end

		return true

	end
	
end


function Vehicles:SetUpPlaneBuild(Player)
	local Data = Modules.PlayerData.sessionData[Player.Name]
	if Data then
		if Data["Tycoon"]["Hot Springs#1"] then
			local unlocked = Modules.PlayerData.sessionData[Player.Name]["PlaneUnlocked"][1]
			if unlocked == false then
				local items = {}
				local Tycoon = workspace.Tycoons:FindFirstChild(Player:GetAttribute("Tycoon"))
				for i,Model in pairs (game.ReplicatedStorage.Assets.BuildA.Plane:GetChildren()) do
					if Modules.PlayerData.sessionData[Player.Name]["PlaneUnlocked"][2][Model.Name] == false then
						if Model:GetAttribute("InTycoon") then
							local CenterPos = Paths.Template.Center.Position
							local ModelPos = Model:GetPivot().p
							local DiffPos = ModelPos - CenterPos
							
							local TycoonPos = Tycoon.Center.Position
							local Pos = TycoonPos + DiffPos
							local Rotation = Tycoon.Center.Orientation.Y
	
							local x, y, z = Model:GetPivot():ToOrientation()
							local TycoonRotation = CFrame.Angles(x, y, z)-- + math.rad(Rotation), z)
							
							local NewCFrame = CFrame.new(Pos) * TycoonRotation
	
							items[Model.Name] = NewCFrame
						else
							items[Model.Name] = Model:GetPrimaryPartCFrame()
						end
					elseif Modules.PlayerData.sessionData[Player.Name]["PlaneUnlocked"][2][Model.Name] then
						items[Model.Name] = true
					end
				end
				Paths.Remotes:WaitForChild("PlaneBuild"):InvokeClient(Player,items)
			else
				local Tycoon = workspace.Tycoons:FindFirstChild(Player:GetAttribute("Tycoon"))
				if Tycoon.Tycoon:FindFirstChild("Hot Springs#1") and Tycoon.Tycoon:FindFirstChild("Hot Springs#1"):FindFirstChild("BrokenPlane") then
					Tycoon.Tycoon:FindFirstChild("Hot Springs#1"):FindFirstChild("BrokenPlane"):Destroy()
				end
			end
		end
	end
end


--- Initializing ---
function Vehicles:SetupVehicleButton(Player, Button)
	Button.Hitbox.Touched:Connect(function(Part)
		if Part.Parent:FindFirstChild("Humanoid") then
			local Char = Part.Parent
			
			if game.Players:GetPlayerFromCharacter(Char) == Player and Button:GetAttribute("Vehicle") and not SpawningDBs[Player.Name] then
				SpawningDBs[Player.Name] = true
				if Button:GetAttribute("Vehicle") == "Sailboat" then
					local unlocked = Modules.PlayerData.sessionData[Player.Name]["BoatUnlocked"][1]
					if not unlocked then
						task.wait(1)
						SpawningDBs[Player.Name] = nil
						return
					end
				elseif Button:GetAttribute("Vehicle") == "Plane" then
					local unlocked = Modules.PlayerData.sessionData[Player.Name]["PlaneUnlocked"][1]
					if not unlocked then
						task.wait(1)
						SpawningDBs[Player.Name] = nil
						return
					end
				end
				Vehicles:SpawnButtonVehicle(Player, Button)
				task.wait(1)
				SpawningDBs[Player.Name] = nil
			end
		end

	end)

end

function Vehicles:SpawnButtonVehicle(Player, Button)
	-- Vehicle variables
	local Vehicle = Button:GetAttribute("Vehicle")
	Vehicles:SpawnVehicle(Player, Button:GetAttribute("Vehicle"), Button.Spawn.CFrame)
end

function Vehicles:SpawnVehicle(Player, Vehicle, CF)
	-- Get player info
	local Tycoon = Modules.Ownership:GetPlayerTycoon(Player)
	local CurrentVehicles = Tycoon.Vehicles

	-- Remove current Vehicle if it's spawned
	if CurrentVehicles:FindFirstChild(Vehicle) then
		CurrentVehicles[Vehicle]:Destroy()
	end

	-- Spawn new Vehicle
	local Model = AllVehicles[Vehicle]:Clone()
	local last = Model.MainPart.Anchored
	Model.MainPart.Anchored = true
	Model.Parent = CurrentVehicles
	Model:PivotTo(CF)
	Model.MainPart.Anchored = last

	-- Other
	local Seat = Model:WaitForChild("DriverSeat", 3)

	if Seat then
		local Prompt = Seat:FindFirstChild("ProximityPrompt")
		local VehicleType = Model:GetAttribute("VehicleType")

		if Prompt then
			VehicleModules[VehicleType]:Setup(Model)
		end

		task.wait(2.5)
		if Seat.Occupant == nil then
			Model.MainPart.Anchored = true
		end
	end
end

Modules.Achievements.Reconciled:Connect(function(Data)
	Modules.Achievements.ReconcileSet(Data, 11, GetTruthsCount(Data["BoatUnlocked"][2]))
	Modules.Achievements.ReconcileSet(Data, 12, GetTruthsCount(Data["PlaneUnlocked"][2]))
end)

return Vehicles