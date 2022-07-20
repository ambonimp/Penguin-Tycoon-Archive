local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local Leaderboards = {}

local Paths = require(script.Parent)
local Modules = Paths.Modules
local Services = Paths.Services
local Remotes = Paths.Remotes

local RegisteredLeaderboards = {}

-- Functions
local function UpdatePosition(Leaderboard)
    local Stat = Leaderboard:GetAttribute("Stat")

    local Value = Remotes.GetStat:InvokeServer("Stats")[Stat] or Remotes.GetStat:InvokeServer(Stat)
    if Stat == "Total Playtime" then
        Value = Modules.Format:FormatTimeDHM(Value)
    else
        Value = Modules.Format:FormatAbbreviated(Value)
    end

    Leaderboard.Display.GUI.PlayerPosition.Value.Text = Value
end

local function LoadLeaderboard(Leaderboard)
    if string.find(Leaderboard.Name, "Leaderboard") then
        table.insert(RegisteredLeaderboards, Leaderboard)

        Leaderboard.Display.GUI.PlayerPosition.PlrName.Text = Paths.Player.Name
        UpdatePosition(Leaderboard)

    end
end


-- Initialize
for _, PotentialLeaderboard in ipairs(Paths.Tycoon.Tycoon:GetChildren()) do
    LoadLeaderboard(PotentialLeaderboard)
end
Paths.Tycoon.Tycoon.ChildAdded:Connect(LoadLeaderboard)


-- Update
Remotes.LeaderboardUpdated.OnClientEvent:Connect(function()
    for _, Leaderboard in ipairs(RegisteredLeaderboards) do
        UpdatePosition(Leaderboard)
    end
end)

-- Rebirth
task.spawn(function()
    repeat task.wait() until Modules.Rebirths
    Modules.Rebirths.Rebirthed:Connect(function()
        RegisteredLeaderboards = {}
    end)
end)

return Leaderboards