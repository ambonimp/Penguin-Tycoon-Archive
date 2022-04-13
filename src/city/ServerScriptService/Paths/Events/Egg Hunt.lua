local EggHunt = {}


--- Main Variables ---
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

local itemList  = {
	["Backwards Cap"] = {Type = "Accessory" , Chance = 20},
	["Bear Hat"] = {Type = "Accessory" , Chance = 20},
	["Cowboy"] = {Type = "Accessory" , Chance = 20},
	["Party Hat"] = {Type = "Accessory" , Chance = 20},
	["Pink Sunhat"] = {Type = "Accessory" , Chance = 20},
}

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
	for i,playerName in pairs (Participants:GetChildren()) do
		if game.Players:FindFirstChild(playerName.Name) and game.Players:FindFirstChild(playerName.Name).Character then
			local player = game.Players:FindFirstChild(playerName.Name)
			local SpawnPos = Map.Spawns:GetChildren()[i].CFrame
			Remotes.Lighting:FireClient(player, "Egg Hunt")
			local Character = Modules.Character:Spawn(player, SpawnPos)
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
			player:SetAttribute("Minigame","Egg Hunt")
		end
	end
end

local function randomEggChance(hatsSpawned)
	local RandomNumber = math.random(1, 100)
	if hatsSpawned < 3 and math.random(1,100) <= 2 then
		local Chosen = "Blue"
		local Number = 0
		for itemName, Chance in pairs(itemList) do
			Number = Number + Chance.Chance
			if RandomNumber <= Number then
				Chosen = {itemName,Chance}
				break
			end
		end
		local Item
		if Chosen[2].Type == "Accessory" then
			Item = Services.SStorage.Accessories:FindFirstChild(Chosen[1]):Clone()
		elseif Chosen[2].Type == "Eyes" then
			Item = Services.SStorage.Eyes:FindFirstChild(Chosen[1]):Clone()
		end
		print(Item,Chosen)
		local Model = Instance.new("Model")
		for i,v in pairs (Item:GetChildren()) do
			v.Parent = Model
		end
		Item = Model
		Item.PrimaryPart = Item.Handle
		local Align = Instance.new("AlignPosition")
		Align.Mode = Enum.PositionAlignmentMode.OneAttachment
		Align.Parent = Item.PrimaryPart
		Align.Attachment0 = Item.PrimaryPart:FindFirstChildOfClass("Attachment")

		local Rot = Instance.new("AngularVelocity")
		Rot.Parent = Item.PrimaryPart
		Rot.Attachment0 = Item.PrimaryPart:FindFirstChildOfClass("Attachment")
		Rot.AngularVelocity = Vector3.new(0,1,0)
		Rot.MaxTorque = 50
		for i,v in pairs (Item:GetDescendants()) do
			if v:IsA("BasePart") then
				v.Anchored = false
				v.CanCollide = false
				v.CanTouch = false
				v.CanQuery = false
				v.Massless = true
			end
		end
		return Item, Chosen
	else
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
end

function findTbl(playerName)
	for i,v in pairs (EggsCollected) do
		if v[1] == playerName then return i end
	end
	return nil
end

function EggHunt:InitiateEvent(Event)
	EggsCollected = {}
	local hatsSpawned = 3
	local Map = workspace.Event["Event Map"]

	for i,spawn in pairs (Map.EggSpawns:GetChildren()) do
		spawn.Transparency = 1
		local addEgg = nil
		addEgg = function()
			local egg,hat = randomEggChance(hatsSpawned)
			if hat then
				hatsSpawned += 1
			end
			egg:SetPrimaryPartCFrame(spawn.CFrame)
			egg.PrimaryPart.AlignPosition.Position = egg.PrimaryPart.Position
			egg.Parent = spawn
			local con 
			local collected = false
			con = spawn.Touched:Connect(function(hit)
				if collected then return end
				if hit.Parent:FindFirstChild("Humanoid") then
					collected = true
					if not hat then
						local tbl = findTbl(hit.Parent.Name)
						if tbl == nil then
							table.insert(EggsCollected,{hit.Parent.Name,0,{
								["Gold"] = 0,
								["Red"] = 0,
								["Purple"] = 0,
								["Green"] = 0,
								["Blue"] = 0,}
							})
						end

						local data = Modules.PlayerData.sessionData[hit.Parent.Name] 
						if data and data["Event"] and data["Event"][1] == "Egg Hunt" then
							if data["Stats"]["Soccer"] then
								data["Event"][2][egg.Name] += 1
							end
						end

						Remotes.EggHunt:FireClient(game.Players:FindFirstChild(hit.Parent.Name),"Collected",spawn,(data and data["Event"]) and data["Event"][2] or nil)
						local tbl = findTbl(hit.Parent.Name)
						
						EggsCollected[tbl][2] += egg:GetAttribute("Score")
						EggsCollected[tbl][3][egg.Name] += 1
					elseif hat then
						Paths.Modules.Accessories:ItemAcquired(game.Players:FindFirstChild(hit.Parent.Name),hat[1],hat[2].Type)
					end
					
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
					task.wait(math.random(15,30))
					addEgg()
				end
			end)
		end
		addEgg()
	end


	EventValues.TextToDisplay.Value = "Initiating Egg Hunt..."

	Remotes.Events:FireAllClients("Initiate Event", Event)
end


function EggHunt:StartEvent()
	local Map = workspace.Event["Event Map"]
	-- Activate Event
	local StartTime = tick()+1
	local FinishTime = StartTime + Modules.EventsConfig["Egg Hunt"].Duration

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
		local TimeLeft = math.floor((FinishTime - tick()))
		
		
		EventValues.TextToDisplay.Value = "Collect Eggs - "..TimeLeft
		task.wait(.25)
		Remotes.EggHunt:FireAllClients("Update",EggsCollected)
	until tick() > FinishTime or #Participants:GetChildren() == 0
	Map.EggSpawns:ClearAllChildren()
	EventValues.TextToDisplay.Value = "Egg hunt has finished!"
	task.wait(1)
	table.sort(EggsCollected,function(a,b)
		return a[2] > b[2]
	end)
	for i = 1,#EggsCollected do
		local tbl = EggsCollected[i]
		if tbl and game.Players:FindFirstChild(tbl[1]) then
			if i == 1 then
				addGems(game.Players:FindFirstChild(tbl[1]),7)
			elseif i == 2 then
				addGems(game.Players:FindFirstChild(tbl[1]),5)
			elseif i == 3 then
				addGems(game.Players:FindFirstChild(tbl[1]),3)
			else
				addGems(game.Players:FindFirstChild(tbl[1]),1)
			end
		end
	end
	return {EggsCollected[1][1],EggsCollected[2] and EggsCollected[2][1] or nil,EggsCollected[3] and EggsCollected[3][1] or nil}
end

return EggHunt