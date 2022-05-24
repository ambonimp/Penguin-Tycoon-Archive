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
local AllVehicles = Services.SStorage.Vehicles

local SpawningDBs = {}

function SailboatBuild.OnServerInvoke(Player,item)
	local Data = Modules.PlayerData.sessionData[Player.Name]

	if Data then
		Modules.PlayerData.sessionData[Player.Name]["BoatUnlocked"][2][item] = true

		local alltrue = true

		for i,v in pairs (Modules.PlayerData.sessionData[Player.Name]["BoatUnlocked"][2]) do
			if v == false then
				alltrue = false
				break
			end
		end
		if alltrue then
			Modules.Badges:AwardBadge(Player.UserId, Modules.Badges.Purchases["Sailboat#1"])
			Modules.PlayerData.sessionData[Player.Name]["Tycoon"]["Sailboat#1"] = true
			Modules.Placement:NewItem(Player, "Sailboat#1", true)
			Modules.PlayerData.sessionData[Player.Name]["BoatUnlocked"][1] = true
			local Tycoon = workspace.Tycoons:FindFirstChild(Player:GetAttribute("Tycoon"))
			if Tycoon.Tycoon:FindFirstChild("Dock#2") and Tycoon.Tycoon:FindFirstChild("Dock#2"):FindFirstChild("Building") then
				Tycoon.Tycoon:FindFirstChild("Dock#2"):FindFirstChild("Building"):Destroy()
			end
		end
		return Modules.PlayerData.sessionData[Player.Name]["BoatUnlocked"]
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
				for i,Model in pairs (game.ReplicatedStorage.BoatBuildParts:GetChildren()) do
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

function PlaneBuild.OnServerInvoke(Player,item)
	local Data = Modules.PlayerData.sessionData[Player.Name]
	print("ATTEMPTED UNLOCK ITEM",item)
	if Data then
		Modules.PlayerData.sessionData[Player.Name]["PlaneUnlocked"][2][item] = true
		print(Modules.PlayerData.sessionData[Player.Name]["PlaneUnlocked"][2],"SET ITEM")
		local alltrue = true

		for i,v in pairs (Modules.PlayerData.sessionData[Player.Name]["PlaneUnlocked"][2]) do
			if v == false then
				alltrue = false
				break
			end
		end
		if alltrue then
			Modules.Badges:AwardBadge(Player.UserId, Modules.Badges.Purchases["Plane#1"])
			Modules.PlayerData.sessionData[Player.Name]["Tycoon"]["Plane#1"] = true
			Modules.Placement:NewItem(Player, "Plane#1", true)
			Modules.PlayerData.sessionData[Player.Name]["PlaneUnlocked"][1] = true
			local Tycoon = workspace.Tycoons:FindFirstChild(Player:GetAttribute("Tycoon"))
			if Tycoon.Tycoon:FindFirstChild("Dock#2") and Tycoon.Tycoon:FindFirstChild("Dock#2"):FindFirstChild("BrokenPlane") then
				Tycoon.Tycoon:FindFirstChild("Dock#2"):FindFirstChild("BrokenPlane"):Destroy()
			end
		end
		return Modules.PlayerData.sessionData[Player.Name]["PlaneUnlocked"]
	end
	
end


function Vehicles:SetUpPlaneBuild(Player)
	local Data = Modules.PlayerData.sessionData[Player.Name]
	if Data then
		if Data["Tycoon"]["Dock#2"] then
			local unlocked = Modules.PlayerData.sessionData[Player.Name]["PlaneUnlocked"][1]
			if unlocked == false then
				local items = {}
				local Tycoon = workspace.Tycoons:FindFirstChild(Player:GetAttribute("Tycoon"))
				for i,Model in pairs (game.ReplicatedStorage.PlaneBuildParts:GetChildren()) do
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
				if Tycoon.Tycoon:FindFirstChild("Dock#2") and Tycoon.Tycoon:FindFirstChild("Dock#2"):FindFirstChild("BrokenPlane") then
					Tycoon.Tycoon:FindFirstChild("Dock#2"):FindFirstChild("BrokenPlane"):Destroy()
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
				Vehicles:SpawnVehicle(Player, Button)
				task.wait(1)
				SpawningDBs[Player.Name] = nil
			end
		end
	end)
end

function Vehicles:SpawnVehicle(Player, Button)
	-- Vehicle variables
	local Vehicle = Button:GetAttribute("Vehicle")
	
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
	Model:PivotTo(Button.Spawn.CFrame)
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



return Vehicles