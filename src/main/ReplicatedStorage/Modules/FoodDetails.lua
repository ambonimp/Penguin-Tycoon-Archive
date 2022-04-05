local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Assets = ReplicatedStorage:WaitForChild("Assets")
local foods = Assets:WaitForChild("Foods")
local FoodDetails = {
	["Carrot"] = {
		Hunger = 30,
		Price = 20,
	},
	["Berries"] = {
		Hunger = 15,
		Price = 10,
	},
	["Apple"] = {
		Hunger = 25,
		Price = 15,
	},
	["Ham"] = {
		Hunger = 35,
		Price = 25,
	},
	["Sausage"] = {
		Hunger = 35,
		Price = 25,
	},
}

return FoodDetails
