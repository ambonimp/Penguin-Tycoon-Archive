local EggHunt = {}


--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes

local EggsCollected = {}

--- Event Variables ---
local EventValues = Services.RStorage.Modules.EventsConfig.Values
local Participants = Services.RStorage.Modules.EventsConfig.Participants
local Votes = Services.RStorage.Modules.EventsConfig.Votes

function addGems(player,amount)
	Modules.Income:AddGems(player, amount, "Egg Hunt")
end

--- Event Functions ---
function EggHunt:SpawnPlayers(ChosenBugName, ChosenBugNum)
	local Map = workspace.Event["Event Map"]
	for i,player in pairs (Participants:GetChildren()) do
		if game.Players:FindFirstChild(player.Name) and game.Players:FindFirstChild(player.Name).Character then
			local player = game.Players:FindFirstChild(player.Name)
			local SpawnPos = Map.Spawns:GetChildren()[i].CFrame
			Remotes.Lighting:FireClient(player, "Egg Hunt")
			local Character = Modules.Character:Spawn(player, SpawnPos)
			Character.Humanoid.WalkSpeed = 0

			player.Character.Humanoid.Died:Connect(function()
				player:Destroy()
			end)
			
			addGems(player,2)

			player:SetAttribute("Minigame","Egg Hunt")
		end
	end
end

local chances = {
	["Gold"] = 10,
	["Red"] = 15,
	["Purple"] = 20,
	["Green"] = 25,
	["Blue"] = 30,
}
local function randomEggChance()
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
	return Paths.Services.RStorage.Assets.Eggs:FindFirstChild(Chosen):Clone()
end


function EggHunt:InitiateEvent(Event)
	EggsCollected = {}
	local Map = workspace.Event["Event Map"]
	local Totals = {
		["Gold"] = 0,
		["Red"] = 0,
		["Purple"] = 0,
		["Green"] = 0,
		["Blue"] = 0,
	}
	for i,spawn in pairs (Map.EggSpawns:GetChildren()) do
		local addEgg = nil
		addEgg = function()
			local egg = randomEggChance()

			egg:SetPrimaryPartCFrame(spawn.CFrame)
			egg.PrimaryPart.AlignPosition.Position = egg.PrimaryPart.Position
			Totals[egg.Name] += 1
			egg.Parent = spawn
			local con 
			local collected = false
			con = spawn.Touched:Connect(function(hit)
				if collected then return end
				if hit.Parent:FindFirstChild("Humanoid") then
					collected = true
					if EggsCollected[hit.Parent.Name] == nil then
						EggsCollected[hit.Parent.Name] = {0,{
							["Gold"] = 0,
							["Red"] = 0,
							["Purple"] = 0,
							["Green"] = 0,
							["Blue"] = 0,}
						}
					end
					EggsCollected[hit.Parent.Name][1] += egg:GetAttribute("Score")
					EggsCollected[hit.Parent.Name][2][egg.Name] += 1
					egg:Destroy()
					con:Disconnect()
					task.wait(math.random(15,30))
					addEgg()
				end
			end)
		end
		addEgg()
	end

	print(Totals)

	EventValues.TextToDisplay.Value = "Initiating Egg Hunt..."

	Remotes.Events:FireAllClients("Initiate Event", Event)
end


function EggHunt:StartEvent()
	local Map = workspace.Event["Event Map"]
	-- Activate Event
	local StartTime = tick()+1
	local FinishTime = StartTime + Modules.EventsConfig["Soccer"].Duration

	for index, playerName in pairs(Participants:GetChildren()) do
		local player = game.Players:FindFirstChild(playerName.Name)
		if player and player.Character and player.Character:FindFirstChild("Humanoid") then
			player.Character.Humanoid.WalkSpeed = 35
			player.Character.Humanoid.JumpPower = 65
		end
	end
	Map.Active.Value = true
	local winners, text = nil,"Egg Hunt has finished!"
	EventValues.TextToDisplay.Value = "Get those eggs!"
	Remotes.Events:FireAllClients("Event Started", "Egg Hunt")
	task.wait(1)
	repeat 
		local TimeLeft = math.floor((FinishTime - tick())*10)/10
		if not string.match(tostring(TimeLeft), "%.") then
			TimeLeft = tostring(TimeLeft)..".0"
		end
		
		for i = 1, select(2, tostring(TimeLeft):gsub("1", "")), 1 do
			TimeLeft = tostring(TimeLeft).." "
		end
		
		EventValues.TextToDisplay.Value = "Collect eggs - "..TimeLeft
		task.wait(1)
	until tick() > FinishTime or #Participants:GetChildren() == 0

	task.wait(1)
	return winners,text
end

return EggHunt