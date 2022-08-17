-- Handles all the player data AND intiating the player on .PlayerAdded; loads and initiates everything: data, tycoon, attributes, gamepasses, badges, chat tag, character

local PlayerData = {}
PlayerData.sessionData = {}

--- Main Variables ---
local Paths = require(script.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes


--- Other Variables ---
local Store = "PlayerData#RELEASE"
local IsTesting = (game.GameId == 3425588324) or (game.GameId == 3662230549)
if IsTesting then Store = "TESTINGSTORE3" end
local IsQA = (game.GameId == 3425594443)
if IsQA then Store = "QASTORE1" end

PlayerData.PlayerDataStore = Services.DataStoreService:GetDataStore(Store)
local DATASTORE_RETRIES = 3





--- Functions ---
local function getData(key)
	return PlayerData.DataStoreRetry(function()
		return PlayerData.PlayerDataStore:GetAsync(key)
	end)
end

PlayerData.getData = getData

function PlayerData.Defaults(Player)
	local Returning = {}

	-- Session Stats
	Returning["Money"] = 50
	Returning["Gems"] = (IsTesting or IsQA) and 10000 or 0
	Returning["Income"] = 0
	Returning["Tycoon"] = {}
	Returning["Robux Tycoon"] = nil -- Initialized later on, it being nil is a flag for whether or previous purchases have been recorded
	Returning["Penguins"] = {}
	Returning["Rebirths"] = 0
	Returning["Auto Collect"] = nil
	Returning["Stored Income"] = 0

	Returning["My Penguin"] = {
		["Name"] = Player.DisplayName;
		["Level"] = 0;
		["BodyColor"] = "Default";
		["Accessory"] = "None";
		["Eyes"] = "Default";
		["Outfit"] = "None";
	}

	-- Possessions
	Returning["Pets_Data"] = {
		Equipped = {},
		PetsOwned = {},
		MaxEquip = 3,
		Unlocked = {},
		MaxOwned = 50,
	}

	Returning["Outfits"] = {
		["None"] = true,
	}

	Returning["Tools"] = {
		["Vehicle Spawner"] = true,
	}

	Returning["Accessories"] = {
		["None"] = true;
	}

	Returning["Emotes"] = {
		["Sit"] = true;
		["Wave"] = true;
		["Sleep"] = true;
		["Point"] = true;
		["Salute"] = true;
		["Whack"] = true;
		["Dab"] = true;
		["Wavy"] = true;
		["Clap"] = true;
		["Hug"] = true;
		["Shy"] = true;
		["Floss"] = true;
		["Push Ups"] = true;
		["Stove Opening"] = true;
		["Dough Flipping"] = true;
		["Cheering"] = true;
		["Crying"] = true;
		["Giving Pizza"] = true;
		["Vegetable Cutting"] = true;
	}

	Returning["Equipped Emotes"] = {
		["1"] = "Sit";
		["2"] = "Wave";
		["3"] = "Sleep";
		["4"] = "Point";
		["5"] = "Salute";
	}

	Returning["Eyes"] = {
		["Default"] = true;
		["Angry"] = true;
		["Surprised"] = true;
		["Unamused"] = true;
		["Scared"] = true;
	}

	Returning["Eyes Rotation"] = Modules.AllEyes:ChooseStoreEyes()

	Returning["Rotation Timer"] = os.time()
	--["Rotation Index"] = 1
	Returning["Accessory Rotation"] = Modules.AllAccessories:ChooseStoreAccessories()

	-- Social Stats
	Returning["Hearts"] = 0
	Returning["Regular Hearts Given"] = {}
	Returning["VIP Hearts Given"] = {}

	-- Long term stats
	Returning["Stats"] = {
		["Total Money"] = 50,
		["Total Playtime"] = 0,
		["Total Gems"] = 0,
		["Total Mined"] = nil,
		["Total Chopped"] = nil,
		["Total Fished"] = nil,
	}

	Returning["LastPlayTime"] = os.time()-(30*60)

	-- Fish
	Returning["Fish Found"] = {}
	Returning["Enchanted Fish Found"] = {}

	-- Rewards
	Returning["Discord Verification"] = false
	Returning["Twitter Verification"] = false

	Returning["Group Reward Claimed"] = false
	Returning["Applied Boosts"] = {}

	Returning["Gamepasses"] = {}
	Returning["Applied Gamepasses"] = {}

	Returning["Tycoon Rewards"] = {}

	Returning["Redeemed Codes"] = {}


	-- Settings
	Returning["Settings"] = {}
	for Setting, Details in pairs(Modules.SettingDetails) do
		Returning["Settings"][Setting] = Details.Default
	end

	-- Multipliers
	Returning["Income Multiplier"] = 1
	Returning["Gem Multiplier"] = 1
	Returning["Walkspeed Multiplier"] = 1


	Returning["Boosts"] = { --[1]owned, [2]time left in current boost
		["Super Fishing Luck"] = {0,0},
		["Ultra Fishing Luck"] = {0,0},
		["x3 Money"] = {0,0},
		["Ultra Lucky Egg"] = {0,0},
		["Super Lucky Egg"] = {0,0},
	}

	-- Vehicles
	Returning["PlaneUnlocked"] = {
		[1] = false,
		[2] = {
			["Wheel 1"] = false,
			["Wheel 2"] = false,
			["Propeller"] = false,
			["Landing Gear"] = false,
			["Body"] = false,
			["Seat"] = false,
			["Wing 1"] = false,
			["Wing 2"] = false,
			["Stabilizer 1"] = false,
			["Stabilizer 2"] = false,
		},
	}

	Returning["BoatUnlocked"] = {
		[1] = false,
		[2] = {
			["Hull"] = false,
			["Windows"] = false,
			["Deck"] = false,
			["Lifebuoy"] = false,
			["Helm"] = false,
			["Seat"] = false,
			["Mast"] = false,
			["Sail 1"] = false,
			["Sail 2"] = false,
			["Flag"] = false,
		},
	}

	Returning["RocketUnlocked"] = {false, {}} -- Completed, Items
	for Item in pairs(Modules.BuildADetails.Rocket) do
		Returning["RocketUnlocked"][2][Item] = false
	end

	-- Other
	Returning["Quests"] = {}
	Returning["Achievements"] = {
		false, -- Reconciled
		{},
		false, -- Reconciled 2
	}
	for Id in ipairs(Modules.AllAchievements) do
		Returning["Achievements"][2][tostring(Id)] = {
			false, -- Completed and collected
			0, -- Progress,
		}
	end

	Returning["Playtime"] = {0,0,{}}
	Returning["Spin"] = {
		true,
		0,
		os.time()
	}

	-- Minigames
	Returning["Youtube Minigame Score"] = 0
	Returning["YoutubeStats"] = {
		Likes = 0,
		Subscribers = 0,
	}

	Returning["Military Minigame Score"] = math.huge

	Returning["Mining"] = {
		Level = 1,
		Mined = {
			Coal = 0,
			Iron = 0,
			Gold = 0,
			Amethyst = 0,
			Ruby = 0,
			Emerald = 0,
			Diamond = 0,
		},
	}

	Returning["Woodcutting"] = {
		Unlocked = {"Oak","Tree"},
		Cut = {
			Oak = 0,
			Birch = 0,
			Spruce = 0,
			Acacia = 0,
			Jungle = 0,
			Blossom = 0,
		},
	}

	return Returning
end

-- Recursively give player any data fields that they might be missing
local function Reconcile(Data, Default)
	for k, v in pairs(Default) do
		if Data[k] == nil then
			Data[k] = v
		elseif typeof(v) == "table" then
			Reconcile(Data[k], v)
		end
	end

end

--- Data Functions ---
function PlayerData.DataStoreRetry(dataStoreFunction)
	local tries = 0
	local success = true
	local data = nil
	repeat
		tries = tries + 1
		success = pcall(function() data = dataStoreFunction() end)
		if not success then task.wait(1) end
	until tries == DATASTORE_RETRIES or success
	if not success then
		warn("Could not access DataStore! Warn players that their data might not get saved!")
	end
	return success, data
end


--- Setting Up Player Data ---
-- Loads player data or sets new data if they don't have existing data
function PlayerData:SetupPlayerData(player)
	local success, data = getData(player.UserId)

	--local isBanned = Commands:IsBanned(player.UserId)
	if not success then--or isBanned then
		PlayerData.sessionData[player.Name] = nil
		if false then--isBanned then
			print(player, "tried to join, but is banned!")
			player:Kick("You are banned. You may appeal at our socials found on the game page.")
		else
			player:Kick("Data could not load! Try rejoining.")
		end
	else
		Modules.Save.LastSaved[player.Name] = tick() - 6
		if not data then--or player.Name == "Kippiiq" then
			PlayerData.sessionData[player.Name] = {}
		else
			PlayerData.sessionData[player.Name] = data
		end

	end

end

local function getPlayerIncome(Player)
	local previousIncome = PlayerData.sessionData[Player.Name]["Income"]

	local levelIncome = Modules.GameFunctions:GetPlayerPenguinIncome(PlayerData.sessionData[Player.Name]["My Penguin"]["Level"])
	local total = levelIncome
	for i,v in pairs (PlayerData.sessionData[Player.Name]["Tycoon"]) do
		local item = Paths.Template:WaitForChild("Buttons"):FindFirstChild(i)
		if item == nil then
			item = Paths.Template:WaitForChild("Upgrades"):FindFirstChild("Island1"):FindFirstChild(i)
		end
		if item ~= nil then
			local income = item:GetAttribute("Income")
			if item:GetAttribute("Type") == "Penguin" then
				income = Modules.GameFunctions:GetPenguinIncome(income,PlayerData.sessionData[Player.Name]["Penguins"][i].Level)
			end
			total = total + income
		else
			print("ILLEGAL:",i)
		end
	end
	PlayerData.sessionData[Player.Name]["Income"] = total
	Player:SetAttribute("Income",total)
end

-- setting up new stats that the player doesn't have by default, or, for non-new players, since they won't get the default data anyway
local function SetupNewStats(Player)
	local Data = PlayerData.sessionData[Player.Name]
	if not Data then return end

	Reconcile(Data, PlayerData.Defaults(Player))

	if IsTesting then
		Data["Money"] = 1000000000
		Data["Gems"] = 1000000000
	end

end

-- Send back the player stat that the client requests
Remotes.GetStat.OnServerInvoke = function(player, stat)
	if PlayerData.sessionData[player.name] ~= nil then
		if stat == "All" then
			return PlayerData.sessionData[player.name]
		else
			return PlayerData.sessionData[player.name][stat]
		end
	end
end
--- INITIALIZE PLAYER ---
game.Players.PlayerAdded:Connect(function(Player)

	local PolicyService = game:GetService("PolicyService")

	-- Setup Data
	PlayerData:SetupPlayerData(Player)
	SetupNewStats(Player)


	local Data = PlayerData.sessionData[Player.Name]

	-- Badges
	Modules.Badges:AwardBadge(Player.UserId, 2124902910) -- Welcome
	Modules.Badges:AwardBadge(Player.UserId, 2124907090) -- Island 1

	coroutine.wrap(function()
		for Item, Owned in pairs(PlayerData.sessionData[Player.Name]["Tycoon"]) do
			if Modules.Badges.Purchases[Item] and Owned then
				Modules.Badges:AwardBadge(Player.UserId, Modules.Badges.Purchases[Item])
			end
		end
	end)()



	-- Initialize Character Functions
	local OldChar = nil
	Player.CharacterAdded:Connect(function(Character)
		Modules.Character:Spawned(Player, Character, OldChar)
		OldChar = Character
	end)

	-- Group reward
	pcall(function()
		if Player:IsInGroup(12843903) and not PlayerData.sessionData[Player.Name]["Group Reward Claimed"] then
			PlayerData.sessionData[Player.Name]["Group Reward Claimed"] = true
			Modules.Income:AddMoney(Player, 5000)
			Remotes.GroupReward:FireClient(Player, true)

			Remotes.Announcement:FireAllClients(Player, {Type = "GroupJoin"})
		end

	end)



	-- Data check just incase
	if not Data then Player:Kick("Data Error: Rejoin") return end
	-- Setup Attributes
	Player:SetAttribute("Tycoon", "None")
	Player:SetAttribute("Money", Data["Money"])
	Player:SetAttribute("Gems", Data["Gems"])
	getPlayerIncome(Player)
	Player:SetAttribute("Income", Data["Income"])
	Player:SetAttribute("Level", Data["My Penguin"]["Level"])
	Player:SetAttribute("Pet", "none")
	Player:SetAttribute("Tool", "None")
	--[[
	if Data["NextGemReward"] and Data["NextGemReward"]-os.time()>0  and Data["NextGemRewardSaved"] == "city" and os.time()-Data["LastPlayTime"] < 30 then
		Player:SetAttribute("Next5Gems", Data["NextGemReward"])
		Modules.Data["NextGemRewardSaved"] = "tycoon"
	end]]

	if Data["Pets"] then
		for i,v in pairs (Data["Pets"].PetsOwned) do
			local breed = string.split(v.RealName," ")[2]
			Data["Pets_Data"].PetsOwned[tostring(v.ID)] = {
				breed, v.RealName,v.Name,"LEGACY",0,{1.05,"All","Income"}
			}
		end
		Data["OldPets"] = Data["Pets"]
		Data["Pets"] = nil
	end

	for i,v in pairs (Data["Pets_Data"].PetsOwned) do
		if typeof(i) == "number" then
			Data["Pets_Data"].PetsOwned[i] = nil
			Data["Pets_Data"].PetsOwned[tostring(i)] = v
		end
	end

	Player:SetAttribute("MaxPetsOwned",Data["Pets_Data"].MaxOwned)
	Player:SetAttribute("MaxEquip",Data["Pets_Data"].MaxEquip)

	if os.time() > Data["Spin"][3] then --- (game.PlaceId == 9118436978 or game.PlaceId == 9118461324)
		Data["Spin"][3] = os.time()+Modules.SpinTheWheel.SpinTime--(12*60*60)
		Data["Spin"][1] = true
	end

	if Data["Quests"].Timer then
		if os.time() >= Data["Quests"].Timer then
			Modules.Quests.getNewQuests(Player)
		end
	else
		Modules.Quests.getNewQuests(Player)
	end

	if Data["Playtime"] and (os.time()-Data["Playtime"][2]) < 5*60 then
		Player:SetAttribute("JoinTime",Data["Playtime"][1])
	else
		Player:SetAttribute("JoinTime",os.time())
		Data["Playtime"] = {
			[1] = os.time(),
			[2] = os.time(),
			[3] = {},
		}
	end

	if not Data["Robux Tycoon"] then
		Data["Robux Tycoon"] = {}

		local Buttons = Paths.Template.Buttons
		for Item in pairs(Data.Tycoon) do
			local Button = Buttons:FindFirstChild(Item)
			if Button then
				local CurrencyType = Button:GetAttribute("CurrencyType")
				if CurrencyType == "Robux" or CurrencyType == "Gamepass" then
					Data["Robux Tycoon"][Item] = true
				end
			end
		end

	end

	if not Data.Stats["Total Mined"] then
		local Total = 0
		for _, OresMined in ipairs(Data.Mining.Mined) do
			Total += OresMined
		end
		Data.Stats["Total Mined"] = Total
	end

	if not Data.Stats["Total Chopped"] then
		local Total = 0
		for _, WoodCut in ipairs(Data.Woodcutting.Cut) do
			Total += WoodCut
		end
		Data.Stats["Total Chopped"] = Total
	end

	if not Data.Stats["Total Fished"] then
		local Total = 0
		for _, FishCaught in pairs(Data["Fish Found"]) do
			Total += FishCaught
		end
		Data.Stats["Total Fished"] = Total
	end


	-- Setup Leaderstats
	local leaderstats = Instance.new("Folder", Player)
	leaderstats.Name = "leaderstats"

	--local MoneyStat = Instance.new("IntValue", leaderstats)
	--MoneyStat.Name = "Money"
	--MoneyStat.Value = Data["Money"]

	local IncomeStat = Instance.new("IntValue", leaderstats)
	IncomeStat.Name = "Income"
	IncomeStat.Value = Data["Income"]

	local NetworthStat = Instance.new("IntValue", leaderstats)
	NetworthStat.Name = "Networth"
	NetworthStat.Value = Data["Stats"]["Total Money"]

	local RebirthStat = Instance.new("IntValue", leaderstats)
	RebirthStat.Name = "Rebirths"
	RebirthStat.Value = Data["Rebirths"]


	-- Updating Leaderstats
	Player:GetAttributeChangedSignal("Money"):Connect(function()
		--MoneyStat.Value = Data["Money"]
		NetworthStat.Value = Data["Stats"]["Total Money"]
	end)

	Player:GetAttributeChangedSignal("Income"):Connect(function()
		IncomeStat.Value = Data["Income"]
	end)
	if Data["Settings"]["Auto Hatch"] == nil then
		Data["Settings"]["Auto Hatch"] = false
	end
	Player:SetAttribute("IsAutoHatch",Data["Settings"]["Auto Hatch"])

	if Data["Boosts"]["Ultra Lucky Egg"] == nil then
		Data["Boosts"]["Ultra Lucky Egg"] = {0,0}
	end
	if Data["Boosts"]["Super Lucky Egg"] == nil then
		Data["Boosts"]["Super Lucky Egg"] = {0,0}
	end
	if not table.find(Data["Woodcutting"].Unlocked,"Tree") then
		table.insert(Data["Woodcutting"].Unlocked,"Tree")
	end

	-- Players path the 6th island get auto collect
	if Data["Auto Collect"] == nil then
		Data["Auto Collect"] = if Data.Tycoon[Modules.ProgressionDetails[23].Object] or Data.Rebirths > 0 then true else false
	end

	-- Initialize Tycoon
	-- Corrects the reversal of a a change we made where all the islands no longer needed purchasing
	for Upgrade in pairs(Data.Tycoon) do
		local Button = Paths.Template.Buttons:FindFirstChild(Upgrade)
		if Button then
			if Button:GetAttribute("CurrencyType") == "Money" then
				local Island = Modules.Initiate.GetIslandIndexFromObject(Upgrade)
				if Island then
					local IslandRoot = Modules.ProgressionDetails[Island].Object
					if IslandRoot and not Data.Tycoon[IslandRoot] then
						Data.Tycoon[IslandRoot] = true
					end

				end

			end

		end

	end

	Player:SetAttribute("StoredIncome", Data["Stored Income"])
	Player:SetAttribute("AutoCollectIncome", Data["Auto Collect"])

	Modules.Tycoon:InitializePlayer(Player)

	-- Check Gamepasses
	Modules.Gamepasses:CheckGamepasses(Player)
	if Data["WasFishing"] and (os.time()-Data["WasFishing"] < 60) then
		task.spawn(function()
			local Tycoon = Paths.Modules.Ownership:GetPlayerTycoon(Player)
			repeat task.wait(.25) Tycoon = Paths.Modules.Ownership:GetPlayerTycoon(Player) until Player == nil or (Tycoon and Tycoon.Tycoon:FindFirstChild("Boat#1") and Player.Character and Player.Character:IsDescendantOf(workspace))
			local boat = Tycoon.Tycoon:FindFirstChild("Boat#1")
			if boat and Player then
				boat.Seat.Disabled = false
				local hum = Player.Character:WaitForChild("Humanoid")
				boat.Seat:Sit(hum)
				boat.Seat.ProximityPrompt.Enabled = false
			end
		end)
	end
	task.spawn(function()
		task.wait(10)
		for name,details in pairs (Data["Boosts"]) do
			if details[2] > 20 then
				task.spawn(function()
					Paths.Modules.Boosts.startPlayerBoost(Player,name,true)
				end)
			else
				details[2] = 0
			end
		end
	end)

	-- Make sure player doesn't own any invalid items
	for _, ItemType in ipairs({"Accessories", "Outfits", "Eyes", "Emotes"}) do
		for Item in pairs(Data[ItemType]) do
			if not Modules["All" .. ItemType].All[Item] then
				Data[ItemType][Item] = nil
			end
		end
	end

	if not Data.Achievements[4] then-- For players who have played prior to the addition of quests, load their data
		Modules.Achievements.Reconciled:Fire(Data)
		Data.Achievements[4] = true
	end

	Data.Settings["Faster Speed"] = true
	Data.Settings["Double Jump"] = true
	-- TESTING
--[[ 	if Player.UserId == 1322669058 and IsTesting then
		Data.Outfits["Banana"] = true
		Data.Outfits["Disco"] = true
		Data.Outfits["Ghost"] = true
		Data.Outfits["Mummy"] = true
		Data.Outfits["Ninja"] = true
		Data.Outfits["Mad Scientist"] = true

		Data.Accessories = PlayerData.Defaults(Player).Accessories
		Data.Accessories["Bath Hat"] = true
		Data.Accessories["Bird Hat"] = true
		Data.Accessories["Giant Bow"] = true
		Data.Accessories["Deely Bopper"] = true
		Data.Accessories["Flower Crown"] = true
		Data.Accessories["Frog Bucket Hat"] = true
		Data.Accessories["Head Lamp"] = true
		Data.Accessories["Headphones"] = true
		Data.Accessories["Mouse Ears"] = true
		Data.Accessories["Pirate Bandana"] = true
		Data.Accessories["Sweatband"] = true
		Data.Accessories["Thug Life Glasses"] = true
		Data.Accessories["Propeller Hat"] = true
	end *]]

	--Modules.Vehicles:SetUpSailboatBuild(Player)
	Modules.Chat:ApplyChatTag(Player)
	task.wait(5)
	-- Setup Chat
	Modules.Chat:ApplyChatTag(Player)
end)


return PlayerData