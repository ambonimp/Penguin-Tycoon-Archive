local ReplicatedStorage = game:GetService("ReplicatedStorage")
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

local Config = Modules.EventsConfig[ EVENT_NAME]

local EventValues = Services.RStorage.Modules.EventsConfig.Values
local Participants = Services.RStorage.Modules.EventsConfig.Participants
local Assets = Services.RStorage.Assets[EVENT_NAME]



local Map
local SpawnPoints


local function addGems(player,amount)
	Modules.Income:AddGems(player, amount, EVENT_NAME)
end

local function DictLength(t)
    local length = 0
    for _, _ in pairs(t) do
        length+= 1;
    end

    return length
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
			Hum.JumpPower = 0
			Hum.WalkSpeed = 0
			Hum.Died:Connect(function()
				Player:Destroy()
			end)

			local Hrp = Character.HumanoidRootPart


            -- Give player cone that scoops land into
            local IceCream = Assets.IceCream:Clone()
            local Cone = IceCream.PrimaryPart

            IceCream:SetPrimaryPartCFrame(Hrp.CFrame * CFrame.new(0, 0, -(2 + Cone.Size.Z / 2)))
            IceCream.Parent = Character

            local weld = Instance.new("WeldConstraint")
            weld.Part0 = Hrp
            weld.Part1 = Cone
            weld.Parent = Cone

            -- TODO: Add hold animation
		end

	end

end

function IceCreamExtravaganza:InitiateEvent(Event)
	Map = workspace.Event["Event Map"]
	SpawnPoints = Map.PlayerSpawns:GetChildren()

	EventValues.TextToDisplay.Value = "Initiating Ice Cream..."
	Remotes.Events:FireAllClients("Initiate Event", Event)
end

function IceCreamExtravaganza:StartEvent()
	local StartTime = tick()+1
	local FinishTime = StartTime + Config.Duration

    local Active = true

	local Scores = {}
	local Scoops = {}
	local Identifier = 1 -- Used to generate id's that help identify which scoops were collected on the client


    -- Activate Event
    for i, PlayerName in pairs(Participants:GetChildren()) do
		local Player = game.Players:FindFirstChild(PlayerName.Name)
		if Player and Player.Character and Player.Character:FindFirstChild("Humanoid") then
			Player.Character.Humanoid.WalkSpeed = 35
			Player.Character.Humanoid.JumpPower = 0

			Scores[Player] = 0
		end
	end

    EventValues.TextToDisplay.Value = "Collect the scoops!"
	Remotes.Events:FireAllClients("Event Started",  EVENT_NAME)
	task.wait(1)


	local DropSpawns = Map.DropSpawns:GetChildren()

    -- Start scoop spawning
    task.spawn(function()
        while Active do
            local Id = Identifier
            Identifier += 1

			local RGN = math.random(1, 10)

            local Scoop = {
                Position = DropSpawns[math.random(1, #DropSpawns)].Position,
                TimeOfDrop = os.clock(),
				-- Bad: 30%, Gold: 10%, Default: 60%
                Type =  if RGN <= 3 then "Bad" else (if RGN == 4 then "Gold" else "Regular")
            }

            Scoops[Id] = Scoop
            Remotes.IceCreamExtravaganza:FireAllClients("DropCreated", Id, Scoop.Position, Scoop.Type)

            task.wait(Config.DropRate)
        end
    end)

    -- Start scoop collecting
    local Connection
    Connection = Remotes.IceCreamExtravaganza.OnServerEvent:Connect(function(Player, Event, Id)
        if Event == "ScoopCollected" then
            local Character = Player.Character
        	if not Character then return end

        	local IceCream = Character:FindFirstChild("IceCream")
        	if not IceCream then return end

        	local Scoop = Scoops[Id]
        	Scoops[Id] = nil


        	local oldScore = Scores[Player]
        	local newScore

        	local Type = Scoop.Type
        	if Type == "Bad" then
        		newScore =  math.max(0, oldScore - 3)

        		for i = oldScore, newScore + 1, -1 do
        			IceCream:FindFirstChild(i):Destroy()
        		end

        	elseif Type == "Regular" then
        		newScore = oldScore + 1

        		local Cone = IceCream.PrimaryPart

        		local scoop = Assets.Scoops.Regular:Clone()
        		scoop.CanTouch = false
        		scoop.Name = newScore
        		scoop.CFrame = Cone.CFrame * CFrame.new(0, (Cone.Size.Y / 2) + (scoop.Size.Y / 2) * (newScore - 1), 0)
        		scoop.Anchored = false
        		scoop.Parent = IceCream

        		local weld = Instance.new("WeldConstraint")
        		weld.Part0 = scoop
        		weld.Part1 = Cone
        		weld.Parent = Cone

			elseif Type == "Gold" then
        	   newScore = oldScore
        	end

        	Scores[Player] = newScore

        end

    end)

    -- Countdown
    repeat
		local TimeLeft = math.floor((FinishTime - tick()))
		EventValues.TextToDisplay.Value = "Collect Scoops-"..TimeLeft
		-- Updates scores. Done here to reduce network traffic
        Remotes.IceCreamExtravaganza:FireAllClients("Update", Scores)

		task.wait(.25)
	until tick() > FinishTime or #Participants:GetChildren() == 0

	-- Game is over
	Active = false
    Connection:Disconnect()

	EventValues.TextToDisplay.Value = "Ice Cream Extravaganza has finished!"
	task.wait(1)


	-- Get scoreboard rankings
	local ScoreBoard = {}
	for i = 1, DictLength(Scores) do
		local HighestScoringPlayer
		local HighestScore = -1

		for Player, Score in pairs(Scores) do
			if Score > HighestScore then
				HighestScoringPlayer = Player
				HighestScore = Score
			end
		end

		Scores[HighestScoringPlayer] = nil
		table.insert(ScoreBoard, {PlayerName = HighestScoringPlayer.Name, Score = HighestScore})
	end


	-- Display scoreboard
	Remotes.IceCreamExtravaganza:FireAllClients("Finished", ScoreBoard)


	local Winners = {}
	for i, Ranked in ipairs(ScoreBoard) do
		local PlayerName = Ranked.PlayerName
		local Player = game.Players:FindFirstChild(PlayerName)

		if i <= 3 then
			table.insert(Winners, PlayerName)
			addGems(Player, WINNER_REWARDS[i])
		else
			addGems(Player, PARTICIPATION_REWARD)
		end
	end


	return #Winners > 0 and Winners or nil
end

return IceCreamExtravaganza


