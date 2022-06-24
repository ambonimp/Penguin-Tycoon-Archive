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
}

PetDetails.EggNameToId = {
    ["Island 1"] = 1,
}

PetDetails.ChanceTables = {
    [1] = {
        Name = "Island 1",
        PriceGems = 50,
        PriceRobux = 45,
        ProductId = 1251433285,
        Pets = {
           {Id = 1,Percentage = .35}, --Common
           {Id = 2,Percentage = .61}, --Common
           {Id = 3,Percentage = .85}, --Rare
           {Id = 4,Percentage =.94}, --Rare
           {Id = 5,Percentage =.99}, --Epic
           {Id = 6,Percentage = 1}, --Legendary
        }
    }
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