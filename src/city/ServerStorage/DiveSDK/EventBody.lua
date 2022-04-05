local eventBody = {}

function eventBody:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function eventBody:addParam(name, value)
    self[name] = value
    return self
end

return eventBody