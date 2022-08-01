local paths = require(script.Parent)

local modules = paths.Modules
local config = modules.FishingConfig

local allAccessories = modules.AllAccessories
local accessories = modules.Accessories

local remotes = paths.Remotes

local DataStoreService = game:GetService("DataStoreService")
local ServerStorage = game:GetService("ServerStorage")
local EventHandler = ServerStorage:FindFirstChild("EventHandler")

local FISH_RARITY_ACHIEVEMENTS = {
	[config.Rarity.Common] = 1,
	[config.Rarity.Rare] = 2,
	[config.Rarity.Epic] = 3,
	[config.Rarity.Legendary] = 4,
	[config.Rarity.Mythic] = 5,
}

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
local FishCategories = {
	["Common"] = {},
	["Rare"] = {},
	["Epic"] = {},
	["Legendary"] = {},
	["Mythic"] = {},
	["All"] = {}
}

for i,v in pairs (config.ItemList) do
	if v.Rarity and FishCategories[v.Rarity] then
		table.insert(FishCategories[v.Rarity],i)
	end
	table.insert(FishCategories["All"],i)
end


function Fishing.GetRandomId(chanceTable,Player)
	if not chanceTable then
		return
	end

	local randomNumber = rand:NextNumber(0, 1)
	local previousValue
	if Player:GetAttribute("FishingSuperLuckBoost") then
		randomNumber *= rand:NextNumber(1.08, 1.115)
	end
	if Player:GetAttribute("FishingUltraLuckBoost") then
		randomNumber *= rand:NextNumber(1.13, 1.155)
	end
	if randomNumber > 1 and (Player:GetAttribute("FishingUltraLuckBoost") or Player:GetAttribute("FishingSuperLuckBoost"))then
		local n = math.random(1,20)
		if n >= 18 then
			if math.random(1,2) == 1 then
				randomNumber = 0.99994
			else
				randomNumber = .99999
			end
		elseif n >= 12 and n <= 18 then
			randomNumber = .99989 * rand:NextNumber(.999, 1)
		else
			randomNumber = .94789 * rand:NextNumber(.7, 1)
		end
	end
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
	end
end

function Fishing.GetRandomFish(playerPosition,Player)
	local zone = Fishing.FindNearestIsland(playerPosition)
	if not config.ChanceTable[zone] then
		return
	end

	-- gets a random fish ID from the zone
	local randomId = Fishing.GetRandomId(config.ChanceTable[zone],Player)

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

	if rod and (rod == "Gold Fishing Rod" or rod == "Rainbow Fishing Rod") then
		debounce = 1 / modules.Pets.getBonus(player,"Fishing","Speed")
	else
		debounce = 3 / modules.Pets.getBonus(player,"Fishing","Speed")
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

function GetEnchantState(position,player)
	local rod = player:GetAttribute("Tool")
	local decimalChance = 0.01

	for _, pool in pairs(workspace.ActivePools:GetChildren()) do
		local poolPos = pool:GetPivot().Position
		if (position - poolPos).Magnitude < 50 then
			decimalChance = 0.1
		end
	end
	if rod == "Rainbow Fishing Rod" then
		decimalChance *= 1.15
	end
	if decimalChance > 1 then
		decimalChance = 1
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

			if lootInfo.Id == 55 then -- Treasure chest
				modules.Achievements.Progress(player, 10)
			end

			-- no need to save junk to index, just give money
		elseif lootInfo.Type == itemTypes.Junk then
			modules.Quests.GiveQuest(player,"Catch","Junk",config.ItemList[lootInfo.Id].Name,1)
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

				if lootInfo.Id == 51 then -- Boots
					modules.Achievements.Progress(player, 8)
				elseif lootInfo.Id == 52 then -- Bottles
					modules.Achievements.Progress(player, 9)
				elseif lootInfo.Id == 53 then
					modules.Achievements.Progress(player, 7)
				end

			end
			modules.Income:AddMoney(player, returnData.Worth)
			--end

			-- all fish
		else
			sessionData[player.Name].Stats["Total Fished"] += 1

			local fishFound = sessionData[player.Name]["Fish Found"]
			local enchantedFishFound = sessionData[player.Name]["Enchanted Fish Found"]
			returnData.Enchanted = GetEnchantState(hitPosition,player)
			if returnData.Enchanted then
				returnData.Worth *= 10
			end

			local rarity = config.ItemList[lootInfo.Id].Rarity
			modules.Quests.GiveQuest(player,"Catch", rarity,"Fish",1)
			modules.Achievements.Progress(player, FISH_RARITY_ACHIEVEMENTS[rarity])

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
					modules.Achievements.Progress(player, 6) -- All fish in the index
				end

			end

		end

	end

end

function Main(player, hitPosition, reroll, AFKFishing)
	if not reroll and not GetPlayerRequest(player) then
		return
	end
	task.defer(function()
		if math.random(1,100) <= 7 then
			paths.Modules.PoolSpawner.createCustom(player,hitPosition + Vector3.new(math.random(-10,10),0,math.random(-10,10)))
		end
	end)
	local multiplier = 1
	if AFKFishing then
		multiplier = 0.25 
	end
	local playerIncome = player:GetAttribute("Income") or 0

	if player:GetAttribute("ThreeFish") then
		local data1 = {}
		for i = 1,3 do
			local data = {}
			local characterPosition = player.Character:GetPivot().Position
			data.LootInfo = Fishing.GetRandomFish(player.Character:GetPivot().Position,player)

			if data.LootInfo["IncomeMultiplier"] then
				data.Worth = math.floor(playerIncome * data.LootInfo.IncomeMultiplier) or 0


				local old = data.Worth
				if old ~= 0 then
					local mult = paths.Modules.Pets.getBonus(player,"Fishing","Income")
					data.Worth = data.Worth * mult
					data.Worth = math.ceil(data.Worth * multiplier)
				end
			end

			if modules.Income then
				AddReward(player, data, hitPosition, AFKFishing)
				announcementRemote:FireAllClients(player, data.LootInfo)
			end
			table.insert(data1,data)
		end
		return data1
	else
		local data = {}
		local characterPosition = player.Character:GetPivot().Position
		data.LootInfo = Fishing.GetRandomFish(player.Character:GetPivot().Position,player)
	
		if data.LootInfo["IncomeMultiplier"] then
			data.Worth = math.floor(playerIncome * data.LootInfo.IncomeMultiplier) or 0
			local old = data.Worth
			if old ~= 0 then
				local mult = paths.Modules.Pets.getBonus(player,"Fishing","Income")
				data.Worth = data.Worth * mult
				data.Worth = math.ceil(data.Worth * multiplier)
			end
		end
	
		if modules.Income then
			AddReward(player, data, hitPosition, AFKFishing)
			announcementRemote:FireAllClients(player, data.LootInfo)
			return data
		end
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
