local Paths = require(script.Parent.Parent)
local Modules = Paths.Modules
local Services = Paths.Services
local Remotes = Paths.Remotes

local UPGRADE = "RebirthMachine"

local Rebirths = {}

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
        for _, Button in ipairs(Paths.Template.Buttons:GetChildren()) do
            local Name = Button.Name
            if Name ~= UPGRADE and Button:GetAttribute("CurrencyType") == "Money" and not Data.Tycoon[Name] then
                return false
            end
        end

       Modules.Buttons:NewButton(Player, UPGRADE)
       return true

    end

end

Remotes.IsRebirthReady.OnServerInvoke = Rebirths.LoadRebirth
Remotes.Rebirth.OnServerInvoke = function(Client, Currency)
    local Data = Modules.PlayerData.sessionData[Client.Name]
    if Data then
        if Data.Tycoon[UPGRADE] then
            local Purchased
            if Currency == "Money" then
                if Data.Money >= 10^10 then
                    Purchased = true
                end
            else -- Gems
                if Data.Gems >= 10^4 then
                    Purchased = true
                end
            end

            if Purchased then
                Data.Rebirths += 1
                Data["Income Multiplier"] += 0.002

                Client.leaderstats.Rebirths.Value = Data.Rebirths

                -- Reset data
                local Defaults = Modules.PlayerData.Defaults(Client)

                Data.Money = Defaults.Money
                -- Data.Gems = Defaults.Gems

                Data.Tycoon = Defaults.Tycoon
                Data.Woodcutting = Defaults.Woodcutting
                Data.Mining = Defaults.Mining
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

                return true

            else
                return
            end

        end

    end

end


return Rebirths