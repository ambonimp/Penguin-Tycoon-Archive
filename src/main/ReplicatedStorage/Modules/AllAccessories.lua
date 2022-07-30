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
	["Jellyfish Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = "rbxassetid://10420216206"};
	["Traffic Cone"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = "rbxassetid://10420208512"};
	["Shark Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = "rbxassetid://10420209525"};
	["Goal 150k"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = "rbxassetid://10420392867"};

	--- Unlockable Hats ---
	-- Collectable
	["Pirate Captain Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = "rbxassetid://10420222353"};
	["Bunny Ears"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = "rbxassetid://10420221896"};
	["Straw Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = "rbxassetid://10420208842"};
	["Feather Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = "rbxassetid://10420219510"};
	["Beret"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = "rbxassetid://10420227689"};
	["Bee Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = "rbxassetid://10420227969"};
	["Hockey Helmet"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = "rbxassetid://10420216657"};
	-- Penguin Hats
	["Steampunk Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true};
	["Fisher Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = "rbxassetid://10420219139"};
	["Ninja Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = "rbxassetid://10420211577"};
	["Pirate Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = "rbxassetid://10420210970"};
	["Backwards Cap"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = "rbxassetid://10420229114"};
	["Gardening Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = "rbxassetid://10420218153"};
	["Adventurer Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true};
	["Witch Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = "rbxassetid://10420207826"};
	["Mushroom Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = "rbxassetid://10420230747"};
	["Bowl Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true};
	["Cap"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = "rbxassetid://10420207982"};

	--Fish Rewards
	["Boot Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = "rbxassetid://10420226858"};
	["Bottle Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = "rbxassetid://10420209369"};
	["Seaweed Hat"] = {Rarity = "Free", IsForSale = false, Achievement = true, Icon = "rbxassetid://10420208171"};

	--- Purchaseable Hats ---
	-- Rares
	["Conical Straw Hat"] = {Rarity = "Rare", IsForSale = true, Achievement = true, Icon = "rbxassetid://10420220905"};
	["Soldier Helmet"] = {Rarity = "Rare", IsForSale = true, Achievement = true, Icon = "rbxassetid://10420209156"};
	["Party Hat"] = {Rarity = "Rare", IsForSale = true, Achievement = true, Icon = "rbxassetid://10420211318"};
	["Pink Sunhat"] = {Rarity = "Rare", IsForSale = true, Achievement = true, Icon = "rbxassetid://10420226977"};
	["Robin Hood"] = {Rarity = "Rare", IsForSale = true, Achievement = true, Icon = "rbxassetid://10420212116"};
	["Cat Ears"] = {Rarity = "Rare", IsForSale = true, Achievement = true, Icon = "rbxassetid://10420222144"};
	["Cowboy"] = {Rarity = "Rare", IsForSale = true, Achievement = true, Icon = "rbxassetid://10420220714"};
	["Spiky Top Hat"] = {Rarity = "Rare", IsForSale = true, Achievement = true, Icon = "rbxassetid://10420209017"};
	["Hair Headband"] = {Rarity = "Rare", IsForSale = true, Achievement = true, Icon = "rbxassetid://10420217294"};
	["Bucket Hat"] = {Rarity = "Rare", IsForSale = true, Achievement = true};
	["Umbrella"] = {Rarity = "Rare", IsForSale = true, Achievement = true};
	["Detective's Hat"] = {Rarity = "Rare", IsForSale = true, Achievement = true};

	-- Epics
	["Pot"] = {Rarity = "Epic", IsForSale = true, Achievement = true, Icon = "rbxassetid://10420210048"};
	["Wizard Hat"] = {Rarity = "Epic", IsForSale = true, Achievement = true, Icon = "rbxassetid://10420207585"};
	["Gentleman's Hat"] = {Rarity = "Epic", IsForSale = true, Achievement = true, Icon = "rbxassetid://10420217900"};
	["Bear Hat"] = {Rarity = "Epic", IsForSale = true, Achievement = true, Icon = "rbxassetid://10420228240"};
	["Drinking Hat"] = {Rarity = "Epic", IsForSale = true, Achievement = true, Icon = "rbxassetid://10420220155"};

	["Chef's Hat"] = {Rarity = "Epic", IsForSale = true, Achievement = true, Icon = "rbxassetid://10420221683"};
	["Sombrero"] = {Rarity = "Epic", IsForSale = true,  Achievement = true, Icon = "rbxassetid://10420211883"};
	["Viking Helmet"] = {Rarity = "Epic", IsForSale = true, Achievement = true, Icon = "rbxassetid://10420208338"};
	["Graduation Hat"] = {Rarity = "Epic", IsForSale = true, Achievement = true, Icon = "rbxassetid://10420217657"};
	["Santa's Hat"] = {Rarity = "Epic", IsForSale = true, Achievement = true, Icon = "rbxassetid://10420209684"};

	["Biker Helmet"] = {Rarity = "Epic", IsForSale = true, Achievement = true, Icon = "rbxassetid://10420227461"};
	["Flower Pot"] = {Rarity = "Epic", IsForSale = true, Achievement = true};
	["Nurse's Hat"] = {Rarity = "Epic", IsForSale = true, Achievement = true};


	-- Legendaries
	["Crown"] = {Rarity = "Legendary", IsForSale = true, Achievement = true, Icon = "rbxassetid://10420220533"};
	["Police Cap"] = {Rarity = "Legendary", IsForSale = true, Achievement = true, Icon = "rbxassetid://10420210459"};
	["Football Helmet"] = {Rarity = "Legendary", IsForSale = true, Achievement = true, Icon = "rbxassetid://10420218668"};
	["Balaclava"] = {Rarity = "Legendary", IsForSale = true, Achievement = true, Icon = "rbxassetid://10420228585"};
	["Joker's Hat"] = {Rarity = "Legendary", IsForSale = true, Achievement = true, Icon = "rbxassetid://10420212348"};

	["Firefighter Hat"] = {Rarity = "Legendary", IsForSale = true, Achievement = true, Icon = "rbxassetid://10420219307"};
	["Knight's Helmet"] = {Rarity = "Legendary", IsForSale = true, Achievement = true};


	--- Code Hats ---
	["Lucky Hat"] = {Rarity = "Epic", IsForSale = false, Icon = ""};
	["Miner Hat"] = {Rarity = "Epic", IsForSale = false, Icon = ""};


	--- Event Hats ---
	["Valentine's Day"] = {Rarity = "Event", IsForSale = false, Icon = ""};
	["Easter Basket"] = {Rarity = "Event", IsForSale = false, Icon = ""};
	["Pink Bunny Ears"] = {Rarity = "Event", IsForSale = false, Icon = ""};

	-- Mining Hats ===
	["Hard Hat"] = {Rarity = "Free", IsForSale = false, Icon = "rbxassetid://10420226495"};

	-- Achievements
	["Bath Hat"] = {Rarity = "Free", IsForSale = false, Icon = "rbxassetid://10420228425"};
	["Bird Hat"] = {Rarity = "Free", IsForSale = false, Icon = "rbxassetid://10420227205"};
	["Giant Bow"] = {Rarity = "Free", IsForSale = false, Icon = "rbxassetid://10420226684"};
	["Deely Bopper"] = {Rarity = "Free", IsForSale = false, Icon = "rbxassetid://10420220348"};
	["Flower Crown"] = {Rarity = "Free", IsForSale = false, Icon = "rbxassetid://10420218909"};
	["Frog Bucket Hat"] = {Rarity = "Free", IsForSale = false, Icon = "rbxassetid://10420231003"};
	["Head Lamp"] = {Rarity = "Free", IsForSale = false, Icon = "rbxassetid://10420216832"};
	["Headphones"] = {Rarity = "Free", IsForSale = false, Icon = "rbxassetid://10420217019"};
	["Mouse Ears"] = {Rarity = "Free", IsForSale = false, Icon = "rbxassetid://10420211743"};
	["Pirate Bandana"] = {Rarity = "Free", IsForSale = false, Icon = "rbxassetid://10420211164"};
	["Sweatband"] = {Rarity = "Free", IsForSale = false, Icon = "rbxassetid://10420208670"};
	["Thug Life Glasses"] = {Rarity = "Free", IsForSale = false}, Icon = "rbxassetid://10420428291";
	["Propeller Hat"] = {Rarity = "Free", IsForSale = false, Icon = "rbxassetid://10420209874"};

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