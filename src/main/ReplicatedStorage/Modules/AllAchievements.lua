local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage.Modules
local FishingConfig = require(Modules.FishingConfig)
local AllAccessories = require(Modules.AllAccessories)
local AllEyes = require(Modules.AllEyes)

local Achievements = {}


-- Counts how many membes have certain values
-- Used for achievement reward requirements
function Achievements.GetMembersWithAttributes(Table, Attributes)
	local Count = 0
	for k, Member in pairs(Table) do
		local HasAttributes = true
		for Attribute, Value in pairs(Attributes) do
			if Member[Attribute] ~= Value then
				HasAttributes = false
				break
			end
		end

		if HasAttributes then
			Count += 1
		end

	end

	return Count
end

local function Reward(type, value)
	return {Type = type or "", Value = value}
end


Achievements.All = {
	[1] = {
		Name = "Catch all common fish",
		Icon = "rbxassetid://10345555415",
		Rewards = {Reward("Gems", 5)},
		ToComplete = Achievements.GetMembersWithAttributes(FishingConfig.ItemList, {Rarity = FishingConfig.Rarity.Common, Type = FishingConfig.ItemType.Fish})
	},
	[2] = {
		Name = "Catch all rare fish",
		Icon = "rbxassetid://10345552847",
		Rewards = {Reward("Gems", 10)},
		ToComplete = Achievements.GetMembersWithAttributes(FishingConfig.ItemList, {Rarity = FishingConfig.Rarity.Rare, Type = FishingConfig.ItemType.Fish})
	},
	[3] = {
		Name = "Catch all epic fish",
		Icon = "rbxassetid://10345555182",
		Rewards = {Reward("Accessory", "Head Lamp")},
		ToComplete = Achievements.GetMembersWithAttributes(FishingConfig.ItemList, {Rarity = FishingConfig.Rarity.Epic, Type = FishingConfig.ItemType.Fish})
	},
	[4] = {
		Name = "Catch all legendary fish",
		Icon = "rbxassetid://10345553421",
		Rewards = {Reward("Accessory", "Mouse Ears")},
		ToComplete = Achievements.GetMembersWithAttributes(FishingConfig.ItemList, {Rarity = FishingConfig.Rarity.Legendary, Type = FishingConfig.ItemType.Fish})
	},
	[5] = {
		Name = "Catch all mythic fish",
		Icon = "rbxassetid://10345553068",
		Rewards = {Reward("Outfit", "Scientist")},
		ToComplete = Achievements.GetMembersWithAttributes(FishingConfig.ItemList, {Rarity = FishingConfig.Rarity.Mythic, Type = FishingConfig.ItemType.Fish})
	},
	[6] = {
		Name = "Catch all fish in the fish index",
		Icon = "rbxassetid://10375957835",
		Rewards = {Reward("Gems", "Ghost")},
		ToComplete = Achievements.GetMembersWithAttributes(FishingConfig.ItemList, {Type = FishingConfig.ItemType.Fish})
	},
	[7] = {
		Name = "Catch 15 seaweed",
		Icon = "rbxassetid://10345557201",
		Rewards = {Reward("Accessory", "Seaweed Hat")},
		ToComplete = 15,
	},
	[8] = {
		Name = "Catch 15 boots",
		Icon = "rbxassetid://10345557924",
		Rewards = {Reward("Accessory", "Boot Hat")},
		ToComplete = 15,
	},
	[9] = {
		Name = "Catch 15 bottles",
		Icon = "rbxassetid://10345557513",
		Rewards = {Reward("Accessory", "Bottle Hat")},
		ToComplete = 15,
	},
	[10] = {
		Name = "Catch a treasure chest",
		Icon = "rbxassetid://10345552361",
		Rewards = {Reward("Accessory", "Pirate Bandana")},
		ToComplete = 1,
	},
	[11] = {
		Name = "Find all of the Build-A-Boat pieces",
		Icon = "rbxassetid://10375957220",
		Rewards = {Reward("Vehicle", "Boat")},
		ToComplete = 10
	},
	[12] = {
		Name = "Find all of the Build-A-Plane pieces",
		Icon = "rbxassetid://9675890147",
		Rewards = {Reward("Vehicle", "Plane")},
		ToComplete = 10,
		AutoClaim = true,
	},
	[13] = {
		Name = "Find all of the hidden hats (Located on middle islands)",
		Icon = "rbxassetid://10345553663",
		Rewards = {Reward("Gems", 5)},
		ToComplete = 4,
		AutoClaim = true,
	},
	[14] = {
		Name = "Own a common pet",
		Icon = "rbxassetid://10345550921",
		Rewards = {Reward("Accessory", "Giant Bow")},
		ToComplete = 1,
	},
	[15] = {
		Name = "Own a rare pet",
		Icon = "rbxassetid://10345551550",
		Rewards = {Reward("Accessory", "Deely Bobber")},
		ToComplete = 1,
	},
	[16] = {
		Name = "Own a epic pet",
		Icon = "rbxassetid://10345551221",
		Rewards = {Reward("Accessory", "Frog Bucket Hat")},
		ToComplete = 1,
	},
	[17] = {
		Name = "Own a legendary pet",
		Icon = "rbxassetid://10345551805",
		Rewards = {Reward("Outfit", "Mummy")},
		ToComplete = 1,
	},
	[18] = {
		Name = "Verify all socials",
		Icon = "rbxassetid://10375957396",
		Rewards = {Reward("Income Multiplier", 10)},
		ToComplete = 2,
	},
	[19] = {
		Name = "Join our community server",
		Icon = "rbxassetid://10345551805",
		Rewards = {Reward("Gems", 100)},
		ToComplete = 1,
	},
	[20] = {
		Name = "Collect all of the rare hats",
		Icon = "rbxassetid://10345552611",
		Rewards = {Reward("Accessory", "Flower Crown")},
		ToComplete = Achievements.GetMembersWithAttributes(AllAccessories.All, {Rarity = "Rare", Achievement = true})
	},
	[21] = {
		Name = "Collect all of the epic hats",
		Icon = "rbxassetid://10375956917",
		Rewards = {Reward("Accessory", "Bath Hat")},
		ToComplete = Achievements.GetMembersWithAttributes(AllAccessories.All, {Rarity = "Epic", Achievement = true}),
	},
	[22] = {
		Name = "Collect all of the legendary hats",
		Icon = "rbxassetid://10345553223",
		Rewards = {Reward("Outfit", "Disco")},
		ToComplete = Achievements.GetMembersWithAttributes(AllAccessories.All, {Rarity = "Legendary", Achievement = true}),
	},
	[23] = {
		Name = "Collect all eyes",
		Icon = "rbxassetid://10345554577",
		Rewards = {Reward("Accessory", "Thug Life Glasses")},
		ToComplete = Achievements.GetMembersWithAttributes(AllEyes.All, {IsForSale = true})
	},
	[24] = {
		Name = "Win 3 skate race minigames",
		Icon = "rbxassetid://10375958054",
		Rewards = {Reward("Outfit", "Poncho")},
		ToComplete = 3,
	},
	[25] = {
		Name = "Win 3 falling tile minigames",
		Icon = "rbxassetid://10375956572",
		Rewards = {Reward("Outfit", "Ninja")},
		ToComplete = 3,
	},
	[26] = {
		Name = "Win 3 soccer minigames",
		Icon = "rbxassetid://10345556263",
		Rewards = {Reward("Accessory", "Sweatband")},
		ToComplete = 3,
	},
	[27] = {
		Name = "Win 3 candy rush minigames",
		Icon = "rbxassetid://10345556887",
		Rewards = {Reward("Accessory", "Headphones")},
		ToComplete = 3,
	},
	[28] = {
		Name = "Win 3 ice cream minigames",
		Icon = "rbxassetid://10375957605",
		Rewards = {Reward("Accessory", "Bird Hat")},
		ToComplete = 3,
	},
	[29] = {
		Name = "Win 3 sled race minigames",
		Icon = "rbxassetid://10375958287",
		Rewards = {Reward("Accessory", "Cat Ears")},
		ToComplete = 3,
	},
	[30] = {
		Name = "Score 5 goals in soccer",
		Icon = "rbxassetid://10345556017",
		Rewards = {Reward("Outfit", "Banana")},
		ToComplete = 5,
	},
	[31] = {
		Name = "Unlock mining zone 3",
		Icon = "",
		Rewards = {Reward("Accessory", "Hard Hat")},
		ToComplete = 3,
	},
	[32] = {
		Name = "Mine 100 diamonds",
		Icon = "",
		Rewards = {Reward("Outfit", "Miner")},
		ToComplete = 100,
	},
	[33] = {
		Name = "Complete all achievements",
		Icon = "rbxassetid://10377956825",
		Rewards = {
			Reward("Gems", 100),
			Reward("Accessory", "Propeller Hat"),
			Reward("Outfit", "Royal Robe Outfit"),
		},
		ToComplete = 32
	}
}

return Achievements