local Server = {}

--Services
local MessagingService = game:GetService("MessagingService")
local Players = game:GetService("Players")
local VoldexMiddleware = require(game:GetService("ReplicatedStorage").VoldexAdmin.VoldexMiddleware)
local Postie = require(game:GetService("ReplicatedStorage").VoldexAdmin.Libs.Postie)

--Extras
local MESSAGING_TOPIC = "VoldexMessage"
--local Init = false
--if Init == true then return Server end Init = true 

--Check if the player is an admin (Compares with attributes of group)
function Server.PlayerIsAdmin(Player: Player)
	if VoldexMiddleware.IsPlayerAuthorized(Player) then
		Player:SetAttribute("Admin", true)
		return true
	end
	return false
end


--When admin requests to send a message to everyone
function Server.SendMessage(Player, Message)
	if Player:GetAttribute("Admin") == true then --Ensure they are an admin
		
		local SendingMessage = Message
		for Hash, List in pairs(SendingMessage) do
			if List == "" then
				SendingMessage[Hash] = nil
			end
		end
		SendingMessage[1], SendingMessage[2], SendingMessage[3], SendingMessage[4], SendingMessage[5], SendingMessage[6], SendingMessage[7], SendingMessage[8]
			= SendingMessage[1] or "Alert" --Title
		, SendingMessage[2] or ""	   --Description
		, SendingMessage[3] or "Okay"  --Accept Button
		, SendingMessage[4] or "Close"	   --Decline Button
		, SendingMessage[5] or 5	   --Duration
		, SendingMessage[6] or nil	   --PlaceId
		, SendingMessage[7] or nil	   --ShowOnPlaceId
		, SendingMessage[8] or ""	   --Image 
		
		
		local publishSuccess, publishResult = pcall(function()
			MessagingService:PublishAsync(MESSAGING_TOPIC, SendingMessage)
		end)
	end

end
Postie.SetCallback("SendMessage", Server.SendMessage)
-- Network:Bind("SendMessage", Server.SendMessage)


-------Initiate only once
Players.PlayerAdded:Connect(function(player)
	
	--Sets player attribute if they are a admin
	Server.PlayerIsAdmin(player)

	-- Subscribe to the topic
	local subscribeSuccess, subscribeConnection = pcall(function()
		return MessagingService:SubscribeAsync(MESSAGING_TOPIC, function(message)
			if message == nil then return end
			if message.Data == nil then return end

			Postie.InvokeClient("ReceiveMessage", player, 5, message.Data)
			--Network:FireClient(player, "ReceiveMessage", message.Data)
		end)
	end)
	
	-- Unsubscribe from topic upon player ancestry change
	if subscribeSuccess then
		player.AncestryChanged:Connect(function()
			subscribeConnection:Disconnect()
		end)
	end

end)

return Server

