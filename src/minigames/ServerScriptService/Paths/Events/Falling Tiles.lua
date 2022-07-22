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
local Config = Modules.EventsConfig[EVENT_NAME]

local WINNER_REWARD = 7
local PARTICIPATION_REWARD = 1


local Map, SpawnPoints


local function RewardGems(Player, Amount)
	Modules.Income:AddGems(Player,  Amount, EVENT_NAME)
end

--- Event Functions ---
function FallingTiles:SpawnPlayers(ChosenBugName, ChosenBugNum)
	for i, Participant in pairs(Participants:GetChildren()) do
		local Player = game.Players:FindFirstChild(Participant.Name)
		local SpawnPos = SpawnPoints[i].CFrame * CFrame.new(0, 3, 0)
		
		if Player then
			Player:SetAttribute("Minigame", EVENT_NAME)
			
			local Character = Modules.Character:Spawn(Player, SpawnPos)
			Character.Humanoid.JumpPower = 0
			Character.Humanoid.WalkSpeed = 0
			
			Modules.Collisions.SetCollision(Character, false)
			Character.Humanoid.Died:Connect(function()
				Participant:Destroy()
			end)

		end

	end

end

function FallingTiles:InitiateEvent()
	Map = workspace.Event["Event Map"]

	Map:Destroy()

	Map = Services.SStorage.EventMaps[EVENT_NAME]:Clone()
	Map.Name = "Event Map"
	Map.Parent = workspace.Event

	SpawnPoints = Map.PlayerSpawns:GetChildren()


	EventValues.Timer.Value = Config.Duration
	EventValues.Timer:SetAttribute("Enabled", true)

	EventValues.TextToDisplay.Value = "Initiating Tiles..."

	Remotes.Events:FireAllClients("Initiate Event")


	-- Initiate Tiles
	local TilesTouched = {}
	for _, Layer in pairs(Map.Layers:GetChildren()) do
		for i, Tile in pairs(Layer:GetChildren()) do
			if i%10 == 0 then
				task.wait()
			end

			Tile.Hitbox.Touched:Connect(function(Hit)
				if(string.find(Hit.Name, "Leg") or Hit.Name == "Main") and not TilesTouched[Tile] and Map.Active.Value == true then
					if Hit.Parent:FindFirstChild("Humanoid") then
						TilesTouched[Tile] = true

						coroutine.resume(coroutine.create(function()
							task.wait(0.6)
							Tile:Destroy()
						end))

					end

				end

			end)

		end

	end

end

function FallingTiles:StartEvent()
	local TimeLeft = Config.Duration

	-- Activate Event
	Map.Active.Value = true
	Map.PlayerSpawns:Destroy()

	local Participated = {}
	-- Give speed back to players
	for _, Participant in pairs(Participants:GetChildren()) do
		local Player = game.Players:FindFirstChild(Participant.Name)
		if Player then
			Player.Character.Humanoid.WalkSpeed = 18
			table.insert(Participated, Player)
		else
			Participant:Destroy()
		end
	end

	Remotes.Events:FireAllClients("Event Started")

	-- Setup death part
	local Rankings = {}
	local Debounces = {}
	Map.KillingFloor.Touched:Connect(function(Hit)
		local Character = Hit.Parent
		local Name = Character.Name
		local Hum = Character:FindFirstChild("Humanoid")

		if Hum and not Debounces[Character] and game.Players:FindFirstChild(Name) then
			Debounces[Character] = true
			Hit.Parent.Humanoid.Health = 0

			table.insert(Rankings, {
				PlayerName = Name,
			})

		end

	end)

	-- Start the event
	EventValues.TextToDisplay.Value = "Stay alive"

	repeat
		task.wait(1)
		TimeLeft -= 1

		EventValues.Timer.Value = TimeLeft

		EventValues.TextToDisplay.Value = "In Progress - "..#Participants:GetChildren().. " Player(s) Left"
	until #Participants:GetChildren() == 0 or TimeLeft <= 0


	-- These people won
	local Winners = {}
	Rankings[#Rankings+1] = Winners
	for _, Participant in ipairs(Participants:GetChildren()) do
		table.insert(Winners, {
			PlayerName = Participant.Name,
		})
	end
	if #Winners == 0 then Rankings[#Rankings] = nil end


	-- Display rankings
	for _, Player in ipairs(Participated) do
		Remotes.FallingTiles:FireClient(Player, "Finished", Modules.FuncLib.ArrayFlip(Rankings))
	end

	-- Leaderboard stuff
	for i, Winner in ipairs(Winners) do
		local Name = Winner.PlayerName
		Winners[i] = Name


		local Data = Modules.PlayerData.sessionData[Name]
		if Data then
			local Stats = Data["Stats"]

			if Stats[EVENT_NAME] then
				Stats[EVENT_NAME] += 1
			else
				Stats[EVENT_NAME] = 1
			end

		end
		Modules.Quests.GiveQuest(game.Players:FindFirstChild(Name),"Win","Minigame","Falling Tiles",1)
		Modules.Quests.GiveQuest(game.Players:FindFirstChild(Name),"Win","Minigame","All",1)
	end

	-- Reward
	for _, Player in ipairs(Participated) do
		if table.find(Winners, Player.Name) then
			RewardGems(Player, WINNER_REWARD)
			
		else
			RewardGems(Player, PARTICIPATION_REWARD)
		end
	end


	return #Winners > 0 and Winners or nil
end

return FallingTiles