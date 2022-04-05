local Buttons = {}


--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes


--- Purchase Variables ---
local PurchaseDBs = {}


--- Purchase Functions ---
function Buttons:NewButton(Player, Button)
	local Button = Paths.Template.Buttons:FindFirstChild(Button)
	if Button then
		local Data = Modules.PlayerData.sessionData[Player.Name]
	
		local Tycoon = Modules.Ownership:GetPlayerTycoon(Player)
		
		if Tycoon.Tycoon:FindFirstChild(Button:GetAttribute("Object")) then return end
		
		local Button = Button:Clone()
		Button.Parent = Tycoon.Buttons
		
		local Position, Rotation = Modules.Placement:GetRelativePos(Player:GetAttribute("Tycoon"), Button.Name, true)
		Modules.Placement:MoveModel(Button, Position, Rotation)
		
		Button.Hitbox.Touched:Connect(function(Part)
			if Part.Parent:FindFirstChild("Humanoid") then
				local Char = Part.Parent
				
				if game.Players:GetPlayerFromCharacter(Char) == Player and not PurchaseDBs[Button.Name] then
					PurchaseDBs[Button.Name] = true
					
					local CurrencyType = Button:GetAttribute("CurrencyType")
					local ItemType = Button:GetAttribute("Type") or "Normal"
					
					if CurrencyType == "Robux" then
						Modules.Products:PromptRobuxItemPurchase(Player, Button:GetAttribute("ID"), Button)
					elseif CurrencyType == "Money" then
						Modules.Purchasing:PurchaseItem(Player, Button.Name, true)
					elseif CurrencyType == "Gamepass" then
						Services.MPService:PromptGamePassPurchase(Player, Button:GetAttribute("ID"))
					end
					
					task.wait(0.3)
					PurchaseDBs[Button.Name] = nil
				end
			end
		end)
	end
end


return Buttons