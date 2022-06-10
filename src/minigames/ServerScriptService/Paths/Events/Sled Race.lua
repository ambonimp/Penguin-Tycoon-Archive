local Players = game:GetService("Players")
local SledRace = {}

--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes

--- Event Variables ---
local EVENT_NAME = script.Name
local WINNER_REWARDS = {7, 5, 3}
local PARTICIPATION_REWARD = 1


local Config = Modules.EventsConfig[EVENT_NAME]
local EventValues = Services.RStorage.Modules.EventsConfig.Values
local Participants = Services.RStorage.Modules.EventsConfig.Participants
local Assets = Services.RStorage.Assets[EVENT_NAME]


local Map, SpawnPoints
local Collectables, Identifier

local function RewardGems(Player, Amount)
	Modules.Income:AddGems(Player,  Amount, EVENT_NAME)
end

local function RelayToParticipants(...)
	for _, PlayerName in ipairs(Participants:GetChildren()) do
		local Player = game.Players:FindFirstChild(PlayerName.Name)
		if Player then
			Remotes.SledRace:FireClient(Player, ...)
		end
	end
end

local function LoadCollectables(Type, Count)
	local Spawns = Map.CollectableSpawns[Type]:GetChildren()

	for i = Count, 1, -1 do
		local Index = math.random(1, #Spawns)
		local ChosenSpawn = Spawns[Index]
		table.remove(Spawns, Index)

		Identifier += 1

		local Collectable = {}
		Collectable.Position = ChosenSpawn.Position
		Collectable.Type = Type

		local Models = Assets.Collectables[Collectable.Type]:GetChildren()
		Collectable.Model = Models[math.random(1, #Models)]

		Collectables[Identifier] = Collectable

	end

end



--- Event Functions ---
function SledRace:SpawnPlayers(ChosenBugName, ChosenBugNum)
	for i, Participant in pairs(Participants:GetChildren()) do
		local Player = game.Players:FindFirstChild(Participant.Name)

		local SpawnPoint = SpawnPoints[i]
		local SpawnCFrame = SpawnPoint.CFrame

		if Player then
			Player:SetAttribute("Minigame", EVENT_NAME)

			local Character = Modules.Character:Spawn(Player)
			Modules.Collisions.SetCollision(Character, false)

			local Hum = Character.Humanoid
			Hum.WalkSpeed = 0
			Hum.Died:Connect(function()
				Participant:Destroy()
			end)

			for _, BasePart in ipairs(Character:GetDescendants()) do
				if BasePart:IsA("BasePart") then
					Services.PhysicsService:SetPartCollisionGroup(BasePart, "SledCharacter")
					BasePart.Massless = true
				end
			end

            local Sled = Assets.Sled:Clone()
			local PrimaryPart = Sled.PrimaryPart
            PrimaryPart.AlignPosition.Position = SpawnCFrame.Position
            PrimaryPart.AlignOrientation.CFrame = SpawnCFrame
            PrimaryPart.Anchored = true
			Sled:SetPrimaryPartCFrame(SpawnCFrame)

            Sled.Parent = workspace
            Sled.Seat:Sit(Hum)
            Sled.Parent = Character

			for _, BasePart in ipairs(Sled:GetDescendants()) do
				if BasePart:IsA("BasePart") then
					Services.PhysicsService:SetPartCollisionGroup(BasePart, "Sled")
					BasePart.Massless = true
				end
			end

		end

	end

end

function SledRace:InitiateEvent()
	Map = workspace.Event["Event Map"]
	SpawnPoints = Map.PlayerSpawns:GetChildren()

	EventValues.Timer.Value = Config.Duration
	EventValues.Timer:SetAttribute("Enabled", true)

	EventValues.TextToDisplay.Value = "Initiating Sled Race..."

	-- Spawn collectables
	Identifier = 0
	Collectables = {}

	LoadCollectables("Boost", 10)
	LoadCollectables("Obstacle", 30)

	Remotes.Events:FireAllClients("Initiate Event", Collectables)

end

function SledRace:StartEvent()
	local StartTime = os.time() + 1
	local TimeLeft = Config.Duration

	local Velocities = {}
	for _, Participant in pairs(Participants:GetChildren()) do
		local Player = game.Players:FindFirstChild(Participant.Name)
		local Character = Player.Character

		local Sled = Character.Sled
		local PrimaryPart = Sled.PrimaryPart
		PrimaryPart.Anchored = false
		PrimaryPart:SetNetworkOwner(Player)

		Velocities[Player] = Config.DefaultVelocity
	end

	Remotes.Events:FireAllClients("Event Started")
    EventValues.TextToDisplay.Value = "Be the first to reach the bottom!"


	-- Used to track when to end the round
	local CompletedRace = {}

	local Conn = Remotes.SledRace.OnServerEvent:Connect(function(Client, Event, ...)
		local Params = table.pack(...)

		if Event == "OnRaceFinished" then
			if Participants:FindFirstChild(Client.Name) then
				table.insert(CompletedRace, {
					PlayerName = Client.Name,
					Score = os.time() - StartTime
				})

				RelayToParticipants("OnSomeoneCompletedRace", CompletedRace)
			end

		elseif Event == "OnCollectableCollected" then
			local Id = Params[1]
			local Collectable = Collectables[Id]

			if Collectable then
				Collectables[Id] = nil

				if Collectable.Type == "Boost" then
					Velocities[Client] = math.min(Config.MaxVelocity, Velocities[Client] + Config.BoostVelocityAddend)
				else
					Velocities[Client] = math.max(Config.MinVelocity, Velocities[Client] + Config.ObstacleVelocityAddend)
				end

			end
		end

	end)

	repeat
		TimeLeft = math.floor(TimeLeft - task.wait(1))
		EventValues.Timer.Value = TimeLeft
	until #CompletedRace >= #Participants:GetChildren() or TimeLeft <= 0

	Conn:Disconnect()

	local Winners = {}
	for i, Ranked in ipairs(CompletedRace) do
		local PlayerName = Ranked.PlayerName
		local Time = Ranked.Score

		local Player = game.Players:FindFirstChild(PlayerName)

		if i == 1 then
			local Data = Modules.PlayerData.sessionData[PlayerName]
			if Data then
				local Stats = Data["Stats"]
				local PreviousTime =  Stats[EVENT_NAME]

				if PreviousTime then
					if Time < PreviousTime then
						Stats[EVENT_NAME] = Time
					end
				else
					Stats[EVENT_NAME] = Time
				end

			end
		end

		if i <= 3 then
			table.insert(Winners, PlayerName)
			RewardGems(Player, WINNER_REWARDS[i])
		else
			RewardGems(Player, PARTICIPATION_REWARD)
		end
	end

	return #Winners > 0 and Winners or nil

end

Remotes.GetUserThumbnail.OnServerInvoke = function(_, Player)
	if not Player then return "" end
	return Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size180x180)
end


return SledRace