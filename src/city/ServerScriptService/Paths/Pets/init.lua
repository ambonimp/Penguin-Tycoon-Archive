--Pet handler on server
local Pets = {}

local Paths = require(script.Parent)
local BadgeService = game:GetService("BadgeService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Assets = ReplicatedStorage:WaitForChild("Assets")
local PetModels = Assets:WaitForChild("Pets")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local PlayerData = Paths.Modules.PlayerData

local EggsModule = require(Modules:WaitForChild("Eggs"))
local ToysModule = require(Modules:WaitForChild("ToyDetails"))
local FoodModule = require(Modules:WaitForChild("FoodDetails"))
local EquipPetRemote = Remotes:WaitForChild("EquipPet")
local UnequipPetRemote = Remotes:WaitForChild("UnequipPet")
local BuyPetRemote = Remotes:WaitForChild("BuyPet")

local ServerPets = require(script:WaitForChild("ServerPets"))
local Personalitys = require(script:WaitForChild("Traits"))
local Badges = {
	["Cat"] = 2125745835,
	["Dog"] = 2125745840,
	["Dinosaur"] = 2125745844,
	["Unicorn"] = 2125745845,
	["Rabbit"] = 2125745852,
	["Panda"] = 2125745857,
}

--Makes sure a player owns the pet ID
function Pets.OwnsPet(Player,ID)
	for i,Pet in pairs (PlayerData.sessionData[Player.Name]["Pets"].PetsOwned) do
		if Pet.ID == ID then
			return true,Pet,i
		end
	end
end

--Gets the pet from the pet ID
function Pets.GetPetFromID(Player,ID)
	local Owns,Pet,i = Pets.OwnsPet(Player,ID)
	if Owns and Pet then
		return Pet,i
	end
end

--Sets data for equipped pet and changes attributes
function Pets.EquipPet(Player,PetID)
	local PetTable = Pets.GetPetFromID(Player,PetID)
	if PetTable then
		local RealName = PetTable.RealName
		local ID = PetTable.ID
		local Hunger = PetTable.Hunger
		local Name = PetTable.Name
		local Entertainment = PetTable.Entertainment
		local Happiness = PetTable.Happiness

		Player:SetAttribute("Pet", RealName)
		Player:SetAttribute("PetName", Name)
		Player:SetAttribute("PetHunger", Hunger)
		Player:SetAttribute("PetEntertainment", Entertainment)
		Player:SetAttribute("PetHappiness",  PetTable.Happiness)
		Player:SetAttribute("PetGender", PetTable.Gender)
		Player:SetAttribute("PetID", ID)

		PlayerData.sessionData[Player.Name]["Pets"].Equipped = {}
		PlayerData.sessionData[Player.Name]["Pets"].Equipped.RealName = RealName
		PlayerData.sessionData[Player.Name]["Pets"].Equipped.ID = ID
		PlayerData.sessionData[Player.Name]["Pets"].Equipped.Name = Name
		PlayerData.sessionData[Player.Name]["Pets"].Equipped.Hunger = Hunger
		PlayerData.sessionData[Player.Name]["Pets"].Equipped.Entertainment = Entertainment
		PlayerData.sessionData[Player.Name]["Pets"].Equipped.Happiness = Happiness
	end
end

--Unequip pet and remove equipped data
function Pets.UnequipPet(Player)
	local PetTable = Pets.GetPetFromID(Player,Player:GetAttribute("PetID"))
	if PetTable then
		local RealName = PetTable.RealName
		local ID = PetTable.ID
		local Hunger = PetTable.Hunger
		local Name = PetTable.Name
		local Entertainment = PetTable.Entertainment

		Player:SetAttribute("Pet", "none")
		Player:SetAttribute("PetID", -1)
		Player:SetAttribute("PetName", "none")
		Player:SetAttribute("PetHunger", 0)
		Player:SetAttribute("PetEntertainment", 0)
		Player:SetAttribute("PetHappiness", 0)

		PlayerData.sessionData[Player.Name]["Pets"].Equipped = nil
	end
end

--feeds pet a random food
function Pets.FeedPet(Player)
	if PlayerData.sessionData[Player.Name]["Pets"].Equipped then
		local amount = 0
		local PetTable = Pets.GetPetFromID(Player,Player:GetAttribute("PetID"))
		local food = Assets.Foods:GetChildren()[math.random(1,# Assets.Foods:GetChildren())].Name
		amount = FoodModule[food].Hunger
		if PetTable.FavFood == food then
			amount = amount * 2
		end
		PetTable.Hunger = PetTable.Hunger + amount 
		if PetTable.Hunger > 100 then
			PetTable.Hunger = 100
		end
		PetTable.Happiness = math.floor((PetTable.Hunger+PetTable.Entertainment)/2)
		Player:SetAttribute("PetHappiness", PetTable.Happiness)
		Player:SetAttribute("PetHunger", PetTable.Hunger)
		Player.Character:SetAttribute("PetAnimation", "Feed_"..food)
		return food,amount
	end
end

--does pet trick
function Pets.PetTrick(Player)
	Player:SetAttribute("PetTrick",tick())
end

--plays catch with pet a 
function Pets.PlayPet(Player)
	if PlayerData.sessionData[Player.Name]["Pets"].Equipped then
		local amount = 0
		local PetTable = Pets.GetPetFromID(Player,Player:GetAttribute("PetID"))
		local toy = Assets.Toys:GetChildren()[math.random(1,# Assets.Toys:GetChildren())].Name
		amount = ToysModule[toy].Entertainment
		if PetTable.FavToy == toy then
			amount = amount * 2
		end
		PetTable.Entertainment = PetTable.Entertainment + amount 
		if PetTable.Entertainment > 100 then
			PetTable.Entertainment = 100
		end
		PetTable.Happiness = math.floor((PetTable.Hunger+PetTable.Entertainment)/2)
		Player:SetAttribute("PetHappiness", PetTable.Happiness)
		Player:SetAttribute("PetEntertainment", PetTable.Entertainment)
		Player.Character:SetAttribute("PetAnimation", "Toy_"..toy)
		return toy,amount
	end
end

--gets a random pet from egg, then gets a random color from list of colors
function getRandomPet(Pets)
	local RandomNumber = math.random(1, 100)
	
	local Number = 0
	local PetType = nil
	for PetName, Chance in pairs(Pets) do
		Number = Number + Chance
		if RandomNumber <= Number then
			PetType = PetName
			break
		end
	end
	local RealPets = EggsModule.Pets[PetType] --colors
	local o = RandomNumber
	RandomNumber = math.random(1, 100)
	Number = 0
	for PetName, Chance in pairs(RealPets) do 
		Number = Number + Chance
		if RandomNumber <= Number then
			PetType = PetName
			break
		end
	end
	return PetType
end

function getOpenPetId(Player) --returns an id from 1-10000 currently not in use, future proof incase we add deleting pets, don't want to shift around ID's
	local pet = #PlayerData.sessionData[Player.Name]["Pets"].PetsOwned
	for i = 1,10000 do
		if Pets.GetPetFromID(Player,i) == nil then
			pet = i
			break
		end
	end
	return pet
end

function addPetToInventory(Player,PetName) --adds a pet to inventory
	local petId = getOpenPetId(Player)
	local newPet = {
		ID = petId,
		Name = PetName,
		Entertainment = 85,
		Hunger = 95,
		Happiness = 90,
		RealName = PetName,
		Adopted = os.date("%x"),
		Personality = Personalitys[math.random(1,#Personalitys)],
		FavFood = Assets.Foods:GetChildren()[math.random(1,#Assets.Foods:GetChildren())].Name,
		FavToy = Assets.Toys:GetChildren()[math.random(1,#Assets.Toys:GetChildren())].Name,
		Gender = math.random(1,2) == 1 and "Male" or "Female"
	}
	table.insert(PlayerData.sessionData[Player.Name]["Pets"].PetsOwned,newPet)
	Remotes.NewPet:FireClient(Player,PlayerData.sessionData[Player.Name]["Pets"])
	return petId
end

function getPetEgg(PetType)
	for i,egg in pairs (EggsModule.Eggs) do
		if egg.Pets[PetType] then
			return egg
		end
	end
	return nil
end

function getPetRarity(PetName)
	local split = string.split(PetName," ")
	local PetType = split[2]
	local egg = getPetEgg(PetType)
	if egg then
		local rarity = egg.Pets[PetType]
		return rarity == 1
	end
end

function changePetName(Player,PetID,NewName,IsNew) --changes pet name first time. also will be used in the future 
	local pet,i = Pets.GetPetFromID(Player,PetID)
	if pet then
		PlayerData.sessionData[Player.Name]["Pets"].PetsOwned[i].Name = NewName
		Remotes.UpdatePetName:FireClient(Player,PlayerData.sessionData[Player.Name]["Pets"],PetID,NewName)
		if PlayerData.sessionData[Player.Name]["Pets"].Equipped == nil then
			Pets.EquipPet(Player,PetID)
		end
		if IsNew then
			for petname,badgeid in pairs (Badges) do
				if BadgeService:UserHasBadge(Player.UserId,badgeid) == false then
					if string.find(string.lower(pet.RealName),string.lower(petname)) then
						print("AWARD BADGE:",petname)
						BadgeService:AwardBadge(Player.UserId, badgeid)
					end
				end
			end
			
			local rarity = getPetRarity(pet.RealName)
			if rarity then
				Remotes.Announcement:FireAllClients({Type = "Poofie", Name = Player.Name, RealName = pet.RealName, Id = 1})
			end
		end
	end
end

function Pets.BuyPet(Player,Egg,product) --buys an egg
	local Price = EggsModule.Eggs[Egg].PriceGems
	local pet = getRandomPet(EggsModule.Eggs[Egg].Pets)
	local petNames = {}
	for Name,Rarity in pairs (EggsModule.Eggs[Egg].Pets) do
		local pets = EggsModule.Pets[Name]
		local count = 0
		for i,v in pairs (pets) do
			count = count + 1
		end
		
		local r = math.random(1,count)
		local x = 0
		for i,v in pairs (pets) do
			x = x + 1
			if x == r then
				table.insert(petNames,i)
				break
			end
		end
	end
	if product then
		local ID = addPetToInventory(Player,pet)
		Remotes.BuyPetProduct:FireClient(Player,petNames, pet, ID, PlayerData.sessionData[Player.Name]["Pets"])
	else
		if PlayerData.sessionData[Player.Name].Gems >= Price then
			PlayerData.sessionData[Player.Name].Gems = PlayerData.sessionData[Player.Name].Gems - Price
			Player:SetAttribute("Gems", PlayerData.sessionData[Player.Name].Gems)
			local ID = addPetToInventory(Player,pet)
			return true, petNames, pet, ID, PlayerData.sessionData[Player.Name]["Pets"]
		else
			return "Not Enough"
		end
	end
end

--used for pet name filter
function FilterString(Player,String)
	return game:GetService("Chat"):FilterStringForBroadcast(String, Player)
end

--Handles depletion of stats
function Pets.HandleStats(Player)
	while Player and wait(5) do
		if PlayerData.sessionData[Player.Name] and PlayerData.sessionData[Player.Name]["Pets"].Equipped then
			local id = PlayerData.sessionData[Player.Name]["Pets"].Equipped.ID

			for i,Pet in pairs (PlayerData.sessionData[Player.Name]["Pets"].PetsOwned) do
				if Pet.ID == id then
					local done1,done2 = false,false
					local w1 = wait(math.random(0,3))
					local w2 = wait(math.random(0,3))
					if w1 == w2 then
						Pet.Hunger = Pet.Hunger > 0 and Pet.Hunger - 1 or 0
						PlayerData.sessionData[Player.Name]["Pets"].Equipped.Hunger = Pet.Hunger

						Pet.Entertainment = Pet.Entertainment > 0 and Pet.Entertainment - 1 or 0
						PlayerData.sessionData[Player.Name]["Pets"].Equipped.Entertainment = Pet.Entertainment

						Pet.Happiness = math.floor((Pet.Hunger + Pet.Entertainment)/2)
						PlayerData.sessionData[Player.Name]["Pets"].Equipped.Happiness = Pet.Happiness

						if Player:GetAttribute("PetID") == id then
							Player:SetAttribute("PetHappiness", Pet.Happiness)
							Player:SetAttribute("PetHunger", Pet.Hunger)
							Player:SetAttribute("PetEntertainment", Pet.Entertainment)
						end

					else
						spawn(function()
							wait(w1)
							if PlayerData.sessionData[Player.Name] then
								Pet.Hunger = Pet.Hunger > 0 and Pet.Hunger - 1 or 0
								PlayerData.sessionData[Player.Name]["Pets"].Equipped.Hunger = Pet.Hunger

								Pet.Happiness = math.floor((Pet.Hunger + Pet.Entertainment)/2)
								PlayerData.sessionData[Player.Name]["Pets"].Equipped.Happiness = Pet.Happiness

								if Player:GetAttribute("PetID") == id then
									Player:SetAttribute("PetHappiness", Pet.Happiness)
									Player:SetAttribute("PetHunger", Pet.Hunger)
								end
							end
							
							done1 = true
						end)
						spawn(function()
							wait(w2)
							if PlayerData.sessionData[Player.Name] then
								Pet.Entertainment = Pet.Entertainment > 0 and Pet.Entertainment - 1 or 0
								PlayerData.sessionData[Player.Name]["Pets"].Equipped.Entertainment = Pet.Entertainment

								Pet.Happiness = math.floor((Pet.Hunger + Pet.Entertainment)/2)
								PlayerData.sessionData[Player.Name]["Pets"].Equipped.Happiness = Pet.Happiness

								if Player:GetAttribute("PetID") == id then
									Player:SetAttribute("PetHappiness", Pet.Happiness)
									Player:SetAttribute("PetEntertainment", Pet.Entertainment)
								end
								done2 = true
							end
						end)
						repeat wait() until done1 and done2
					end
					break
				end
			end
		end
	end
end

--Connect remote events
EquipPetRemote.OnServerEvent:Connect(Pets.EquipPet)
UnequipPetRemote.OnServerEvent:Connect(Pets.UnequipPet)
Remotes.UpdatePetName.OnServerEvent:Connect(changePetName)

BuyPetRemote.OnServerInvoke = Pets.BuyPet
Remotes.FeedPet.OnServerInvoke = Pets.FeedPet
Remotes.PlayPet.OnServerInvoke = Pets.PlayPet
Remotes.FilterString.OnServerInvoke = FilterString

Remotes.PetTrick.OnServerEvent:Connect(Pets.PetTrick)
Remotes.ResetPetAnimation.OnServerEvent:Connect(function(player)
	player.Character:SetAttribute("PetAnimation","none")
end)

for i,Player in pairs (game.Players:GetPlayers()) do
	spawn(function()
		Pets.HandleStats(Player)
	end)
end

game.Players.PlayerAdded:Connect(Pets.HandleStats)


return Pets
