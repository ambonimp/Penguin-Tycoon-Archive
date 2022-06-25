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
local IsTesting = (game.GameId == 3425588324)
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

local function Defaults(Player)
	return {
		-- Session Stats
		["Money"] = 50,
		["Gems"] = (IsTesting or IsQA) and 10000 or 0,
		["Income"] = 0,
		["Tycoon"] = {},
		["Penguins"] = {},

		["My Penguin"] = {
			["Name"] = Player.DisplayName;
			["Level"] = 0;
			["BodyColor"] = "Default";
			["Accessory"] = "None";
			["Eyes"] = "Default";
			["Outfit"] = "None";
		},

		-- Possessions
		["PetsData"] = {
			Equipped = {},
			PetsOwned = {},
			MaxEquip = 3,
			Unlocked = {},
			MaxOwned = 50,
		},

		["Outfits"] = {
			["None"] = true,
		},

		["Tools"] = {
			["Vehicle Spawner"] = true,
		},

		["Accessories"] = {
			["None"] = true;
		},

		["Emotes"] = {
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
		},

		["Equipped Emotes"] = {
			["1"] = "Sit";
			["2"] = "Wave";
			["3"] = "Sleep";
			["4"] = "Point";
			["5"] = "Salute";
		},

		["Eyes"] = {
			["Default"] = true;
			["Angry"] = true;
			["Surprised"] = true;
			["Unamused"] = true;
			["Scared"] = true;
		},

		["Eyes Rotation"] = Modules.AllEyes:ChooseStoreEyes(),

		["Rotation Timer"] = os.time();
		--["Rotation Index"] = 1;
		["Accessory Rotation"] = Modules.AllAccessories:ChooseStoreAccessories();

		-- Social Stats
		["Hearts"] = 0,
		["Regular Hearts Given"] = {},
		["VIP Hearts Given"] = {},

		-- Long term stats
		["Stats"] = {
			["Total Money"] = 50,
			["Total Playtime"] = 0,
			["Total Gems"] = 0,
		},

		["LastPlayTime"] = os.time()-(30*60),

		-- Fish
		["Fish Found"] = {},
		["Enchanted Fish Found"] = {},

		-- Rewards
		["Discord Verification"] = false,
		["Twitter Verification"] = false,

		["Group Reward Claimed"] = false,
		["Applied Boosts"] = {},

		["Gamepasses"] = {},
		["Applied Gamepasses"] = {},

		["Tycoon Rewards"] = {},

		["Redeemed Codes"] = {},

		-- Settings
		["Settings"] = {
			["Chat Tag"] = true,
			["Music"] = true,
			["Progress Bar"] = true,
			["Faster Speed"] = true,
			["Double Jump"] = true,
			["Show Hearts"] = true,
		},

		-- Multipliers
		["Income Multiplier"] = 1,
		["Gem Multiplier"] = 1,
		["Walkspeed Multiplier"] = 1,


		["Boosts"] = { --[1]owned, [2]time left in current boost
			["Super Fishing Luck"] = {0,0},
			["Ultra Fishing Luck"] = {0,0},
			["x3 Money"] = {0,0},
		},

		-- Vehicles
		["PlaneUnlocked"] = {
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
		},

		["BoatUnlocked"] = {
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
		},

		-- Other
		["Quests"] = {},

		["Playtime"] = {0,0,{}},
		["Spin"] = {true,0,os.time()},

		-- Minigames
		["Youtube Minigame Score"] = 0,
		["YoutubeStats"] = {
			Likes = 0,
			Subscribers = 0,
		},

		["Military Minigame Score"] = math.huge,

		["Mining"] = {
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
	}

end

-- Recursively give player any data fields that they might be missing
local function Reconcile(Data, Default)
	for k, v in pairs(Default) do
		if not Data[k] then
			Data[k] = Default[k]
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
		local item = game.ReplicatedStorage:WaitForChild("Template"):WaitForChild("Buttons"):FindFirstChild(i)
		if item == nil then
			item = game.ReplicatedStorage:WaitForChild("Template"):WaitForChild("Upgrades"):FindFirstChild("Island1"):FindFirstChild(i)
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

	if IsTesting or IsQA then
		Data["Money"] = 1000000000
		Data["Gems"] = 1000000000
	end

	Reconcile(Data, Defaults(Player))
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
		end
	end)


	-- Data check just incase
	if not PlayerData.sessionData[Player.Name] then Player:Kick("Data Error: Rejoin") return end
	-- Setup Attributes
	Player:SetAttribute("Tycoon", "None")
	Player:SetAttribute("Money", PlayerData.sessionData[Player.Name]["Money"])
	Player:SetAttribute("Gems", PlayerData.sessionData[Player.Name]["Gems"])
	getPlayerIncome(Player)
	Player:SetAttribute("Income", PlayerData.sessionData[Player.Name]["Income"])
	Player:SetAttribute("Level", PlayerData.sessionData[Player.Name]["My Penguin"]["Level"])
	Player:SetAttribute("Pet", "none")
	Player:SetAttribute("Tool", "None")
	--[[
	if PlayerData.sessionData[Player.Name]["NextGemReward"] and PlayerData.sessionData[Player.Name]["NextGemReward"]-os.time()>0  and PlayerData.sessionData[Player.Name]["NextGemRewardSaved"] == "city" and os.time()-PlayerData.sessionData[Player.Name]["LastPlayTime"] < 30 then
		Player:SetAttribute("Next5Gems", PlayerData.sessionData[Player.Name]["NextGemReward"])
		Modules.PlayerData.sessionData[Player.Name]["NextGemRewardSaved"] = "tycoon"
	end]]
	if PlayerData.sessionData[Player.Name]["Pets"] then
		for i,v in pairs (PlayerData.sessionData[Player.Name]["Pets"].PetsOwned) do
			local breed = string.split(v.RealName," ")[2]
			PlayerData.sessionData[Player.Name]["PetsData"].PetsOwned[v.ID] = {
				breed, v.RealName,v.Name,"LEGACY",0,{1.05,"All","Income"}
			}
		end
		PlayerData.sessionData[Player.Name]["OldPets"] = PlayerData.sessionData[Player.Name]["Pets"]
		PlayerData.sessionData[Player.Name]["Pets"] = nil
	end

	Player:SetAttribute("MaxEquip",PlayerData.sessionData[Player.Name]["PetsData"].MaxEquip)

	Player:SetAttribute("MaxEquip",PlayerData.sessionData[Player.Name]["PetsData"].MaxEquip)

	if os.time() > PlayerData.sessionData[Player.Name]["Spin"][3] or (game.PlaceId == 9118436978 or game.PlaceId == 9118461324) then
		PlayerData.sessionData[Player.Name]["Spin"][3] = os.time()+Modules.SpinTheWheel.SpinTime--(12*60*60)
		PlayerData.sessionData[Player.Name]["Spin"][1] = true
	end

	if PlayerData.sessionData[Player.Name]["Quests"].Timer then
		if os.time() >= PlayerData.sessionData[Player.Name]["Quests"].Timer then
			Modules.Quests.getNewQuests(Player)
		end
	else
		Modules.Quests.getNewQuests(Player)
	end
	if PlayerData.sessionData[Player.Name]["Playtime"] and (os.time()-PlayerData.sessionData[Player.Name]["Playtime"][2]) < 5*60 then
		Player:SetAttribute("JoinTime",PlayerData.sessionData[Player.Name]["Playtime"][1])
	else
		Player:SetAttribute("JoinTime",os.time())
		PlayerData.sessionData[Player.Name]["Playtime"] = {
			[1] = os.time(),
			[2] = os.time(),
			[3] = {},
		}
	end
	-- Setup Leaderstats
	local leaderstats = Instance.new("Folder", Player)
	leaderstats.Name = "leaderstats"

	--local MoneyStat = Instance.new("IntValue", leaderstats)
	--MoneyStat.Name = "Money"
	--MoneyStat.Value = PlayerData.sessionData[Player.Name]["Money"]

	local IncomeStat = Instance.new("IntValue", leaderstats)
	IncomeStat.Name = "Income"
	IncomeStat.Value = PlayerData.sessionData[Player.Name]["Income"]

	local NetworthStat = Instance.new("IntValue", leaderstats)
	NetworthStat.Name = "Networth"
	NetworthStat.Value = PlayerData.sessionData[Player.Name]["Stats"]["Total Money"]


	-- Updating Leaderstats
	Player:GetAttributeChangedSignal("Money"):Connect(function()
		--MoneyStat.Value = PlayerData.sessionData[Player.Name]["Money"]
		NetworthStat.Value = PlayerData.sessionData[Player.Name]["Stats"]["Total Money"]
	end)

	Player:GetAttributeChangedSignal("Income"):Connect(function()
		IncomeStat.Value = PlayerData.sessionData[Player.Name]["Income"]
	end)

	Player:SetAttribute("Loaded",true)
	-- Initialize Tycoon
	Modules.Tycoon:InitializePlayer(Player)


	-- Check Gamepasses
	Modules.Gamepasses:CheckGamepasses(Player)
	if PlayerData.sessionData[Player.Name]["WasFishing"] and (os.time()-PlayerData.sessionData[Player.Name]["WasFishing"] < 60) then
		task.spawn(function()
			local Tycoon = Paths.Modules.Ownership:GetPlayerTycoon(Player)
			repeat task.wait(.25) print("WAITING FOR BOAT1") until Player == nil or (Tycoon.Tycoon:FindFirstChild("Boat#1") and Player.Character and Player.Character:IsDescendantOf(workspace))
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
		for name,details in pairs (PlayerData.sessionData[Player.Name]["Boosts"]) do
			if details[2] > 20 then
				task.spawn(function()
					Paths.Modules.Boosts.startPlayerBoost(Player,name,true)
				end)
			else
				details[2] = 0
			end
		end
	end)

	--Modules.Vehicles:SetUpSailboatBuild(Player)
	Modules.Chat:ApplyChatTag(Player)
	task.wait(5)
	-- Setup Chat
	Modules.Chat:ApplyChatTag(Player)
end)


return PlayerData