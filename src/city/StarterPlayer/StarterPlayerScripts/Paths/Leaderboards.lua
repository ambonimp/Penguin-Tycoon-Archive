local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local Leaderboards = {}

local Paths = require(script.Parent)
local Modules = Paths.Modules
local Services = Paths.Services
local Remotes = Paths.Remotes


for _, Leaderboard in ipairs(workspace.Leaderboards:GetChildren()) do
    Leaderboard.Display.GUI.PlayerPosition.PlrName.Text = Paths.Player.Name
end


local function UpdatePosition()
    local Stats = Remotes.GetStat:InvokeServer("Stats")
    for _, Leaderboard in ipairs(workspace.Leaderboards:GetChildren()) do
        local Stat = Leaderboard.Name
        local Details = Modules.LeaderboardDetails[Stat]

        local Value = Stats[Stat] or Remotes.GetStat:InvokeServer(Stat)
        Leaderboard.Display.GUI.PlayerPosition.Value.Text = if Value then (if Details.Format then Details.Format(Value) else Modules.Format.FormatAbbreviated(Value)) else "-"

    end

end

UpdatePosition()
Remotes.LeaderboardUpdated.OnClientEvent:Connect(UpdatePosition)

return Leaderboards