local CandyRush = {}

--- Main Variables ---
local EVENT_NAME = "Candy Rush"

local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes

local EggsCollected = {}

local chances = {
	["Gold"] = 10,
	["Red"] = 15,
	["Purple"] = 20,
	["Green"] = 25,
	["Blue"] = 30,
}

--- Event Variables ---
local EventValues = Services.RStorage.Modules.EventsConfig.Values
local Participants = Services.RStorage.Modules.EventsConfig.Participants
local Config = Modules.EventsConfig[EVENT_NAME]


function addGems(player,amount)
	Modules.Income:AddGems(player, amount, EVENT_NAME)
end

--- Event Functions ---
function CandyRush:SpawnPlayers(ChosenBugName, ChosenBugNum)
	local Map = workspace.Event["Event Map"]
	for i,playerName in pairs (Participants:GetChildren()) do
		if game.Players:FindFirstChild(playerName.Name) and game.Players:FindFirstChild(playerName.Name).Character then
			local player = game.Players:FindFirstChild(playerName.Name)
			local SpawnPos = Map.Spawns:GetChildren()[i].CFrame
			Remotes.Lighting:FireClient(player, EVENT_NAME)
			local Character = Modules.Character:Spawn(player, SpawnPos,true)
			Character.Humanoid.WalkSpeed = 0
			
			player.Character.Humanoid.Died:Connect(function()
				playerName:Destroy()
			end)
			
			addGems(player,2)
			table.insert(EggsCollected,{player.Name,0,{
				["Gold"] = 0,
				["Red"] = 0,
				["Purple"] = 0,
				["Green"] = 0,
				["Blue"] = 0,}
			})

			player:SetAttribute("Minigame",EVENT_NAME)

		end

	end

end

local function randomEggChance(hatsSpawned)
	local RandomNumber = math.random(1, 100)
	
	local Chosen = "Blue"
	local Number = 0
	for Egg, Chance in pairs(chances) do
		Number = Number + Chance
		if RandomNumber <= Number then
			Chosen = Egg
			break
		end
	end
	return Paths.Services.RStorage.Assets.Candy:FindFirstChild(Chosen):Clone()
	
end

function findTbl(playerName)
	for i,v in pairs (EggsCollected) do
		if v[1] == playerName then return i end
	end
	return nil
end

function CandyRush:InitiateEvent(Event)
	local Map = workspace.Event["Event Map"]
	Map:Destroy()

	Map = Services.SStorage.EventMaps[EVENT_NAME]:Clone()
	Map.Name = "Event Map"
	Map.Parent = workspace.Event

	EggsCollected = {}
	for i,spawn in pairs (Map.EggSpawns:GetChildren()) do
		spawn.Transparency = 1
		local addEgg = nil
		addEgg = function()
			local egg = randomEggChance()
			egg:SetPrimaryPartCFrame(spawn.CFrame)
			egg.PrimaryPart.AlignPosition.Position = egg.PrimaryPart.Position
			egg.Parent = spawn
			local con 
			local collected = false
			con = spawn.Touched:Connect(function(hit)
				if collected then return end
				if hit.Parent:FindFirstChild("Humanoid") then
					local playerName = hit.Parent.Name
					local player = game.Players:FindFirstChild(playerName)

					collected = true
					Modules.Quests.GiveQuest(player, "Collect","Minigame", "Candy Rush", 1)
					Modules.Achievements.Progress(player, 27)

					local stats = Modules.PlayerData.sessionData[playerName].Stats
					if stats["Candy Collected"] then
						stats["Candy Collected"] += 1
					else
						stats["Candy Collected"] = 1
					end

					local tbl = findTbl(playerName)
					if tbl == nil then
						table.insert(EggsCollected,{playerName,0,{
							["Gold"] = 0,
							["Red"] = 0,
							["Purple"] = 0,
							["Green"] = 0,
							["Blue"] = 0,}
						})
					end

					Remotes.CandyRush:FireClient(player, "Collected",spawn)
					local tbl = findTbl(hit.Parent.Name)
					
					EggsCollected[tbl][2] += egg:GetAttribute("Score")
					EggsCollected[tbl][3][egg.Name] += 1
					
					
					egg.PrimaryPart.AngularVelocity.AngularVelocity = Vector3.new(0,3,0)
					egg.PrimaryPart.AlignPosition.Position = egg.PrimaryPart.Position + Vector3.new(0,4,0)
					con:Disconnect()
					for i = 0,1,.025 do
						for _,v in pairs (egg:GetDescendants()) do
							if v:IsA("BasePart") then
								v.Transparency = i
							end
						end
						task.wait()
					end
					egg:Destroy()
					task.wait(math.random(10,20))
					addEgg()
				end
			end)
		end
		local s,m = pcall(function()
			addEgg()
		end)
		if s == false then print(m) end
	end

	EventValues.Timer.Value = Config.Duration
	EventValues.Timer:SetAttribute("Enabled", true)

	EventValues.TextToDisplay.Value = "Initiating Candy Rush..."

	Remotes.Events:FireAllClients("Initiate Event")
end


function CandyRush:StartEvent()
	local Map = workspace.Event["Event Map"]
	-- Activate Event
	local StartTime = tick()+1
	local FinishTime = StartTime + Modules.EventsConfig[EVENT_NAME].Duration

	for index, playerName in pairs(Participants:GetChildren()) do
		local player = game.Players:FindFirstChild(playerName.Name)
		if player and player.Character and player.Character:FindFirstChild("Humanoid") then
			player.Character.Humanoid.WalkSpeed = 35
			player.Character.Humanoid.JumpPower = 65
		end
	end
	Map.Active.Value = true
	local winners, text = nil,"Candy Rush has finished!"

	EventValues.TextToDisplay.Value = "Collect the candy!"
	Remotes.Events:FireAllClients("Event Started")
	task.wait(1)
	repeat 
		local TimeLeft = math.floor((FinishTime - tick()))
		EventValues.Timer.Value = TimeLeft
		
		task.wait(.25)
		Remotes.CandyRush:FireAllClients("Update",EggsCollected)

	until tick() > FinishTime or #Participants:GetChildren() == 0

	Map.EggSpawns:ClearAllChildren()
	EventValues.TextToDisplay.Value = "Candy Rush has finished!"
	task.wait(1)
	table.sort(EggsCollected,function(a,b)
		return a[2] > b[2]
	end)
	Remotes.CandyRush:FireAllClients("Finished",EggsCollected)
	for i = 1,#EggsCollected do
		local tbl = EggsCollected[i]

		local player = game.Players:FindFirstChild(tbl[1])
		if tbl and player then
			if i == 1 then
				local data = Modules.PlayerData.sessionData[tbl[1]]
				if data and data["Stats"][EVENT_NAME] then
					data["Stats"][EVENT_NAME] = data["Stats"][EVENT_NAME] + 1
				elseif data then
					data["Stats"][EVENT_NAME] =  1
				end
				addGems(player, 7)
				Modules.Quests.GiveQuest(player,"Win","Minigame","Candy Rush",1)
				Modules.Quests.GiveQuest(player,"Win","Minigame","All",1)
			elseif i == 2 then
				addGems(player, 5)
			elseif i == 3 then
				addGems(player, 3)
			else
				addGems(player, 1)
			end

		end

	end

	return {EggsCollected[1][1],EggsCollected[2] and EggsCollected[2][1] or nil,EggsCollected[3] and EggsCollected[3][1] or nil}
end


return CandyRush