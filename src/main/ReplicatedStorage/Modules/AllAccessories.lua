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
	["Jellyfish Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = ""};
	["Traffic Cone"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = ""};
	["Shark Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = ""};
	["Goal 150k"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = ""};

	--- Unlockable Hats ---
	-- Collectable
	["Pirate Captain Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = ""};
	["Bunny Ears"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = ""};
	["Straw Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = ""};
	["Feather Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = ""};
	["Beret"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = ""};
	["Bee Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = ""};
	["Hockey Helmet"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = ""};
	-- Penguin Hats
	["Steampunk Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = ""};
	["Fisher Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = ""};
	["Ninja Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = ""};
	["Pirate Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = ""};
	["Backwards Cap"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = ""};
	["Gardening Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = ""};
	["Adventurer Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = ""};
	["Witch Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = ""};
	["Mushroom Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = ""};
	["Bowl Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = ""};
	["Cap"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = ""};

	--Fish Rewards
	["Boot Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = ""};
	["Bottle Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = ""};
	["Seaweed Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = ""};

	--- Purchaseable Hats ---
	-- Rares
	["Conical Straw Hat"] = {Rarity = "Rare", IsForSale = true, Achievement = true, Icon = ""};
	["Soldier Helmet"] = {Rarity = "Rare", IsForSale = true, Achievement = true, Icon = ""};
	["Party Hat"] = {Rarity = "Rare", IsForSale = true, Achievement = true, Icon = ""};
	["Pink Sunhat"] = {Rarity = "Rare", IsForSale = true, Achievement = true, Icon = ""};
	["Robin Hood"] = {Rarity = "Rare", IsForSale = true, Achievement = true, Icon = ""};
	["Cat Ears"] = {Rarity = "Rare", IsForSale = true, Achievement = true, Icon = ""};
	["Cowboy"] = {Rarity = "Rare", IsForSale = true, Achievement = true, Icon = ""};
	["Spiky Top Hat"] = {Rarity = "Rare", IsForSale = true, Achievement = true, Icon = ""};
	["Hair Headband"] = {Rarity = "Rare", IsForSale = true, Achievement = true, Icon = ""};
	["Bucket Hat"] = {Rarity = "Rare", IsForSale = true, Achievement = true, Icon = ""};
	["Umbrella"] = {Rarity = "Rare", IsForSale = true, Achievement = true, Icon = ""};
	["Detective's Hat"] = {Rarity = "Rare", IsForSale = true, Achievement = true, Icon = ""};

	-- Epics
	["Pot"] = {Rarity = "Epic", IsForSale = true, Achievement = true, Icon = ""};
	["Wizard Hat"] = {Rarity = "Epic", IsForSale = true, Achievement = true, Icon = ""};
	["Gentleman's Hat"] = {Rarity = "Epic", IsForSale = true, Achievement = true, Icon = ""};
	["Bear Hat"] = {Rarity = "Epic", IsForSale = true, Achievement = true, Icon = ""};
	["Drinking Hat"] = {Rarity = "Epic", IsForSale = true, Achievement = true, Icon = ""};

	["Chef's Hat"] = {Rarity = "Epic", IsForSale = true, Achievement = true, Icon = ""};
	["Sombrero"] = {Rarity = "Epic", IsForSale = true,  Achievement = true, Icon = ""};
	["Viking Helmet"] = {Rarity = "Epic", IsForSale = true, Achievement = true, Icon = ""};
	["Graduation Hat"] = {Rarity = "Epic", IsForSale = true, Achievement = true, Icon = ""};
	["Santa's Hat"] = {Rarity = "Epic", IsForSale = true, Achievement = true, Icon = ""};

	["Biker Helmet"] = {Rarity = "Epic", IsForSale = true, Achievement = true, Icon = ""};
	["Flower Pot"] = {Rarity = "Epic", IsForSale = true, Achievement = true, Icon = ""};
	["Nurse's Hat"] = {Rarity = "Epic", IsForSale = true, Achievement = true, Icon = ""};


	-- Legendaries
	["Crown"] = {Rarity = "Legendary", IsForSale = true, Achievement = true, Icon = ""};
	["Police Cap"] = {Rarity = "Legendary", IsForSale = true, Achievement = true, Icon = ""};
	["Football Helmet"] = {Rarity = "Legendary", IsForSale = true, Achievement = true, Icon = ""};
	["Balaclava"] = {Rarity = "Legendary", IsForSale = true, Achievement = true, Icon = ""};
	["Joker's Hat"] = {Rarity = "Legendary", IsForSale = true, Achievement = true, Icon = ""};

	["Firefighter Hat"] = {Rarity = "Legendary", IsForSale = true, Achievement = true, Icon = ""};
	["Knight's Helmet"] = {Rarity = "Legendary", IsForSale = true, Achievement = true, Icon = ""};


	--- Code Hats ---
	["Lucky Hat"] = {Rarity = "Epic", IsForSale = false, Icon = ""};
	["Miner Hat"] = {Rarity = "Epic", IsForSale = false, Icon = ""};


	--- Event Hats ---
	["Valentine's Day"] = {Rarity = "Event", IsForSale = false, Icon = ""};
	["Easter Basket"] = {Rarity = "Event", IsForSale = false, Icon = ""};
	["Pink Bunny Ears"] = {Rarity = "Event", IsForSale = false, Icon = ""};

	-- Mining Hats ===
	["Hard Hat"] = {Rarity = "Free", IsForSale = false, Icon = ""};

	-- Achievements
	["Bath Hat"] = {Rarity = "Free", IsForSale = false, Icon = ""};
	["Bird Hat"] = {Rarity = "Free", IsForSale = false, Icon = ""};
	["Giant Bow"] = {Rarity = "Free", IsForSale = false, Icon = ""};
	["Deely Bopper"] = {Rarity = "Free", IsForSale = false, Icon = ""};
	["Flower Crown"] = {Rarity = "Free", IsForSale = false, Icon = ""};
	["Frog Bucket Hat"] = {Rarity = "Free", IsForSale = false, Icon = ""};
	["Head Lamp"] = {Rarity = "Free", IsForSale = false, Icon = ""};
	["Headphones"] = {Rarity = "Free", IsForSale = false, Icon = ""};
	["Mouse Ears"] = {Rarity = "Free", IsForSale = false, Icon = ""};
	["Pirate Bandana"] = {Rarity = "Free", IsForSale = false, Icon = ""};
	["Sweatband"] = {Rarity = "Free", IsForSale = false, Icon = ""};
	["Thug Life Glasses"] = {Rarity = "Free", IsForSale = false}, Icon = "";
	["Propeller Hat"] = {Rarity = "Free", IsForSale = false, Icon = ""};

}

if game:GetService("RunService"):IsServer() then
	task.spawn(function()
		for Accessory in pairs(Accessories.All) do
			if Accessory ~= "None" then
				assert(game:GetService("ServerStorage").Accessories:FindFirstChild(Accessory), Accessory)
			end
		end
	end)
end


return Accessories