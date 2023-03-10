local IceCreamExtravaganza = {}


--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes

--- Event Variables ---
local EVENT_NAME = script.Name

local WINNER_REWARDS = {7, 5, 3}
local PARTICIPATION_REWARD = 1

local CONE_GRAB_ANIMATION = Instance.new("Animation")
CONE_GRAB_ANIMATION.AnimationId = "rbxassetid://9725354929"

local DROP_CHANCES = {
	Invicible = 5,
	Double = 10,
	Obstacle = 28,
	Regular = 57,
}

local Config = Modules.EventsConfig[ EVENT_NAME]

local EventValues = Services.RStorage.Modules.EventsConfig.Values
local Participants = Services.RStorage.Modules.EventsConfig.Participants
local Assets = Services.RStorage.Assets[EVENT_NAME]



local Map, SpawnPoints

local Scores



local function RewardGems(Player, Amount)
	Modules.Income:AddGems(Player,  Amount, EVENT_NAME)
end

local function SortScores()
	local Sorted = {}

	local Clone = Modules.FuncLib.TableClone(Scores)
	for i = 1, Modules.FuncLib.DictLength(Clone) do
		local HighestScoringPlayer
		local HighestScore = -1

		for Player, Score in pairs(Clone) do
			if Score > HighestScore then
				HighestScoringPlayer = Player
				HighestScore = Score
			end
		end

		Clone[HighestScoringPlayer] = nil
		table.insert(Sorted, {PlayerName = HighestScoringPlayer.Name, Score = HighestScore})

	end

	return Sorted
end

-- Randomly selects a drop based on DROP_CHANCES
local function GetDropType()
	local rng = math.random(1, 100)
	for Type, Probability in pairs(DROP_CHANCES) do
		if rng <= Probability then
			return Type
		else
			rng -= Probability
		end
	end

end

local function RelayToParticipants(...)
	for _, PlayerName in ipairs(Participants:GetChildren()) do
		local Player = game.Players:FindFirstChild(PlayerName.Name)
		if Player then
			Remotes.IceCreamExtravaganza:FireClient(Player, ...)
		end
	end
end

--- Event Functions ---
function IceCreamExtravaganza:SpawnPlayers(ChosenBugName, ChosenBugNum)
	for i, Player in pairs(Participants:GetChildren()) do
		local player = game.Players:FindFirstChild(Player.Name)
		local SpawnPos = SpawnPoints[i].CFrame * CFrame.new(0, 3, 0)

		if player then
			Remotes.Lighting:FireClient(player,  EVENT_NAME)
			player:SetAttribute("Minigame", EVENT_NAME)


			local Character = Modules.Character:Spawn(player, SpawnPos)
			Modules.Collisions.SetCollision(Character, false)

			local Hum = Character.Humanoid
			Hum.WalkSpeed = 0
			Hum.Died:Connect(function()
				Player:Destroy()
			end)

			local Hrp = Character.HumanoidRootPart

            -- Give player cone that scoops land into
            local IceCream = Assets.IceCream:Clone()
            local Cone = IceCream.PrimaryPart

            IceCream:SetPrimaryPartCFrame(Hrp.CFrame * CFrame.new(0, 0, -(1 + Cone.Size.Z / 2)))
            IceCream.Parent = Character

            local weld = Instance.new("WeldConstraint")
            weld.Part0 = Character.Main
            weld.Part1 = Cone
            weld.Parent = Cone

            local track = Hum:LoadAnimation(CONE_GRAB_ANIMATION)
            track:Play()

		end

	end

end

function IceCreamExtravaganza:InitiateEvent()
	Map = workspace.Event["Event Map"]
	SpawnPoints = Map.PlayerSpawns:GetChildren()

	EventValues.TextToDisplay.Value = "Initiating Ice Cream..."

	EventValues.Timer.Value = Config.Duration
	EventValues.Timer:SetAttribute("Enabled", true)

	Remotes.Events:FireAllClients("Initiate Event")
end

