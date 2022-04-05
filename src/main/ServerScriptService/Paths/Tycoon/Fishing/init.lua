local paths = require(script.Parent.Parent)

local modules = paths.Modules
local config = modules.FishingConfig

local allAccessories = modules.AllAccessories
local accessories = modules.Accessories

local remotes = paths.Remotes

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

function Fishing.GetRandomId(chanceTable)
	if not chanceTable then return end

	local randomNumber = rand:NextNumber(0, 1)
	local previousValue

	for i, entry in ipairs(chanceTable) do
		if i == 1 then previousValue = 0
		else
			previousValue = chanceTable[i-1].Percentage
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
	
	table.sort(dataTable, function(a, b) return a.Magnitude < b.Magnitude end)
	if #dataTable == 0 then return end

	if dataTable[1].Magnitude < ISLAND_RADIUS then
		return dataTable[1].IslandName
	else
		return "OpenSea"
	end
end

function Fishing.GetRandomFish(playerPosition)
	local zone = Fishing.FindNearestIsland(playerPosition)
	if not config.ChanceTable[zone] then return end
	
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
	
	if rod and rod == 'Gold Fishing Rod' then debounce = 1 else debounce = 3 end
	return debounce
end

function GetPlayerRequest(player)
	local debounceSeconds = GetDebounceSeconds(player)
	
	if not RequestList[player.UserId] then
		RequestList[player.UserId] = {
			PreviousCall = nil
		}
	end	

	local playerRequest = RequestList[player.UserId]
	if playerRequest['PreviousCall'] and (os.clock() - playerRequest.PreviousCall < debounceSeconds) then
		return false
	end
	
	playerRequest['PreviousCall'] = os.clock()
	return true
end

function GiveHat(player, playerData)
	local receivedHat = false
	
	for hatName, info in pairs(allAccessories.All) do
		if not info.IsForSale then continue end
		
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

function AddReward(player, returnData, hitPosition)
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
			modules.Income:AddGems(player, lootInfo.Gems, "Reward")
			
		-- no need to save junk to index, just give money
		elseif lootInfo.Type == itemTypes.Junk then
			modules.Income:AddMoney(player, returnData.Worth)	
			
		-- all fish			
		else
			local fishFound = sessionData[player.Name]["Fish Found"]
			local enchantedFishFound = sessionData[player.Name]["Enchanted Fish Found"]
			returnData.Enchanted = GetEnchantState(hitPosition)
			if returnData.Enchanted then returnData.Worth *= 10 end
			
			modules.Income:AddMoney(player, returnData.Worth)	
			
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
	end
end


function Main(player, hitPosition, reroll)
	if not reroll and not GetPlayerRequest(player) then return end

	local playerIncome = player:GetAttribute("Income") or 0	

	local data = {}
	local characterPosition = player.Character:GetPivot().Position
	data.LootInfo = Fishing.GetRandomFish(player.Character:GetPivot().Position)


	if data.LootInfo["IncomeMultiplier"] then
		data.Worth = math.floor(playerIncome * data.LootInfo.IncomeMultiplier) or 0		
	end

	if modules.Income then		
		AddReward(player, data, hitPosition)	
		announcementRemote:FireAllClients(player, data.LootInfo)
		return data
	end
end


reelFish.OnServerInvoke = Main


FishingRemote.OnServerEvent:Connect(function(player, handlingType, data)
	if handlingType == 'Delete' and data then
		return
	end
	
	FishingRemote:FireAllClients(player, handlingType, data)
end)

return Fishing
