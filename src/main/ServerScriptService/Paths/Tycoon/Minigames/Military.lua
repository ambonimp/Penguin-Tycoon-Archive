local Minigame = {}

--- Main Variables ---
local Paths = require(script.Parent.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes

local function RemoveTools(Player)
    local Data
    repeat
        task.wait()
        Data = Modules.PlayerData.sessionData[Player.Name]
    until Data or not Player.Parent

    if Data then
        Modules.Tools.RemoveTool(Player, "Snowball Launcher")
        Modules.Tools.RemoveTool(Player, "Snow Grenade")
    end

end

Remotes.MilitaryMinigame.OnServerInvoke = function(Player, Event, ...)
    local Params = table.pack(...)

    local Data = Modules.PlayerData.sessionData[Player.Name]
    if not Data or not Data.Tycoon["Sergeant#1"] then return end

    if Event == "OnRoundBegan" then
        Modules.Tools.AddTool(Player, "Snowball Launcher", true)
        Modules.Tools.AddTool(Player, "Snow Grenade", true)

        return true
    elseif Event == "OnRoundCompleted" then
        local Time = Params[1]
        RemoveTools(Player)

        if Data["Military Minigame Score"] > Time then
            Data["Military Minigame Score"] = Time
        end

        local Reward =  if Time <= 35 then 3 else (if Time <= 45 then 2 else (if Time <= 60 then 1 else 0))
        Modules.Income:AddGems(Player, Reward, "Military Minigame")


    elseif Event == "OnRoundCancelled" then
        RemoveTools(Player)

    end

end

game.Players.PlayerAdded:Connect(RemoveTools)



return Minigame