local Loading = {}


--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes


--- Purchase Functions ---
function Loading:LoadTycoon(Player)
	local Data = Modules.PlayerData.sessionData[Player.Name]
	
	if Data then
		local Tycoon = Data["Tycoon"]
		local TycoonModel = Paths.Modules.Ownership:GetPlayerTycoon(Player)

		-- Load Items
		for Item, IsOwned in pairs(Tycoon) do
			Modules.Placement:NewItem(Player, Item, false)
		end

		-- Load Buttons
		for i, Button in pairs(Paths.Template.Buttons:GetChildren()) do
			if Tycoon[Button:GetAttribute("Dependency")] and not Tycoon[Button:GetAttribute("Object")] and not TycoonModel.Tycoon:FindFirstChild(Button:GetAttribute("Object")) then
				Modules.Buttons:NewButton(Player, Button.Name)
			end
		end

		for i, Extra in pairs(Paths.Template.Extra:GetChildren()) do
			Modules.Placement:LoadExtra(Player,Extra:Clone())
		end
	end
	
	Modules.Buttons:NewButton(Player, "Snow#1")
end


return Loading