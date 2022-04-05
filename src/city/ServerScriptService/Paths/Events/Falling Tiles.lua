local FallingTiles = {}


--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes



--- Event Variables ---
local EventValues = Services.RStorage.Modules.EventsConfig.Values
local Participants = Services.RStorage.Modules.EventsConfig.Participants
local Votes = Services.RStorage.Modules.EventsConfig.Votes



--- Event Functions ---
function FallingTiles:SpawnPlayers(ChosenBugName, ChosenBugNum)
	local Map = workspace.Event["Event Map"]
	local Spawns = Map.Spawns
	
	for index, playerName in pairs(Participants:GetChildren()) do
		local player = game.Players:FindFirstChild(playerName.Name)
		local SpawnPos = Spawns["Spawn"..index].CFrame * CFrame.new(0, 3, 0)
		
		if player then
			Remotes.Lighting:FireClient(player, "Falling Tiles")
			
			local Character = Modules.Character:Spawn(player, SpawnPos)
			Character.Humanoid.JumpPower = 0
			Character.Humanoid.WalkSpeed = 0
			
			Modules.Collisions.SetCollision(Character, false)
			
			Character.Humanoid.Died:Connect(function()
				playerName:Destroy()
			end)

			player:SetAttribute("Minigame","Falling Tiles")
		end
	end
end

function FallingTiles:InitiateEvent(Event)
	local Map = workspace.Event["Event Map"]

	EventValues.TextToDisplay.Value = "Initiating Tiles..."
	-- Initiate Tiles
	local TilesTouched = {}

	for i, Layer in pairs(Map.Layers:GetChildren()) do
		for i, Tile in pairs(Layer:GetChildren()) do
			if i%10 == 0 then wait() end
			Tile.TileHitbox.Touched:Connect(function(part)
				if string.match(part.Name, "Leg") and not TilesTouched[Tile] and Map.Active.Value == true then
					if part.Parent:FindFirstChild("Humanoid") then
						TilesTouched[Tile] = true

						coroutine.resume(coroutine.create(function()
							wait(0.5)
							Tile:Destroy()
						end))
					end
				end
			end)
		end
	end
	
	Remotes.Events:FireAllClients("Initiate Event", Event)
end

function FallingTiles:StartEvent()
	local Map = workspace.Event["Event Map"]
	
	
	-- Activate Event
	Map.Active.Value = true
	Map.Spawns:Destroy()
	local rewardValid = true--#Participants:GetChildren() >= 3
	
	
	-- Give speed back to players
	for index, playerName in pairs(Participants:GetChildren()) do
		local player = game.Players:FindFirstChild(playerName.Name)
		if player and player.Character and player.Character:FindFirstChild("Humanoid") then
			player.Character.Humanoid.WalkSpeed = 18
			Modules.Income:AddGems(game.Players[player.Name], 2, "Falling Tiles")
		end
	end

	Remotes.Events:FireAllClients("Event Started", "Falling Tiles")
	
	local StartTime = tick()
	local FinishTime = StartTime + Modules.EventsConfig["Falling Tiles"].Duration

	EventValues.TextToDisplay.Value = "GO!!"
	wait(1)
	
	
	-- Setup death part
	local TouchDb = {}
	
	Map.KillingFloor.Touched:Connect(function(Part)
		if Part.Name == "HumanoidRootPart" and Part.Parent:FindFirstChild("Humanoid") and game.Players:FindFirstChild(Part.Parent.Name) and not TouchDb[Part.Parent] then
			TouchDb[Part] = true

			Part.Parent.Humanoid.Health = 0
			
			task.wait(1)
			TouchDb[Part] = nil
		end
	end)
	
	-- Start the event
	repeat
		task.wait()
		
		EventValues.TextToDisplay.Value = "In Progress - "..#Participants:GetChildren().. " Player(s) Left"
		
		
	until #Participants:GetChildren() <= 1 or tick() > FinishTime

	if #Participants:GetChildren() == 1 then
		for i, v in pairs(Participants:GetChildren()) do
			if game.Players:FindFirstChild(v.Name) and rewardValid then
				Modules.Income:AddGems(game.Players[v.Name],15, "Falling Tiles")
				local data = Modules.PlayerData.sessionData[v.Name] 
				
				if data then
					print(data["Stats"])
					if data["Stats"]["Falling Tiles"] then
						data["Stats"]["Falling Tiles"] = data["Stats"]["Falling Tiles"] + 1
					else
						data["Stats"]["Falling Tiles"] =  1
					end
				end
			end
			
			return {v.Name}
		end
	end

	return false
end

return FallingTiles