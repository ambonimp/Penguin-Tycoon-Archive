local Eggs = {
	Eggs = {
		Egg1 = {
			PriceGems = 150,
			PriceRobux = 149,
			DevId = 1251433285,
			Name = "Egg1",
			Pets = {
				["Panda"] = 1, --panda ultra
				["Unicorn"] = 5, --unicorn rare
				["Dinosaur"] = 9, --dinosaur uncommon
				["Rabbit"] = 24, --rabbit uncommon
				["Dog"] = 26, --dog common
				["Cat"] = 35, --cat common
			}
		}
	}
}

Eggs.Pets = {
	["Cat"] = {
		["Blue Cat"] = 2,
		["Gray Cat"] = 23,
		["Black Cat"] = 75,
	},
	["Dog"] = {
		["Gray Dog"] = 20,
		["Brown Dog"] = 30,
		["Black Dog"] = 50,
	},
	["Panda"] = {
		["Purple Panda"] = 10,
		["Blue Panda"] = 30,
		["Black Panda"] = 60,
	},
	["Rabbit"] = {
		["Blue Rabbit"] = 20,
		["Yellow Rabbit"] = 30,
		["White Rabbit"] = 50,
	},
	["Unicorn"] = {
		["Yellow Unicorn"] = 10,
		["Blue Unicorn"] = 30,
		["White Unicorn"] = 60,
	},
	["Dinosaur"] = {
		["Pink Dinosaur"] = 10,
		["Green Dinosaur"] = 30,
		["Brown Dinosaur"] = 60,
	},
}

return Eggs
