local PetDetails = {}

PetDetails.Rarities = {
    [.35] = "Common",
    [.61] = "Common",
    [.85] = "Rare",
    [.94] = "Rare",
    [.99] = "Epic",
    [1] = "Legendary",
}

PetDetails.RarityColors = {
    ["Common"] = Color3.fromRGB(94, 255, 0),
    ["Rare"] = Color3.fromRGB(0, 174, 255),
    ["Epic"] = Color3.fromRGB(247, 0, 255),
    ["Legendary"] = Color3.fromRGB(255, 217, 0),
    ["Mythic"] = Color3.fromRGB(224, 0, 0),
    ["LEGACY"] = Color3.fromRGB(0, 60, 255),
}

PetDetails.Pets = {
    [1] = {"Leafy","Default",1.05,"Fishing","Income"},
    [2] = {"Cakku","Default",1.07,"Fishing","Income"},
    [3] = {"Leafy","Purple",1.07,"Fishing","Income"},
    [4] = {"Cakku","Flower",1.1,"Fishing","Income"},
    [5] = {"Garr","Metallic",1.25,"Fishing","Income"},
    [6] = {"Drake","Default",1.5,"Fishing","Income"},

    [7] = {"Garr","Default",1.05,"Woodcutting","Income"},
    [8] = {"Waphy","Default",1.07,"Woodcutting","Income"},
    [9] = {"Garr","Purple",1.07,"Woodcutting","Income"},
    [10] = {"Waphy","Genie",1.1,"Woodcutting","Income"},
    [11] = {"Elebuddy","Black",1.25,"Woodcutting","Income"},
    [12] = {"Starlight","Default",1.5,"Woodcutting","Income"},

    [13] = {"Elebuddy","Default",1.05,"Walk","Speed"},
    [14] = {"Unicorn","Default",1.07,"Walk","Speed"},
    [15] = {"Elebuddy","Pink",1.07,"Walk","Speed"},
    [16] = {"Unicorn","Pinky",1.1,"Walk","Speed"},
    [17] = {"Leafy","Lime",1.25,"Walk","Speed"},
    [18] = {"Prismus","Default",1.5,"Walk","Speed"},

    [19] = {"Prismus","Sapphire",1.05,"Mining","Income"},
    [20] = {"Elebuddy","Blue",1.07,"Mining","Income"},
    [21] = {"Unicorn","Stellar",1.07,"Mining","Income"},
    [22] = {"Leafy","Orange",1.1,"Mining","Income"},
    [23] = {"Cakku","Magician",1.25,"Mining","Income"},
    [24] = {"Glacyx","Violet",1.5,"Mining","Income"},

    [25] = {"Glacyx","Default",1.05,"Paycheck","Income"},
    [26] = {"Unicorn","Alachi",1.07,"Paycheck","Income"},
    [27] = {"Prismus","Emerald",1.07,"Paycheck","Income"},
    [28] = {"Cakku","Cowboy",1.1,"Paycheck","Income"},
    [29] = {"Garr","Aquamarine",1.25,"Paycheck","Income"},
    [30] = {"Phantoon","Pirate",1.5,"Paycheck","Income"},

    [31] = {"Hountron","Default",1.025,"Fishing","Speed"},
    [32] = {"Prismus","Ruby",1.035,"Fishing","Speed"},
    [33] = {"Glacyx","Nocturne",1.035,"Fishing","Speed"},
    [34] = {"Waphy","Country",1.05,"Fishing","Speed"},
    [35] = {"Waphy","Pirate",1.125,"Fishing","Speed"},
    [36] = {"Hountron","Spectral",1.25,"Fishing","Speed"},

    [37] = {"Phantoon","Default",1.025,"Woodcutting","Speed"},
    [38] = {"Glacyx","Fairy",1.035,"Woodcutting","Speed"},
    [39] = {"Phantoon","Wizard",1.035,"Woodcutting","Speed"},
    [40] = {"Prismus","Purple",1.05,"Woodcutting","Speed"},
    [41] = {"Elebuddy","Green",1.125,"Woodcutting","Speed"},
    [42] = {"Terrasaur","Metallic",1.25,"Woodcutting","Speed"},

    [43] = {"Terrasaur","Default",1.025,"Mining","Speed"},
    [44] = {"Hountron","Lumina",1.035,"Mining","Speed"},
    [45] = {"Glacyx","Black",1.035,"Mining","Speed"},
    [46] = {"Phantoon","Vampire",1.05,"Mining","Speed"},
    [47] = {"Unicorn","Blaze",1.125,"Mining","Speed"},
    [48] = {"Celebliss","Default",1.25,"Mining","Speed"},
}

PetDetails.EggNameToId = {
    ["Island 1"] = 1,
    ["Island 3"] = 2,
    ["Island 5"] = 3,
    ["Island 6"] = 4,
    ["Island 8"] = 5,
    ["Island 9"] = 6,
    ["Island 11"] = 7,
    ["Island 12"] = 8,
}

