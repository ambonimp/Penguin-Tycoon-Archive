local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local DiveSDK = require(ServerStorage.DiveSDK)
local EventBody = require(ServerStorage.DiveSDK.EventBody)
local EventHandler = ServerStorage:FindFirstChild("EventHandler")

EventHandler.Event:Connect(function(event, player, data)
	DiveSDK:recordEvent(player, event, data)
end)

-- Example functions for a joined player
local function playerJoined(player)
    -- Start SDK For player
    DiveSDK:initClient(player)
    -- Set Custom Parameters
	DiveSDK:setPlayerId(player, player.UserId)

    -- Send Launch Event
    DiveSDK:launch(player)

end

-- Example funciton for player left
local function playerRemoved(player)
   DiveSDK:stopClient(player)
end

local function initSDK()
    -- First Init the server SDK with config
    DiveSDK:initServer({
		appToken = "8b9a54bf-d213-45e1-8838-839cafce7b00", -- string
		hashKey = "C7D097BD153B26893760B", -- string
		serverUrl = "https://a.voldex.dive.games/penguint", -- string
		apiUrl = "https://api.voldex.dive.games",
		environment = (game.PlaceId ==  7951464846 and "live") or "dev", --string
        hasIdentityConsent = true, -- boolean
        showInfoLogs = true -- boolean
    })
	
    -- These functions are applied globally
    DiveSDK:setServerSessionId("424242-424242-424242-4242")
    DiveSDK:setGameVersion("1.0")
    DiveSDK:setDiveCid("dt1212")
    DiveSDK:setCustomHeaderParam("custom_global_header_test", "testing custom header")

    -- Add event for new players
	Players.PlayerAdded:Connect(function(player)
		local success, errorMessage = pcall(function()
			playerJoined(player)
		end)
		if not success then warn(errorMessage) end
    end)

    -- Add event for players leaving
	Players.PlayerRemoving:Connect(function(player)
		local success, errorMessage = pcall(function()
			playerRemoved(player)
		end)
		if not success then warn(errorMessage) end
    end)

    -- Fire for players that are already in game
	for _, player in ipairs(Players:GetPlayers()) do
		local success, errorMessage = pcall(function()
			coroutine.wrap(playerJoined)(player)
		end)
		if not success then warn(errorMessage) end
    end

end

-- Call the init
initSDK();
