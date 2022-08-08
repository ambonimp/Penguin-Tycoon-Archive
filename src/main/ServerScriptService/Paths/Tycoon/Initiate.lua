local Initiate = {}


--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes

local Buttons

local function IsUnlockable(Index, Button)
	if not Index then return false end
    return Button:GetAttribute("CurrencyType") == "Money" and Button.Name ~= Modules.ProgressionDetails[Index].Object
end

function Initiate:UnlockDependents(Player, Dependee)
	local HasDependents = false

	for _, Button in pairs(Buttons:GetChildren()) do
		if Button:GetAttribute("Dependency") == Dependee then
			local NewItem = Button.Name

			local Data = Modules.PlayerData.sessionData[Player.Name]
			if not (Data.Rebirths ~= 0 and Button.Name == "Pets#1") then -- Ignored after a rebirth
				if Data["Robux Tycoon"][NewItem] then
					Modules.Purchasing:ItemPurchased(Player, NewItem, true, true)
				else
					if Modules.Buttons:NewButton(Player, NewItem) and Button:GetAttribute("CurrencyType") == "Money" then
						HasDependents = true
					end
					-- print(Dependee, Button, HasDependents)
				end

			end

		end

	end

	if not HasDependents then
		Modules.Rebirths.LoadRebirth(Player)
	end

end

--- Purchase Functions ---
function Initiate:InitiateButtons()
	Buttons = Paths.Template:WaitForChild("Buttons")
	
	for _, Tycoon in pairs(workspace.Tycoons:GetChildren()) do
		-- Fired when an item is purchased in a tycoon
		Tycoon.Buttons.ChildRemoved:Connect(function(ButtonRemoved)
			if ButtonRemoved:GetAttribute("Purchased") then -- Could potentially be removed for rebirthing
				local Owner = Tycoon.Owner.Value
				local Player = game.Players:FindFirstChild(Owner)

				if Player then
					Remotes.ButtonPurchased:FireClient(Player, Initiate.GetIslandIndexFromObject(ButtonRemoved.Name), ButtonRemoved.Name, ButtonRemoved:GetAttribute("Island"))
					Initiate:UnlockDependents(Player, ButtonRemoved.Name)
				end

			end

		end)

	end

end

function Initiate.GetIslandIndexFromObject(Object : string)
	local Button = Buttons:FindFirstChild(Object)
	if Button then
	    local Island = Button:GetAttribute("Island")
	    if Island == "Island1" then
	        return 1
	    else
	        for i = 2, #Modules.ProgressionDetails do
	            local FirstButton = Buttons[Modules.ProgressionDetails[i].Object]
	            if FirstButton:GetAttribute("Island") == Island then
	                return i
	            end
	        end

	    end

	end

end

function Initiate.GetIslandIndexFromUpgrade(Upgrade : string)
	local UpgradeModel = Paths.Template.Upgrades:FindFirstChild(Upgrade)
	if UpgradeModel then
		warn("NICE")

		for Id, Details in pairs(Modules.ProgressionDetails) do
			if UpgradeModel:FindFirstChild(Details.Object) then
				return Id
			end
		end
	end
end

Remotes.GetIslandIndexFromUpgrade.OnServerInvoke = function(_, Upgrade : string)
	return Initiate.GetIslandIndexFromUpgrade(Upgrade)
end

Remotes.GetTemplateButtonAttribute.OnServerInvoke = function(_, Id, Attribute)
    return Paths.Template.Buttons[Id]:GetAttribute(Attribute)
end

Remotes.GetTemplateUpgradeAttribute.OnServerInvoke = function(_, Island, Id, Attribute)
    return Paths.Template.Upgrades[Island][Id]:GetAttribute(Attribute)
end


Initiate:InitiateButtons()

return Initiate