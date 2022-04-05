local VoldexServer = {}

-- Import Services
local HttpService = game:GetService("HttpService")

-- Constants
local BASE_URL = "http://voldexgamesapi-env.eba-knsj9fir.us-east-2.elasticbeanstalk.com"
local AUTHORIZATION_HEADER = "04715122-fd02-430f-8e09-dec1b2411708"
local CONTENT_TYPE = "application/json"

function VoldexServer.IsPlayerBanned(player: Player): boolean
    local success, isBanned = pcall(function()
		local url = ("%s/banned/%d/%s"):format(BASE_URL, game.PlaceId, player.UserId)
		local req = HttpService:RequestAsync({
			Url = url,
			Method = "GET",
			Headers = {
				["authorization"] = AUTHORIZATION_HEADER,
			},
		})

		-- Get response as a lua table object
		local response = HttpService:JSONDecode(req.Body)
		return response.isBanned
	end)

	if not success then
		warn("Something went wrong while trying to check if player is banned. Check API health!")
		return false
	end

	return isBanned
end

function VoldexServer.BanPlayer(moderator: Player, player: Player, reason: string)
    local success, response = pcall(function()
		local url = ("%s/banned"):format(BASE_URL)
		local req = HttpService:RequestAsync({
			Url = url,
			Method = "POST",
			Headers = {
				["authorization"] = AUTHORIZATION_HEADER,
                ["Content-Type"] = CONTENT_TYPE,
			},
            Body = HttpService:JSONEncode({
                gameId = game.PlaceId,
                robloxId = player.UserId,
                robloxUsername = player.Name,
                modId = moderator.UserId,
                modUsername = moderator.Name,
                reason = reason,
            }),
		})

		-- Get response as a lua table object
		local response = HttpService:JSONDecode(req.Body)
		return response
	end)

	if not success then
		warn("Something went wrong while trying to ban this player")
        warn(response)
        return false
	end

	return response
end

function VoldexServer.UnbanPlayer(player: Player, reason: string)
    local success, response = pcall(function()
		local url = ("%s/banned/unban"):format(BASE_URL)
		local req = HttpService:RequestAsync({
			Url = url,
			Method = "POST",
			Headers = {
				["authorization"] = AUTHORIZATION_HEADER,
                ["Content-Type"] = CONTENT_TYPE,
			},
            Body = HttpService:JSONEncode({
                gameId = game.PlaceId,
                robloxId = player.UserId,
                robloxUsername = player.Name,
            }),
		})

		-- Get response as a lua table object
		local response = HttpService:JSONDecode(req.Body)
		return response
	end)

	if not success then
		warn("Something went wrong while trying to ban this player")
        warn(response)
        return false
	end

	return response
end

return VoldexServer
