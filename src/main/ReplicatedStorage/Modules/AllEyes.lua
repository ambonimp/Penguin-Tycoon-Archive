local Eyes = {}

--- Other Variables ---
local MPService = game:GetService("MarketplaceService")


--- Accessory Variables ---

Eyes.RarityInfo = {
	["Free"] = {ID = 0000000000, PriceInRobux = 1, PriceInGems = 1};
	["Event"] = {ID = 0000000000, PriceInRobux = 1000, PriceInGems = 100000};
	["Regular"] = {ID = 1232615468, PriceInRobux = 49, PriceInGems = 60};
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
	["Default"] = {Rarity = "Free", IsForSale = false, Icon = "rbxassetid://10534765352"};
	["Angry"] = {Rarity = "Free", IsForSale = false, Icon = "rbxassetid://10534766583"};
	["Surprised"] = {Rarity = "Free", IsForSale = false, Icon = "rbxassetid://10534763447"};
	["Scared"] = {Rarity = "Free", IsForSale = false, Icon = "rbxassetid://10534764006"};
	["Unamused"] = {Rarity = "Free", IsForSale = false, Icon = "rbxassetid://10534762227"};
	
	--- Purchaseable Eyes ---
	["Excited"] = {Rarity = "Regular", IsForSale = true, Icon = "rbxassetid://10534764969"};
	["Cheeky"] = {Rarity = "Regular", IsForSale = true, Icon = "rbxassetid://10534766303"};
	["Crying"] = {Rarity = "Regular", IsForSale = true, Icon = "rbxassetid://10534765819"};
	["Shook"] = {Rarity = "Regular", IsForSale = true, Icon = "rbxassetid://10534763733"};
	["Tearing Up"] = {Rarity = "Regular", IsForSale = true, Icon = "rbxassetid://10534763047"};
	
	["Unbothered"] = {Rarity = "Regular", IsForSale = true, Icon = "rbxassetid://10534762011"};
	["Raised Eyebrow"] = {Rarity = "Regular", IsForSale = true, Icon = "rbxassetid://10534764187"};
	["Worried"] = {Rarity = "Regular", IsForSale = true, Icon = "rbxassetid://10534761795"};
	["Furious"] = {Rarity = "Regular", IsForSale = true, Icon = "rbxassetid://10534764692"};
	["Thick Eyebrows"] = {Rarity = "Regular", IsForSale = true, Icon = "rbxassetid://10534762705"};
	
	["Dizzy"] = {Rarity = "Regular", IsForSale = true, Icon = "rbxassetid://10534765180"};
	["Cute"] = {Rarity = "Regular", IsForSale = true, Icon = "rbxassetid://10534765568"};
	["Confused"] = {Rarity = "Regular", IsForSale = true, Icon = "rbxassetid://10534766069"};
	["Huh"] = {Rarity = "Regular", IsForSale = true, Icon = "rbxassetid://10534764339"};
	["Tired"] = {Rarity = "Regular", IsForSale = true, Icon = "rbxassetid://10534762464"};
	
	--- Event Eyes ---
	
	--- Code Eyes ---
	["Heart Eyes"] = {Rarity = "Regular", IsForSale = false, Icon = "rbxassetid://10535189923"};
	["100k Eyes"] = {Rarity = "Regular", IsForSale = false, Icon = "rbxassetid://10534768113"};
	--["200k Eyes"] = {Rarity = "Regular", IsForSale = false, Icon = "rbxassetid://10534767926"};
	--["300k Eyes"] = {Rarity = "Regular", IsForSale = false, Icon = "rbxassetid://10534767694"};
}

return Eyes