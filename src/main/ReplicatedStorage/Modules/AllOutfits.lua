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
	["Hazmat Suit"] = {Rarity = "Free", IsForSale = false, Icon = "rbxassetid://10534831732"};
	["Royale Robe"] = {Rarity = "Free", IsForSale = false, Icon = "rbxassetid://10534828174"};
	["Lobster"] = {Rarity = "Free", IsForSale = false, Icon = "rbxassetid://10534831405"};
	["Wilco Shirt"] = {Rarity = "Free", IsForSale = false, Icon = "rbxassetid://10534826550"};
	["Unicorn"] = {Rarity = "Free", IsForSale = false, Icon = "rbxassetid://10534826814"};
	--- Purchaseable Hats ---
	-- Rares
	--["Green Shirt"] = {Rarity = "Rare", IsForSale = true};
	["Gardener"] = {Rarity = "Rare", IsForSale = true, Icon = "rbxassetid://10534832457"};
	["Fisherman"] = {Rarity = "Rare", IsForSale = true, Icon = "rbxassetid://10534836913"};
	["Farmer"] = {Rarity = "Rare", IsForSale = true, Icon = "rbxassetid://10534837275"};
	["Nurse"] = {Rarity = "Rare", IsForSale = true, Icon = "rbxassetid://10534829830"};
	["Paramedic"] = {Rarity = "Rare", IsForSale = true, Icon = "rbxassetid://10534829591"};
	["Alien"] = {Rarity = "Rare", IsForSale = false, Icon = "rbxassetid://10534841504"};
	["Dog Suit"] = {Rarity = "Rare", IsForSale = false, Icon = "rbxassetid://10534838019"};
	["Cat Suit"] = {Rarity = "Rare", IsForSale = false, Icon = "rbxassetid://10534839811"};
	-- Epics
	["Steampunk"] = {Rarity = "Epic", IsForSale = true, Icon = "rbxassetid://10534827723"};
	["Engineer"] = {Rarity = "Epic", IsForSale = true, Icon = "rbxassetid://10534837561"};
	["Adventurer"] = {Rarity = "Epic", IsForSale = true, Icon = "rbxassetid://10534841727"};
	["Caveman"] = {Rarity = "Epic", IsForSale = true, Icon = "rbxassetid://10534839475"};
	["Sailor"] = {Rarity = "Epic", IsForSale = true, Icon = "rbxassetid://10534839214"};
	["Lumberjack"] = {Rarity = "Epic", IsForSale = true, Icon = "rbxassetid://10534831188"};
	["Tuxedo"] = {Rarity = "Epic",IsForSale = true, Icon = "rbxassetid://10534827038"};
	["Frog"] = {Rarity = "Epic",IsForSale = true, Icon = "rbxassetid://10534832799"};
	["Scientist"] = {Rarity = "Free", IsForSale = true, Icon = "rbxassetid://10534827957"};
	["Turtle Suit"] = {Rarity = "Epic", IsForSale = false, Icon = "rbxassetid://10534827310"};
	-- Legendaries
	--["Red Coat"] = {Rarity = "Legendary", IsForSale = true};
	["Firefighter"] = {Rarity = "Legendary", IsForSale = true, Icon = "rbxassetid://10534837114"};
	["Chef"] = {Rarity = "Legendary", IsForSale = true, Icon = "rbxassetid://10534838821"};
	["Astronaut"] = {Rarity = "Legendary", IsForSale = true, Icon = "rbxassetid://10534840813"};
	["Police Officer"] = {Rarity = "Legendary", IsForSale = true, Icon = "rbxassetid://10534829209"};
	["Bunny Suit"] = {Rarity = "Legendary", IsForSale = true, Icon = "rbxassetid://10534840169"};
	["Bee"] = {Rarity = "Legendary", IsForSale = true, Icon = "rbxassetid://10534841982"};
	["Parrot Suit"] = {Rarity = "Legendary", IsForSale = false, Icon = "rbxassetid://10534829414"};
	--- Code Outfits ---
	
	--- Event Outfits ---
	["Red Jersey"] = {Rarity = "Event", IsForSale = false, Icon = "rbxassetid://10534828482"};
	["Blue Jersey"] = {Rarity = "Event", IsForSale = false, Icon = "rbxassetid://10534840317"};

	-- Mining Outfits
	["Miner"] = {Rarity = "Free", IsForSale = false, Icon = "rbxassetid://10534830789"};

	-- Achievement
	["Banana"] = {Rarity = "Free", IsForSale = false, Icon = "rbxassetid://10534840571"};
	["Disco"] = {Rarity = "Free", IsForSale = false, Icon = "rbxassetid://10534838292"};
	["Ghost"] = {Rarity = "Free", IsForSale = false, Icon = "rbxassetid://10534832120"};
	["Mummy"] = {Rarity = "Free", IsForSale = false, Icon = "rbxassetid://10534830386"};
	["Ninja"] = {Rarity = "Free", IsForSale = false, Icon = "rbxassetid://10534830099"};
	["Mad Scientist"] = {Rarity = "Free", IsForSale = false, Icon = "rbxassetid://10534830962"};

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