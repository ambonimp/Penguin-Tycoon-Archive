local Achievements = {}
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes

local Dependency = Services.RStorage.ClientDependency.Achievements

local Popup = Paths.UI.Top.Bottom.Popups.AchievementCompleted
local List = Paths.UI.Center.Achievements.Sections.Achievements.List

local Template = Dependency.Template
Template.Parent = nil

local RewardFontSize = 0.025
local Camera = workspace.CurrentCamera

function Complete(Id)
    if Remotes.CollectAchievement:InvokeServer(Id) then
        UpdateProgress(Id, {true}) -- Fake data that does the job
        return true
    end
end


function UpdateProgress(Id, Data)
    local Details = Modules.AllAchievements[Id]

    local Lbl = List[Id]
    local Progress = Lbl.Progress

    if Data[1] then -- Completed
        Progress.Bar.Visible = true
        Progress.Claim.Visible = false

        Progress.TextLabel.Visible = true
        Progress.TextLabel.Text = "Completed"

        Lbl.Completed.Visible = true
        Lbl.LayoutOrder = #Modules.AllAchievements + Id

    else
        Lbl.Completed.Visible = false
        local ToComplete = Details.ToComplete
        local Completed = math.min(Data[2], ToComplete)

        Progress.Bar.Size = UDim2.fromScale(Completed / ToComplete, 1)
        Progress.TextLabel.Text = Completed .. "/" .. ToComplete

        if Completed == ToComplete then
            if Details.AutoClaim then
                Complete(Id)
            else
                Modules.Milestones.Badge(true, "Achievements")

                Progress.Bar.Visible = false
                Progress.TextLabel.Visible = false
                Progress.Claim.Visible = true

                local Conn
                Conn = Progress.Claim.MouseButton1Down:Connect(function()
                    if Complete(Id) then
                        Conn:Disconnect()
                        Modules.Milestones.Badge(false, "Achievements")
                    end

                end)

            end

            -- Open popup
            Popup.Size = UDim2.fromScale(0,0)
            Popup.Visible = true
            Popup:TweenSize(UDim2.fromScale(0.4, 1), Enum.EasingDirection.Out,Enum.EasingStyle.Quad, 0.25, true, function()
                task.wait(5)
                Popup.Visible = false
            end)

        end

    end

end

local Data = Remotes.GetStat:InvokeServer("Achievements")[2]
for Id , Achievement in pairs(Modules.AllAchievements) do
    local Lbl = Template:Clone()
    Lbl.Name = Id
    Lbl.Description.Text = Achievement.Name
    Lbl.Icon.Image = Achievement.Icon
    Lbl.LayoutOrder = Id

    local Rewards = Lbl.Rewards
    local SingleReward = #Achievement.Rewards == 1
    for i, Reward in ipairs(Achievement.Rewards) do
        if i ~= 1 then
            local PlusIcon = Dependency.Plus:Clone()
            PlusIcon.Parent = Rewards
        end

        local RewardIcon = Dependency.RewardIcon:Clone()
        local RewardValue = Dependency.RewardValue:Clone()

        if Reward.Type == "Gems" then
            RewardIcon.Image = "rbxassetid://9846753652"
            RewardValue.Text = if SingleReward then Reward.Value else "Gems"

        elseif Reward.Type == "Accessory" then -- TODO: Make it a hat icon
            RewardIcon.Image = "rbxassetid://10376007095" -- "rbxassetid://" .. Reward.Value .. "_Accessory"
            RewardValue.Text = if SingleReward then Reward.Value else "Hat"

        elseif Reward.Type == "Outfit" then -- TODO: Make it a penguin name
            RewardIcon.Image = "rbxassetid://10376007313"
            RewardValue.Text = if SingleReward then Reward.Value .. " Outfit" else "Outfit"

        elseif Reward.Type == "Vehicle" then
            RewardIcon.Image = "rbxassetid://10377606580"
            RewardValue.Text = Reward.Value .. " Vehicle"

        elseif string.find(Reward.Type, "Multiplier") then
            RewardIcon.Image = "rbxassetid://10376081736"
            RewardValue.Text = string.format("%s%% %s", Reward.Value, Reward.Type)

        end

        RewardIcon.BackgroundTransparency = 1
        RewardIcon.Parent = Rewards

        RewardValue.Parent = Rewards

    end

    Lbl.Parent = List
    UpdateProgress(Id, Data[tostring(Id)])

end

Remotes.AchievementProgress.OnClientEvent:Connect(function(Id, Data)
    UpdateProgress(Id, Data)
end)

local function ScaleRewardTextLabels()
    local ViewportHeight = Camera.ViewportSize.Y
    local TextSize = RewardFontSize * ViewportHeight

    for _, Achievement in ipairs(List:GetChildren()) do
        if Achievement:IsA("Frame") then
            for _, TextLabel in ipairs(Achievement.Rewards:GetChildren()) do
                if TextLabel:IsA("TextLabel") and TextLabel.Name ~= "Plus" then
                    TextLabel.TextSize = TextSize
                end
            end

        end

    end

end

ScaleRewardTextLabels()
Camera:GetPropertyChangedSignal("ViewportSize"):Connect(ScaleRewardTextLabels)
return Achievements