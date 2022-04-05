local RemoteConfig = {}

function RemoteConfig:getValueOrDefault(key, default)
  for _, obj in pairs(self['remote_config']) do
    if obj.key == key then
      return obj.value
    end
  end 
  return default
end

function RemoteConfig:new(o)
  local remoteConfig = {};
  remoteConfig.remote_config = o or {}   -- create object if user does not provide one
  setmetatable(remoteConfig, self)
  self.__index = self
  return remoteConfig
end

return RemoteConfig;