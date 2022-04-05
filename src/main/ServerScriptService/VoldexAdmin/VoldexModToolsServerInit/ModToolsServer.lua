local ModToolsServer = {}

--\\ Dependencies //--
local Postie = require(game.ReplicatedStorage.VoldexAdmin.Libs.Postie)
local VoldexMiddleware = require(game.ReplicatedStorage.VoldexAdmin.VoldexMiddleware)
local VoldexServer = require(game.ServerScriptService.VoldexAdmin.VoldexServer)

--- Ban a given player
local function handleBanRequest(moderator: Player, player: Player, reason: string)
    -- Check if moderator is authorized
    if not VoldexMiddleware.IsPlayerAuthorized(moderator) then
        return
    end

    local response = VoldexServer.BanPlayer(moderator, player, reason)

    if response and response.success then
        player:Kick("You are banned! Please join our community to appeal this ban.")
    end

    return response
end

--- Unban a given player
local function handleUnbanRequest(moderator: Player, player: Player)
    -- Check if moderator is authorized
    if not VoldexMiddleware.IsPlayerAuthorized(moderator) then
        return
    end

    local response = VoldexServer.UnbanPlayer(player)
    return response
end

function ModToolsServer.Start()
	Postie.SetCallback("RequestBan", handleBanRequest)
    Postie.SetCallback("RequestUnban", handleUnbanRequest)
end

return ModToolsServer
