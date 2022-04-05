--[[
Changelog:
    -Sessions are now paused for 30 seconds (SESSION_TIMEOUT_SEC) when player leaves the place before it's considered as permanent session termination.
     Useful for teleportation between subplaces and restoring sessions after crash or when player accidentally switch apps on phone and returns to Roblox front page instead of game
]]

local diveAPI = require(script.DiveAPI)
local Logger = require(script.Logger)
local DiveConfig = require(script.DiveConfig)
local settings = require(script.Settings)
local Utils = require(script.Utilities)
local LaunchBody = require(script.LaunchBody)
local EventBody = require(script.EventBody)
local EventHeader = require(script.EventHeader)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--local Postie = require(ReplicatedStorage.Postie) -- Postie is legacy and outdated library...
local HTTP = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local LS = game:GetService("LocalizationService")

local GetDeviceTypeFunction = Instance.new("RemoteFunction")
GetDeviceTypeFunction.Name = "GetDeviceTypeFunction"
GetDeviceTypeFunction.Parent = ReplicatedStorage

local AppBackgroundEvent = Instance.new("RemoteEvent")
AppBackgroundEvent.Name = "AppBackgroundEvent"
AppBackgroundEvent.Parent = ReplicatedStorage

local AppForegroundEvent = Instance.new("RemoteEvent")
AppForegroundEvent.Name = "AppForegroundEvent"
AppForegroundEvent.Parent = ReplicatedStorage

local diveSDK = {
    customHeaders = {}
}
--[[
    Init SDK on Server
]]--
function diveSDK:initServer(config)

	self.onReleaseCallbacks = {}

    if not DiveConfig:isConfigValid(config) then
        Logger:e("Init failed")
        return
    end

    -- Set Dive Config
    self:setDiveConfig(config)

    -- Set Authorizer
    diveAPI:setAuthorizer(config.hashKey);

    -- Get Server Settings
    diveAPI:getServerSettings()

    -- Load Previously Saved SDK settings
    if self.config.serverURL ~= settings.ANALYTICS_URL and not Utils:isStringNullOrEmpty(settings.ANALYTICS_URL) then self.config.serverURL = settings.ANALYTICS_URL end

    AppBackgroundEvent.OnServerEvent:Connect(function(player)
        self:onAppBackground(player)
    end)

    AppForegroundEvent.OnServerEvent:Connect(function(player)
        self:onAppForeground(player)
    end)

    self.sdkInitialized = true;
end

function diveSDK:setDiveConfig(config)
    settings.config = config;
    self.config = config
end

--[[
    Functions for Users
]]--
function diveSDK:isPlayerInitialized(player)
    if not self.sdkInitialized then
        return false
    end

    local playerData = settings:getPlayerDataFromCache(player.UserId)
    return playerData and playerData.appLaunched or false
end

function diveSDK:initClient(player)
    if not self.sdkInitialized then 
        Logger:e("Server SDK is not initialized. Cannot start sdk for User. Call DiveSDK:initServer(config)")
        return
    end

    local playerData = settings:getPlayerData(player)
    
    if playerData.isTrackingStopped then
        Logger:w("Event Tracking was disabled via setOptOut(player, true) for User." .. player.UserId .. ". No events will be sent until setOptOut(player, false) is called.");
        return
    end

    if Utils:isStringNullOrEmpty(settings.config.appToken or Utils:isStringNullOrEmpty(settings.config.hashKey) or Utils:isStringNullOrEmpty(settings.config.serverURL)) then
        Logger:e("DiveConfig parameter is missing. Please check if the AppToken, HashKey and ServerURL are configured properly");
        return;
    end

	local isSuccess, device = pcall(function()
        return GetDeviceTypeFunction:InvokeClient(player, 10)
    end)

	if isSuccess then
		playerData.device = device
        playerData.device.offset = DateTime.now().UnixTimestamp - playerData.device.timestamp 
	end

    local country
    pcall(function()
        country = LS:GetCountryRegionForPlayerAsync(player)
    end)
    playerData.country = country

    if not playerData.sdkStarted then
        diveSDK:recordEvent(player, "sdkStarted", LaunchBody:new(player))
        playerData.sdkStarted = true;
    end

    Logger:d("DiveSDK is started for User " .. player.UserId)
    if settings.BEACON_ENABLED then
        self:startBeaconSession(player)
    end
end

function diveSDK:launch(player, body)
    local playerData = settings:getPlayerDataFromCache(player.UserId);
    if not playerData.sdkStarted then
        Logger:e("DiveSDK was not started for a User: " .. player.UserId)
    end

    playerData.sessionStartedAt = os.clock()

    if playerData.appLaunched then
        return
    end

    diveSDK:recordEvent(player, "appLaunched", LaunchBody:new(player, body))
    playerData.appLaunched = true
