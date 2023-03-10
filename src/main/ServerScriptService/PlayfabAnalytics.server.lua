local ServerStorage = game:GetService("ServerStorage")
local EventHandler = ServerStorage:FindFirstChild("EventHandler")
local AnalyticsService = game:GetService("AnalyticsService")
local SocialService = game:GetService("SocialService")

-- Constants
local MAIN_PLACE_ID = 7951464846

EventHandler.Event:Connect(function(event, player, data)
    -- Ignore in case this is not the main place
	if game.PlaceId ~= MAIN_PLACE_ID then
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