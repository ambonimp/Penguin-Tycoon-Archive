local logger = require(script.Parent.Logger)

local diveConfig = {}
local requiredConfigParameters = {  appToken = "string",
                                    hashKey = "string",
                                    serverUrl = "string",
                                    hasIdentityConsent = "boolean",
                                    environment = "string",
                                    showInfoLogs = "boolean" }

function diveConfig:new(options)
    if self.isConfigValid(options) then
        return self
    end
end

function diveConfig:isConfigValid(options)
    local errors = 0;
    for option, optionType in pairs(requiredConfigParameters) do
        if options[option] == nil then
            logger:e("Config '"..option.."' parameter is missing")
            errors = errors + 1
        elseif type(options[option]) ~= optionType then
            logger:e("Config parameter '"..option.."' wrong type. Expected: '"..optionType.."', got '"..typeof(options[option]).."'." )
            errors = errors + 1
        end
    end
    if errors > 0 then
        return false
    end
    logger:d("config is valid")
    return true
end

return diveConfig