PetDetails.ChanceTables = {
    [1] = {
        Name = "Island 1",
        PriceGems = 49,
        PriceRobux = 39,
        ProductId = 1276705832,
        Pets = {
           {Id = 1,Percentage = .35}, --Common
           {Id = 2,Percentage = .61}, --Common
           {Id = 3,Percentage = .85}, --Rare
           {Id = 4,Percentage =.94}, --Rare
           {Id = 5,Percentage =.99}, --Epic
           {Id = 6,Percentage = 1}, --Legendary
        }
    },
    [2] = {
        Name = "Island 3",
        PriceGems = 79,
        PriceRobux = 64,
        ProductId = 1276705868,
        Pets = {
           {Id = 7,Percentage = .35}, --Common
           {Id = 8,Percentage = .61}, --Common
           {Id = 9,Percentage = .85}, --Rare
           {Id = 10,Percentage =.94}, --Rare
           {Id = 11,Percentage =.99}, --Epic
           {Id = 12,Percentage = 1}, --Legendary
        }
    },
    [3] = {
        Name = "Island 5",
        PriceGems = 139,
        PriceRobux = 119,
        ProductId = 1276720361,
        Pets = {
           {Id = 13,Percentage = .35}, --Common
           {Id = 14,Percentage = .61}, --Common
           {Id = 15,Percentage = .85}, --Rare
           {Id = 16,Percentage =.94}, --Rare
           {Id = 17,Percentage =.99}, --Epic
           {Id = 18,Percentage = 1}, --Legendary
        }
    },
    [4] = {
        Name = "Island 6",
        PriceGems = 179,
        PriceRobux = 159,
        ProductId = 1276721630,
        Pets = {
           {Id = 19,Percentage = .35}, --Common
           {Id = 20,Percentage = .61}, --Common
           {Id = 21,Percentage = .85}, --Rare
           {Id = 22,Percentage = .94}, --Rare
           {Id = 23,Percentage = .99}, --Epic
           {Id = 24,Percentage = 1}, --Legendary
        }
    },
    [5] = {
        Name = "Island 8",
        PriceGems = 239,
        PriceRobux = 199,
        ProductId = 1276753445,
        Pets = {
           {Id = 25,Percentage = .35}, --Common
           {Id = 26,Percentage = .61}, --Common
           {Id = 27,Percentage = .85}, --Rare
           {Id = 28,Percentage = .94}, --Rare
           {Id = 29,Percentage = .99}, --Epic
           {Id = 30,Percentage = 1}, --Legendary
        }
    },
    [6] = {
        Name = "Island 9",
        PriceGems = 279,
        PriceRobux = 259,
        ProductId = 1276753534,
        Pets = {
           {Id = 31,Percentage = .35}, --Common
           {Id = 32,Percentage = .61}, --Common
           {Id = 33,Percentage = .85}, --Rare
           {Id = 34,Percentage = .94}, --Rare
           {Id = 35,Percentage = .99}, --Epic
           {Id = 36,Percentage = 1}, --Legendary
        }
    },
    [7] = {
        Name = "Island 11",
        PriceGems = 349,
        PriceRobux = 299,
        ProductId = 1276753571,
        Pets = {
           {Id = 37,Percentage = .35}, --Common
           {Id = 38,Percentage = .61}, --Common
           {Id = 39,Percentage = .85}, --Rare
           {Id = 40,Percentage = .94}, --Rare
           {Id = 41,Percentage = .99}, --Epic
           {Id = 42,Percentage = 1}, --Legendary
        }
    },
    [8] = {
        Name = "Island 12",
        PriceGems = 389,
        PriceRobux = 339,
        ProductId = 1276753612,
        Pets = {
           {Id = 43,Percentage = .35}, --Common
           {Id = 44,Percentage = .61}, --Common
           {Id = 45,Percentage = .85}, --Rare
           {Id = 46,Percentage = .94}, --Rare
           {Id = 47,Percentage = .99}, --Epic
           {Id = 48,Percentage = 1}, --Legendary
        }
    },
}

PetDetails.PetsOffset = {
	[1] = {
		[1] = CFrame.new(0,-2,5)
	},
	[2] = {
		[1] = CFrame.new(2.5,-2,5),
		[2] = CFrame.new(-2.5,-2,5),
	},
	[3] = {
		[1] = CFrame.new(3.5,-2,5),
		[2] = CFrame.new(0,-2,5),
		[3] = CFrame.new(-3.5,-2,5),
	},
	[4] = {
		[1] = CFrame.new(2.5,-2,5),
		[2] = CFrame.new(-2.5,-2,5),
		[3] = CFrame.new(2.5,-2,9.5),
		[4] = CFrame.new(-2.5,-2,9.5),
	},
	[5] = {
		[1] = CFrame.new(3.5,-2,5),
		[2] = CFrame.new(0,-2,5),
		[3] = CFrame.new(-3.5,-2,5),
		[4] = CFrame.new(-2.5,-2,9.5),
		[5] = CFrame.new(2.5,-2,9.5),
	},
	[6] = {
		[1] = CFrame.new(3.5,-2,5),
		[2] = CFrame.new(0,-2,5),
		[3] = CFrame.new(-3.5,-2,5),
		[4] = CFrame.new(3.5,-2,9.5),
		[5] = CFrame.new(0,-2,9.5),
		[6] = CFrame.new(-3.5,-2,9.5),
	},
}

return PetDetails