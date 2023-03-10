local Rebirths = {}

local Paths = require(script.Parent.Parent)
local Modules = Paths.Modules
local Services = Paths.Services
local Remotes = Paths.Remotes

local UPGRADE = "RebirthMachine"
local BUTTONS_TO_IGNORE = {
    [UPGRADE] = true,
    ["Pets#1"] = true,
    ["Glider#1"] = true,
}



local ToolsToReset = {}
for _, Button in ipairs(Paths.Template.Buttons:GetChildren()) do
    if Button:GetAttribute("Type") == "Tool" and Button:GetAttribute("CurrencyType") == "Money" then
        local Upgrade = Paths.Template.Upgrades[Button:GetAttribute("Island")][Button:GetAttribute("Object")]
        ToolsToReset[Upgrade:GetAttribute("Tool")] = true
    end
end



function Rebirths.LoadRebirth(Player)
    local Data = Modules.PlayerData.sessionData[Player.Name]
    if Data then
        if Data.Tycoon[UPGRADE] or Modules.Ownership:GetPlayerTycoon(Player).Buttons:FindFirstChild(UPGRADE) then
            return
        end

        for _, Button in ipairs(Paths.Template.Buttons:GetChildren()) do
            local Name = Button.Name
            if not BUTTONS_TO_IGNORE[Name] and Button:GetAttribute("CurrencyType") == "Money" and not Data.Tycoon[Name] then
                return false
            end
        end

        Remotes.RebirthReady:FireClient(Player)
        Modules.Buttons:NewButton(Player, UPGRADE)

        return true

    end

end

Remotes.Rebirth.OnServerInvoke = function(Client, Currency)
    local Data = Modules.PlayerData.sessionData[Client.Name]
    if Data then
        if Data.Tycoon[UPGRADE] then
            local Purchased
            if Currency == "Money" then
                if Data.Money >= 10 ^ 9 + (10 ^ 9) * 0.25 * Data.Rebirths then
                    Purchased = true
                end
            else -- Gems
                if Data.Gems >= 1000 + (1000) * 0.25 * Data.Rebirths then
                    Purchased = true
                end
            end

            if Purchased then
                local EventHandler = game:GetService("ServerStorage"):FindFirstChild("EventHandler")

                Data.Rebirths += 1
                Data["Income Multiplier"] += 0.1
                Client.leaderstats.Rebirths.Value = Data.Rebirths

                -- Reset data
                local Defaults = Modules.PlayerData.Defaults(Client)

                Data.Money = Defaults.Money
                Client:SetAttribute("Money", Data.Money)

                Data.Income = Defaults.Income
                Client.leaderstats.Income.Value = Data.Income

                Client:SetAttribute("StoredIncome", 0)
	            Data["Stored Income"] = 0

                Data["My Penguin"].Level = 0
                Client:SetAttribute("Level", 0)

                Data.Tycoon = Defaults.Tycoon
                Data.Penguins = Defaults.Penguins
                Data.YoutubeStats = Defaults.YoutubeStats
                Data.PlaneUnlocked = Defaults.PlaneUnlocked
                Data.RocketUnlocked = Defaults.RocketUnlocked
                Data.BoatUnlocked = Defaults.BoatUnlocked

                for Tool in pairs(Data.Tools) do
                    if ToolsToReset[Tool] then
                        Modules.Tools.RemoveTool(Client, Tool)
                    end
                end

                -- Unload tycoon
                local Tycoon = Client:GetAttribute("Tycoon")
                Modules.Ownership:UnclaimTycoon(Tycoon)
                Modules.Tycoon:InitializePlayer(Client, Tycoon)

                EventHandler:Fire("Rebirth", Client, {
                    Amount = Data.Rebirths,
                })

                return Data.Rebirths
            end

        end

    end

end


return Rebirths