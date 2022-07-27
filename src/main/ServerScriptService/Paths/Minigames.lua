local Minigames = {}

local Paths = require(script.Parent)
local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes

Modules.Achievements.Reconciled:Connect(function(Data)
    Modules.Achievements.ReconcileSet(Data, 24, Data["Skate Race Wins"])
    Modules.Achievements.ReconcileSet(Data, 25, Data["Falling Tiles"])
    Modules.Achievements.ReconcileSet(Data, 26, Data["Soccer Wins"])
    Modules.Achievements.ReconcileSet(Data, 27, Data["Candy Rush"])
    Modules.Achievements.ReconcileSet(Data, 28, Data["Ice Cream Extravaganza"])
    Modules.Achievements.ReconcileSet(Data, 29, Data["Sled Race Wins"])
end)


return Minigames
