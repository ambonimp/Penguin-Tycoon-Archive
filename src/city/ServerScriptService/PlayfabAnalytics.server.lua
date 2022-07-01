local ServerStorage = game:GetService("ServerStorage")
local EventHandler = ServerStorage:FindFirstChild("EventHandler")
local AnalyticsService = game:GetService("AnalyticsService")
local SocialService = game:GetService("SocialService")

-- Constants
local CITY_PLACE_ID = 7967681044

EventHandler.Event:Connect(function(event, player, data)
    -- Ignore in case this is not the main place
	if game.PlaceId ~= CITY_PLACE_ID then
		return
	end

	-- Tries to post Playfab event
	pcall(function()
		AnalyticsService:FireCustomEvent(player, event, data)
	end)
end)

SocialService.GameInvitePromptClosed:Connect(function(player, recipientIds)
	EventHandler:Fire("inviteFriends", player, {
		placeId = game.PlaceId
	})
end)