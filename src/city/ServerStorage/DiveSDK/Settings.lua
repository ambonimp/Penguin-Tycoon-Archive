local RunService = game:GetService("RunService")
local HTTP = game:GetService("HttpService")
local DS = game:GetService("DataStoreService")
local Logger = require(script.Parent.Logger)
local SyncedTime = require(script.Parent.SyncedTime)

local DisableStore = false -- RunService:IsStudio()

local settings = {
    PlayerDS = DisableStore and {} or DS:GetDataStore("Dive_PlayerDS_1.0.0"),
    PlayerCache = {},
    DataToSave = {
		"isTrackingStopped",
        "remoteConfig"
	},

    customHeaders = {},
    config = {},
    millesecondsElapsed = 0,

    SDK_VERSION = "1.5",
    SDK_NAME = "Roblox Dive SDK",
    TIMESTAMP_FORMAT = "YYYY-MM-DDTHH:mm:ssZ",
    DATE_FORMAT = "YYYY-MM-DD",
    SDK_ENABLED = true,
    BEACON_ENABLED = true,
    BEACON_FREQ = 60,
    RETRIES_AMOUNT = 3,
    RETRIES_SLEEP = 10,
    ANALYTICS_URL = "http://analytics.test.dive.games/game1",
    API_URL = "https://apitest.dive.games",
    SETTINGS_URL = "https://public.dive.games/sdk",
    FLUSH_COUNT = 500,
    FLUSH_FREQUENCY = 1,
    SESSION_LIFETIME_SEC = 0,
    SESSION_TIMEOUT_SEC = 30 -- Time for teleport or return back after quitting the game
}

RunService.Heartbeat:Connect(function(t)
    settings.millesecondsElapsed = settings.millesecondsElapsed + t * 1000
end)

-- BEACON
local Beacon = {}
Beacon.__index = Beacon
function Beacon.new(player, sdk)
    local self = setmetatable({
        player = player,
        sdk = sdk
    }, Beacon)

    return self
end

function Beacon:start()
    local elapsed = settings.BEACON_FREQ
    self:stop()

    self.connection = RunService.Heartbeat:Connect(function(deltaTime)
        elapsed += deltaTime
        if not self.connection then
            return
        end

        if elapsed < settings.BEACON_FREQ then
            return
        end

        elapsed -= settings.BEACON_FREQ

        local playerData = settings:getPlayerDataFromCache(self.player.UserId)
        if not playerData then
            return
        end
        
        if playerData.sdkStarted and not playerData.isTrackingStopped then
            if(not playerData.backgrounded)then
                self.sdk:recordEvent(self.player, "beacon")
            end
        end
    end)
end

function Beacon:stop()
    if self.connection then
        self.connection:Disconnect()
        self.connection = nil
    end
end

-- PLAYER DATA - TODO: Move to own module script

local PlayerData = {}
PlayerData.__index = PlayerData

function PlayerData.new(playerData)
    local self = setmetatable(playerData, PlayerData)

    return self
end

function PlayerData:setRemoteConfig(config)
    self.remoteConfig = config;
end

function PlayerData:startCheckpoint(name, runOnBackground)
    self.checkpoints = self.checkpoints or {}
    local id = HTTP:GenerateGUID(false)
    self.checkpoints[name] = {
        id = id,
        name = name,
        timestamp = settings.millesecondsElapsed,
        runOnBackground = runOnBackground
    }
    return {
        name = name,
        id = id
    }
end

function PlayerData:endCheckpoint(name)
    self.checkpoints = self.checkpoints or {}
    local checkpoint = self.checkpoints[name] or nil
    if checkpoint ~= nil then
        local totalMilliseconds = settings:getMillisecondsElapsedSince(checkpoint.timestamp)
        local id = checkpoint.id
        self.checkpoints[name] = nil
        return {
            name = name,
            id = id,
            total_milliseconds = totalMilliseconds
        }
    end
end

function PlayerData:startSession()
    if self:resumeSession() then
        return
    end

    if self.sdkStarted then
        self:resetSession()
    else
        self.localSessionId = HTTP:GenerateGUID(false)
        self.sessionLength = 0
    end

    if self.deviceId == nil then
        self.deviceId = HTTP:GenerateGUID(false)
    end
