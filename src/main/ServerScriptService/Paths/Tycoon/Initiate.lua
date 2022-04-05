local Initiate = {}


--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes


--- Purchase Functions ---
function Initiate:InitiateButtons()
	local Buttons = Paths.Template:WaitForChild("Buttons")
	
	for iB, Button in pairs(Buttons:GetChildren()) do
		for iT, Tycoon in pairs(workspace.Tycoons:GetChildren()) do
			-- Fired when an item is purchased in a tycoon
			Tycoon.Buttons.DescendantRemoving:Connect(function(ButtonRemoved)
				if Button:GetAttribute("Dependency") == ButtonRemoved.Name then
					local Owner = Tycoon.Owner.Value
					if game.Players:FindFirstChild(Owner) then
						local Player = game.Players[Owner]
						Modules.Buttons:NewButton(Player, Button.Name)
					end
				end				
			end)
		end
	end
end

Initiate:InitiateButtons()

return Initiate