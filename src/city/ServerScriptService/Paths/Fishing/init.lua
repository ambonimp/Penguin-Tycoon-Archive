local paths = require(script.Parent)

local modules = paths.Modules
local config = modules.FishingConfig

local allAccessories = modules.AllAccessories
local accessories = modules.Accessories

local remotes = paths.Remotes

local DataStoreService = game:GetService("DataStoreService")
local ServerStorage = game:GetService("ServerStorage")
local EventHandler = ServerStorage:FindFirstChild("EventHandler")

local REEL_DEBOUNCE = 2.9 -- seconds
local MAXIMUM_THROW_DISTANCE = 100
local ISLAND_RADIUS = 450
local announcementRemote: RemoteEvent = remotes:WaitForChild("Announcement")

local reelFish: RemoteFunction = remotes:WaitForChild("ReelFish")
local FishingRemote: RemoteEvent = remotes:WaitForChild("FishingRemote")
local rand = Random.new()
local RequestList = {}
local itemTypes = config.ItemType

local Fishing = {}
local RewardQueue = {}

local awards = {
	["Common"] = 40,
	["Rare"] = 50,
	["Epic"] = 75,
	["Legendary"] = 100,
	["Mythic"] = 200,
}
local RarityAmount = {}
local FishCategories = {
	["Common"] = {},
	["Rare"] = {},
	["Epic"] = {},
	["Legendary"] = {},
	["Mythic"] = {},
}

for i,v in pairs (config.ItemList) do
	if v.Rarity and FishCategories[v.Rarity] then
		table.insert(FishCategories[v.Rarity],i)
	end
end
for i,v in pairs (FishCategories) do
	RarityAmount[i] = #v
end

function checkFishRewards(Player)
	local sessionData = modules.PlayerData.sessionData[Player.Name]
	if sessionData then
		if modules.PlayerData.sessionData[Player.Name]["Fish Rewards"] == nil then
			modules.PlayerData.sessionData[Player.Name]["Fish Rewards"] = {}
		end
		local CaughtFish = sessionData["Fish Found"]
		local CaughtJunk = sessionData["Junk Found"]
		local ownedRarity = {
			["Common"] = 0,
			["Rare"] = 0,
			["Epic"] = 0,
			["Legendary"] = 0,
			["Mythic"] = 0,
		}
		for ID,fishData in pairs (config.ItemList) do
			if fishData.Rarity and CaughtFish[tostring(ID)] and CaughtFish[tostring(ID)] >= 1 and ownedRarity[fishData.Rarity] then
				ownedRarity[fishData.Rarity] += 1
			end
		end
		for rarity,amount in pairs (ownedRarity) do
			if amount >= RarityAmount[rarity] and sessionData["Fish Rewards"][rarity] == nil then
				modules.PlayerData.sessionData[Player.Name]["Fish Rewards"][rarity] = true
				modules.Income:AddGems(Player, awards[rarity], "Fish Reward")
				remotes.FishRewards:FireClient(Player,rarity,awards[rarity])
			end
		end

		if CaughtJunk then
			if CaughtJunk["51"] and CaughtJunk["51"] >= 200 and sessionData["Accessories"]["Boot Hat"] == nil then --boot
				modules.Accessories:ItemAcquired(Player, "Boot Hat", "Accessory")
				remotes.FishRewards:FireClient(Player,"Boot Hat")
			end
			if CaughtJunk["52"] and CaughtJunk["52"] >= 200 and sessionData["Accessories"]["Bottle Hat"] == nil then
				modules.Accessories:ItemAcquired(Player, "Bottle Hat", "Accessory")
				remotes.FishRewards:FireClient(Player,"Bottle Hat")
			end
			if CaughtJunk["53"] and CaughtJunk["53"] >= 200 and sessionData["Accessories"]["Seaweed Hat"] == nil then
				modules.Accessories:ItemAcquired(Player, "Seaweed Hat", "Accessory")
				remotes.FishRewards:FireClient(Player,"Seaweed Hat")
			end
		end
	end
