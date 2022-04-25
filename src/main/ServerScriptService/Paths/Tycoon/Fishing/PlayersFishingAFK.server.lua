-- Simple script that checks how many players are AFK fishing across the servers

-- Services
local Players = game:GetService("Players")
local MessagingService = game:GetService("MessagingService")

-- Constants
local MESSAGING_TOPIC = "AFKFishingEvent"
local ROUTINE_INTERVAL = 5
local GROUP_ID = 12843903
local GROUP_RANK = 240

-- Members
local servers = {}

local remoteFunction = Instance.new("RemoteFunction")
remoteFunction.Name = "CountPlayersFishingAFK"
remoteFunction.Parent = game:GetService("ReplicatedStorage").Remotes

-- Listener to receive messages from others servers with the players AFK count
local subscribeSuccess, subscribeConnection = pcall(function()
	return MessagingService:SubscribeAsync(MESSAGING_TOPIC, function(message)
		servers[message.Data.jobId] = message.Data.count
	end)
end)

-- Server function to check how many players are online fishing right now and notify other servers
local function checkPlayersFishingInServer()
	local count = 0

	-- Count how many players are fishing on this server
	for _, player in pairs(Players:GetPlayers()) do
		local isFishing = player:GetAttribute("isAFKFishing")
		count = isFishing and count + 1 or count
	end

	-- Send a message across all servers with how many players are fishing on this server
	local publishSuccess, publishResult = pcall(function()
		local message = count
		MessagingService:PublishAsync(MESSAGING_TOPIC, {
			count = count,
			jobId = game.JobId,
		})
	end)
	if not publishSuccess then
		warn(publishResult)
	end
end

remoteFunction.OnServerInvoke = function(player)
	if player:GetRankInGroup(GROUP_ID) >= GROUP_RANK then
		-- Start checking
		checkPlayersFishingInServer()

		print("Processing how many players are AFK fishing (Wait a few seconds) ...")

		-- Waiting interval
		wait(ROUTINE_INTERVAL)

		-- Do the count with data from all servers
		local total = 0
		for _, server in pairs(servers) do
			total = total + server
		end

		-- Shows in server console output how many concurrent players are fishing
		print("Players AFK fishing: " .. total)
	end
end
