local Quests = {}

local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes
local UI = Paths.UI.Center.Achievements.Sections.Quests

local Snackbar = Paths.UI.Full.QuestHelp

local RerollId = 1284829211
local QuestData = nil

local GUI_INSET = Paths.Services.GuiService:GetGuiInset()

function getReward(difficult)
    local reward = 5
    if difficult == 2 or difficult == 4 or difficult == 5 then
        reward = 15
    elseif difficult == 3 then
        reward = 25
    end
    return "rbxassetid://9846753652",reward
end

UI.Quests.Reroll.MouseButton1Down:Connect(function()
    Services.MPService:PromptProductPurchase(Paths.Player, 1284829211)
end)

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
        Frame:SetAttribute("QuestId", i)

        Frame.Help.Visible = Quest[2][5] ~= nil

        if Quest[3] == "CLAIMED" then
            Frame.ProgressText.Text = Quest[2][3].."/"..Quest[2][3]
            Frame.Progress.Frame.Size = UDim2.new(1,0,1,0)
            Frame.Progress.Claim:SetAttribute("Claimed",true)
            Frame.Progress.Claim.Text.Text = "CLAIMED!"
            Frame.Progress.Claim.Visible = true
            Frame.ProgressText.Visible = false

        else

            local per = Quest[3]/Quest[2][3]
            Frame.Progress.Frame.Size = UDim2.new(per,0,1,0)
            if per == 1 then
                Frame.Progress.Claim:SetAttribute("Claim",true)
                Frame.Progress.Claim.Text.Text = "CLAIM REWARD"
                Frame.Progress.Claim.Visible = true

                Frame.ProgressText.Visible = false

            else
                Frame.ProgressText.Text = Quest[3].."/"..Quest[2][3]
                Frame.ProgressText.Visible = true

                Frame.Progress.Claim:SetAttribute("Claim",false)
                Frame.Progress.Claim.Visible = false
            end

        end

        Frame.Help.MouseButton1Down:Connect(function()

        end)

    end

end

--[[
function OpenQuestHelp(id)
    local Quest = QuestData.Quests[id]
end]]

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
   --[[ Frame.Help.MouseButton1Down:Connect(function()

    end)]]
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

-- Help bars
local ScrollConn
local function CloseHelp()
    Snackbar.Visible = false
    Snackbar:SetAttribute("QuestId", nil)

    if ScrollConn then
        ScrollConn:Disconnect()
    end

end

for _, Container in ipairs(UI.Quests:GetChildren()) do
    if string.find(Container.Name, "Quest") then
        local Btn = Container.Help
        Btn.MouseButton1Down:Connect(function()
            local QuestId = Container:GetAttribute("QuestId")

            if Snackbar:GetAttribute("QuestId") == QuestId then
                CloseHelp()
            else
                local Quest = QuestData.Quests[QuestId]

                Snackbar.Visible = true
                Snackbar.TextLabel.Text = Quest[2][5]
                Snackbar:SetAttribute("QuestId", QuestId)

                local ViewportSize = workspace.CurrentCamera.ViewportSize
                local BtnPos = Btn.AbsolutePosition
                Snackbar.Position = UDim2.fromScale(
                    (BtnPos.X + GUI_INSET.X - Snackbar.Arrow.AbsoluteSize.Y) / ViewportSize.X,
                    (BtnPos.Y + GUI_INSET.Y + (Btn.AbsoluteSize.Y / 2)) / ViewportSize.Y
                )

                ScrollConn = UI.Quests:GetPropertyChangedSignal("CanvasPosition"):Connect(CloseHelp)
            end

        end)

    end

end

Paths.UI.Center.Achievements:GetPropertyChangedSignal("Visible"):Connect(CloseHelp)

for _, tab in ipairs(Paths.UI.Center.Achievements.Buttons:GetChildren()) do
    if tab:IsA("ImageButton") then
        tab.MouseButton1Down:Connect(function()
            if tab.Name ~= "Quests" then
                CloseHelp()
            end
        end)
    end

end


return Quests