end

function Fishing.GetRandomId(chanceTable)
	if not chanceTable then
		return
	end

	local randomNumber = rand:NextNumber(0, 1)
	local previousValue

	for i, entry in ipairs(chanceTable) do
		if i == 1 then
			previousValue = 0
		else
			previousValue = chanceTable[i - 1].Percentage
		end

		if randomNumber >= previousValue and randomNumber <= entry.Percentage then
			return entry.Id
		end
	end
end

function Fishing.FindNearestIsland(playerPosition)
	local items = {"OpenSea"}
	for island, data in pairs(config.IslandsData) do
		table.insert(items,island)
	end

	return items[math.random(1,#items)]--[[
	local dataTable = {}

	for island, data in pairs(config.IslandsData) do
		local mag = (playerPosition - data.CenterPosition).Magnitude
		table.insert(dataTable, { IslandName = island, Magnitude = mag })
	end

	table.sort(dataTable, function(a, b)
		return a.Magnitude < b.Magnitude
	end)
	if #dataTable == 0 then
		return
	end

	if dataTable[1].Magnitude < ISLAND_RADIUS then
		return dataTable[1].IslandName
	else
		return "OpenSea"
	end]]
end

function Fishing.GetRandomFish(playerPosition)
	local zone = Fishing.FindNearestIsland(playerPosition)
	if not config.ChanceTable[zone] then
		return
	end

	-- gets a random fish ID from the zone
	local randomId = Fishing.GetRandomId(config.ChanceTable[zone])

	local fishInfo = {}
	fishInfo.Id = randomId

	-- create table of data
	for i, v in pairs(config.ItemList[randomId]) do
		fishInfo[i] = v
	end

	return fishInfo
end

function GetDebounceSeconds(player)
	local rod = player:GetAttribute("Tool")
	local debounce

	if rod and rod == "Gold Fishing Rod" then
		debounce = 1
	else
		debounce = 3
	end
	return debounce
end

function GetPlayerRequest(player)
	local debounceSeconds = GetDebounceSeconds(player)

	if not RequestList[player.UserId] then
		RequestList[player.UserId] = {
			PreviousCall = nil,
		}
	end

	local playerRequest = RequestList[player.UserId]
	if playerRequest["PreviousCall"] and (os.clock() - playerRequest.PreviousCall < debounceSeconds) then
		return false
	end

	playerRequest["PreviousCall"] = os.clock()
	return true
end

function GiveHat(player, playerData)
	local receivedHat = false

	for hatName, info in pairs(allAccessories.All) do
		if not info.IsForSale then
			continue
		end

		if not playerData.Accessories[hatName] then
			accessories:ItemAcquired(player, hatName, "Accessory")
			receivedHat = true
			break
		end
	end

	return receivedHat
end

function GetEnchantState(position)
	local decimalChance = 0.01

	for _, pool in pairs(workspace.ActivePools:GetChildren()) do
		local poolPos = pool:GetPivot().Position
		if (position - poolPos).Magnitude < 50 then
			decimalChance = 0.1
		end
	end

	return rand:NextNumber(0, 1) <= decimalChance
end

remotes.AFKFishing.OnServerEvent:Connect(function(player, fishing)
	if fishing then
		player:SetAttribute("isAFKFishing", true)
		modules.PlayerData.sessionData[player.Name]["WasFishing"] = os.time()
	elseif  modules.PlayerData.sessionData[player.Name] and modules.PlayerData.sessionData[player.Name]["WasFishing"] then
		player:SetAttribute("isAFKFishing", false)
		local duration = os.time() - modules.PlayerData.sessionData[player.Name]["WasFishing"]
		modules.PlayerData.sessionData[player.Name]["WasFishing"] = nil

		-- Avoid sending many requests, so fire only if longer than 3 seconds
		if duration > 3 then
			-- Fires a bindable event to notify server that this event has occured with given data
			-- Used normally to integrate with Game Analytics / Dive / Playfab
			local success, msg = pcall(function()
				EventHandler:Fire("endedFishing", player, {
					duration_in_seconds = duration,
				})
			end)
		end
	else
		player:SetAttribute("isAFKFishing", false)
		modules.PlayerData.sessionData[player.Name]["WasFishing"] = nil
	end
end)

