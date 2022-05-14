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
if IsQA then Store = "QASTORE" end

PlayerData.PlayerDataStore = Services.DataStoreService:GetDataStore(Store)
local DATASTORE_RETRIES = 3


--- Data Functions ---
function PlayerData.DataStoreRetry(dataStoreFunction)
	local tries = 0
	local success = true
	local data = nil
	repeat
		tries = tries + 1
		success = pcall(function() data = dataStoreFunction() end)
		if not success then wait(1) end
	until tries == DATASTORE_RETRIES or success
	if not success then
		warn("Could not access DataStore! Warn players that their data might not get saved!")
	end
	return success, data
end


--- Functions ---
function PlayerData.getData(key)
	return PlayerData.DataStoreRetry(function()
		return PlayerData.PlayerDataStore:GetAsync(key)
	end)
end

--- Setting Up Player Data ---
function PlayerData:SetupPlayerData(player)
	local success, data = PlayerData.getData(player.UserId)
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
			PlayerData.sessionData[player.Name] = {
				-- Session Stats
				["Money"] = 10,
				["Income"] = 0,
				["Tycoon"] = {},
				["Penguins"] = {},

				["My Penguin"] = {
					["Name"] = player.DisplayName;
					["Level"] = 0;
					["BodyColor"] = "Default";
					["Accessory"] = "None";
					["Eyes"] = "Default";
					["Outfit"] = "None";
				},

				-- Accessory Info
				["Accessories"] = {
					["None"] = true;
				},

				["Outfits"] = {
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

				["Rotation Timer"] = os.time();
				--["Rotation Index"] = 1;
				["Accessory Rotation"] = Modules.AllAccessories:ChooseStoreAccessories();
				--["Outfits Rotation"] = Modules.AllOutfits:ChooseStoreAccessories();
				-- Social Stats
				["Hearts"] = 0,
				["Regular Hearts Given"] = {},
				["VIP Hearts Given"] = {},

				-- Long term stats
				["Stats"] = {
					["Total Money"] = 10,
					["Total Playtime"] = 0,
				},

				-- Settings 
				["Settings"] = {
					["Chat Tag"] = true,
					["Music"] = true,
					["Faster Speed"] = true,
					["Double Jump"] = true,
					["Show Hearts"] = true,
				},

				-- Other
				["Income Multiplier"] = 1,
				["Walkspeed Multiplier"] = 1,

				["Group Reward Claimed"] = false,
				["Applied Boosts"] = {},

				["Gamepasses"] = {},
				["Applied Gamepasses"] = {},

				["Redeemed Codes"] = {},
			}
		else
			PlayerData.sessionData[player.Name] = data
		end
	end
end


--- setting up new stats that the player doesn't have by default, or, for non-new players, since they won't get the default data anyway
local function SetupNewStats(Player)
	local Data = PlayerData.sessionData[Player.Name]
	if not Data then return end

	-- Eyes
	if not Data["Eyes"] then
		Data["Eyes"] = {
			["Default"] = true;
			["Angry"] = true;
			["Surprised"] = true;
			["Unamused"] = true;
			["Scared"] = true;
		}
	end

	if not Data["Eyes Rotation"] then
		Data["Eyes Rotation"] = Modules.AllEyes:ChooseStoreEyes()
	end

	--[[if not Data["Outfits Rotation"] then
		Data["Outfits Rotation"] = Modules.AllOutfits:ChooseStoreAccessories()
	end]]
	
	if not Data["LastPlayTime"] then
		Data["LastPlayTime"] = os.time()-(30*60)
	end
	
	if not Data["Gems"] then
		Data["Gems"] = 1000
		Data["Stats"]["Total Gems"] = 0
	end
	
	if not Data["Tools"] then
		Data["Tools"] = {}
	end

	if not Data["Fish Found"] then
		Data["Fish Found"] = {}
	end

	if not Data["Enchanted Fish Found"] then
		Data["Enchanted Fish Found"] = {}
	end

	if not Data["Twitter Verification"] then
		Data["Twitter Verification"] = false
	end

	if not Data["Discord Verification"] then
		Data["Discord Verification"] = false
	end

	if not Data["Event"] then
		Data["Event"] = {
			[1] = "Egg Hunt", -- event name
			[2] = { --eggs found
				["Blue"] = 0,
				["Green"] = 0,
				["Purple"] = 0,
				["Red"] = 0,
				["Gold"] = 0,
			},
			[3] = {
				--unlocked
			}
		}
	end

	if Data["Event"] then
		if not Data["Event"][3] then
			Data["Event"][3] = {}
		end
	end

	if not Data["Outfits"] then
		Data["Outfits"] = {
			["None"] = true,
		}
	end

	if not Data["My Penguin"]["Outfit"] then
		Data["My Penguin"]["Outfit"] = "None"
	end

	if not Data["Emotes"]["Vegetable Cutting"] then
		Data["Emotes"]["Vegetable Cutting"] = true;
		Data["Emotes"]["Giving Pizza"] = true;
		Data["Emotes"]["Crying"] = true;
		Data["Emotes"]["Stove Opening"] = true;
		Data["Emotes"]["Dough Flipping"] = true;
		Data["Emotes"]["Cheering"] = true;
	end
		

	if not Data["Equipped Emotes"] then
		Data["Equipped Emotes"] = {
			["1"] = "Sit";
			["2"] = "Wave";
			["3"] = "Sleep";
			["4"] = "Point";
			["5"] = "Salute";
		}
	end

	if not Data["Pets"] then
		Data["Pets"] = {
			Equipped = nil, 
			PetsOwned = {
			}, 
			Food = {
				--{Name = "Carrot", Amount = 4},	
			},
			Toys = {
				--{Name = "Plushy"},	
			},
		}
	end

end


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
	-- Setup Data
	PlayerData:SetupPlayerData(Player)
	SetupNewStats(Player)
	

	-- Setup Chat
	Modules.Chat:ApplyChatTag(Player)


	-- Group reward
	pcall(function()
		if Player:IsInGroup(12843903) and not PlayerData.sessionData[Player.Name]["Group Reward Claimed"] then
			PlayerData.sessionData[Player.Name]["Group Reward Claimed"] = true
			Modules.Income:AddMoney(Player, 5000)
			Remotes.GroupReward:FireClient(Player, true)
		end
	end)
	
	
	-- Initialize Character Functions
	local OldChar = nil
	Player.CharacterAdded:Connect(function(Character)
		Modules.Character:Spawned(Player, Character, OldChar)
		OldChar = Character
	end)
	
	
	-- Check Gamepasses
	Modules.Gamepasses:CheckGamepasses(Player)
	
	
	-- Data check just incase
	if not PlayerData.sessionData[Player.Name] then Player:Kick("Data Error: Rejoin") return end
	
	
	-- Setup Attributes
	Player:SetAttribute("Tycoon", "None")
	Player:SetAttribute("Money", PlayerData.sessionData[Player.Name]["Money"])
	Player:SetAttribute("Gems", PlayerData.sessionData[Player.Name]["Gems"])
	Player:SetAttribute("Income", PlayerData.sessionData[Player.Name]["Income"])
	Player:SetAttribute("Hearts", PlayerData.sessionData[Player.Name]["Hearts"])
	Player:SetAttribute("Level", PlayerData.sessionData[Player.Name]["My Penguin"]["Level"])
	
	
	Player:SetAttribute("Next5Gems", PlayerData.sessionData[Player.Name]["NextGemReward"])
	Modules.PlayerData.sessionData[Player.Name]["NextGemRewardSaved"] = "city"

	
	if PlayerData.sessionData[Player.Name]["Pets"].Equipped then
		Player:SetAttribute("Pet", PlayerData.sessionData[Player.Name]["Pets"].Equipped.RealName)
		Player:SetAttribute("PetID", PlayerData.sessionData[Player.Name]["Pets"].Equipped.ID)
		Player:SetAttribute("PetName", PlayerData.sessionData[Player.Name]["Pets"].Equipped.Name)
		Player:SetAttribute("PetHunger", PlayerData.sessionData[Player.Name]["Pets"].Equipped.Hunger)
		Player:SetAttribute("PetEntertainment", PlayerData.sessionData[Player.Name]["Pets"].Equipped.Entertainment)
		Player:SetAttribute("PetHappiness", PlayerData.sessionData[Player.Name]["Pets"].Equipped.Happiness)
	end
	
	-- Setup Leaderstats
	local leaderstats = Instance.new("Folder", Player)
	leaderstats.Name = "leaderstats"

	--local MoneyStat = Instance.new("IntValue", leaderstats)
	--MoneyStat.Name = "Money"
	--MoneyStat.Value = PlayerData.sessionData[Player.Name]["Money"]

	--local IncomeStat = Instance.new("IntValue", leaderstats)
	--IncomeStat.Name = "Income"
	--IncomeStat.Value = PlayerData.sessionData[Player.Name]["Income"]

	local NetworthStat = Instance.new("IntValue", leaderstats)
	NetworthStat.Name = "Networth"
	NetworthStat.Value = PlayerData.sessionData[Player.Name]["Stats"]["Total Money"]
	
	
	-- Updating Leaderstats
	Player:GetAttributeChangedSignal("Money"):Connect(function()
		NetworthStat.Value = PlayerData.sessionData[Player.Name]["Stats"]["Total Money"]
	end)
	
	Player:GetAttributeChangedSignal("Hearts"):Connect(function()
		if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Player.Character.HumanoidRootPart:FindFirstChild("CustomName") then
			Player.Character.HumanoidRootPart.CustomName.Hearts.Amount.Text = Modules.Format:FormatComma(PlayerData.sessionData[Player.Name]["Hearts"])
		end
	end)
	
	--Player:GetAttributeChangedSignal("Income"):Connect(function()
	--	IncomeStat.Value = PlayerData.sessionData[Player.Name]["Income"] * PlayerData.sessionData[Player.Name]["Income Multiplier"]
	--end)
	
	-- Spawn character
	Modules.Character:Spawn(Player)
	Player:SetAttribute("Loaded",true)
end)

return PlayerData