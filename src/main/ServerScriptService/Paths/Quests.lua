local Players = game:GetService("Players")
local Quests = {}
local Paths = require(script.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes

local EventHandler = game:GetService("ServerStorage"):FindFirstChild("EventHandler")
local AllQuests = Modules.AllQuests
Quests.QuestResetTime = (24*60*60)

if game.PlaceId == 9118436978 or game.PlaceId == 9118461324 then
    Quests.QuestResetTime = 3*60
end

local function shallowCopy(original)
	local copy = {}
	for key, value in pairs(original) do
		copy[key] = value
	end
	return copy
end

function getRandom(intbl,possible)
    local amount = #possible
    local copy = shallowCopy(possible)
    local new = nil
    for i,v in pairs (intbl) do
        if table.find(copy,v) then
            table.remove(copy,table.find(copy,v))
        end
    end
    new = copy[math.random(1,amount)]
    return new
end

function getReward(difficult)
    local reward = 5
    if difficult == 2 or difficult == 4 or difficult == 5 then
        reward = 15
    elseif difficult == 3 then
        reward = 25
    end
    return reward
end

function claimQuest(Player,QuestNumber)
    print(type(QuestNumber))
    local Data = Modules.PlayerData.sessionData[Player.Name]
    if (QuestNumber == 4 or QuestNumber == 5) and not Data["Gamepasses"]["26269102"] then return end --return if they try to claim vip and don't own it
    print("owns gamepass")
    if Data["Quests"].Quests and Data["Quests"].Quests[QuestNumber] then
        local Quest = Data["Quests"].Quests[QuestNumber]
        local reward = getReward(QuestNumber)
        if Quest[3] == Quest[2][3] then
            Modules.Income:AddGems(Player,reward,"Quest")

            local success, msg = pcall(function()
                EventHandler:Fire("Quest Completed", Player, {
                    questData = Quest,
                })
            end)
            Quest[3] = "CLAIMED"
            return reward
        end
    end
    return nil
end

function Quests.ProductReset(Player)
    local Data = Modules.PlayerData.sessionData[Player.Name]
    if Data then
        Quests.getNewQuests(Player)
        Remotes.Quests:InvokeClient(Player,Data["Quests"])
    end
end

function Quests.getNewQuests(Player)
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

    local Data = Modules.PlayerData.sessionData[Player.Name]

    local currentQuests = {}

    local newEasy = getRandom(currentQuests,AllQuests["Easy"][easy])
    table.insert(currentQuests,newEasy[2])
    local newMedium = getRandom(currentQuests,AllQuests["Medium"][medium])
    table.insert(currentQuests,newMedium[2])
    local newHard = getRandom(currentQuests,AllQuests["Hard"][hard])
    table.insert(currentQuests,newHard[2])

    local newVip1 = getRandom(currentQuests,AllQuests["Medium"][vip1])
    table.insert(currentQuests,newVip1[2])
    local newVip2 = getRandom(currentQuests,AllQuests["Medium"][vip2])
    table.insert(currentQuests,newVip2[2])

    Data["Quests"].Timer = os.time() + Quests.QuestResetTime
    Data["Quests"].Quests = {
        [1] = {easy,newEasy,0},
        [2] = {medium,newMedium,0},
        [3] = {hard,newHard,0},
        [4] = {vip1,newVip1,0},
        [5] = {vip2,newVip2,0},
    }
end

--Example: Modules.Quests.GiveQuest(Player,"Collect","Woodcutting","Tree",1)
function Quests.GiveQuest(Player,QuestKind,QuestName,QuestType,Amount)
    local Data = Modules.PlayerData.sessionData[Player.Name]
    if Data["Quests"] then
        local updated = false
        for i=1,5 do
            local Quest = Data["Quests"].Quests[i]
            if Quest[1] == QuestKind and Quest[2][1] == QuestName and Quest[2][2] == QuestType and Quest[3] ~= "CLAIMED" then
                updated = true
                local new = Quest[3]+Amount
                if new >= Quest[2][3] then
                    new = Quest[2][3]
                end
                Quest[3] = new
            end
        end
        if updated then
            Remotes.Quests:InvokeClient(Player,Data["Quests"])
        end
    end
end

function Remotes.Quests.OnServerInvoke(Player,Kind,QuestId)
    if Kind == "Reward" then
        return claimQuest(Player,QuestId)
    elseif Kind == "Reset" then
        Quests.getNewQuests(Player)
        return Modules.PlayerData.sessionData[Player.Name]["Quests"]
    end
end

return Quests