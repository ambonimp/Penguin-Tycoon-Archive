local RunService = game:GetService("RunService")
local settings = require(script.Parent.Settings)
local Authorizer = require(script.Authorizer)
local Logger = require(script.Parent.Logger)
local thread = require(script.Parent.Threading)
local RemoteConfig = require(script.Parent.RemoteConfigResponse)

local diveAPI = {}

local eventsPath = "events"
local EventsQueue = {}

local HTTP = game:GetService("HttpService")

function diveAPI:setAuthorizer(salt) 
	Authorizer:setSalt(salt)
end

function diveAPI:buildRequest(method, body)
	
	local request =  {}

	request.Url = settings.ANALYTICS_URL .. "/" .. eventsPath
	request.Method = method
	request.Headers = {
		["Content-Type"] = "application/json",
		["Authorization"] = "Bearer " .. settings.config.appToken,
	}
	body = body or {}
	local requestBody
	Logger:d(body)
	pcall(function()
		requestBody = HTTP:JSONEncode(body)
	end)

	if requestBody ~= nil then
		request.Body = requestBody
	else 
		Logger:e("Error Encoding request body to JSON")
		return
	end

	request.Headers["dive-digest"] = Authorizer:buildToken(request.Body)

	return request
end

local function send(request, retires, sleep)
	local response = {}
	for i=1, retires or settings.RETRIES_AMOUNT do

		local success, error = pcall(function()
			response = HTTP:RequestAsync(request)
		end)

		if success then
			local responseBody
			-- Logger:d("Response code: " .. response.StatusCode ..", message: " .. response.StatusMessage)
			pcall(function()
				responseBody = HTTP:JSONDecode(response.Body)
			end)

			if responseBody ~= nil then
				return responseBody
			end
			return
		else
			Logger:w("The request failed:", response.StatusCode, response.StatusMessage)
			Logger:w(error)
		end

		task.wait(sleep or settings.RETRIES_SLEEP)
	end
end

local function getEventsQueue()
	if #EventsQueue <= settings.FLUSH_COUNT then
		local eventsQueue = EventsQueue
		EventsQueue = {}
		return eventsQueue
	else
		local eventsQueue = table.create(settings.FLUSH_COUNT)
		for i = 1, settings.FLUSH_COUNT do
			eventsQueue[i] = EventsQueue[i]
		end

		-- Shift everything down and overwrite old events
		local eventCount = #EventsQueue
		for i = 1, math.min(settings.FLUSH_COUNT, eventCount) do
			EventsQueue[i] = EventsQueue[i + settings.FLUSH_COUNT]
		end

		-- Clear additional events
		for i = settings.FLUSH_COUNT + 1, eventCount do
			EventsQueue[i] = nil
		end

		return eventsQueue
	end
end

local function sendEventsAsArray() 
	local eventsQueue = getEventsQueue()
	if #eventsQueue > 0 then
		local request = diveAPI:buildRequest("POST", eventsQueue)
		send(request)
	end
end

local function processEvents()
	sendEventsAsArray()
	thread:scheduleTimer(settings.FLUSH_FREQUENCY, processEvents)
end

function diveAPI:addEvent(event)
	if #EventsQueue >= settings.FLUSH_COUNT then
		sendEventsAsArray()
	end
	EventsQueue[#EventsQueue+1] = event
end

function diveAPI:getServerSettings()
	local request =  {}
	request.Url = settings.SETTINGS_URL .. "/" .. settings.config.appToken .. ".json"
	request.Method = "GET"
	request.Headers = {
		["Content-Type"] = "application/json",
	}

	local response = send(request)
	
	if response ~= nil then
		local platfrom
		if response["roblox"] ~= nil then 
			platfrom = response["roblox"]
		elseif response['default'] ~= nil then
			Logger:d("Remote settings for platform [roblox] not found. Using [default]")
			platfrom = response["default"]
		end

		if platfrom ~= nil then
			settings.BEACON_FREQ = platfrom["beacon_freq_sec"] or settings.BEACON_FREQ
			settings.BEACON_ENABLED = platfrom["is_beacon_enabled"] or settings.BEACON_ENABLED
			settings.SDK_ENABLED = platfrom["is_sdk_enabled"] or settings.SDK_ENABLED
			settings.RETRIES_AMOUNT = platfrom["retries_no"] or settings.RETRIES_AMOUNT
			settings.RETRIES_SLEEP = platfrom["retries_sleep_sec"] or settings.RETRIES_SLEEP
			settings.ANALYTICS_URL = platfrom["tracking_url"] or settings.ANALYTICS_URL
			settings.API_URL = platfrom["api_url"] or settings.API_URL
			settings.FLUSH_COUNT = platfrom["flush_count"] or settings.FLUSH_COUNT
			settings.FLUSH_FREQUENCY = platfrom["flush_frequency"] or settings.FLUSH_FREQUENCY
			settings.SESSION_LIFETIME_SEC = platfrom["session_lifetime_sec"] or settings.SESSION_LIFETIME_SEC

			settings.config.API_URL = platfrom["api_url"] or settings.config.API_URL
		else
			Logger:w("Server Settings Corrupted or Does not have settings for [default] and [roblox] platforms")
		end
	else
		Logger:w("Could not load Server Settings")
	end
end

function diveAPI:getRemoteConfig(playerId, success, fail)
	local request = {}
	if(settings.config.API_URL == nil or settings.config.API_URL == "")then
		fail("RemoteConfig: ApiUrl is empty")
		return
	end
	if(playerId == nil or playerId == "")then
		fail("RemoteConfig: playerId is empty")
		return
	end

	Logger:d("Remote config url: "..settings.config.API_URL .. "/remoteConfig/player?api_key=" .. settings.config.appToken .. "&player_id=" .. playerId)

	request.Url = settings.config.API_URL .. "/remoteConfig/player?api_key=" .. settings.config.appToken .. "&player_id=" .. playerId

	request.Method = "GET"
	request.Headers = {
		["Content-Type"] = "application/json",
	}
	local response = send(request, 3, 0.1)
	local playerData = settings:getPlayerDataFromCache(playerId);

	if playerData ~= nil and response ~= nil then
		playerData:setRemoteConfig(RemoteConfig:new(response))
		success(playerData.remoteConfig)
		return
	else
		Logger:w("RemoteConfig: Failed To Fetch")
	end
	
	if playerData ~= nil and playerData.remoteConfig ~= nil then
		Logger:w("Using Cached Remote Config")
		success(playerData.remoteConfig)
	else
		fail("RemoteConfig: Failed to fetch Remote Config & No Cached Remote Config")
	end
end

processEvents()

game:BindToClose(function()
	Logger:d("Server is being shutdown. Waiting for all API responses")

	-- Number of attempts before shutting down to not hold process forever
	local retries = 0

	-- Check if there are any events in queue
	while (#EventsQueue > 0) do
		-- In case this routine reaches the max number of attempts
		if retries > 15 then
			break
		end        

		-- Increments the number of attempts
		retries = retries + 1

		Logger:d(("Retrying [%d]... "):format(retries))
		wait(1)    
	end


	Logger:d("All events were registered. Shutting down")
end)

return diveAPI
