local ServerStorage = game:GetService("ServerStorage")
local EventHandler = ServerStorage:FindFirstChild("EventHandler")
local AnalyticsService = game:GetService("AnalyticsService")

EventHandler.Event:Connect(function(event, player, data)
    -- Tries to post Playfab event
	pcall(function()
		AnalyticsService:FireCustomEvent(player, event, data)
	end)
end)