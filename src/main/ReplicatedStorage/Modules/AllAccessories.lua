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
	["Ice Hockey Player#1"] = "Hockey Helmet";
	["Bumble Bee#1"] = "Bee Hat";
	["Factory Owner#1"] = "Steampunk Hat";
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
	["Jellyfish Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true};
	["Traffic Cone"] = {Rarity = "Free", IsForSale = false, Achievement = true};
	["Shark Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true};
	["Goal 150k"] = {Rarity = "Free", IsForSale = false, Achievement = true};

	--- Unlockable Hats ---
	-- Collectable
	["Pirate Captain Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true};
	["Bunny Ears"] = {Rarity = "Free", IsForSale = false, Achievement = true};
	["Straw Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true};
	["Feather Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true};
	["Beret"] = {Rarity = "Free", IsForSale = false, Achievement = true};
	["Bee Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true};
	["Hockey Helmet"] = {Rarity = "Free", IsForSale = false, Achievement = true};
	-- Penguin Hats
	["Steampunk Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true};
	["Fisher Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true};
	["Ninja Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true};
	["Pirate Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true};
	["Backwards Cap"] = {Rarity = "Free", IsForSale = false, Achievement = true};
	["Gardening Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true};
	["Adventurer Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true};
	["Witch Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true};
	["Mushroom Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true};
	["Bowl Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true};
	["Cap"] = {Rarity = "Free", IsForSale = false, Achievement = true};

	--Fish Rewards
	["Boot Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true};
	["Bottle Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true};
	["Seaweed Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true};

	--- Purchaseable Hats ---
	-- Rares
	["Conical Straw Hat"] = {Rarity = "Rare", IsForSale = true, Achievement = true};
	["Soldier Helmet"] = {Rarity = "Rare", IsForSale = true, Achievement = true};
	["Party Hat"] = {Rarity = "Rare", IsForSale = true, Achievement = true};
	["Pink Sunhat"] = {Rarity = "Rare", IsForSale = true, Achievement = true};
	["Robin Hood"] = {Rarity = "Rare", IsForSale = true, Achievement = true};
	["Cat Ears"] = {Rarity = "Rare", IsForSale = true, Achievement = true};
	["Cowboy"] = {Rarity = "Rare", IsForSale = true, Achievement = true};
	["Spiky Top Hat"] = {Rarity = "Rare", IsForSale = true, Achievement = true};
	["Hair Headband"] = {Rarity = "Rare", IsForSale = true, Achievement = true};
	["Bucket Hat"] = {Rarity = "Rare", IsForSale = true, Achievement = true};
	["Umbrella"] = {Rarity = "Rare", IsForSale = true, Achievement = true};
	["Detective's Hat"] = {Rarity = "Rare", IsForSale = true, Achievement = true};

	-- Epics
	["Pot"] = {Rarity = "Epic", IsForSale = true, Achievement = true};
	["Wizard Hat"] = {Rarity = "Epic", IsForSale = true, Achievement = true};
	["Gentleman's Hat"] = {Rarity = "Epic", IsForSale = true, Achievement = true};
	["Bear Hat"] = {Rarity = "Epic", IsForSale = true, Achievement = true};
	["Drinking Hat"] = {Rarity = "Epic", IsForSale = true, Achievement = true};
	
	["Chef's Hat"] = {Rarity = "Epic", IsForSale = true, Achievement = true};
	["Sombrero"] = {Rarity = "Epic", IsForSale = true,  Achievement = true};
	["Viking Helmet"] = {Rarity = "Epic", IsForSale = true, Achievement = true};
	["Graduation Hat"] = {Rarity = "Epic", IsForSale = true, Achievement = true};
	["Santa's Hat"] = {Rarity = "Epic", IsForSale = true, Achievement = true};
	
	["Biker Helmet"] = {Rarity = "Epic", IsForSale = true, Achievement = true};
	["Flower Pot"] = {Rarity = "Epic", IsForSale = true, Achievement = true};
	["Nurse's Hat"] = {Rarity = "Epic", IsForSale = true, Achievement = true};


	-- Legendaries
	["Crown"] = {Rarity = "Legendary", IsForSale = true, Achievement = true};
	["Police Cap"] = {Rarity = "Legendary", IsForSale = true, Achievement = true};
	["Football Helmet"] = {Rarity = "Legendary", IsForSale = true, Achievement = true};
	["Balaclava"] = {Rarity = "Legendary", IsForSale = true, Achievement = true};
	["Joker's Hat"] = {Rarity = "Legendary", IsForSale = true, Achievement = true};
	
	["Firefighter Hat"] = {Rarity = "Legendary", IsForSale = true, Achievement = true};
	["Knight's Helmet"] = {Rarity = "Legendary", IsForSale = true, Achievement = true};


	--- Code Hats ---
	["Lucky Hat"] = {Rarity = "Epic", IsForSale = false};
	["Miner Hat"] = {Rarity = "Epic", IsForSale = false};
	
	
	--- Event Hats ---
	["Valentine's Day"] = {Rarity = "Event", IsForSale = false};
	["Easter Basket"] = {Rarity = "Event", IsForSale = false};
	["Pink Bunny Ears"] = {Rarity = "Event", IsForSale = false};

	-- Mining Hats ===
	["Hard Hat"] = {Rarity = "Free", IsForSale = false};

	-- Achievements
	["Bath Hat"] = {Rarity = "Free", IsForSale = false};
	["Bird Hat"] = {Rarity = "Free", IsForSale = false};
	["Giant Bow"] = {Rarity = "Free", IsForSale = false};
	["Deely Bobber"] = {Rarity = "Free", IsForSale = false};
	["Flower Crown"] = {Rarity = "Free", IsForSale = false};
	["Frog Bucket Hat"] = {Rarity = "Free", IsForSale = false};
	["Head Lamp"] = {Rarity = "Free", IsForSale = false};
	["Headphones"] = {Rarity = "Free", IsForSale = false};
	["Mouse Ears"] = {Rarity = "Free", IsForSale = false};
	["Pirate Bandana"] = {Rarity = "Free", IsForSale = false};
	["Sweatband"] = {Rarity = "Free", IsForSale = false};
	["Thug Life Glasses"] = {Rarity = "Free", IsForSale = false};
	["Propeller Hat"] = {Rarity = "Free", IsForSale = false};

}

return Accessories