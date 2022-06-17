local Initiate = {}


--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes

local Buttons

--- Purchase Functions ---
function Initiate:InitiateButtons()
	Buttons = Paths.Template:WaitForChild("Buttons")
	
	for _, Tycoon in pairs(workspace.Tycoons:GetChildren()) do
		-- Fired when an item is purchased in a tycoon
		Tycoon.Buttons.ChildRemoved:Connect(function(ButtonRemoved)
			local Owner = Tycoon.Owner.Value
			local Player = game.Players:FindFirstChild(Owner)

			if Player then
				Remotes.ButtonPurchased:FireClient(Player, ButtonRemoved.Name)

				for _, Button in pairs(Buttons:GetChildren()) do
					if Button:GetAttribute("Dependency") == ButtonRemoved.Name then
						Modules.Buttons:NewButton(Player, Button.Name)
					end
				end

			end

		end)

	end

end



Remotes.IslandProgressRewardCollected.OnServerEvent:Connect(function(Client, Index, Island)
	local Data = Modules.PlayerData.sessionData[Client.Name]
	if Data and not Data["Tycoon Rewards"][Island] then
		Data["Tycoon Rewards"][Island] = true

		local Unlocked = 0
		local Unlockables = 0

		for _, Button in pairs(Buttons:GetChildren()) do
			if Button:GetAttribute("Island") == Island and  Button:GetAttribute("CurrencyType") == "Money" and Button.Name ~= Modules.ProgressionDetails[Index].Object then
				Unlockables += 1
				if Data.Tycoon[Button.Name] then
					Unlocked += 1
				end
			end
		end

		-- warn(Unlocked, Unlockables)
		if Unlocked == math.floor(Unlockables/2) then
			Modules.Income:AddGems(Client, 5, "Tycoon Reward")
		end
	end

end)

Initiate:InitiateButtons()

return Initiate