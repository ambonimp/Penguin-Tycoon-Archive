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


local Map, SpawnPoints, RParams
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

local function GetNormalIncline(RaycastResults)
    local V1 = Vector3.new(0, 1, 0)
    local V2 = RaycastResults.Normal
    return -math.acos(math.clamp(V1:Dot(V2),-1,1)) / (V1.Magnitude*V2.Magnitude)
end

local function LoadCollectables(Type, Count)
	local Spawns = Map.CollectableSpawns[Type]:GetChildren()

	for i = Count, 1, -1 do
		-- Get spawn point
		local Index = math.random(1, #Spawns)
		local ChosenSpawn = Spawns[Index]
		table.remove(Spawns, Index)

		-- Load model
		Identifier += 1

		local Models = Assets.Collectables[Type]:GetChildren()
        local Model = Models[math.random(1, #Models)]:Clone()
        Model.Name = Identifier
        Model.Parent = Map.Collectables

		local Position = ChosenSpawn.Position
        local CenterCFrame, Size = Model:GetBoundingBox()
        local PrimaryPartOffset = CenterCFrame:ToObjectSpace(Model.PrimaryPart.CFrame)

        local Results = assert(workspace:Raycast(Position, Vector3.new(0, -50, 0), RParams))
        local FloorCFrame = CFrame.new(Results.Position) * CFrame.fromEulerAnglesYXZ(-GetNormalIncline(Results), math.pi, 0)

		Model:SetPrimaryPartCFrame(FloorCFrame * PrimaryPartOffset * CFrame.new(Size * Vector3.new(0, 0.5, 0)))


		Collectables[Identifier] = {
			Type = Type,
			Model = Model
		}

	end

end



--- Event Functions ---

function SledRace:InitiateEvent()
	Map = workspace.Event["Event Map"]
	SpawnPoints = Map.PlayerSpawns:GetChildren()

    RParams = RaycastParams.new()
    RParams.FilterDescendantsInstances = Map.Course:GetChildren()
    RParams.FilterType = Enum.RaycastFilterType.Whitelist


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


function SledRace:StartEvent()
	local TimeLeft = Config.Duration

	local Velocities = {}
	local LastPositions = {}
	local SpeedInfractions = {}
	for _, Participant in pairs(Participants:GetChildren()) do
		local Player = game.Players:FindFirstChild(Participant.Name)
		local Character = Player.Character

		local Sled = Character.Sled
		local PrimaryPart = Sled.PrimaryPart
		PrimaryPart.Anchored = false
		PrimaryPart:SetNetworkOwner(Player)

		Velocities[Player] = Config.DefaultVelocity
		LastPositions[Player] = PrimaryPart.Position
		SpeedInfractions[Player] = {}
	end

	Remotes.Events:FireAllClients("Event Started")
    EventValues.TextToDisplay.Value = "Be the first to reach the bottom!"

	-- Anti exploints


	local CompletedRace = {}
	local Conn = Remotes.SledRace.OnServerEvent:Connect(function(Client, Event, ...)
		local Params = table.pack(...)

		if Event == "OnRaceFinished" then
			local PlayerName = Client.Name
			local Time = Config.Duration - TimeLeft

			-- Anti exploit
			local Infractions = SpeedInfractions[Client]
			local InvalidScore = false
			if #Infractions > 3 then
				InvalidScore = true
			else
				for _, Deviation in ipairs(Infractions) do
					if Deviation > 500 then
						InvalidScore = true
					end
				end
			end

			if InvalidScore or Time <= 35 then
				warn(Client, "Score invalidated", #Infractions, Time)
				return
			end


			if Participants:FindFirstChild(PlayerName) then
				local Data = Modules.PlayerData.sessionData[PlayerName]

				if Data then
					local Stats = Data["Stats"]
					local PreviousRecord =  Stats[EVENT_NAME]
					local FormattedTime = math.floor(Time * 100)

					if not PreviousRecord or PreviousRecord == 0 then
						Stats[EVENT_NAME] = FormattedTime
					else
						-- Previously set this to doubles, this corrects that
						if PreviousRecord < 100 then
							PreviousRecord *= 100
							Stats[EVENT_NAME] = PreviousRecord
						end

						if FormattedTime < PreviousRecord then
							Stats[EVENT_NAME] = FormattedTime
						end

					end

				end

				table.insert(CompletedRace, {
					PlayerName = Client.Name,
					Score = Time
				})

			end

		elseif Event == "OnCollectableCollected" then -- Track velocity for anti exploit
			if not Client.Parent then return end

			local Id = Params[1]
			local Collectable = Collectables[Id]

			if Collectable then
				local Addend = if Collectable.Type == "Boost" then Config.BoostVelocityAddend else -Config.ObstacleVelocityMinuend
				Velocities[Client] = math.clamp(Velocities[Client] + Addend, Config.MinVelocity, Config.MaxVelocity)

				task.delay(Config.CollectableEffectDuration, function() --Longer  to account for latency
					Velocities[Client] = math.clamp(Velocities[Client] - Addend, Config.MinVelocity, Config.MaxVelocity)
				end)

			end

		end

	end)

	-- Anti exploit
	task.spawn(function()
		while Conn do -- Just a random flag to check race finished
			local dt = task.wait(0.1)
			for Player, LastPosition in pairs(LastPositions) do
				if Participants:FindFirstChild(Player.Name) then -- Still playing
					local Position = Player.Character.Sled.PrimaryPart.Position

					local Velocity = (LastPosition - Position).Magnitude / dt
					local Deviation = Velocity - Velocities[Player]

					if Deviation > 100 then
						warn(Player, "Velocity devitation: ", Deviation)
						table.insert(SpeedInfractions[Player], Deviation)
					end

					LastPositions[Player] = Position

				else
					LastPositions[Player] = nil
					Velocities[Player] = nil
					SpeedInfractions[Player] = nil
				end

			end

		end

	end)

	repeat
		TimeLeft -= task.wait()
		EventValues.Timer.Value = math.floor(TimeLeft)
	until #CompletedRace >= #Participants:GetChildren() or TimeLeft <= 0

	-- Finished
	Conn:Disconnect()
    Map.Collectables:ClearAllChildren() -- Reset map
	RelayToParticipants("Finished", CompletedRace)


	local Winners = {}
	for i, Ranked in ipairs(CompletedRace) do
		local PlayerName = Ranked.PlayerName
		local Player = game.Players[PlayerName]

		if i <= 3 then
			if i == 1 then
				local Data = Modules.PlayerData.sessionData[PlayerName]
				if Data then
					local Stats = Data.Stats

					if Stats["Sled Race Wins"] then
						Stats["Sled Race Wins"] += 1
					else
						Stats["Sled Race Wins"] = 1
					end

					Modules.Achievements.Progress(Player, 29)
				end

			end

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
