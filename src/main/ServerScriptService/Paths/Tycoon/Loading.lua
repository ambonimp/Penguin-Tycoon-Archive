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
		local i = 0
		for Item in pairs(Tycoon) do
			Modules.Placement:NewItem(Player, Item, false)
			i += 1
			if i % 50 == 0 then
				task.wait(0.5)
			end
		end

		-- Load Buttons
		for i, Button in pairs(Paths.Template.Buttons:GetChildren()) do
			if Tycoon[Button:GetAttribute("Dependency")] and not Tycoon[Button:GetAttribute("Object")] and not TycoonModel.Tycoon:FindFirstChild(Button:GetAttribute("Object")) then
				Modules.Buttons:NewButton(Player, Button.Name)
			end
			if i % 50 == 0 then
				task.wait(0.5)
			end
		end

		for _, Extra in pairs(Paths.Template.Extra:GetChildren()) do
			Modules.Placement:LoadExtra(Player,Extra:Clone())
		end
	end
	
	Modules.Buttons:NewButton(Player, "Snow#1")
	Modules.Rebirths.LoadRebirth(Player)

end


return Loading