local EventBody = require(script.Parent.EventBody);
local settings = require(script.Parent.Settings)
local Logger = require(script.Parent.Logger)

local launchBody = {}
-- o - extra body parameters
function launchBody:new(player, o) 
    local playerData = settings:getPlayerDataFromCache(player.UserId)
    o = o or {}
    -- This is all device data known;
    if(not playerData)then return o end
    
    if(playerData.device and playerData.device.language)then
        o["lang"] = playerData.device.language
    else 
        Logger:w("DiveSDK: No language data for user " .. player.UserId)
    end

    if(playerData.device and playerData.device.device_type)then
        o["device_type"] = playerData.device.device_type
    else
        Logger:w("DiveSDK: No device_type data for user " .. player.UserId)
    end

    if(playerData.device and playerData.device.screen)then
        o["screen"] = playerData.device.screen
    else
        Logger:w("DiveSDK: No screen data for user " .. player.UserId)
    end

    return o
end

return launchBody