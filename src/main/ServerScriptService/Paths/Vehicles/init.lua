local Vehicles = {}

--- Main Variables ---
local Paths = require(script.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes

local VehicleModules = {}
for i, v in pairs(script:GetChildren()) do
	VehicleModules[v.Name] = require(v)
end


--- Variables --
local AllVehicles = Services.SStorage.Vehicles

local SpawningDBs = {}



--- Initializing ---
function Vehicles:SetupVehicleButton(Player, Button)
	Button.Hitbox.Touched:Connect(function(Part)
		if Part.Parent:FindFirstChild("Humanoid") then
			local Char = Part.Parent
			
			if game.Players:GetPlayerFromCharacter(Char) == Player and Button:GetAttribute("Vehicle") and not SpawningDBs[Player.Name] then
				SpawningDBs[Player.Name] = true
				
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
	Model.MainPart.Anchored = true
	Model.Parent = CurrentVehicles
	Model:PivotTo(Button.Spawn.CFrame)
	Model.MainPart.Anchored = false
	
	-- Other
	local Seat = Model:WaitForChild("DriverSeat", 3)
	
	if Seat then
		local Prompt = Seat:FindFirstChild("ProximityPrompt")
		local VehicleType = Model:GetAttribute("VehicleType")
		
		if Prompt then
			VehicleModules[VehicleType]:Setup(Model)
		end
	end
end



return Vehicles