function AddReward(player, returnData, hitPosition, AFKFishing)
	local sessionData = modules.PlayerData.sessionData
	local lootInfo = returnData.LootInfo

	if sessionData and sessionData[player.Name] then
		-- should hats be added to some sort of index?
		if lootInfo.Type == itemTypes.Hat then
			local result = GiveHat(player, sessionData[player.Name])

			if not result then
				Main(player, hitPosition, true)
			end
		elseif lootInfo.Type == itemTypes.Gem then
			--if not AFKFishing then
			modules.Income:AddGems(player, lootInfo.Gems, "Reward")
			--end

			-- no need to save junk to index, just give money
		elseif lootInfo.Type == itemTypes.Junk then
			--if not AFKFishing then
			if sessionData[player.Name]["Junk Found"] == nil then
				sessionData[player.Name]["Junk Found"] = {
					["51"] = 0,
					["52"] = 0,
					["53"] = 0,
				}
			end
			
			if lootInfo.Id then
				sessionData[player.Name]["Junk Found"][tostring(lootInfo.Id)] += 1
				returnData.Amount = sessionData[player.Name]["Junk Found"][tostring(lootInfo.Id)]
			end

			modules.Income:AddMoney(player, returnData.Worth)
			--end

			-- all fish
		else
			local fishFound = sessionData[player.Name]["Fish Found"]
			local enchantedFishFound = sessionData[player.Name]["Enchanted Fish Found"]
			returnData.Enchanted = GetEnchantState(hitPosition)
			if returnData.Enchanted then
				returnData.Worth *= 10
			end

			--if not AFKFishing then
			modules.Income:AddMoney(player, returnData.Worth)
			--end

			if returnData.Enchanted then
				if enchantedFishFound and enchantedFishFound[tostring(lootInfo.Id)] then
					enchantedFishFound[tostring(lootInfo.Id)] += 1
				else
					enchantedFishFound[tostring(lootInfo.Id)] = 1
				end
			else
				if fishFound and fishFound[tostring(lootInfo.Id)] then
					fishFound[tostring(lootInfo.Id)] += 1
				else
					fishFound[tostring(lootInfo.Id)] = 1
				end
			end
		end
		checkFishRewards(player)
	end
end

function Main(player, hitPosition, reroll, AFKFishing)
	if not reroll and not GetPlayerRequest(player) then
		return
	end--[[
	task.defer(function()
		if math.random(1,100) <= 2 then
			paths.Modules.PoolSpawner.createCustom(player,hitPosition + Vector3.new(math.random(-10,10),0,math.random(-10,10)))
		end
	end)]]
	local multiplier = 1
	if AFKFishing then
		multiplier = 0.25 
	end
	local playerIncome = player:GetAttribute("Income") or 0

	local data = {}
	local characterPosition = player.Character:GetPivot().Position
	data.LootInfo = Fishing.GetRandomFish(player.Character:GetPivot().Position)
	--print(data,data.LootInfo)
	if data.LootInfo and data.LootInfo["IncomeMultiplier"] then
		data.Worth = math.floor(playerIncome * data.LootInfo.IncomeMultiplier) or 0
		local old = data.Worth
		if old ~= 0 then
			data.Worth = math.ceil(data.Worth * multiplier)
		end
	end

	if modules.Income then
		AddReward(player, data, hitPosition, AFKFishing)
		announcementRemote:FireAllClients(player, data.LootInfo)
		return data
	end
end

reelFish.OnServerInvoke = Main

local last = {}

FishingRemote.OnServerEvent:Connect(function(player, handlingType, data)
	if handlingType == "Delete" and data then
		return
	end
	FishingRemote:FireAllClients(player, handlingType, data)
end)

return Fishing