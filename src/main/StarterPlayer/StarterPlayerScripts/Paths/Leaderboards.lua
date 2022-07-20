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

    local Display = Leaderboard:FindFirstChild("Display")
    if Display then
        Display:WaitForChild("GUI"):WaitForChild("PlayerPosition"):WaitForChild("Value").Text = Value
    end

end

local function LoadLeaderboard(Leaderboard)
    if string.find(Leaderboard.Name, "Leaderboard") then
        task.spawn(function()
            local Display = Leaderboard:WaitForChild("Display", math.huge)
            local GUI = Display:WaitForChild("GUI")
            local PlayerPosition = GUI:WaitForChild("PlayerPosition")
            local PlayerList = GUI:WaitForChild("PlayerList")

            PlayerList.Size = UDim2.fromScale(PlayerList.Size.X.Scale, PlayerList.Size.Y.Scale - PlayerPosition.Size.Y.Scale)
            PlayerPosition.Visible = true

            PlayerPosition.PlrName.Text = Paths.Player.Name

            UpdatePosition(Leaderboard)
            table.insert(RegisteredLeaderboards, Leaderboard)
        end)

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