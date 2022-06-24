local Accessories = {}

--- Other Variables ---
local MPService = game:GetService("MarketplaceService")


--- Accessory Variables ---
Accessories.StoreAmounts = {
	["Rare"] = 3;
	["Epic"] = 2;
	["Legendary"] = 1;
}

Accessories.RarityInfo = {
	["Free"] = {ID = 0000000000, PriceInRobux = 1, PriceInGems = 1};
	["Event"] = {ID = 0000000000, PriceInRobux = 1000, PriceInGems = 100000};
	["Rare"] = {ID = 1231222253, PriceInRobux = 99, PriceInGems = 75};
	["Epic"] = {ID = 1231222252, PriceInRobux = 199, PriceInGems = 150};
	["Legendary"] = {ID = 1231222251, PriceInRobux = 499, PriceInGems = 400};
}

local Time_24Hours = 86400
Accessories.RotationInterval = Time_24Hours


--- Accessory Functions ---
function Accessories:ChooseStoreAccessories()
	local ChosenAccessories = {}

	for Rarity, Amount in pairs(Accessories.StoreAmounts) do
		local AccessoryList = {}

		for Accessory, Info in pairs(Accessories.All) do
			if Info.IsForSale and Info.Rarity == Rarity then
				table.insert(AccessoryList, Accessory)
			end
		end

		if #AccessoryList > Amount then
			for i = 1, Accessories.StoreAmounts[Rarity], 1 do
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


--- Accessory Lists ---
Accessories.Unlockables = {
	-- Penguin Unlockables
	["Fisherman#1"] = "Fisher Hat";
	["Ninja Penguin#1"] = "Ninja Hat";
	["Pirate Penguin#1"] = "Pirate Hat";
	["Painter#1"] = "Backwards Cap";
	["Gardener#1"] = "Gardening Hat";
	["Farmer#1"] = "Straw Hat";
	["Farmer#2"] = "Gardening Hat";
	["Adventurer#1"] = "Adventurer Hat";
	["Witch#1"] = "Witch Hat";
	["Shroom#1"] = "Mushroom Hat";
	["Nurse#1"] = "Bowl Hat";
	["Soldier#1"] = "Beret";
	["Youtuber#1"] = "Cap";
	-- Pick-up Unlockables
	["Bunny Ears"] = true;
	["Feather Hat"] = true;
	["Pirate Captain Hat"] = true;
	["Straw Hat"] = true;

}


Accessories.All = {	
	--- Default Hat(s) ---
	["None"] = {Rarity = "Free", IsForSale = false};
	--Rewards
	["Jellyfish Hat"] = {Rarity = "Free", IsForSale = false};
	["Traffic Cone"] = {Rarity = "Free", IsForSale = false};
	["Shark Hat"] = {Rarity = "Free", IsForSale = false};
	--- Unlockable Hats ---
	-- Collectable
	["Pirate Captain Hat"] = {Rarity = "Free", IsForSale = false};
	["Bunny Ears"] = {Rarity = "Free", IsForSale = false};
	["Straw Hat"] = {Rarity = "Free", IsForSale = false};
	["Feather Hat"] = {Rarity = "Free", IsForSale = false};
	["Beret"] = {Rarity = "Free", IsForSale = false};

	-- Penguin Hats
	["Fisher Hat"] = {Rarity = "Free", IsForSale = false};
	["Ninja Hat"] = {Rarity = "Free", IsForSale = false};
	["Pirate Hat"] = {Rarity = "Free", IsForSale = false};
	["Backwards Cap"] = {Rarity = "Free", IsForSale = false};
	["Gardening Hat"] = {Rarity = "Free", IsForSale = false};
	["Adventurer Hat"] = {Rarity = "Free", IsForSale = false};
	["Witch Hat"] = {Rarity = "Free", IsForSale = false};
	["Mushroom Hat"] = {Rarity = "Free", IsForSale = false};
	["Bowl Hat"] = {Rarity = "Free", IsForSale = false};
	["Cap"] = {Rarity = "Free", IsForSale = false};

	--Fish Rewards
	["Boot Hat"] = {Rarity = "Free", IsForSale = false};
	["Bottle Hat"] = {Rarity = "Free", IsForSale = false};
	["Seaweed Hat"] = {Rarity = "Free", IsForSale = false};

	--- Purchaseable Hats ---
	-- Rares
	["Conical Straw Hat"] = {Rarity = "Rare", IsForSale = true};
	["Soldier Helmet"] = {Rarity = "Rare", IsForSale = true};
	["Party Hat"] = {Rarity = "Rare", IsForSale = true};
	["Pink Sunhat"] = {Rarity = "Rare", IsForSale = true};
	["Robin Hood"] = {Rarity = "Rare", IsForSale = true};
	["Cat Ears"] = {Rarity = "Rare", IsForSale = true};
	["Cowboy"] = {Rarity = "Rare", IsForSale = true};
	["Spiky Top Hat"] = {Rarity = "Rare", IsForSale = true};
	["Hair Headband"] = {Rarity = "Rare", IsForSale = true};
	["Bucket Hat"] = {Rarity = "Rare", IsForSale = true};
	["Umbrella"] = {Rarity = "Rare", IsForSale = true};
	["Detective's Hat"] = {Rarity = "Rare", IsForSale = true};

	-- Epics
	["Pot"] = {Rarity = "Epic", IsForSale = true};
	["Wizard Hat"] = {Rarity = "Epic", IsForSale = true};
	["Gentleman's Hat"] = {Rarity = "Epic", IsForSale = true};
	["Bear Hat"] = {Rarity = "Epic", IsForSale = true};
	["Drinking Hat"] = {Rarity = "Epic", IsForSale = true};
	
	["Chef's Hat"] = {Rarity = "Epic", IsForSale = true};
	["Sombrero"] = {Rarity = "Epic", IsForSale = true};
	["Viking Helmet"] = {Rarity = "Epic", IsForSale = true};
	["Graduation Hat"] = {Rarity = "Epic", IsForSale = true};
	["Santa's Hat"] = {Rarity = "Epic", IsForSale = true};
	
	["Biker Helmet"] = {Rarity = "Epic", IsForSale = true};
	["Flower Pot"] = {Rarity = "Epic", IsForSale = true};
	["Nurse's Hat"] = {Rarity = "Epic", IsForSale = true};


	-- Legendaries
	["Crown"] = {Rarity = "Legendary", IsForSale = true};
	["Police Cap"] = {Rarity = "Legendary", IsForSale = true};
	["Football Helmet"] = {Rarity = "Legendary", IsForSale = true};
	["Balaclava"] = {Rarity = "Legendary", IsForSale = true};
	["Joker's Hat"] = {Rarity = "Legendary", IsForSale = true};
	
	["Firefighter Hat"] = {Rarity = "Legendary", IsForSale = true};
	["Knight's Helmet"] = {Rarity = "Legendary", IsForSale = true};


	--- Code Hats ---
	["Lucky Hat"] = {Rarity = "Epic", IsForSale = false};
	["Miner Hat"] = {Rarity = "Epic", IsForSale = false};
	
	
	--- Event Hats ---
	["Valentine's Day"] = {Rarity = "Event", IsForSale = false};
	["Easter Basket"] = {Rarity = "Event", IsForSale = false};
	["Pink Bunny Ears"] = {Rarity = "Event", IsForSale = false};

	-- Mining Hats ===
	["Hard Hat"] = {Rarity = "Free", IsForSale = false};

}

return Accessories