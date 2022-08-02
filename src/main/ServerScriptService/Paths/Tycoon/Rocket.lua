local CollectionService = game:GetService("CollectionService")
local Rocket = {}

local Paths = require(script.Parent.Parent)
local Modules = Paths.Modules
local Remotes = Paths.Remotes
local Services = Paths.Services

local function Unlock(Player)
    local Tycoon = workspace.Tycoons:FindFirstChild(Player:GetAttribute("Tycoon"))
    if Tycoon.Tycoon:FindFirstChild("Icy Access#1") and Tycoon.Tycoon:FindFirstChild("Icy Access#1"):FindFirstChild("BrokenRocketShip") then
        Tycoon.Tycoon:FindFirstChild("Icy Access#1"):FindFirstChild("BrokenRocketShip"):Destroy()
    end

end


function Rocket.Load(Player)
    local Data = Modules.PlayerData.sessionData[Player.Name]
    if Data then
        if Data["RocketUnlocked"][1] then
            Unlock(Player)
        end

    end

end

CollectionService:GetInstanceAddedSignal("BuildAItem"):Connect(function(Placeholder)
    Placeholder.Transparency = 1
end)

Remotes.RocketBuild.OnServerInvoke = function(Client, Item)
    local Data = Modules.PlayerData.sessionData[Client.Name]
    if Data then
        local UnlockingData = Data["RocketUnlocked"]

        local OwnsBrokenRocket = Data.Tycoon["Icy Access#1"]
        local OwnsIsland = Data.Tycoon[Modules.ProgressionDetails[Modules.Initiate.GetIslandIndex(Modules.BuildADetails.Rocket[Item])].Object]

        if not UnlockingData[1] and OwnsBrokenRocket and OwnsIsland then
            UnlockingData[2][Item] = true

            local Completed = true
            for OtherItem in pairs(Modules.BuildADetails.Rocket) do
                if not UnlockingData[2][OtherItem] then
                    Completed = false
                    break
                end
            end

            if Completed then
                UnlockingData[1] = true

                Data.Tycoon["Rocketship#1"] = true
                Modules.Placement:NewItem(Client, "Rocketship#1", true)

                if not Modules.Ownership:GetPlayerTycoon(Client).Buttons:FindFirstChild("New Island!#32") then
                    Modules.Initiate:UnlockDependents(Client, "New Island!#32")
                end
                Modules.Purchasing:ItemPurchased(Client, "New Island!#32", true)

                Unlock(Client)
            end

            return UnlockingData

        end

    end

end

return Rocket