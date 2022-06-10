---This is a script that handles data that is common along all places, like playtime and teleports
local ServerStorage = game:GetService("ServerStorage")
local EventHandler = ServerStorage:FindFirstChild("EventHandler")

-- Services
local Players = game:GetService("Players")

-- Members
local playersJoinTime = {}

local function onPlayerAdded(player: Player)
    -- Caches player join time
    playersJoinTime[player.UserId] = tick()
end

local function onPlayerRemoving(player: Player)
    -- Gets total playtime in this session
    local sessionLength = tick() - playersJoinTime[player.UserId]
    
    -- Clears player cached join time
    playersJoinTime[player.UserId] = nil

    -- Fires an analytics event
    EventHandler:Fire("sessionEnded", player, {
        length = sessionLength,
        area = "Social"
    })
end

-- Event Listeners
Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)