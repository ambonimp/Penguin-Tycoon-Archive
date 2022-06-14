local minigame = {}

--- Main Variables ---
--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes

local debounces = {}

local UPLOAD_COOLDOWN = 30

-- This event is only fired when the game is finished
Remotes.YoutubeMinigameFinished.OnServerEvent:Connect(function(player, computer, score, subs, likes)
    local data = Modules.PlayerData.sessionData[player.Name]
    if data then
        if data.Tycoon[computer] and not debounces[player] then
            debounces[player] = true

            if data["Youtube Minigame Score"] < score then
                data["Youtube Minigame Score"] = score
            end

            local stats = data["YoutubeStats"]
            stats.Likes += likes
            stats.Subscribers += subs

            local gemsEarned = if score >= 40 then 3 else (if score >= 25 then 2 else (if score >= 10 then 1 else 0))
            Modules.Income:AddGems(player, gemsEarned, "Youtube Minigame")

            task.wait(UPLOAD_COOLDOWN * 0.6) -- Shorter to account for latenc
            debounces[player] = false
        end

    end

end)

game.Players.PlayerRemoving:Connect(function(player)
    if debounces[player] then
        debounces[player] = nil
    end
end)

return minigame