local Minigames = {}

local Paths = require(script.Parent)
local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes

Modules.Achievements.Reconciled:Connect(function(Data)
    Modules.Achievements.ReconcileSet(Data, 24, Data.Stats["Skate Race Wins"])
    Modules.Achievements.ReconcileSet(Data, 25, Data.Stats["Falling Tiles"])
    Modules.Achievements.ReconcileSet(Data, 26, Data.Stats["Soccer Wins"])
    Modules.Achievements.ReconcileSet(Data, 27, Data.Stats["Candy Rush"])
    Modules.Achievements.ReconcileSet(Data, 28, Data.Stats["Ice Cream Extravaganza"])
    Modules.Achievements.ReconcileSet(Data, 29, Data.Stats["Sled Race Wins"])
    Modules.Achievements.ReconcileSet(Data, 30, Data.Stats["Soccer"])
end)


return Minigames
