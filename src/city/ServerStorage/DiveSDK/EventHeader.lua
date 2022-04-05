
local HTTP = game:GetService("HttpService")
local eventHeader = {}
local settings = require(script.Parent.Settings)
local Logger = require(script.Parent.Logger)

-- JSONEncoder considers huge int a 'null' value.
local null = math.huge

function eventHeader:new(player, eventName, eventBody, extraHeaders)
    local playerData = settings:getPlayerDataFromCache(player.UserId);
    local eventUuid = HTTP:GenerateGUID(false)
    local utcTimeStamp = DateTime.now()

    local timeStamp = DateTime.fromUnixTimestamp(utcTimeStamp.UnixTimestamp); 
    if playerData ~= nil and playerData.device ~= nil and playerData.device.offset ~= nil then
        timeStamp = DateTime.fromUnixTimestamp(utcTimeStamp.UnixTimestamp + playerData.device.offset);
    end
    
    local timezone = "000"
    if(playerData.device ~= nil and playerData.device.timezone ~= nil)then
        timezone = playerData.device.timezone
    end

    local body = {
        ["name"] = eventName,
        ["roblox_user_id"] = player.UserId,
        ["player_id"] = playerData.playerId or null,
        ["xp_before"] = playerData.playerXp,
        ["level_before"] = playerData.playerLevel,
        ["c_session_id"] = playerData.localSessionId,
        ["c_session_restarted_from"] = playerData.restartedLocalSessionId,
        ["s_session_id"] = playerData.serverSessionId or settings.serverSessionId or null,
        ["platform"] = "roblox",
        ["env"] = settings.config.environment,
        ["app_token"] = settings.config.appToken,
        ["game_ver"] = settings.gameVersion,
        ["sdk_ver"] =  "Roblox Dive SDK " .. (settings.SDK_VERSION or ""),
        ["uuid"] = eventUuid,
        ["unixts"] = utcTimeStamp.UnixTimestamp,
        ["timestamp_utc"] = utcTimeStamp:ToIsoDate(),
        ["date_utc"] = utcTimeStamp:FormatUniversalTime(settings.DATE_FORMAT, "en-us"),
        ["ts"] = timeStamp:ToIsoDate(),
        ["device_id"] = playerData.deviceId,
        ["user_country"] = playerData.country,
        ["timezone"] = timezone,
        ["body"] = eventBody,
        ["place_ver"] = tostring(game.PlaceVersion)
    }

    



    -- Adding global dive Headers
    if settings.customHeaders ~= nil then 
        for name, value in pairs(settings.customHeaders) do
            body[name] = value
        end
    end
    
    -- Adding custom dive user Headers
    if playerData.customHeaders ~= nil then 
        for name, value in pairs(playerData.customHeaders) do
            body[name] = value
        end
    end

    -- Adding extra dive Headers
    if extraHeaders ~= nil then 
        for name, value in pairs(extraHeaders) do
            body[name] = value
        end
    end
    return body
end

return eventHeader