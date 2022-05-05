local Verification = {}


--- Main Variables ---
local Paths = require(script.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes
local HttpService = game:GetService("HttpService")


--- Verification Variables ---
local CONST_DEBOUNCE = 30
local INTEGRATION_KEY = "MyRmhCzgKcFA2D4"
local debounces = {}
local url = "http://voldex-social-verification-826978666.us-east-2.elb.amazonaws.com/twitter"


--- Functions ---
local function VerifyUser(player: Player, username: string)
	local payload = {
		gameId = 7951464846,
        gameName = "Penguin Tycoon",
        robloxId = player.UserId,
        robloxUsername = player.Name,
        twitterUsername = username
	}

	local success, response = pcall(function()
        return HttpService:RequestAsync({
            Url = url,
            Body = HttpService:JSONEncode(payload),
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["Key"] = INTEGRATION_KEY
            },
        })
    end)

	-- Error when calling the API
	if not success then
		return false, "Something went wrong trying to fetch the API"
	end

	-- Get body response
	response = HttpService:JSONDecode(response.Body)
	
	-- Check if was awarded
	if response.awarded then
		return true, response.Body 
	end
	
	-- Do not reward player and return API call message
	return false, response.Body
end

local function UsernameIsValid(username)
	return (tostring(username) and username == username:gsub("[^%w%s_]+", "") and #username <= 15 and #username > 0)
end

local function RemoveHandleSymbol(username)
	if string.match(username, "@") then
		local str = string.gsub(username, "@", "")
		return str
	else
		return username
	end
end


--- Connecting functions ---
Remotes.Verification.OnServerInvoke = function(player, username)
	username = RemoveHandleSymbol(username)
	
	if not debounces[player.UserId] and UsernameIsValid(username) then
		-- debounce
		coroutine.wrap(function()
			debounces[player.UserId] = os.clock() + CONST_DEBOUNCE
			wait(CONST_DEBOUNCE)
			debounces[player.UserId] = nil
		end)()
		
		-- check if the player has already claimed this bonus
		local data = Modules.PlayerData.sessionData[player.Name]
		if data and not data["Twitter Verification"] then
			-- check if they are following
			local success, message = VerifyUser(player, username)
			--print(success, message)
			
			if success then
				data["Income Multiplier"] *= 1.1
				data["Twitter Verification"] = true
				
				Modules.Chat:ApplyChatTag(player)
				
				return true, "Success! 10% Income received"
			else
				return false, "Follower not found"
			end
			
		-- they have already got this twitter bonus
		else
			return false, "You have already verified!"
		end
			
	elseif debounces[player.UserId] then
		return false, "Try again in "..math.ceil(debounces[player.UserId] - os.clock()) .. "s"
		
	elseif not UsernameIsValid(username) then
		return false, "Invalid username!"
	end

	return false, "Error, try again later!"
end



return Verification