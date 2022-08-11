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
	["Rare"] = {ID = 1231222253, PriceInRobux = 49, PriceInGems = 60};
	["Epic"] = {ID = 1231222252, PriceInRobux = 99, PriceInGems = 125};
	["Legendary"] = {ID = 1231222251, PriceInRobux = 299, PriceInGems = 380};
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
	["Clown#1"] = "Clown Hair";
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
	["Jellyfish Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = "rbxassetid://10534501013"};
	["Traffic Cone"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = "rbxassetid://10534490062"};
	["Shark Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = "rbxassetid://10534492432"};
	["Goal 150k"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = "rbxassetid://10534520202"};
	--["Goal 175k"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = "rbxassetid://10535584361"};
	--["Goal 225k"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = "rbxassetid://10535585356"};
	--["Goal 250k"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = "rbxassetid://10535585157"};
	--["Goal 275k"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = "rbxassetid://10535583901"};

	--- Unlockable Hats ---
	-- Collectable
	["Pirate Captain Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = "rbxassetid://10534510515"};
	["Bunny Ears"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = "rbxassetid://10534509967"};
	["Straw Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = "rbxassetid://10534490703"};
	["Feather Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = "rbxassetid://10534507347"};

	-- Penguin Hats
	["Steampunk Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = "rbxassetid://10534490994"};
	["Fisher Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = "rbxassetid://10534503597"};
	["Ninja Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = "rbxassetid://10534498965"};
	["Pirate Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = "rbxassetid://10534494750"};
	["Backwards Cap"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = "rbxassetid://10534516561"};
	["Gardening Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = "rbxassetid://10534502607"};
	["Adventurer Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = "rbxassetid://10534209654"};
	["Witch Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = "rbxassetid://10534488506"};
	["Mushroom Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = "rbxassetid://10534491690"};
	["Bowl Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = "rbxassetid://10534510845"};
	["Cap"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = "rbxassetid://10534488785"};
	["Beret"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = "rbxassetid://10534511919"};
	["Bee Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = "rbxassetid://10534512170"};
	["Hockey Helmet"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = "rbxassetid://10534501266"};
	["Clown Hair"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = "rbxassetid://10534493306"};

	--Fish Rewards
	["Boot Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = "rbxassetid://10534511175"};
	["Bottle Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = "rbxassetid://10534491878"};
	["Seaweed Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = "rbxassetid://10534489160"};

	--- Purchaseable Hats ---
	-- Rares
	["Conical Straw Hat"] = {Rarity = "Rare", IsForSale = true, Achievement = true, Icon = "rbxassetid://10534509117"};
	["Soldier Helmet"] = {Rarity = "Rare", IsForSale = true, Achievement = true, Icon = "rbxassetid://10534491522"};
	["Party Hat"] = {Rarity = "Rare", IsForSale = true, Achievement = true, Icon = "rbxassetid://10534498578"};
	["Pink Sunhat"] = {Rarity = "Rare", IsForSale = true, Achievement = true, Icon = "rbxassetid://10534511338"};
	["Robin Hood"] = {Rarity = "Rare", IsForSale = true, Achievement = true, Icon = "rbxassetid://10534500265"};
	["Cat Ears"] = {Rarity = "Rare", IsForSale = true, Achievement = true, Icon = "rbxassetid://10534510312"};
	["Cowboy"] = {Rarity = "Rare", IsForSale = true, Achievement = true, Icon = "rbxassetid://10534508871"};
	["Spiky Top Hat"] = {Rarity = "Rare", IsForSale = true, Achievement = true, Icon = "rbxassetid://10534491327"};
	["Hair Headband"] = {Rarity = "Rare", IsForSale = true, Achievement = true, Icon = "rbxassetid://10534501849"};
	["Bucket Hat"] = {Rarity = "Rare", IsForSale = true, Achievement = true, Icon = "rbxassetid://10534518992"};
	["Umbrella"] = {Rarity = "Rare", IsForSale = true, Achievement = true, Icon = "rbxassetid://10534489856"};
	["Detective's Hat"] = {Rarity = "Rare", IsForSale = true, Achievement = true, Icon = "rbxassetid://10534508114"};

	-- Epics
	["Pot"] = {Rarity = "Epic", IsForSale = true, Achievement = true, Icon = "rbxassetid://10534493794"};
	["Wizard Hat"] = {Rarity = "Epic", IsForSale = true, Achievement = true, Icon = "rbxassetid://10534488235"};
	["Gentleman's Hat"] = {Rarity = "Epic", IsForSale = true, Achievement = true, Icon = "rbxassetid://10534502306"};
	["Bear Hat"] = {Rarity = "Epic", IsForSale = true, Achievement = true, Icon = "rbxassetid://10534512368"};
	["Drinking Hat"] = {Rarity = "Epic", IsForSale = true, Achievement = true, Icon = "rbxassetid://10534507962"};
	["Chef's Hat"] = {Rarity = "Epic", IsForSale = true, Achievement = true, Icon = "rbxassetid://10534509697"};
	["Sombrero"] = {Rarity = "Epic", IsForSale = true,  Achievement = true, Icon = "rbxassetid://10534499813"};
	["Viking Helmet"] = {Rarity = "Epic", IsForSale = true, Achievement = true, Icon = "rbxassetid://10534489433"};
	["Graduation Hat"] = {Rarity = "Epic", IsForSale = true, Achievement = true, Icon = "rbxassetid://10534502060"};
	["Santa's Hat"] = {Rarity = "Epic", IsForSale = true, Achievement = true, Icon = "rbxassetid://10534492600"};
	["Biker Helmet"] = {Rarity = "Epic", IsForSale = true, Achievement = true, Icon = "rbxassetid://10534511673"};
	["Flower Pot"] = {Rarity = "Epic", IsForSale = true, Achievement = true, Icon = "rbxassetid://10534503301"};
	["Nurse's Hat"] = {Rarity = "Epic", IsForSale = true, Achievement = true, Icon = "rbxassetid://10534498785"};


	-- Legendaries
	["Crown"] = {Rarity = "Legendary", IsForSale = true, Achievement = true, Icon = "rbxassetid://10534508670"};
	["Police Cap"] = {Rarity = "Legendary", IsForSale = true, Achievement = true, Icon = "rbxassetid://10534494292"};
	["Football Helmet"] = {Rarity = "Legendary", IsForSale = true, Achievement = true, Icon = "rbxassetid://10534503176"};
	["Balaclava"] = {Rarity = "Legendary", IsForSale = true, Achievement = true, Icon = "rbxassetid://10534516167"};
	["Joker's Hat"] = {Rarity = "Legendary", IsForSale = true, Achievement = true, Icon = "rbxassetid://10534500729"};
	["Firefighter Hat"] = {Rarity = "Legendary", IsForSale = true, Achievement = true, Icon = "rbxassetid://10534507041"};
	["Knight's Helmet"] = {Rarity = "Legendary", IsForSale = true, Achievement = true, Icon = "rbxassetid://10534500466"};


	--- Code Hats ---
	["Lucky Hat"] = {Rarity = "Epic", IsForSale = false, Icon = "rbxassetid://10534500096"};
	["Miner Hat"] = {Rarity = "Epic", IsForSale = false, Icon = "rbxassetid://10534499308"};
	["Cow Bucket Hat"] = {Rarity = "Free", IsForSale = false, Icon = "rbxassetid://10534518757"};
	["Rainbow Deely Bopper"] = {Rarity = "Free", IsForSale = false, Icon = "rbxassetid://10534493129"};

	--- Event Hats ---
	["Valentine's Day"] = {Rarity = "Event", IsForSale = false, Icon = "rbxassetid://10534489677"};
	["Easter Basket"] = {Rarity = "Event", IsForSale = false, Icon = "rbxassetid://10534507813"};
	["Pink Bunny Ears"] = {Rarity = "Event", IsForSale = false, Icon = "rbxassetid://10534498240"};

	-- Mining Hats ===

	["Hard Hat"] = {Rarity = "Free", IsForSale = false, Icon = "rbxassetid://10534499529"};
	["Chicken Hat"] = {Rarity = "Free", IsForSale = false, Icon = "rbxassetid://10534509511"};
	["Popcorn Hat"] = {Rarity = "Free", IsForSale = false, Icon = "rbxassetid://10534494025"};

	-- Achievements
	["Bath Hat"] = {Rarity = "Free", IsForSale = false, Icon = "rbxassetid://10534515949"};
	["Bird Hat"] = {Rarity = "Free", IsForSale = false, Icon = "rbxassetid://10534511478"};
	["Giant Bow"] = {Rarity = "Free", IsForSale = false, Icon = "rbxassetid://10534510992"};
	["Deely Bopper"] = {Rarity = "Free", IsForSale = false, Icon = "rbxassetid://10534508299"};
	["Flower Crown"] = {Rarity = "Free", IsForSale = false, Icon = "rbxassetid://10534503473"};
	["Frog Bucket Hat"] = {Rarity = "Free", IsForSale = false, Icon = "rbxassetid://10534518521"};
	["Head Lamp"] = {Rarity = "Free", IsForSale = false, Icon = "rbxassetid://10534501507"};
	["Headphones"] = {Rarity = "Free", IsForSale = false, Icon = "rbxassetid://10534501657"};
	["Mouse Ears"] = {Rarity = "Free", IsForSale = false, Icon = "rbxassetid://10534499154"};
	["Pirate Bandana"] = {Rarity = "Free", IsForSale = false, Icon = "rbxassetid://10534498049"};
	["Sweatband"] = {Rarity = "Free", IsForSale = false, Icon = "rbxassetid://10534490415"};
	["Thug Life Glasses"] = {Rarity = "Free", IsForSale = false, Icon = "rbxassetid://10534758204"};
	["Propeller Hat"] = {Rarity = "Free", IsForSale = false, Icon = "rbxassetid://10534493556"};

}

if game:GetService("RunService"):IsServer() then
	task.spawn(function()
		for Accessory in pairs(Accessories.All) do
			if Accessory ~= "None" then
				if not game:GetService("ServerStorage").Accessories:FindFirstChild(Accessory) then
					warn(Accessory .. " accessory model doesn't exist")
				end
			end
		end
	end)
end


return Accessories