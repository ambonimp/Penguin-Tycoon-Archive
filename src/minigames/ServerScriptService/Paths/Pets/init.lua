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

function getRandomPet(chanceTable)
	local randomNumber = rand:NextNumber(0, 1)
	local previousValue

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

function givePet(Player, PetId, Chosen, IslandId)
	local Data = Modules.PlayerData.sessionData[Player.Name]
	if Data then
		Data = Data["Pets_Data"]
		if #Data.PetsOwned >= Data.MaxOwned then return  end

		local petInfo = PetDetails.Pets[PetId]
		local newId = getEmptyNum(Data.PetsOwned)

		Data.PetsOwned[newId] = {
			petInfo[1],
			petInfo[2],
			petInfo[1],
			PetDetails.Rarities[Chosen.Percentage],
			1,
			{
				petInfo[3],
				petInfo[4],
				petInfo[5]
			},
			PetId,IslandId
		}

		warn(Chosen.Id, typeof(Chosen.Id))
		if Data.Unlocked[tostring(Chosen.Id)] then
			Data.Unlocked[tostring(Chosen.Id)] += 1
		else
			Data.Unlocked[tostring(Chosen.Id)] = 1
		end

		warn("THIS2: ", Data.Unlocked)
		print(Data)
		return newId, petInfo
	end

end

function Pets.BuyRobuxPet(Player,IslandId)
	local ChanceTable = PetDetails.ChanceTables[IslandId]
	local chosen = getRandomPet(ChanceTable.Pets)
	local petId, petInfo = givePet(Player,chosen.Id,chosen,IslandId)
	Remotes.BuyEgg:InvokeClient(Player,"NewPet",Modules.PlayerData.sessionData[Player.Name]["Pets_Data"],petId,petInfo)
end

function BuyEgg(Player,Island,Type)
	if Modules.PlayerData.sessionData[Player.Name] then
		local ChanceTable = PetDetails.ChanceTables[PetDetails.EggNameToId[Island]]

		if Type == "Robux" then
			Services.MPService:PromptProductPurchase(Player, ChanceTable.ProductId)
		elseif Type == "Gems" then
			local Price = ChanceTable.PriceGems

			if Modules.PlayerData.sessionData[Player.Name]["Gems"] >= Price then
				local chosen = getRandomPet(ChanceTable.Pets)
				local newId,petInfo = givePet(Player,chosen.Id,chosen,PetDetails.EggNameToId[Island])
				Modules.PlayerData.sessionData[Player.Name]["Gems"] -= Price
				Player:SetAttribute("Gems", Modules.PlayerData.sessionData[Player.Name]["Gems"])

				warn(Modules.PlayerData.sessionData[Player.Name]["Pets_Data"].Unlocked)

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

return Pets
