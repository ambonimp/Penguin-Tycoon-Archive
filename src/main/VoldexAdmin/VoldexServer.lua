local VoldexServer = {}

-- Import Services
local HttpService = game:GetService("HttpService")

-- Constants
local BASE_URL = "http://voldexgamesapi-env.eba-knsj9fir.us-east-2.elasticbeanstalk.com"
local AUTHORIZATION_HEADER = "04715122-fd02-430f-8e09-dec1b2411708"
local CONTENT_TYPE = "application/json"
local DEBOUNCE_TIME = 4

local debounce = {}


function VoldexServer.RedeemCode(player: Player, code: string, placeId: string)
	-- Get current place ID as default value
	if not placeId then
		placeId = game.PlaceId
	end

	-- Does a debouncer to avoid too many HTTP calls
	if debounce[player.UserId] then
		return {
			claimed =  false,
			message = "Too many attempts",
		}
	end
	debounce[player.UserId] = true

	-- Does the HTTP call to claim the code
    local success, response = pcall(function()
		local url = ("%s/code"):format(BASE_URL)
		local req = HttpService:RequestAsync({
			Url = url,
			Method = "POST",
			Headers = {
				["authorization"] = AUTHORIZATION_HEADER,
                ["Content-Type"] = CONTENT_TYPE,
			},
            Body = HttpService:JSONEncode({
                gameId = placeId,
                robloxId = player.UserId,
                robloxUsername = player.Name,
                code = code,
            }),
		})

		-- Get response as a lua table object
		local response = HttpService:JSONDecode(req.Body)
		return response
	end)

	-- In case this request fails, shows the error message
	if not success then
		warn("Something went wrong while trying to claim this code")
        warn(response)
        return {
			claimed =  false,
			message = "Something went wrong. Try again later!",
		}
	end

	-- Removes the debounce
	spawn(function()
		wait(DEBOUNCE_TIME)
		debounce[player.UserId] = false
	end)

	-- Returns the response as a lua table object
	return response
end

function VoldexServer.GetCodesFromGameId(gameId): table
	if not gameId then
		gameId = game.PlaceId
	end

	local success, codes = pcall(function()
		local url = ("%s/code/%d"):format(BASE_URL, gameId)
		local req = HttpService:RequestAsync({
			Url = url,
			Method = "GET",
			Headers = {
				["authorization"] = AUTHORIZATION_HEADER,
			},
		})

		-- Get response as a lua table object
		local response = HttpService:JSONDecode(req.Body)
		return response.codes
	end)

	if not success then
		warn("Something went wrong while trying to fetch codes for this game. Check API health!")
		return false
	end

	return codes
end

function VoldexServer.GetBannedPlayers(): table
	local success, bannedPlayers = pcall(function()
		local url = ("%s/banned/%d"):format(BASE_URL, game.PlaceId)
		local req = HttpService:RequestAsync({
			Url = url,
			Method = "GET",
			Headers = {
				["authorization"] = AUTHORIZATION_HEADER,
			},
		})

		-- Get response as a lua table object
		local response = HttpService:JSONDecode(req.Body)
		return response.players
	end)

	if not success then
		warn("Something went wrong while trying to fetch banned players. Check API health!")
		return false
	end

	return bannedPlayers
end

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
		warn("Something went wrong while trying to unban this player")
        warn(response)
        return false
	end

	return response
end

return VoldexServer