end

function PlayerData:resumeSession()
    if not settings.SESSION_TIMEOUT_SEC or not self.sessionPausedAt then
        --warn("self.sessionPausedAt", self.sessionPausedAt)
        return false
    end

    local now = SyncedTime.time()
    local elapsed = now - self.sessionPausedAt
    if elapsed > settings.SESSION_TIMEOUT_SEC then
        Logger:d(string.format("Session timeout expired: %s | %s > %d", self.serverSessionId or "", self.localSessionId or "", elapsed))
        self.serverSessionId = nil
        self.restartedLocalSessionId = nil
        self.localSessionId = nil
        self.sessionPausedAt = nil
        self.sessionLength = 0
        return false
    end

    self.sdkStarted = true
    self.appLaunched = true
    self.sessionRestored = true
    Logger:d(string.format("Session was resumed successfully: %s | %s", self.serverSessionId, self.localSessionId))
    return true
end

function PlayerData:resetSession()
    if self.beacon then
        self.beacon:stop()
    end

    self.restartedLocalSessionId = self.localSessionId
    self.playerXp = nil
    self.playerLevel = nil
    self.localSessionId = HTTP:GenerateGUID(false)
    self.sessionLength = 0
    self.checkpoints = {}
    self.customHeaders = {}
    self.sdkStarted = false
    self.appLaunched = false
end

-- SETTINGS

function settings:getPlayerDataFromCache(userId)
    local playerData = settings.PlayerCache[tonumber(userId)]
    if playerData then
        return playerData
    end
    playerData = settings.PlayerCache[tostring(userId)]
    return playerData
end

function settings:savePlayerData(player)
    --Variables
    local playerData = settings:getPlayerDataFromCache(player.UserId)
    local savePlayerData = {}

    if not playerData then
        return
    end

    --Fill
    for _, key in pairs(settings.DataToSave) do
        savePlayerData[key] = playerData[key]
    end

    if settings.SESSION_TIMEOUT_SEC then
        savePlayerData.serverSessionId = playerData.serverSessionId
        savePlayerData.restartedLocalSessionId = playerData.restartedLocalSessionId
        savePlayerData.localSessionId = playerData.localSessionId
        savePlayerData.deviceId = playerData.deviceId
        savePlayerData.sessionPausedAt = SyncedTime.time()
        savePlayerData.sessionLength = playerData.sessionLength
        
        Logger:d(string.format("Session paused before quitting: %s | %s", savePlayerData.serverSessionId, savePlayerData.localSessionId))
    end

    --Save
    if not DisableStore then
        local success, result = pcall(function()
            settings.PlayerDS:SetAsync(player.UserId, savePlayerData)
        end)

        if not success then
            Logger:w(string.format("Unable to save players data: %s : %s", player.UserId, result))
        end
    end
end

function settings:removePlayerData(player)
    self.PlayerCache[player.UserId] = nil
end

function settings:getPlayerData(player)
    local playerData = self.PlayerCache[player.UserId]

    if playerData ~= nil and playerData.sdkStarted then
        playerData:startSession()
        return playerData
    end

	local success, result = pcall(function()
        playerData = DisableStore and {} or (settings.PlayerDS:GetAsync(player.UserId) or {})
	end)

    if not success then
        Logger:w(string.format("Unable to get players data: %s : %s", player.UserId, result))
    end

    --warn("playerData", playerData)

    -- If there is no saves for the user return
	if not success then
		playerData = {
            isTrackingStopped = false,
            deviceId = HTTP:GenerateGUID(false),
            checkpoints = {},
            remoteConfigFetched = false
        }
	end

    playerData = PlayerData.new(playerData)
    playerData:startSession()

    self.PlayerCache[player.UserId] = playerData

	return playerData
end

function settings:getMillisecondsElapsedSince(timestamp)
    return tonumber(string.format("%.2f", math.floor(settings.millesecondsElapsed - timestamp)))
end

function settings:newBeacon(player, sdk)
    return Beacon.new(player, sdk)
end

return settings