end

function diveSDK:startBeaconSession(player)
    local playerData = settings:getPlayerDataFromCache(player.UserId)
    if not playerData.beacon then
        playerData.beacon = settings:newBeacon(player, self)
    end

    playerData.beacon:start()
    Logger:d("Starting beacon session: " .. player.UserId)
end

function diveSDK:stopBeaconSession(player)
    local playerData = settings:getPlayerDataFromCache(player.UserId)
    if playerData.beacon then
        playerData.beacon:stop()
        Logger:d("Stopped beacon session: " .. player.UserId)
    end
end

function diveSDK:screenViewed(player, screenName)
    if not self.sdkInitialized then return end -- Block event if SDK is not initialized on server
    local playerData = settings:getPlayerDataFromCache(player.UserId);
    if not playerData.appLaunched then return end -- Block event if user hasn't started SDK
    local checkpoint = playerData:endCheckpoint("dive_screen_track")
    local body = EventBody:new({
            screen = screenName,
            screen_before = "",
            screen_before_milliseconds = 0
        })
    if playerData.screenBefore ~= nil then
        body:addParam("screen_before", playerData.screenBefore)
    end

    if checkpoint ~= nil and checkpoint.total_milliseconds ~= nil then 
        body:addParam("screen_before_milliseconds", checkpoint.total_milliseconds or 0)
    end
    playerData.screenBefore = screenName
    self:recordEvent(player, "screenViewed", body)
    playerData:startCheckpoint("dive_screen_track")
end

function diveSDK:onAppForeground(player)
    if not self.sdkInitialized then return end -- Block event if SDK is not initialized on server
    local playerData = settings:getPlayerDataFromCache(player.UserId)
    if not playerData then return end
    if not playerData.appLaunched then return end -- Block event if user hasn't started SDK
    playerData.backgrounded = false
    if playerData.checkpoints ~= nil and playerData.checkpoints["dive_background_checkpoin"] ~= nil then 
        local checkpoint = playerData:endCheckpoint("dive_background_checkpoin")
        local totalSeconds = tonumber(string.format("%.2f",checkpoint.total_milliseconds / 1000)) 

        -- Reset session for user if there is a session time and it has expired
        if settings.SESSION_LIFETIME_SEC ~= 0 and totalSeconds > settings.SESSION_LIFETIME_SEC then
            playerData.restartedLocalSessionId = playerData.localSessionId
            playerData.localSessionId = HTTP:GenerateGUID(false)
            self:recordEvent(player, "appResumed", {
                total_seconds = totalSeconds
            })
        end
        self:recordEvent(player, "appForeground", {
            id = checkpoint.id,
            total_seconds = totalSeconds
        })
        for _,c in pairs(playerData.checkpoints) do
            if not c.runOnBackground then
                c.timestamp = c.timestamp + checkpoint.total_milliseconds
            end
        end
    end
end

function diveSDK:onAppBackground(player)
    if not self.sdkInitialized then return end -- Block event if SDK is not initialized on server
    local playerData = settings:getPlayerDataFromCache(player.UserId)
    if not playerData then return end
    if not playerData.appLaunched then return end -- Block event if user hasn't started SDK
    playerData.backgrounded = true
    local checkpoint = playerData:startCheckpoint("dive_background_checkpoin")
    self:recordEvent(player, "appBackground", {
        id = checkpoint.id
    })
end

function diveSDK:recordEvent(player, eventName, eventBody, extraHeaders)
    Logger:d("Post Event " .. eventName)
    local playerData = settings:getPlayerDataFromCache(player.UserId);
	if playerData.isTrackingStopped then
        Logger:w("Player " .. player.UserId .." Tracking Has been stopped. No events can be sent")
        return
    end
	local body = EventHeader:new(player, eventName, eventBody, extraHeaders);
    diveAPI:addEvent(body)
end

function diveSDK:recordError(player, code, desciption) 
    self:recordEvent(player, "errorCreated", EventBody:new({
        code = code,
        desciption = desciption
    }))
end

function diveSDK:setOptOut(player, isTrackingStopped)
    local playerData = settings:getPlayerDataFromCache(player.UserId);
    if playerData.isTrackingStopped and isTrackingStopped then
        Logger:d("Player tracking is already stopped for User: " .. player.UserId)
        return
    end

    playerData.isTrackingStopped = isTrackingStopped;
    if isTrackingStopped then
        Logger:d("Player tracking is stopped for User: " .. player.UserId)
        self:stopTracking(player)
        settings:savePlayerData(player)
        self:stopClient(player);
    else
        Logger:d("Opt In - SDK Event Tracking will resume in next player session.")
        settings:savePlayerData(player)
    end
