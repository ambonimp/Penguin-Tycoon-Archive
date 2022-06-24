local Minigame = {}

--- Main Variables ---
local Paths = require(script.Parent.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes

local function RemoveTools(Player)
    Modules.Tools.RemoveTool(Player, "Snowball Launcher")
    Modules.Tools.RemoveTool(Player, "Snow Grenade")
end

Remotes.MilitaryMinigame.OnServerInvoke = function(Player, Event, ...)
    local Params = table.pack(...)

    if Event == "OnRoundBegan" then
        -- TODO: Check that upgrade is owned
        Modules.Tools.AddTool(Player, "Snowball Launcher", true)
        Modules.Tools.AddTool(Player, "Snow Grenade", true)

    elseif Event == "OnRoundCompleted" then
        local Time = Params[1]
        RemoveTools(Player)

    elseif Event == "OnRoundCancelled" then
        RemoveTools(Player)

    end

end

game.Players.PlayerAdded:Connect(RemoveTools)



return Minigame