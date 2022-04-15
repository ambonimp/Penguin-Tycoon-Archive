local ModToolsServer = {}

--\\ Constants //--
local CHECK_BANNED_PLAYERS_INTERVAL = 5
local CACHE_BANNED_PLAYERS_INTERVAL = 20

--\\ Dependencies //--
local Postie = require(game.ReplicatedStorage.VoldexAdmin.Libs.Postie)
local VoldexMiddleware = require(game.ReplicatedStorage.VoldexAdmin.VoldexMiddleware)
local VoldexServer = require(game.ServerScriptService.VoldexAdmin.VoldexServer)
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local voldexStore = DataStoreService:GetDataStore("VoldexStore")

local bannedPlayers = {}

local function kickPlayer(player)
	pcall(function()
		player:Kick("You are banned! Please join our community to appeal this ban.")
	end)
end

--- Ban a given player
local function handleBanRequest(moderator: Player, player: Player, reason: string)
	-- Check if moderator is authorized
	if not VoldexMiddleware.IsPlayerAuthorized(moderator) then
		return
	end

	local response = VoldexServer.BanPlayer(moderator, player, reason)

	if response and response.success then
		kickPlayer(player)
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

local function cacheBannedPlayers()
	pcall(function()
		bannedPlayers = VoldexServer.GetBannedPlayers()

		wait(CACHE_BANNED_PLAYERS_INTERVAL)
		cacheBannedPlayers()
	end)
end

local function checkBannedPlayersOnline()
	pcall(function()
		for _, bannedPlayer in pairs(bannedPlayers) do
			if Players:GetPlayerByUserId(bannedPlayer.robloxId) then
				kickPlayer(Players:GetPlayerByUserId(bannedPlayer.robloxId))
			end
		end

		wait(CHECK_BANNED_PLAYERS_INTERVAL)
		checkBannedPlayersOnline()
	end)
end

local function getPlayerData(playerRequesting, player)
	local playerData = voldexStore:GetAsync(player.UserId)
	if not playerData then
		playerData = {
			totalPlaytime = 1,
			averagePlaytime = 1,
			sessions = {},
		}
	end
	return playerData
end

function ModToolsServer.Start()
	Postie.SetCallback("RequestBan", handleBanRequest)
	Postie.SetCallback("RequestUnban", handleUnbanRequest)
	Postie.SetCallback("GetPlayerData", getPlayerData)

	-- Add event for new players
	Players.PlayerAdded:Connect(function(player)
		pcall(function()
            if VoldexServer.IsPlayerBanned(player) then
                kickPlayer(player)
            end
		end)
	end)

	-- Starts the routine to check banned players in server
	spawn(cacheBannedPlayers)
	spawn(checkBannedPlayersOnline)
end

return ModToolsServer
