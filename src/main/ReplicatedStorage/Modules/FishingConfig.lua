local Config = {}


Config.Constants = {
	MAX_THROW_DISTANCE = 5000,
	PLAYER_ISLAND_RADIUS = 600,
	FISH_TIME = 3
}

Config.ItemType = {
	Junk = "Junk",
	Gem = "Gem",
	Hat = "Hat",
	Fish = "Fish"
}

Config.Rarity = {
	Common = "Common",
	Rare = "Rare",
	Epic = "Epic",
	Legendary = "Legendary",
	Mythic = "Mythic"
}

Config.ItemList = {
	[1] = {
		Name = "Azmus",
		IncomeMultiplier = 9.5,
		Rarity = Config.Rarity.Epic,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486711698"
	},
	[2] = {
		Name = "Belcher",
		IncomeMultiplier = 1.5,
		Rarity = Config.Rarity.Common,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486711385"
	},
	[3] = {
		Name = "Blu",
		IncomeMultiplier = 1,
		Rarity = Config.Rarity.Common,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486709644"
	},
	[4] = {
		Name = "Blueback",
		IncomeMultiplier = 38,
		Rarity = Config.Rarity.Mythic,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486709405"
	},
	[5] = {
		Name = "Bozzo",
		IncomeMultiplier = 19,
		Rarity = Config.Rarity.Legendary,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486709230"
	},
	[6] = {
		Name = "Bub",
		IncomeMultiplier = 5,
		Rarity = Config.Rarity.Rare,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486709038"
	},
	[7] = {
		Name = "Bubbles",
		IncomeMultiplier = 25,
		Rarity = Config.Rarity.Legendary,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486708836"
	},
	[8] = {
		Name = "Cherry",
		IncomeMultiplier = 1,
		Rarity = Config.Rarity.Common,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486708355"
	},
	[9] = {
		Name = "Daphne",
		IncomeMultiplier = 25,
		Rarity = Config.Rarity.Legendary,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486760547"
	},
	[10] = {
		Name = "Fiddel",
		IncomeMultiplier = 4.5,
		Rarity = Config.Rarity.Rare,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486759591"
	},
	[11] = {
		Name = "Fin",
		IncomeMultiplier = 1.5,
		Rarity = Config.Rarity.Common,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486759356"
	},
	[12] = {
		Name = "Flicker",
		IncomeMultiplier = 5,
		Rarity = Config.Rarity.Rare,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486759158"
	},
	[13] = {
		Name = "Flips",
		IncomeMultiplier = 0.8,
		Rarity = Config.Rarity.Common,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486758957"
	},
	[14] = {
		Name = "Fury",
		IncomeMultiplier = 50,
		Rarity = Config.Rarity.Mythic,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486758481"
	},
	[15] = {
		Name = "Gazella",
		IncomeMultiplier = 1,
		Rarity = Config.Rarity.Common,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486758316"
	},
	[16] = {
		Name = "Gobbles",
		IncomeMultiplier = 3.8,
		Rarity = Config.Rarity.Rare,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486758174"
	},
	[17] = {
		Name = "Gulby",
		IncomeMultiplier = 1.2,
		Rarity = Config.Rarity.Common,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486757886"
	},
	[18] = {
		Name = "Harpo",
		IncomeMultiplier = 9.8,
		Rarity = Config.Rarity.Epic,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486757536"
	},
	[19] = {
		Name = "Iris",
		IncomeMultiplier = 5,
		Rarity = Config.Rarity.Rare,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486757309"
	},
	[20] = {
		Name = "JarJar",
		IncomeMultiplier = 3.8,
		Rarity = Config.Rarity.Rare,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486756833"
	},
	[21] = {
		Name = "Jelly",
		IncomeMultiplier = 21,
		Rarity = Config.Rarity.Legendary,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486756641"
	},
	[22] = {
		Name = "Jimbo",
		IncomeMultiplier = 3.8,
		Rarity = Config.Rarity.Rare,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486756422"
	},
	[23] = {
		Name = "Jughead",
		IncomeMultiplier = 3,
		Rarity = Config.Rarity.Rare,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486756134"
	},
	[24] = {
		Name = "Lilo",
		IncomeMultiplier = 1,
		Rarity = Config.Rarity.Common,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486793558"
	},
	[25] = {
		Name = "Maurice",
		IncomeMultiplier = 5,
		Rarity = Config.Rarity.Rare,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486793364"
	},
	[26] = {
		Name = "Mello",
		IncomeMultiplier = 1.5,
		Rarity = Config.Rarity.Common,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486796568"
	},
	[27] = {
		Name = "Nero",
		IncomeMultiplier = 1.5,
		Rarity = Config.Rarity.Common,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486792948"
	},
	[28] = {
		Name = "Omega",
		IncomeMultiplier = 35,
		Rarity = Config.Rarity.Mythic,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486792667"
	},
	[29] = {
		Name = "Opal",
		IncomeMultiplier = 3,
		Rarity = Config.Rarity.Rare,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486792447"
	},
	[30] = {
		Name = "Phantom",
		IncomeMultiplier = 25,
		Rarity = Config.Rarity.Legendary,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486792031"
	},
	[31] = {
		Name = "Pickle",
		IncomeMultiplier = 1.5,
		Rarity = Config.Rarity.Common,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486791700"
	},
	[32] = {
		Name = "Queenie",
		IncomeMultiplier = 11,
		Rarity = Config.Rarity.Epic,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486791210"
	},
	[33] = {
		Name = "Reya",
		IncomeMultiplier = 50,
		Rarity = Config.Rarity.Mythic,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486790647"
	},
	[34] = {
		Name = "Rippy",
		IncomeMultiplier = 45,
		Rarity = Config.Rarity.Mythic,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486790371"
	},
	[35] = {
		Name = "Shamoo",
		IncomeMultiplier = 18,
		Rarity = Config.Rarity.Legendary,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486789441"
	},
	[36] = {
		Name = "Shelly",
		IncomeMultiplier = 22,
		Rarity = Config.Rarity.Legendary,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486789193"
	},
	[37] = {
		Name = "Slippy",
		IncomeMultiplier = 3,
		Rarity = Config.Rarity.Rare,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486788929"
	},
	[38] = {
		Name = "Smilo",
		IncomeMultiplier = 1,
		Rarity = Config.Rarity.Common,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486788263"
	},
	[39] = {
		Name = "Speckles",
		IncomeMultiplier = 9,
		Rarity = Config.Rarity.Epic,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486788063"
	},
	[40] = {
		Name = "Spotty",
		IncomeMultiplier = 11,
		Rarity = Config.Rarity.Epic,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486787487"
	},
	[41] = {
		Name = "Starso",
		IncomeMultiplier = 25,
		Rarity = Config.Rarity.Legendary,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486787038"
	},
	[42] = {
		Name = "Stitches",
		IncomeMultiplier = 11,
		Rarity = Config.Rarity.Epic,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486786849"
	},
	[43] = {
		Name = "Tackle",
		IncomeMultiplier = 50,
		Rarity = Config.Rarity.Mythic,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486819338"
	},
	[44] = {
		Name = "Tiggles",
		IncomeMultiplier = 10,
		Rarity = Config.Rarity.Epic,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486819042"
	},
	[45] = {
		Name = "Toffee",
		IncomeMultiplier = 11,
		Rarity = Config.Rarity.Epic,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486818822"
	},
	[46] = {
		Name = "Ungo",
		IncomeMultiplier = 1.2,
		Rarity = Config.Rarity.Common,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486818232"
	},
	[47] = {
		Name = "Venus",
		IncomeMultiplier = 50,
		Rarity = Config.Rarity.Mythic,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486818009"
	},
	[48] = {
		Name = "Whopper",
		IncomeMultiplier = 1.5,
		Rarity = Config.Rarity.Common,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486817624"
	},
	[49] = {
		Name = "Wiggle",
		IncomeMultiplier = 4.5,
		Rarity = Config.Rarity.Rare,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486817421"
	},
	[50] = {
		Name = "Zeus",
		IncomeMultiplier = 10.5,
		Rarity = Config.Rarity.Epic,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486817004"
	},

	-- junk
	[51] = {
		Name = "Old Boots",
		IncomeMultiplier = 0.2,
		Type = Config.ItemType.Junk
	},

	[52] = {
		Name = "Bottle",
		IncomeMultiplier = 0.2,
		Type = Config.ItemType.Junk
	},

	[53] = {
		Name = "Sea Weed",
		IncomeMultiplier = 0.2,
		Type = Config.ItemType.Junk
	},

	-- gems
	[54] = {
		Name = "Gem",
		Gems = 1,
		Type = Config.ItemType.Gem
	},
	[55] = {
		Name = "Treasure Chest",
		Gems = 10,
		Type = Config.ItemType.Gem
	},

	-- hat
	[56] = {
		Name = "Any Hat",
		Type = Config.ItemType.Hat
	},

	[57] = {
		Name = "Slowfie",
		IncomeMultiplier = 1,
		Rarity = Config.Rarity.Common,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486788606"
	},
	[58] = {
		Name = "Tommy",
		IncomeMultiplier = 1,
		Rarity = Config.Rarity.Common,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486818687"
	},
	[59] = {
		Name = "Troy",
		IncomeMultiplier = 1,
		Rarity = Config.Rarity.Common,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486818420"
	},
	[60] = {
		Name = "Sally",
		IncomeMultiplier = 1,
		Rarity = Config.Rarity.Common,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486789808"
	},
	[61] = {
		Name = "Diana",
		IncomeMultiplier = 1,
		Rarity = Config.Rarity.Common,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486760120
	},

	[62] = {
		Name = "Empress",
		IncomeMultiplier = 3,
		Rarity = Config.Rarity.Rare,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486759874"
	},
	[63] = {
		Name = "Cara",
		IncomeMultiplier = 3,
		Rarity = Config.Rarity.Rare,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486708602"
	},
	[64] = {
		Name = "Benedict",
		IncomeMultiplier = 3,
		Rarity = Config.Rarity.Rare,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486709914"
	},
	[65] = {
		Name = "Zee",
		IncomeMultiplier = 3,
		Rarity = Config.Rarity.Rare,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486817216"
	},
	[66] = {
		Name = "Flower",
		IncomeMultiplier = 3,
		Rarity = Config.Rarity.Rare,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486758736"
	},

	[67] = {
		Name = "Rainbow",
		IncomeMultiplier = 10,
		Rarity = Config.Rarity.Epic,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486790984"
	},
	[68] = {
		Name = "Kai",
		IncomeMultiplier = 10,
		Rarity = Config.Rarity.Epic,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486850920"
	},
	[69] = {
		Name = "Scarlett",
		IncomeMultiplier = 10,
		Rarity = Config.Rarity.Epic,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486789634"
	},
	[70] = {
		Name = "Cory",
		IncomeMultiplier = 10,
		Rarity = Config.Rarity.Epic,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486708118"
	},
	[71] = {
		Name = "Pinocchio",
		IncomeMultiplier = 10,
		Rarity = Config.Rarity.Epic,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486791423"
	},
	---
	[72] = {
		Name = "Snippers",
		IncomeMultiplier = 25,
		Rarity = Config.Rarity.Legendary,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486856251"
	},
	[73] = {
		Name = "Wally",
		IncomeMultiplier = 25,
		Rarity = Config.Rarity.Legendary,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486882532"
	},
	[74] = {
		Name = "Blade",
		IncomeMultiplier = 25,
		Rarity = Config.Rarity.Legendary,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486872791"
	},
	[75] = {
		Name = "King",
		IncomeMultiplier = 25,
		Rarity = Config.Rarity.Legendary,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486886269"
	},
	[76] = {
		Name = "Cutie",
		IncomeMultiplier = 25,
		Rarity = Config.Rarity.Legendary,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486760951"
	},
	---
	[77] = {
		Name = "Danger",
		IncomeMultiplier = 50,
		Rarity = Config.Rarity.Mythic,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486760773"
	},
	[78] = {
		Name = "Diago",
		IncomeMultiplier = 50,
		Rarity = Config.Rarity.Mythic,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486760373"
	},
	[79] = {
		Name = "Jacques",
		IncomeMultiplier = 50,
		Rarity = Config.Rarity.Mythic,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486757062"
	},
	[80] = {
		Name = "Squidney",
		IncomeMultiplier = 50,
		Rarity = Config.Rarity.Mythic,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486787279"
	},
	[81] = {
		Name = "Spike",
		IncomeMultiplier = 50,
		Rarity = Config.Rarity.Mythic,
		Type = Config.ItemType.Fish,
		Icon = "rbxassetid://10486787869"
	},
	---
}

