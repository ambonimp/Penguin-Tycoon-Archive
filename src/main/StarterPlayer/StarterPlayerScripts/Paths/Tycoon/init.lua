local Penguins = {}


--- Main Variables ---
local Paths = require(script.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes
local UI = Paths.UI


--- Other Variables ---
local CustomizationUI = UI.Left.Customization
Penguins.Penguins = {}


--- Connecting penguins to SetupPenguin() function ---
local PlayerTycoon = Paths.Player:GetAttribute("Tycoon")

local function NewObject(Object, Type)
	if Type then
		if Type == "Penguin" then
			Modules.Penguins:SetupPenguin(Object)
		end
	end
end

local function ButtonRemoved(Button)
	Modules.Help:ButtonRemoved(Button)
end

coroutine.wrap(function()
	workspace.Tycoons[PlayerTycoon].Tycoon.ChildAdded:Connect(function(Object)
		local Type = Object:GetAttribute("Type")
		NewObject(Object, Type)

		Modules.AudioHandler:ItemPurchased()
	end)
	
	workspace.Tycoons[PlayerTycoon].Buttons.ChildRemoved:Connect(function(Button)
		local Type = Button:GetAttribute("Type")
		ButtonRemoved(Button, Type)
	end)
	
	for i, Object in pairs(workspace.Tycoons[PlayerTycoon].Tycoon:GetChildren()) do
		local Type = Object:GetAttribute("Type")
		NewObject(Object, Type)
	end
end)()


return Penguins