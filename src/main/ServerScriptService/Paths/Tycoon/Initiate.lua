local Initiate = {}


--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes

local Buttons

local function GetIslandIndex(Reference)
    local Island = Reference:GetAttribute("Island")
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


local function IsUnlockable(Index, Button)
	if not Index then return false end
    return Button:GetAttribute("CurrencyType") == "Money" and Button.Name ~= Modules.ProgressionDetails[Index].Object
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
					Remotes.ButtonPurchased:FireClient(Player, GetIslandIndex(ButtonRemoved), ButtonRemoved.Name, ButtonRemoved:GetAttribute("Island"))

					local HadDependents = false -- last button that leads to rebirth won't have anything after it so only check completion in that scenario

					for _, Button in pairs(Buttons:GetChildren()) do
						if Button:GetAttribute("Dependency") == ButtonRemoved.Name then
							if Modules.PlayerData.sessionData[Player.Name].Rebirths ~= 0 and Button.Name == "Pets#1" then continue end
							if Button:GetAttribute("CurrencyType") == "Money" then
								HadDependents = true
							end
							Modules.Buttons:NewButton(Player, Button.Name)
						end

					end

					if not HadDependents then
						Modules.Rebirths.LoadRebirth(Player)
					end

				end

			end

		end)

	end

end

function Initiate.GetIslandIndex(Upgrade : string)
	local UpgradeModel = Paths.Template.Upgrades[Upgrade]
	for Id, Details in pairs(Modules.ProgressionDetails) do
		if UpgradeModel:FindFirstChild(Details.Object) then
			return Id
		end
	end
end

Remotes.IslandProgressRewardCollected.OnServerEvent:Connect(function(Client, Index, Island)
	local Data = Modules.PlayerData.sessionData[Client.Name]
	if Data and not Data["Tycoon Rewards"][Island] then
		Data["Tycoon Rewards"][Island] = true

		local Unlocked = 0
		local Unlockables = 0

		for _, Button in pairs(Buttons:GetChildren()) do
			if IsUnlockable(GetIslandIndex(Button), Button) then
				Unlockables += 1
				if Data.Tycoon[Button.Name] then
					Unlocked += 1
				end
			end
		end

		-- warn(Unlocked, Unlockables)
		if Unlocked == math.floor(Unlockables/2) then
			Modules.Income:AddGems(Client, 3, "Tycoon Reward")
		end
	end

end)


Remotes.GetIslandIndex.OnServerInvoke = function(_, Upgrade : string)
	return Initiate.GetIslandIndex(Upgrade)
end

Remotes.GetTemplateButtonAttribute.OnServerInvoke = function(_, Id, Attribute)
    return Paths.Template.Buttons[Id]:GetAttribute(Attribute)
end

Remotes.GetTemplateUpgradeAttribute.OnServerInvoke = function(_, Island, Id, Attribute)
    return Paths.Template.Upgrades[Island][Id]:GetAttribute(Attribute)
end



Remotes.GetTycoonInfo.OnServerInvoke = function(Client)
	local Unlocking = {}

	for i = 1, #Modules.ProgressionDetails do
		Unlocking[i] = {
			Unlocked = 0,
			Unlockables = {},
		}
	end
	-- Unlocked
	local Data = Modules.PlayerData.sessionData[Client.Name]
	if Data then
		Data = Data.Tycoon

		-- Unlockables
		for _, Button in pairs(Buttons:GetChildren()) do
			local Index = GetIslandIndex(Button)
			if IsUnlockable(Index, Button) then
				table.insert(Unlocking[Index].Unlockables, Button)

				if Data[Button.Name] then
					Unlocking[Index].Unlocked += 1
				end

			end

		end

		for _, v in ipairs(Unlocking) do
			v.Unlockables = #v.Unlockables
		end

		return Unlocking

	end

end


Initiate:InitiateButtons()

return Initiate