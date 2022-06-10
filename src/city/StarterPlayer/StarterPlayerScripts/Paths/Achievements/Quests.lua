local Quests = {}

local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes
local UI = Paths.UI.Center.Achievements.Sections.Quests

local QuestData = nil

function getReward(difficult)
    local reward = 5
    if difficult == 2 or difficult == 4 or difficult == 5 then
        reward = 15
    elseif difficult == 3 then
        reward = 25
    end
    return "rbxassetid://9846753652",reward
end

function claimQuest(questNum,Button)
    local Reward = Remotes.Quests:InvokeServer("Reward",questNum)

    if Reward then
        Button:SetAttribute("Claimed",true)
        Button.Text.Text = "CLAIMED!"
        local text = "You received "..Reward.." Gems!"
		Paths.Modules.Setup:Notification(text,Color3.new(0.945098, 0.525490, 0.282352),7)
    end
end

function getQuestIcon(Quest)
    if Quest[2] == "Fish" or Quest[1] == "Junk" then
        return "rbxassetid://9708857672"
    elseif Quest[2] == "Soccer" then
        return "rbxassetid://9708856039"
    elseif Quest[2] == "Ice Cream Extravaganza" then
        return "rbxassetid://9708855166"
    elseif Quest[2] == "Candy Rush" then
        return "rbxassetid://9708874449"
    elseif Quest[2] == "Tree" then
        return "rbxassetid://9870879036"
    elseif Quest[2] == "Falling Tiles" then
        return "rbxassetid://9708857803"
    elseif Quest[2] == "Skate Race" then
        return "rbxassetid://9708857177"
    elseif Quest[2] == "All" then
        return "rbxassetid://9230901637"
    end
end

function updateQuestData(data)
    QuestData = data
    for i = 1,5 do 
        local Quest = QuestData.Quests[i]
        local Icon,Reward = getReward(i)
        local Frame = UI.Quests:FindFirstChild("Quest"..i)
        Frame.Icon.Image = getQuestIcon(Quest[2])
        Frame.Reward.Icon.Image = Icon
        Frame.Reward.Text.Text = Reward
        Frame.Description.Text = Quest[2][4]
        if Quest[3] == "CLAIMED" then
            Frame.ProgressText.Text = Quest[2][3].."/"..Quest[2][3]
            Frame.Progress.Frame.Size = UDim2.new(1,0,1,0)
            Frame.Progress.Claim:SetAttribute("Claimed",true)
            Frame.Progress.Claim.Text.Text = "CLAIMED!"
            Frame.Progress.Claim.Visible = true
        else
            Frame.ProgressText.Text = Quest[3].."/"..Quest[2][3]
        
            local per = Quest[3]/Quest[2][3]
            Frame.Progress.Frame.Size = UDim2.new(per,0,1,0)
            if per == 1 then
                Frame.Progress.Claim:SetAttribute("Claim",true)
                Frame.Progress.Claim.Text.Text = "CLAIM REWARD"
                Frame.Progress.Claim.Visible = true
            else
                Frame.Progress.Claim:SetAttribute("Claim",false)
                Frame.Progress.Claim.Visible = false
            end
        end
        
    end
end

for i = 1,5 do
    local Frame = UI.Quests:FindFirstChild("Quest"..i)
    Frame.Progress.Claim.MouseButton1Down:Connect(function()    
        if Frame.Progress.Claim:GetAttribute("Claimed") then return end
        if Frame.Progress.Claim:GetAttribute("Claim") then
            if (i == 4 or i == 5) then
                if Modules.Gamepasses.Owned[26269102] then
                    claimQuest(i,Frame.Progress.Claim)
                else
                    Services.MPService:PromptGamePassPurchase(Paths.Player, 26269102)
                end
            else
                claimQuest(i,Frame.Progress.Claim)
            end
        else
            Frame.Progress.Claim.Visible = false
        end
    end)
end

function Remotes.Quests.OnClientInvoke(Data)
    QuestData = Data
    updateQuestData(QuestData)
end

task.spawn(function()
    repeat 
        QuestData = Remotes.GetStat:InvokeServer("Quests")
        task.wait(1)
    until QuestData and QuestData.Quests
    updateQuestData(QuestData)

    local function toHMS(leftOver)
        return string.format("%02i:%02i:%02i", leftOver/60^2, leftOver/60%60, leftOver%60)
    end

    local function doTimer()
        local time1 = QuestData.Timer
        local timeLeft = time1-os.time()
        while timeLeft > 0 do
            timeLeft -= 1
            UI.Timer.Text = toHMS(timeLeft)
            task.wait(1)
        end

        QuestData = Remotes.Quests:InvokeServer("Reset")
        updateQuestData(QuestData)
        doTimer()
    end

    doTimer()
end)

return Quests