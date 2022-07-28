local Achievements = {}

local Paths = require(script.Parent)
local Services = Paths.Services
local Remotes = Paths.Remotes
local Modules = Paths.Modules

--[[
    Fired when a player whose last session happened prior to the release of achievements
    Modules connect and progresses the player based on their data
]]--
Achievements.Reconciled = Modules.Signal.new()

Remotes.CollectAchievement.OnServerInvoke = function(Player, Id)
    local Data = Modules.PlayerData.sessionData[Player.Name]
    if Data then
        local Store = Data.Achievements[2][tostring(Id)]
        if not Store[1] and Store[2] >= Modules.AllAchievements[Id].ToComplete then -- Not completed yet
            -- Rewards
            for _, Reward in pairs(Modules.AllAchievements[Id].Rewards) do
                if Reward.Type == "Gems" then
                    Modules.Income:AddGems(Player, Reward.Value)
                elseif Reward.Type == "Accessory" then
                    Modules.Accessories:ItemAcquired(Player, Reward.Value, "Accessory")
                elseif Reward.Type == "Outfit" then
                    Modules.Accessories:ItemAcquired(Player,  Reward.Value, "Outfits")
                elseif Reward.Type == "Income Multiplier" then
                    Data["Income Multiplier"] += Reward.Value / 100
                end
            end

            Achievements.Progress(Player, 33) -- Complete all achievements

            Store[1] = true
            return true

        end

    end

end

function Achievements.Progress(Player : Player, Id : number)
    if not Id or not Player then return end

    local Data = Modules.PlayerData.sessionData[Player.Name]
    if Data then
        local Store = Data.Achievements[2][tostring(Id)]
        if not Store[1] and Store[2] < Modules.AllAchievements[Id].ToComplete then -- Second check is so that we don't spam client
            Store[2] += 1
            Remotes.AchievementProgress:FireClient(Player, Id, Store)
        end
    end

end

-- When i was testing, i needed to reconcile a bunch of times and that doesn't work well with increment :D
function Achievements.ReconcileReset(Data, Id : number)
    if not Id then return end
    Data.Achievements[2][tostring(Id)][2] = 0
end

function Achievements.ReconcileSet(Data, Id : number, Value : number)
    if not Id or not Value then return end
    Data.Achievements[2][tostring(Id)][2] = Value
end

function Achievements.ReconcileIncrement(Data, Id : number)
    if not Id then return end
    Data.Achievements[2][tostring(Id)][2] += 1
end

return Achievements