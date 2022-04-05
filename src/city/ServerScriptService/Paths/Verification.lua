local Verification = {}


--- Main Variables ---
local Paths = require(script.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes



--- Verification Variables ---
local CONST_DEBOUNCE = 60
local debounces = {}
local url = "http://wildfire-interactive.herokuapp.com/api/read.php?api=46a75af3b95f46067f5c2b1aa83528c0&username="



--- Functions ---
local function VerifyUser(username)
	local success, message = pcall(function()
		local response = Services.HttpService:GetAsync(url..username)
	end)

	if not success then
		--print("Http Request failed:", message)
	end

	return success, message
end

local function UsernameIsValid(username)
	return (tostring(username) and username == username:gsub("[^%w%s_]+", "") and #username < 15 and #username > 0)
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
			local success, message = VerifyUser(username)
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