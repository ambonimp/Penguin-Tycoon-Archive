local Eyes = {}

--- Other Variables ---
local MPService = game:GetService("MarketplaceService")


--- Accessory Variables ---

Eyes.RarityInfo = {
	["Free"] = {ID = 0000000000, PriceInRobux = 1, PriceInGems = 1};
	["Event"] = {ID = 0000000000, PriceInRobux = 1000, PriceInGems = 100000};
	["Regular"] = {ID = 1232615468, PriceInRobux = 199, PriceInGems = 150};
}

local Time_24Hours = 86400
Eyes.RotationInterval = Time_24Hours


--- Accessory Functions ---
function Eyes:ChooseStoreEyes()
	local ChosenEyes = {}
	
	local EyesList = {}

	for Eyes, Info in pairs(Eyes.All) do
		if Info.IsForSale and Info.Rarity ~= "Free" then
			table.insert(EyesList, Eyes)
		end
	end
	
	for i = 1, 6, 1 do
		local RandomNum = Random.new():NextInteger(1, #EyesList)
		local ChosenAccessory = EyesList[RandomNum]
		
		ChosenEyes[ChosenAccessory] = true
		table.remove(EyesList, RandomNum)
	end
	
	return ChosenEyes
end


--- Eyes Lists ---
Eyes.Unlockables = {
	
}


Eyes.All = {	
	--- Default Eye(s) ---
	["Default"] = {Rarity = "Free", IsForSale = false};
	["Angry"] = {Rarity = "Free", IsForSale = false};
	["Surprised"] = {Rarity = "Free", IsForSale = false};
	["Scared"] = {Rarity = "Free", IsForSale = false};
	["Unamused"] = {Rarity = "Free", IsForSale = false};
	
	--- Purchaseable Eyes ---
	["Excited"] = {Rarity = "Regular", IsForSale = true};
	["Cheeky"] = {Rarity = "Regular", IsForSale = true};
	["Crying"] = {Rarity = "Regular", IsForSale = true};
	["Shook"] = {Rarity = "Regular", IsForSale = true};
	["Tearing Up"] = {Rarity = "Regular", IsForSale = true};
	
	["Unbothered"] = {Rarity = "Regular", IsForSale = true};
	["Raised Eyebrow"] = {Rarity = "Regular", IsForSale = true};
	["Worried"] = {Rarity = "Regular", IsForSale = true};
	["Furious"] = {Rarity = "Regular", IsForSale = true};
	["Thick Eyebrows"] = {Rarity = "Regular", IsForSale = true};
	
	["Dizzy"] = {Rarity = "Regular", IsForSale = true};
	["Cute"] = {Rarity = "Regular", IsForSale = true};
	["Confused"] = {Rarity = "Regular", IsForSale = true};
	["Huh"] = {Rarity = "Regular", IsForSale = true};
	["Tired"] = {Rarity = "Regular", IsForSale = true};
	
	--- Event Eyes ---
	
	--- Code Eyes ---
	["Heart Eyes"] = {Rarity = "Regular", IsForSale = false};
	["100k Eyes"] = {Rarity = "Regular", IsForSale = false};
}

return Eyes