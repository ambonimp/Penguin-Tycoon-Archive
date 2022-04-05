RemoteConfig = require(script.Parent.RemoteConfig)
local remoteConfigResponse = {}

function remoteConfigResponse:new(o)
  if o ~= nil and o['remote_config'] ~= nil  then
    o.remoteConfig = RemoteConfig:new(o['remote_config']);
  else
    o = o or {}
  end
  setmetatable(o, self)
  self.__index = self
  return o
end

return remoteConfigResponse;



