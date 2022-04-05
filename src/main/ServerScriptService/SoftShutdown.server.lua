--[[
	This system lets you shut down servers without losing a lot of players.
	When game.OnClose is called, the script teleports everyone in the server
	into a reserved server.
	
	When the reserved servers start up, they wait a few seconds, and then
	send everyone back into the main place.
	
	I added task.wait() in a couple of places because if you don't, everyone will spawn into
	their own servers with only 1 player.
--]]

local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local Remote = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Shutdown")

if (game.VIPServerId ~= "" and game.VIPServerOwnerId == 0) then
	-- this is a reserved server without a VIP server owner
	local m = Instance.new("Message")
	m.Text = "Teleporting back in a moment!"
	m.Parent = workspace
	
	Remote:FireAllClients("Two")
	
	local waitTime = 5

	Players.PlayerAdded:connect(function(player)
		task.wait(waitTime)
		waitTime = waitTime / 2
		TeleportService:Teleport(game.PlaceId, player)
	end)
	
	for _,player in pairs(Players:GetPlayers()) do
		TeleportService:Teleport(game.PlaceId, player)
		task.wait(waitTime)
		waitTime = waitTime / 2
	end
else
	game:BindToClose(function()
		if (#Players:GetPlayers() == 0) then
			return
		end
		
		if (game.JobId == "") then
			-- Offline
			return
		end
		
		local One = "One"
		Remote:FireAllClients(One)
--		local m = Instance.new("Message")
--		m.Text = "Restarting Servers for an Update! Please wait patiently."
--		m.Parent = workspace
		task.wait(2)
		local reservedServerCode = TeleportService:ReserveServer(game.PlaceId)
		
		for _,player in pairs(Players:GetPlayers()) do
			TeleportService:TeleportToPrivateServer(game.PlaceId, reservedServerCode, { player })
		end
		Players.PlayerAdded:connect(function(player)
			TeleportService:TeleportToPrivateServer(game.PlaceId, reservedServerCode, { player })
		end)
		while (#Players:GetPlayers() > 0) do
			task.wait(1)
		end	
		
		-- done
	end)
end