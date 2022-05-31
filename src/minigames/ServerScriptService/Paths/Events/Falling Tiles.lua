local FallingTiles = {}


--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes



--- Event Variables ---
local EVENT_NAME = "Falling Tiles"
local EventValues = Services.RStorage.Modules.EventsConfig.Values
local Participants = Services.RStorage.Modules.EventsConfig.Participants



--- Event Functions ---
function FallingTiles:SpawnPlayers(ChosenBugName, ChosenBugNum)
	local Map = workspace.Event["Event Map"]
	local Spawns = Map.Spawns
	
	for index, playerName in pairs(Participants:GetChildren()) do
		local player = game.Players:FindFirstChild(playerName.Name)
		local SpawnPos = Spawns["Spawn"..index].CFrame * CFrame.new(0, 3, 0)
		
		if player then
			Remotes.Lighting:FireClient(player, EVENT_NAME)
			
			local Character = Modules.Character:Spawn(player, SpawnPos)
			Character.Humanoid.JumpPower = 0
			Character.Humanoid.WalkSpeed = 0
			
			Modules.Collisions.SetCollision(Character, false)
			
			Character.Humanoid.Died:Connect(function()
				playerName:Destroy()
			end)

			player:SetAttribute("Minigame",EVENT_NAME)
		end
	end
end

function FallingTiles:InitiateEvent()
	local Map = workspace.Event["Event Map"]
	Map:Destroy()

	Map = Services.SStorage.EventMaps[EVENT_NAME]:Clone()
	Map.Name = "Event Map"
	Map.Parent = workspace.Event


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
	
	Remotes.Events:FireAllClients("Initiate Event")
end

function FallingTiles:StartEvent()
	local Map = workspace.Event["Event Map"]

	local allPlayers = {}
	-- Activate Event
	Map.Active.Value = true
	Map.Spawns:Destroy()
	local rewardValid = true--#Participants:GetChildren() >= 3
	
	
	-- Give speed back to players
	for index, playerName in pairs(Participants:GetChildren()) do
		local player = game.Players:FindFirstChild(playerName.Name)
		if player and player.Character and player.Character:FindFirstChild("Humanoid") then
			table.insert(allPlayers,player)
			player.Character.Humanoid.WalkSpeed = 18
			Modules.Income:AddGems(game.Players[player.Name], 5, EVENT_NAME)
		end
	end

	Remotes.Events:FireAllClients("Event Started")
	
	local StartTime = tick()
	local FinishTime = StartTime + Modules.EventsConfig[EVENT_NAME].Duration

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
	local n = ""
	if #Participants:GetChildren() == 1 then
		for i, v in pairs(Participants:GetChildren()) do
			if game.Players:FindFirstChild(v.Name) and rewardValid then
				Paths.Remotes.ClientNotif:FireClient(game.Players[v.Name],"You did great, you earned  <font color=\"rgb(62, 210, 255)\">15 gems</font>!",Color3.new(0.184313, 0.752941, 0.792156),6.5)
				Modules.Income:AddGems(game.Players[v.Name],15, EVENT_NAME)
				local data = Modules.PlayerData.sessionData[v.Name] 
				n = v.Name
				if data then
					print(data["Stats"])
					if data["Stats"][EVENT_NAME] then
						data["Stats"][EVENT_NAME] = data["Stats"][EVENT_NAME] + 1
					else
						data["Stats"][EVENT_NAME] =  1
					end
				end
			else
				
			end
			for i,v in pairs (allPlayers) do
				if v and v.Name ~= n then
					Paths.Remotes.ClientNotif:FireClient(v,"You did great, you earned  <font color=\"rgb(62, 210, 255)\">5 gems</font>!",Color3.new(0.184313, 0.752941, 0.792156),6.5)
				end
			end
			return {v.Name}
		end
	end

	

	return false
end

return FallingTiles