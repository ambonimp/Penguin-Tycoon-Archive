local IceCreamExtravaganza = {}


--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes

--- Event Variables ---
local Config = Modules.EventsConfig["Ice Cream Extravaganza"]

local EventValues = Services.RStorage.Modules.EventsConfig.Values
local Participants = Services.RStorage.Modules.EventsConfig.Participants
local Assets = Services.RStorage.Assets


--- Event Functions ---
function IceCreamExtravaganza:SpawnPlayers(ChosenBugName, ChosenBugNum)
	local Map = workspace.Event["Event Map"]
	local Spawns = Map.Spawns:GetChildren()

	for i, Player in pairs(Participants:GetChildren()) do
		local player = game.Players:FindFirstChild(Player.Name)
		local SpawnPos = Spawns[i].CFrame * CFrame.new(0, 3, 0)

		if player then
			Remotes.Lighting:FireClient(player, "Ice Cream Extravaganza")
			player:SetAttribute("Minigame","Ice Cream Extravaganza")


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
	EventValues.TextToDisplay.Value = "Initiating Ice Cream..."
	Remotes.Events:FireAllClients("Initiate Event", Event)

end

function IceCreamExtravaganza:StartEvent()
	local Map = workspace.Event["Event Map"]
	local SpawnPoints = Map.SpawnPoints:GetChildren()


	local StartTime = tick()+1
	local FinishTime = StartTime + Config.Duration

    local Active = true

	local Scores = {}
	local Scoops = {}
	local Identifier = 0 -- Used to generate id's that help identify which scoops were collected on the client


    -- Activate Event
    for i, playerName in pairs(Participants:GetChildren()) do
		local player = game.Players:FindFirstChild(playerName.Name)
		if player and player.Character and player.Character:FindFirstChild("Humanoid") then
			player.Character.Humanoid.WalkSpeed = 35
			-- player.Character.Humanoid.JumpPower = 65
		end
	end
    EventValues.TextToDisplay.Value = "Collect the scoops!"
	Remotes.Events:FireAllClients("Event Started", "Ice Cream Extraveganza")
	task.wait(1)


    -- Start scoop spawning
    task.spawn(function()
        while Active do
            local Id = Identifier
            Identifier += 1

            local Scoop = {
                Position = SpawnPoints[math.random(1, #SpawnPoints)].Position,
                TimeOfDrop = os.clock(),
                IsBad = math.random(1, 3) == 1 -- 1 in 3 chance of spawnning a bad drop
            }

            Scoop[Id] = Scoop
            Remotes.IceCreamExtravaganza:FireAllClients(Id, Scoop.Position, Scoop.IsBad)

            task.wait(Config.DropRate)
        end
    end)

    -- Start scoop collecting
    local Connection
    Connection = Remotes.IceCreamExtravaganza.OnServerEvent:Connect(function(Player, Event, Id)
        if Event == "OnScoopCollected" then
            local Character = Player.Character
        	if not Character then return end

        	local IceCream = Character:FindFirstChild("IceCream")
        	if not IceCream then return end


        	local Scoop = Scoops[Id]
        	Scoop[Id] = nil

        	local oldScore = Scores[Player]
        	local newScore
        	if Scoop.IsBad then
        		newScore =  math.max(0, oldScore - 3)

        		for i = oldScore, newScore do
        			IceCream:FindFirstChild(i):Destroy()
        		end

        	else
        		newScore = oldScore + 1

        		local Cone = IceCream.PrimaryPart

        		local scoop = Assets.Scoops.Good:Clone()
        		scoop.CanTouch = false
        		scoop.Name = newScore
        		scoop.CFrame = Cone.CFrame * CFrame.new(0, (Cone.Size.Y / 2) + (scoop.Size.Y / 2) * (newScore - 1), 0)
        		scoop.Anchored = false
        		scoop.Parent = IceCream

        		local weld = Instance.new("WeldConstraint")
        		weld.Part0 = scoop
        		weld.Part1 = Cone
        		weld.Parent = Cone

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


end

return IceCreamExtravaganza