Config.ChanceTable = {
	OpenSea = {
		
		-- Common (50%)
		{ Id = 13, Percentage = 0.045454545454545456 },
		{ Id = 15, Percentage = 0.09090909090909091 },
		{ Id = 8, Percentage = 0.13636363636363635 },
		{ Id = 3, Percentage = 0.18181818181818182 },
		{ Id = 38, Percentage = 0.2272727272727273 },
		{ Id = 24, Percentage =  0.27272727272727276 },
		{ Id = 46, Percentage = 0.31818181818181823 },
		{ Id = 17, Percentage = 0.3636363636363637 },
		{ Id = 27, Percentage = 0.40909090909090917 },
		{ Id = 11, Percentage = 0.45454545454545464 },
		{ Id = 61, Percentage = 0.50 },
		
		-- Rare (25%)
		{ Id = 23, Percentage = 0.5278 },
		{ Id = 37, Percentage = 0.5556000000000001 },
		{ Id = 29, Percentage = 0.5834000000000001 },
		{ Id = 16, Percentage = 0.6112000000000002 },
		{ Id = 22, Percentage = 0.6390000000000002 },
		{ Id = 20, Percentage = 0.6668000000000003 },
		{ Id = 10, Percentage = 0.6946000000000003 },
		{ Id = 49, Percentage = 0.7224000000000004 },
		{ Id = 66, Percentage = 0.75 },
		
		-- Junk (10%)
		{ Id = 51, Percentage = 0.78333333 },
		{ Id = 52, Percentage = 0.81666666 },
		{ Id = 53, Percentage = 0.85 },
		
		-- Epic (9.789%)
		{ Id = 39, Percentage = 0.866 },
		{ Id = 1, Percentage = 0.882 },
		{ Id = 18, Percentage = 0.898 },
		{ Id = 44, Percentage = 0.914 },
		{ Id = 50, Percentage = 0.93 },
		{ Id = 71, Percentage = 0.94789 },

		-- Regular Gem (5%)
		{ Id = 54, Percentage = 0.99789 },
		
		-- Treasure Chest (0.1%)
		{ Id = 55, Percentage = 0.99889 },
		
		-- legendary (0.1%)
		{ Id = 35, Percentage = 0.99908 },
		{ Id = 5, Percentage = 0.99927 },
		{ Id = 21, Percentage = 0.99946 },
		{ Id = 36, Percentage = 0.99965 },
		{ Id = 76, Percentage = 0.99989 },
		
		-- mythic (0.01%)
		{ Id = 28, Percentage = 0.9999418333333334 },
		{ Id = 4, Percentage = 0.9999603333333335 },
		{ Id = 34, Percentage = 0.9999788333333335 },
		{ Id = 81, Percentage = 0.99999 },

		-- random hat (0.001%)
		{ Id = 56, Percentage = 1.000 }
	},
	GrassyLand = {
		-- common (50%)
		{ Id = 57, Percentage = 0.25 },
		{ Id = 31, Percentage = 0.5 },
		
		-- rare (25%)
		{ Id = 62, Percentage = 0.625 },
		{ Id = 6, Percentage = 0.75 },
		
		-- Junk (10%)
		{ Id = 51, Percentage = 0.78333333 },
		{ Id = 52, Percentage = 0.81666666 },
		{ Id = 53, Percentage = 0.85 },
		
		-- Epic (9.789%)
		{ Id = 67, Percentage = 0.898945 },
		{ Id = 32, Percentage = 0.94789 },
		
		-- Regular Gem (5%)
		{ Id = 54, Percentage = 0.99789 },

		-- Treasure Chest (0.1%)
		{ Id = 55, Percentage = 0.99889 },
		
		-- Legendary (0.1%)
		{ Id = 72, Percentage = 0.99939 },
		{ Id = 41, Percentage = 0.99989 },
		
		-- Mythic (0.01%)
		{ Id = 77, Percentage = 0.99994 },
		{ Id = 47, Percentage = 0.99999 },
		
		-- random hat (0.001%)
		{ Id = 56, Percentage = 1.000 }
	},
	Swamp = {
		-- common (50%)
		{ Id = 59, Percentage = 0.25 },
		{ Id = 2, Percentage = 0.5 },

		-- rare (25%)
		{ Id = 64, Percentage = 0.625 },
		{ Id = 25, Percentage = 0.75 },

		-- Junk (10%)
		{ Id = 51, Percentage = 0.78333333 },
		{ Id = 52, Percentage = 0.81666666 },
		{ Id = 53, Percentage = 0.85 },

		-- Epic (9.789%)
		{ Id = 69, Percentage = 0.898945 },
		{ Id = 40, Percentage = 0.94789 },

		-- Regular Gem (5%)
		{ Id = 54, Percentage = 0.99789 },

		-- Treasure Chest (0.1%)
		{ Id = 55, Percentage = 0.99889 },

		-- Legendary (0.1%)
		{ Id = 74, Percentage = 0.99939 },
		{ Id = 30, Percentage = 0.99989 },

		-- Mythic (0.01%)
		{ Id = 79, Percentage = 0.99994 },
		{ Id = 14, Percentage = 0.99999 },

		-- random hat (0.001%)
		{ Id = 56, Percentage = 1.000 }
	},
	SandIsland = {
		-- common (50%)
		{ Id = 60, Percentage = 0.25 },
		{ Id = 26, Percentage = 0.5 },

		-- rare (25%)
		{ Id = 65, Percentage = 0.625 },
		{ Id = 12, Percentage = 0.75 },

		-- Junk (10%)
		{ Id = 51, Percentage = 0.78333333 },
		{ Id = 52, Percentage = 0.81666666 },
		{ Id = 53, Percentage = 0.85 },

		-- Epic (9.789%)
		{ Id = 70, Percentage = 0.898945 },
		{ Id = 45, Percentage = 0.94789 },

		-- Regular Gem (5%)
		{ Id = 54, Percentage = 0.99789 },

		-- Treasure Chest (0.1%)
		{ Id = 55, Percentage = 0.99889 },

		-- Legendary (0.1%)
		{ Id = 75, Percentage = 0.99939 },
		{ Id = 7, Percentage = 0.99989 },

		-- Mythic (0.01%)
		{ Id = 80, Percentage = 0.99994 },
		{ Id = 33, Percentage = 0.99999 },

		-- random hat (0.001%)
		{ Id = 56, Percentage = 1.000 }
	},
	TreasureBeach = {
		-- common (50%)
		{ Id = 58, Percentage = 0.25 },
		{ Id = 48, Percentage = 0.5 },

		-- rare (25%)
		{ Id = 63, Percentage = 0.625 },
		{ Id = 19, Percentage = 0.75 },

		-- Junk (10%)
		{ Id = 51, Percentage = 0.78333333 },
		{ Id = 52, Percentage = 0.81666666 },
		{ Id = 53, Percentage = 0.85 },

		-- Epic (9.789%)
		{ Id = 68, Percentage = 0.898945 },
		{ Id = 42, Percentage = 0.94789 },

		-- Regular Gem (5%)
		{ Id = 54, Percentage = 0.99789 },

		-- Treasure Chest (0.1%)
		{ Id = 55, Percentage = 0.99889 },

		-- Legendary (0.1%)
		{ Id = 73, Percentage = 0.99939 },
		{ Id = 9, Percentage = 0.99989 },

		-- Mythic (0.01%)
		{ Id = 78, Percentage = 0.99994 },
		{ Id = 43, Percentage = 0.99999 },

		--Random hat
		{ Id = 56, Percentage = 1.000 }
	}
}


Config.IslandsData = {
	GrassyLand = {
		CenterPosition = Vector3.new(22.2, 22.06, -3341.3)
	},
	Swamp = {
		CenterPosition = Vector3.new(1691.982, 7.72, -1102.589)
	},
	SandIsland = {
		CenterPosition = Vector3.new(112.5, 6.5, 1038.3)
	},
	TreasureBeach = {
		CenterPosition = Vector3.new(-1540.914, 9.402, -1160.668)
	}
}


return Config
