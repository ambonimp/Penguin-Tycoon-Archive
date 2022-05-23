local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Assets = ReplicatedStorage:WaitForChild("Assets")
local ToyDetails = {
	["Stick"] = {
		Entertainment = 15,
		Price = 10,
	},
	["Ball"] = {
		Entertainment = 30,
		Price = 25,
	},
	
	["String"] = {
		Entertainment = 10,
		Price = 5,
	},
	
	["Plushy"] = {
		Entertainment = 20,
		Price = 15,
	},

}

return ToyDetails