end

function diveSDK:onClientRelease(onReleaseCallback:(player,playerData) -> nil, params)
	-- table.insert(self.onReleaseCallbacks,onReleaseCallback)
	table.insert(self.onReleaseCallbacks,
		{
			callback = onReleaseCallback,
			params
		}
	)
end

function diveSDK:stopClient(player)
    Logger:d("Stopping SDK for User: " .. player.UserId)
    local playerData = settings:getPlayerDataFromCache(player.UserId)
    if not playerData or playerData.leaving then
        return
	end
	
	for _, clk in pairs(self.onReleaseCallbacks) do
		clk(player,playerData)
	end

    playerData.leaving = true

    local sessionLength = os.clock() - playerData.sessionStartedAt
    playerData.sessionLength += sessionLength

    self:recordEvent(player, "playerLeft", {
        sessionLength = sessionLength,
        totalSessionLength = playerData.sessionLength
    })

	if settings.SESSION_TIMEOUT_SEC then
        self:stopBeaconSession(player)
        settings:savePlayerData(player)

		playerData.sdkStarted = false
		task.wait(settings.SESSION_TIMEOUT_SEC)

        if playerData.sdkStarted then
            playerData.leaving = false
			Logger:d("Player resumed in time, session restored: " .. player.UserId)
            return -- Player was added again in timeout
        end
    end

    playerData.sdkStarted = false
	playerData.appLaunched = false
    settings:removePlayerData(player)
	Logger:d("Stopped SDK for User: " .. player.UserId)
end

function diveSDK:stopTracking(player)
    self:recordEvent(player, "trackingStopped", LaunchBody:new(player))
end

function diveSDK:setCustomHeaderParam(name, value, player)  
    if player ~= nil then
        local playerData = settings:getPlayerDataFromCache(player.UserId);
        if playerData ~= nil then
            if type(value) ~= "table"  then
                Logger:d("Set Custom Header for user " .. player.UserId .. " -> " .. name .. " : " .. tostring(value))
            else
                Logger:d("Set Custom Header for user " .. player.UserId .. " -> " .. name )
            end
            playerData.customHeaders = playerData.customHeaders or {}
            playerData.customHeaders[name] = value
        else
            Logger:e("NO PLAYER DATA FOR PLAYER" .. player.UserId .. name );
        end
    else 
        if type(value) ~= "table"  then
            Logger:d("Set Custom Header for all events -> " .. name .. " : " .. tostring(value))
        else
            Logger:d("Set Custom Header for all events -> " .. name)
        end
        settings.customHeaders[name] = value
    end
end

function diveSDK:getRemoteConfig(player, success, fail)

    diveAPI:getRemoteConfig(player.UserId,
        function(remoteConfig)
            self:setCustomHeaderParam('config_version', remoteConfig['config_version'], player);
            self:setCustomHeaderParam('metadata_experiments', remoteConfig['metadata_experiments'], player);
            success(remoteConfig);
        end,
        function(error)
            fail(error)
        end
    )

end

function diveSDK:setPlayerId(player, value)
    Logger:d("Set Player Id to: " .. value)
    local playerData = settings:getPlayerDataFromCache(player.UserId);
    playerData.playerId = value
end

function diveSDK:setPlayerXp(player, value)
    Logger:d("Set Player Xp to: " .. value)
    local playerData = settings:getPlayerDataFromCache(player.UserId);
    playerData.playerXp = value
end


function diveSDK:setPlayerLevel(player, value)
    Logger:d("Set Player Level to: " .. value)
    local playerData = settings:getPlayerDataFromCache(player.UserId);
    playerData.playerLevel = value
end

function diveSDK:setGameVersion(value)
    Logger:d("Set Game Version to: " .. value)
    settings.gameVersion = value;
end

function diveSDK:setServerSessionId(value, player)
    if player ~= nil then
        local playerData = settings:getPlayerDataFromCache(player.UserId);
        if not self.sessionRestored then
            playerData.serverSessionId = value
            Logger:d("Set Player's Server Session Id to: " .. value)
        else
            Logger:d("Using Previous Server Session Id: " .. playerData.serverSessionId)
        end
    else
        settings.serverSessionId = value
        Logger:d("Set Server Session Id to: " .. value)
    end
end

function diveSDK:setDiveCid(value)
    Logger:d("Set Dive CID to: " .. value)
    self.customHeaders["dive_cid"] = value
end

function diveSDK:getDeviceId(player)
    local playerData = settings:getPlayerDataFromCache(player.UserId)
    if playerData ~= nil then
        return playerData.deviceId
    end
end

return diveSDK