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
	["Rare"] = {ID = 1259048664, PriceInRobux = 149, PriceInGems = 115};
	["Epic"] = {ID = 1259048717, PriceInRobux = 299, PriceInGems = 225};
	["Legendary"] = {ID = 1259048739, PriceInRobux = 599, PriceInGems = 450};
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
	["Hazmat Suit"] = {Rarity = "Free", IsForSale = false};
	["Royale Robe"] = {Rarity = "Free", IsForSale = false};
	["Lobster"] = {Rarity = "Free", IsForSale = false};
	["Wilco Shirt"] = {Rarity = "Free", IsForSale = false};
	["Unicorn"] = {Rarity = "Free", IsForSale = false};
	--- Purchaseable Hats ---
	-- Rares
	--["Green Shirt"] = {Rarity = "Rare", IsForSale = true};
	["Gardener"] = {Rarity = "Rare", IsForSale = true};
	["Fisherman"] = {Rarity = "Rare", IsForSale = true};
	["Scientist"] = {Rarity = "Rare", IsForSale = true};
	["Farmer"] = {Rarity = "Rare", IsForSale = true};
	["Nurse"] = {Rarity = "Rare", IsForSale = true};
	["Paramedic"] = {Rarity = "Rare", IsForSale = true};
	["Alien"] = {Rarity = "Rare", IsForSale = false};
	["Dog Suit"] = {Rarity = "Rare", IsForSale = false};
	["Cat Suit"] = {Rarity = "Rare", IsForSale = false};
	-- Epics
	["Steampunk"] = {Rarity = "Epic", IsForSale = true};
	["Engineer"] = {Rarity = "Epic", IsForSale = true};
	["Adventurer"] = {Rarity = "Epic", IsForSale = true};
	["Caveman"] = {Rarity = "Epic", IsForSale = true};
	["Sailor"] = {Rarity = "Epic", IsForSale = true};
	["Lumberjack"] = {Rarity = "Epic", IsForSale = true};
	["Tuxedo"] = {Rarity = "Epic",IsForSale = true};
	["Frog"] = {Rarity = "Epic",IsForSale = true};
	["Turtle Suit"] = {Rarity = "Epic", IsForSale = false};
	-- Legendaries
	--["Red Coat"] = {Rarity = "Legendary", IsForSale = true};
	["Firefighter"] = {Rarity = "Legendary", IsForSale = true};
	["Chef"] = {Rarity = "Legendary", IsForSale = true};
	["Astronaut"] = {Rarity = "Legendary", IsForSale = true};
	["Police Officer"] = {Rarity = "Legendary", IsForSale = true};
	["Bunny Suit"] = {Rarity = "Legendary", IsForSale = true};
	["Bee"] = {Rarity = "Legendary", IsForSale = true};
	["Parrot Suit"] = {Rarity = "Legendary", IsForSale = false};
	--- Code Outfits ---
	
	--- Event Outfits ---
	["Red Jersey"] = {Rarity = "Event", IsForSale = false};
	["Blue Jersey"] = {Rarity = "Event", IsForSale = false};

	-- Mining Outfits
	["Miner"] = {Rarity = "Free", IsForSale = false};

	-- Achievement
	["Banana"] = {Rarity = "Free", IsForSale = false};
	["Disco"] = {Rarity = "Free", IsForSale = false};
	["Ghost"] = {Rarity = "Free", IsForSale = false};
	["Mummy"] = {Rarity = "Free", IsForSale = false};
	["Ninja"] = {Rarity = "Free", IsForSale = false};

}

return Outfits