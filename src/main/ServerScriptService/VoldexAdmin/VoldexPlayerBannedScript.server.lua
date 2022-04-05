-- Import Services
local Players = game:GetService("Players")
local VoldexServer = require(game.ServerScriptService.VoldexAdmin.VoldexServer)

-- Add event for new players
Players.PlayerAdded:Connect(function(player)
	if VoldexServer.IsPlayerBanned(player) then
		player:Kick("You are banned! Please join our community to appeal this ban.")
	end
end)
