local Quests = {}
local Paths = require(script.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes

local AllQuests = Modules.AllQuests

local function shallowCopy(original)
	local copy = {}
	for key, value in pairs(original) do
		copy[key] = value
	end
	return copy
end

function getNewQuest()
    local possibleTypes = shallowCopy(AllQuests.Types)


    local easy = possibleTypes[math.random(1,#possibleTypes)]
    table.remove(possibleTypes,table.find(possibleTypes,easy))
    local medium = possibleTypes[math.random(1,#possibleTypes)]
    table.remove(possibleTypes,table.find(possibleTypes,medium))
    local hard = possibleTypes[math.random(1,#possibleTypes)]

    possibleTypes = shallowCopy(AllQuests.Types)

    local vip1 = possibleTypes[math.random(1,#possibleTypes)]
    table.remove(possibleTypes,table.find(possibleTypes,vip1))
    local vip2 = possibleTypes[math.random(1,#possibleTypes)]

    print("QUESTS",easy,medium,hard,vip1,vip2)
end


getNewQuest()
return Quests