--Pet handler on server
local Pets = {}
local Paths = require(script.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes
local PetDetails = Modules.PetDetails
local Assets = Services.RStorage.Assets
local PetsAssets = Assets.Pets
local Chat = game:GetService("Chat")
local rand = Random.new()

local announcementRemote = Remotes:WaitForChild("Announcement")

local FreePets = {
	[1] = {"Leafy","Default",1.05,"Fishing","Income",1,1},
	[2] = {"Elebuddy","Default",1.05,"Walk","Speed",3,13},
	[3] = {"Glacyx","Default",1.05,"Paycheck","Income",5,25},
}

local RARITY_ACHIEVEMENTS = {
	Common = 14,
	Rare = 15,
	Epic = 16,
	Legendary = 17
}


function getEmptyNum(data)
	for i=1,math.huge do
		if data[tostring(i)] == nil then
			return tostring(i)
		end
	end
end

function Pets.getBonus(Player,BonusKind,BonusType)
	if Modules.PlayerData.sessionData[Player.Name] then
		local data = Modules.PlayerData.sessionData[Player.Name]["Pets_Data"]
		local current = 1
		for i,id in pairs (data.Equipped) do
			if data.PetsOwned[id] and (data.PetsOwned[id][6][2] == BonusKind or data.PetsOwned[id][6][2] == "All") and data.PetsOwned[id][6][3] == BonusType then
				current = current * data.PetsOwned[id][6][1]
			end
		end
		return current
	end
	return 1
end

function GetData(Player,ToRetrieve) --Returns a specific players Data
	if Modules.PlayerData.sessionData[ToRetrieve.Name] then
		return Modules.PlayerData.sessionData[ToRetrieve.Name]["Pets_Data"]
	end
	while ToRetrieve and Modules.PlayerData.sessionData[ToRetrieve.Name] == nil do
		task.wait()
	end
	if Modules.PlayerData.sessionData[ToRetrieve.Name]then
		return Modules.PlayerData.sessionData[ToRetrieve.Name]["Pets_Data"]
	else
		return nil
	end
end

function EditName(Player,ID,NewName)
	if Modules.PlayerData.sessionData[Player.Name] then
		local data = Modules.PlayerData.sessionData[Player.Name]["Pets_Data"]
		if data.PetsOwned[ID] then
			local text
			local s,m = pcall(function()
				text = Chat:FilterStringForBroadcast(NewName, Player)
			end)
			if s == false then
				text = "####"
			end
			Modules.PlayerData.sessionData[Player.Name]["Pets_Data"].PetsOwned[ID][3] = text
			return Modules.PlayerData.sessionData[Player.Name]["Pets_Data"],text
		end
	end
	return false
end

function DeletePet(Player,IDs)
	if Modules.PlayerData.sessionData[Player.Name] then
		local data = Modules.PlayerData.sessionData[Player.Name]["Pets_Data"]
		for i,v in pairs (IDs) do
			if data.PetsOwned[v] then
				data.PetsOwned[v] = nil
			end
		end
		return true,Modules.PlayerData.sessionData[Player.Name]["Pets_Data"]
	end
	return false
end

function Merge(Player,ID1,ID2)
	if Modules.PlayerData.sessionData[Player.Name] then
		local data = Modules.PlayerData.sessionData[Player.Name]["Pets_Data"]
		if data.PetsOwned[ID1] and data.PetsOwned[ID2] then
			if table.find(data.Equipped,ID1) or table.find(data.Equipped,ID2) then
				return false,"Equipped"
			end
			if data.PetsOwned[ID1][1] == data.PetsOwned[ID2][1] and data.PetsOwned[ID1][2] == data.PetsOwned[ID2][2] then
				if data.PetsOwned[ID1][5] == data.PetsOwned[ID2][5] then
					Modules.PlayerData.sessionData[Player.Name]["Pets_Data"].PetsOwned[ID1][5] += 1
					Modules.PlayerData.sessionData[Player.Name]["Pets_Data"].PetsOwned[ID1][6][1] += (.025*Modules.PlayerData.sessionData[Player.Name]["Pets_Data"].PetsOwned[ID1][5])
					DeletePet(Player,{ID2})
					return true,Modules.PlayerData.sessionData[Player.Name]["Pets_Data"],ID1,ID2
				else
					return false,"Not same level"
				end
			else
				return false,"Not same"
			end
		else
			return false,"Not Owned"
		end
	end
end

function getRandomPet(chanceTable,ownsPass,Player)
	local randomNumber = rand:NextNumber(0, 1)
	local previousValue
	if randomNumber*1.2 <= 1 and ownsPass then
		local prev = randomNumber
		randomNumber *= 1.2
	end
	if randomNumber*1.2 <= 1 and Player:GetAttribute("UltraEggLuck") then
		randomNumber = randomNumber*1.2
	end
	if randomNumber*1.1 <= 1 and Player:GetAttribute("SuperEggLuck") then
		randomNumber = randomNumber*1.1
	end
	for i, entry in ipairs(chanceTable) do
		if i == 1 then
			previousValue = 0
		else
			previousValue = chanceTable[i - 1].Percentage
		end

		if randomNumber >= previousValue and randomNumber <= entry.Percentage then
			return entry
		end
	end
end

function giveFreePet(Player,Chosen)
	local Data = Modules.PlayerData.sessionData[Player.Name]
	if Data then
		Data = Data["Pets_Data"]
		if Data.ClaimedFree == nil then
			Data.ClaimedFree = true
			local petInfo = FreePets[Chosen]
			local newId = getEmptyNum(Data.PetsOwned)
			
			Data.PetsOwned[newId] = {
				petInfo[1],
				petInfo[2],
				petInfo[1],
				PetDetails.Rarities[.35],
				1,
				{
					petInfo[3],
					petInfo[4],
					petInfo[5]
				},
				petInfo[7],petInfo[6]
			}
			
			if Data.Unlocked[tostring(petInfo[7])] then
				Data.Unlocked[tostring(petInfo[7])] += 1
			else
				Data.Unlocked[tostring(petInfo[7])] = 1
			end
			
			if #Data.Equipped < Player:GetAttribute("MaxEquip") then
				table.insert(Modules.PlayerData.sessionData[Player.Name]["Pets_Data"].Equipped,newId)
				Player:SetAttribute("PetsEquipped",tick())
			end
			
			return true,Data,newId, petInfo
		end
	end
	return false
end

function givePet(Player, PetId, Chosen, IslandId)
	local Data = Modules.PlayerData.sessionData[Player.Name]
	if Data then
		Data = Data["Pets_Data"]
		if #Data.PetsOwned >= Data.MaxOwned then return end

		local petInfo = PetDetails.Pets[PetId]
		local newId = getEmptyNum(Data.PetsOwned)

		local rarity = PetDetails.Rarities[Chosen.Percentage]
		Data.PetsOwned[newId] = {
			petInfo[1],
			petInfo[2],
			petInfo[1],
			rarity,
			1,
			{
				petInfo[3],
				petInfo[4],
				petInfo[5]
			},
			PetId,IslandId
		}

		Modules.Achievements.Progress(Player, RARITY_ACHIEVEMENTS[rarity])

		if Data.Unlocked[tostring(Chosen.Id)] then
			Data.Unlocked[tostring(Chosen.Id)] += 1
		else
			Data.Unlocked[tostring(Chosen.Id)] = 1
		end

		return newId, petInfo
	end

end

function Pets.BuyRobuxPet(Player,IslandId)
	local Data = Modules.PlayerData.sessionData[Player.Name]
	if Data then
		local ChanceTable = PetDetails.ChanceTables[IslandId]
		local chosen = getRandomPet(ChanceTable.Pets,Data["Gamepasses"]["56844198"],Player)
		local petId, petInfo = givePet(Player,chosen.Id,chosen,IslandId)
		task.spawn(function()
			if chosen.Percentage == 1 then
				announcementRemote:FireAllClients({
					Type = "Poofie",
					Name = Player.Name,
					RealName = petInfo[1],

				})
			end
		end)
		Remotes.BuyEgg:InvokeClient(Player,"NewPet",Modules.PlayerData.sessionData[Player.Name]["Pets_Data"],petId,petInfo)
	end
end

function BuyEgg(Player,Island,Type)
	if Modules.PlayerData.sessionData[Player.Name] then
		local ChanceTable = PetDetails.ChanceTables[PetDetails.EggNameToId[Island]]

		if Type == "Robux" then
			Services.MPService:PromptProductPurchase(Player, ChanceTable.ProductId)
		elseif Type == "Gems" then
			local Price = ChanceTable.PriceGems

			if Modules.PlayerData.sessionData[Player.Name]["Gems"] >= Price then
				local chosen = getRandomPet(ChanceTable.Pets,Modules.PlayerData.sessionData[Player.Name]["Gamepasses"]["56844198"],Player)
				local newId,petInfo = givePet(Player,chosen.Id,chosen,PetDetails.EggNameToId[Island])
				Modules.PlayerData.sessionData[Player.Name]["Gems"] -= Price
				Player:SetAttribute("Gems", Modules.PlayerData.sessionData[Player.Name]["Gems"])
				task.spawn(function()
					if chosen.Percentage == 1 then
						announcementRemote:FireAllClients({
							Type = "Poofie",
							Name = Player.Name,
							RealName = petInfo[1],

						})
					end
				end)

				return true, Modules.PlayerData.sessionData[Player.Name]["Pets_Data"], petInfo, newId
			else
				return false,"gems"
			end

		end

	end

	return nil
end

function EquipPet(Player,PetIDs)
	if Modules.PlayerData.sessionData[Player.Name] then
		local data = Modules.PlayerData.sessionData[Player.Name]["Pets_Data"]
		if #data.Equipped < Player:GetAttribute("MaxEquip") then
			local except = {}
			for i,PetID in pairs (PetIDs) do
				if data.PetsOwned[PetID] then
					if table.find(data.Equipped,PetID) == nil and #data.Equipped < Player:GetAttribute("MaxEquip") then
						table.insert(Modules.PlayerData.sessionData[Player.Name]["Pets_Data"].Equipped,PetID)
					else
						table.insert(except,PetID)
					end
				else
					table.insert(except,PetID)
				end
			end
			if #PetIDs == 1 and #except == 1 then
				return false
			end
			Player:SetAttribute("PetsEquipped",tick())
			return Modules.PlayerData.sessionData[Player.Name]["Pets_Data"],true,except
		end
	end
	return false
end

function UnequipPet(Player,PetIDs)
	if Modules.PlayerData.sessionData[Player.Name] then
		local data = Modules.PlayerData.sessionData[Player.Name]["Pets_Data"]
		for i,PetID in pairs (PetIDs) do
			local except = {}
			if data.PetsOwned[PetID] then
				if table.find(data.Equipped,PetID) then
					table.remove(Modules.PlayerData.sessionData[Player.Name]["Pets_Data"].Equipped,table.find(data.Equipped,PetID))
				else
					table.insert(except,PetID)
				end
			else
				table.insert(except,PetID)
			end
			if #PetIDs == 1 and #except == 1 then
				return false
			end
			Player:SetAttribute("PetsEquipped",tick())
			return Modules.PlayerData.sessionData[Player.Name]["Pets_Data"],true,except
		end

	end
	return false
end

Remotes.BuyEgg.OnServerInvoke = BuyEgg
Remotes.PetsRemote.OnServerInvoke = GetData
Remotes.EquipPet.OnServerInvoke = EquipPet
Remotes.UnequipPet.OnServerInvoke = UnequipPet
Remotes.MergePet.OnServerInvoke = Merge
Remotes.PetName.OnServerInvoke = EditName
Remotes.DeletePet.OnServerInvoke = DeletePet
Remotes.GetBonus.OnServerInvoke = Pets.getBonus
Remotes.ClaimPet.OnServerInvoke = giveFreePet

return Pets
