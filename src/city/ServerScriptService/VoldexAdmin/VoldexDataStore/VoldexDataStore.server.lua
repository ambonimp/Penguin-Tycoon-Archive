local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local LocalizationService = game:GetService("LocalizationService")
local Postie = require(game.ReplicatedStorage.VoldexAdmin.Libs.Postie)
local ServerStorage = game:GetService("ServerStorage")

local voldexStore = DataStoreService:GetDataStore("VoldexStore")

local playersData = {}
local diveSDK = nil

local function getLanguage()
	return LocalizationService.RobloxLocaleId
end

if ServerStorage:FindFirstChild("DiveSDK", true) then
	diveSDK = require(ServerStorage:FindFirstChild("DiveSDK", true))
end

-- Add event for new players
Players.PlayerAdded:Connect(function(player)
	local playerData = voldexStore:GetAsync(player.UserId)

	-- Initializes data for the first time
	if not playerData then
		playerData = {
			totalPlaytime = 0,
			sessions = {},
		}
	end

	local joinData = player:GetJoinData()
	local placeId = joinData.SourcePlaceId

	if not placeId then
		playerData.lastSessionId = tick()
		table.insert(playerData.sessions, {})
	end

	playersData[player.UserId] = {
		sessionStart = tick(),
		totalPlaytime = playerData.totalPlaytime,
		sessions = playerData.sessions,
		device = "Unknown",
		lastSessionId = playerData.lastSessionId,
	}

	-- Tries to get player's device in a protected call
	pcall(function()
		local success, device = Postie.InvokeClient("GetPlayerDevice", player, 15)
		if success then
			playersData[player.UserId].device = device
		end
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	local success, errorMessage = pcall(function()
		local sessionOpen = playersData[player.UserId].sessionStart
		local sessionClose = tick()
		local addToPlaytime = sessionClose - sessionOpen

		local totalPlaytime = playersData[player.UserId].totalPlaytime + addToPlaytime

		local session = {
			open = playersData[player.UserId].sessionStart,
			closed = tick(),
			placeId = game.PlaceId,
			language = getLanguage(),
			device = playersData[player.UserId].device,
		}
		local sessions = playersData[player.UserId].sessions
		table.insert(sessions[#sessions], session)

		local sessionsQuantity = #sessions
		if not sessionsQuantity or sessionsQuantity <= 1 then
			sessionsQuantity = 1
		end

		local averagePlaytime = totalPlaytime / sessionsQuantity

		local payload = {
			sessions = playersData[player.UserId].sessions,
			totalPlaytime = totalPlaytime,
			averagePlaytime = averagePlaytime,
			lastSessionId = playersData[player.UserId].lastSessionId,
		}
		voldexStore:SetAsync(player.UserId, payload)
		
		if diveSDK then
			pcall(function()
				payload.placeId = game.PlaceId
				diveSDK:recordEvent(player, "gameSessionEnded", payload)
			end)
		end
	end)
	if not success then
		print(errorMessage)
	end
end)
