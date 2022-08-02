local Outfits = {}

--- Other Variables ---
local MPService = game:GetService("MarketplaceService")

--- Accessory Variables ---
Outfits.StoreAmounts = {
	["Rare"] = 3;
	["Epic"] = 2;
	["Legendary"] = 1;
}

Outfits.Bundles = {
	[1] = {
		Outfits = {
			{"Parrot Suit","Outfits"},
			{"Cat Suit","Outfits"},
			{"Dog Suit","Outfits"},
			{"Turtle Suit","Outfits"},
		},
		Expires = 1659110400, --7/29 12pm est
		DevId = 1287414995,
	}
}

Outfits.RarityInfo = {
	["Free"] = {ID = 0000000000, PriceInRobux = 1, PriceInGems = 1};
	["Event"] = {ID = 0000000000, PriceInRobux = 1000, PriceInGems = 100000};
	["Rare"] = {ID = 1259048664, PriceInRobux = 99, PriceInGems = 125};
	["Epic"] = {ID = 1259048717, PriceInRobux = 199, PriceInGems = 250};
	["Legendary"] = {ID = 1259048739, PriceInRobux = 399, PriceInGems = 500};
}

--- Accessory Functions ---
function Outfits:ChooseStoreAccessories()
	local ChosenAccessories = {}

	for Rarity, Amount in pairs(Outfits.StoreAmounts) do
		local AccessoryList = {}

		for Accessory, Info in pairs(Outfits.All) do
			if Info.IsForSale and Info.Rarity == Rarity then
				table.insert(AccessoryList, Accessory)
			end
		end

		if #AccessoryList > Amount then
			for i = 1, Outfits.StoreAmounts[Rarity], 1 do
				local RandomNum = Random.new():NextInteger(1, #AccessoryList)
				local ChosenAccessory = AccessoryList[RandomNum]

				ChosenAccessories[ChosenAccessory] = true
				--table.insert(ChosenAccessories, ChosenAccessory)
				table.remove(AccessoryList, RandomNum)
			end
		end
	end

	return ChosenAccessories
end

Outfits.All = {	
	--- Default Outfit(s) ---
	["None"] = {Rarity = "Free", IsForSale = false};
	--Rewards
	["Hazmat Suit"] = {Rarity = "Free", IsForSale = false, Icon = ""};
	["Royale Robe"] = {Rarity = "Free", IsForSale = false, Icon = ""};
	["Lobster"] = {Rarity = "Free", IsForSale = false, Icon = ""};
	["Wilco Shirt"] = {Rarity = "Free", IsForSale = false, Icon = ""};
	["Unicorn"] = {Rarity = "Free", IsForSale = false, Icon = ""};
	--- Purchaseable Hats ---
	-- Rares
	--["Green Shirt"] = {Rarity = "Rare", IsForSale = true};
	["Gardener"] = {Rarity = "Rare", IsForSale = true, Icon = ""};
	["Fisherman"] = {Rarity = "Rare", IsForSale = true, Icon = ""};
	["Farmer"] = {Rarity = "Rare", IsForSale = true, Icon = ""};
	["Nurse"] = {Rarity = "Rare", IsForSale = true, Icon = ""};
	["Paramedic"] = {Rarity = "Rare", IsForSale = true, Icon = ""};
	["Alien"] = {Rarity = "Rare", IsForSale = false, Icon = ""};
	["Dog Suit"] = {Rarity = "Rare", IsForSale = false, Icon = ""};
	["Cat Suit"] = {Rarity = "Rare", IsForSale = false, Icon = ""};
	-- Epics
	["Steampunk"] = {Rarity = "Epic", IsForSale = true, Icon = ""};
	["Engineer"] = {Rarity = "Epic", IsForSale = true, Icon = ""};
	["Adventurer"] = {Rarity = "Epic", IsForSale = true, Icon = ""};
	["Caveman"] = {Rarity = "Epic", IsForSale = true, Icon = ""};
	["Sailor"] = {Rarity = "Epic", IsForSale = true, Icon = ""};
	["Lumberjack"] = {Rarity = "Epic", IsForSale = true, Icon = ""};
	["Tuxedo"] = {Rarity = "Epic",IsForSale = true, Icon = ""};
	["Frog"] = {Rarity = "Epic",IsForSale = true, Icon = ""};
	["Scientist"] = {Rarity = "Free", IsForSale = true, Icon = ""};
	["Turtle Suit"] = {Rarity = "Epic", IsForSale = false, Icon = ""};
	-- Legendaries
	--["Red Coat"] = {Rarity = "Legendary", IsForSale = true};
	["Firefighter"] = {Rarity = "Legendary", IsForSale = true, Icon = ""};
	["Chef"] = {Rarity = "Legendary", IsForSale = true, Icon = ""};
	["Astronaut"] = {Rarity = "Legendary", IsForSale = true, Icon = ""};
	["Police Officer"] = {Rarity = "Legendary", IsForSale = true, Icon = ""};
	["Bunny Suit"] = {Rarity = "Legendary", IsForSale = true, Icon = ""};
	["Bee"] = {Rarity = "Legendary", IsForSale = true, Icon = ""};
	["Parrot Suit"] = {Rarity = "Legendary", IsForSale = false, Icon = ""};
	--- Code Outfits ---
	
	--- Event Outfits ---
	["Red Jersey"] = {Rarity = "Event", IsForSale = false, Icon = ""};
	["Blue Jersey"] = {Rarity = "Event", IsForSale = false, Icon = ""};

	-- Mining Outfits
	["Miner"] = {Rarity = "Free", IsForSale = false, Icon = ""};

	-- Achievement
	["Banana"] = {Rarity = "Free", IsForSale = false, Icon = ""};
	["Disco"] = {Rarity = "Free", IsForSale = false, Icon = ""};
	["Ghost"] = {Rarity = "Free", IsForSale = false, Icon = ""};
	["Mummy"] = {Rarity = "Free", IsForSale = false, Icon = ""};
	["Ninja"] = {Rarity = "Free", IsForSale = false, Icon = ""};
	["Mad Scientist"] = {Rarity = "Free", IsForSale = false, Icon = ""};

}

if game:GetService("RunService"):IsServer() then
	task.spawn(function()
		for Outfit in pairs(Outfits.All) do
			if Outfit ~= "None" then
				assert(game:GetService("ReplicatedStorage").Assets.Shirts:FindFirstChild(Outfit), Outfit)
			end
		end
	end)
end

return Outfits