function IceCreamExtravaganza:StartEvent()
	local StartTime = os.time() + 1
	local TimeLeft = Config.Duration

    local Active = true

	Scores = {}
	local Scoops = {}
	local Identifier = 1 -- Used to generate id's that help identify which scoops were collected on the client

    -- Activate Event
    for _, PlayerName in pairs(Participants:GetChildren()) do
		local Player = game.Players:FindFirstChild(PlayerName.Name)

		if Player then
			local Character = Player.Character
			if Character then
				local Humanoid = Character:FindFirstChild("Humanoid")
				if Humanoid then
					Humanoid.WalkSpeed = 35
					Scores[Player] = 0

					continue
				end
			end
		end

		PlayerName:Destroy()
	end

    EventValues.TextToDisplay.Value = "Collect the scoops!"
	Remotes.Events:FireAllClients("Event Started")
    -- Update scoreboards on client to display zeroes and participants
	RelayToParticipants("Update", SortScores())
	task.wait(1)


	local DropSpawns = Map.DropSpawns:GetChildren()

    -- Start scoop spawning
    task.spawn(function()
        while Active do
            Identifier += 1

            local Id = Identifier
			local Position = DropSpawns[math.random(1, #DropSpawns)].Position
			local Type = GetDropType()

			local Models = Assets.Drops[Type]:GetChildren()
			local Model = Models[math.random(1, #Models)]

            Scoops[Id] = {
                Position = Position,
                Type = Type,
                Model = Model
            }

			Remotes.IceCreamExtravaganza:FireAllClients("DropCreated", Id, Position, Model)
            task.wait(Config.DropRate)

        end

    end)


    -- Start scoop collecting
    local InviciblePlayers = {}

    local Connection
    Connection = Remotes.IceCreamExtravaganza.OnServerEvent:Connect(function(Player, Event, Id)
        if Event == "ScoopCollected" then
            local Character = Player.Character
        	if not Character then return end

        	local IceCream = Character:FindFirstChild("IceCream")
        	local Scoop = Scoops[Id]

        	if IceCream and Scoop then
	        	Scoops[Id] = nil

	        	local oldScore = Scores[Player]
	        	local newScore

	        	local Type = Scoop.Type
				if Type == "Obstacle" then
					if not InviciblePlayers[Player] then
						newScore =  math.max(0, oldScore - 1)

						for i = oldScore, newScore + 1, -1 do
							IceCream:FindFirstChild(i):Destroy()
						end
					end
				elseif Type == "Invicible" then
					if not InviciblePlayers[Player] then
						-- Debounce
						InviciblePlayers[Player] = true

						-- Make opaque
						local PreviousProperties = {}
						for _, BasePart in ipairs(Character:GetDescendants()) do
							if BasePart:IsA("BasePart") and BasePart.Transparency == 0 then
								PreviousProperties[BasePart] = {Color = BasePart.Color, Material = BasePart.Material}

								BasePart.Material = Enum.Material.ForceField
								BasePart.Color = Color3.fromRGB(255, 255, 255)
							end
						end

						-- Revert
						task.delay(Config.InvicibilityLength, function()
							if Character.Parent then -- Character hasn't died
								for Changed, Props in pairs(PreviousProperties) do
									Changed.Material = Props.Material
									Changed.Color = Props.Color
								end
							end

							InviciblePlayers[Player] = nil
						end)
					end

				else
	        		local Cone = IceCream.PrimaryPart

					newScore = oldScore
					for i = 1, (Type == "Regular" and 1 or 2) do
						newScore += 1
		        		local Scoop = Scoop.Model:Clone()
		        		local _, ScoopSize = Scoop:GetBoundingBox()

		        		Scoop.Name = newScore
		        		Scoop:SetPrimaryPartCFrame(Cone.CFrame * CFrame.new(0, (Cone.Size.Y / 2) + (ScoopSize.Y / 2) * (newScore - 1), 0))
		        		Scoop.PrimaryPart.Anchored = false
		        		Scoop.Parent = IceCream

		        		local weld = Instance.new("WeldConstraint")
		        		weld.Part0 = Scoop.PrimaryPart
		        		weld.Part1 = Cone
		        		weld.Parent = Cone

		        	end

	        	end

	        	Scores[Player] = newScore or oldScore
				if newScore and newScore > oldScore then
					Modules.Quests.GiveQuest(Player,"Collect","Minigame","Ice Cream Extravaganza",1)
				end
	        end

        end

    end)

    -- Countdown
    repeat
		task.wait(1)
		TimeLeft -= 1

		EventValues.Timer.Value = TimeLeft

		-- Updates scores. Done here to reduce network traffic
		RelayToParticipants("Update", SortScores())

		task.wait(.25)
	until TimeLeft < 0 or #Participants:GetChildren() == 0

	-- Game is over
	Active = false
    Connection:Disconnect()

	EventValues.TextToDisplay.Value = "Ice Cream Extravaganza has finished!"
	task.wait(1)


	-- Get scoreboard rankings
	local ScoreBoard = SortScores()

	-- Display scoreboard
	RelayToParticipants("Finished", ScoreBoard)

	local Winners = {}
	for i, Ranked in ipairs(ScoreBoard) do
		local PlayerName = Ranked.PlayerName
		local Player = game.Players:FindFirstChild(PlayerName)

		if i == 1 then
			local Data = Modules.PlayerData.sessionData[PlayerName]
			if Data then
				local Stats = Data["Stats"]

				if Stats[EVENT_NAME] then
					Stats[EVENT_NAME] += 1
				else
					Stats[EVENT_NAME] = 1
				end

				Modules.Achievements.Progress(Player, 28)

				Modules.Quests.GiveQuest(Player,"Win","Minigame","Ice Cream Extravanganza",1)
				Modules.Quests.GiveQuest(Player,"Win","Minigame","All",1)
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

return IceCreamExtravaganza


