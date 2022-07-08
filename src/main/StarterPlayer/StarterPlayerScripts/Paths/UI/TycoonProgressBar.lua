local TycoonProgressBar = {}

--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes
local UI = Paths.UI
local Dependency = Services.RStorage.ClientDependency.ProgressBarUI

local Top = UI.Top
local ProgressBar = Top.ProgressBar
local Bar = ProgressBar.Bar

local TopBottomPadding = Top.Bottom.UIPadding

local Dividers = ProgressBar.Dividers
local DividerTemplate = Dependency.Divider
local DividerSize = DividerTemplate.Size.X.Scale

local Popup = UI.Top.Bottom.Popups.ProgressBarReward
local PopupSession




local CurrentIsland
local Unlocking = {}



function TycoonProgressBar.Toggle(Toggle)
    if Toggle then
        if not ProgressBar:GetAttribute("Disabled") and Paths.UI.Center.Settings.Holder["Progress Bar"].Toggle.IsToggled.Value then
            ProgressBar.Visible = true
            TopBottomPadding.PaddingBottom = UDim.new(-0.15, 0)
            TopBottomPadding.PaddingTop = UDim.new(0.15, 0)
        end
    else
        ProgressBar.Visible = false
        TopBottomPadding.PaddingTop = UDim.new(0, 0)
        TopBottomPadding.PaddingBottom = UDim.new(0, 0)
    end
end

local function GetNextIslandIndex()
   return CurrentIsland ~= #Modules.ProgressionDetails and CurrentIsland + 1 or nil
end
local function GetIncompleteIslandIndex()
    for i,v in ipairs(Unlocking) do
        if v.Unlocked < v.Unlockables then
            -- warn(v)
            return i
        end
    end
end

local function IsUnlockable(Index, Button)
    return Remotes.GetTemplateButtonAttribute:InvokeServer(Button, "CurrencyType") == "Money" and Button ~= Modules.ProgressionDetails[Index].Object
end

local function UpdateBar(Tween)
    local IslandInfo = Unlocking[CurrentIsland]
    local Unlocked = IslandInfo.Unlocked
    local Unlockables = IslandInfo.Unlockables

    local Size = UDim2.fromScale((Dividers.UIListLayout.Padding.Scale+DividerSize)*Unlocked-(DividerSize/2), 1)
    Size = Unlocked == Unlockables and UDim2.fromScale(1, 1) or Size
    if Tween then
        Bar:TweenSize(Size, Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.1, true)
    else
        Bar.Size = Size
    end

    Bar.Visible = Unlocked ~= 0

end

function LoadIsland(Island)
    CurrentIsland = Island

    -- Dividers
    for _, Divider in ipairs(Dividers:GetChildren()) do
        if Divider:IsA('Frame') then
            Divider:Destroy()
        end
    end

    local Unlockables = Unlocking[CurrentIsland].Unlockables - 1
    Dividers.UIListLayout.Padding = UDim.new((1 - DividerSize*Unlockables) / (Unlockables+1), 0)
    for i = 1, Unlockables do
        local Divider = DividerTemplate:Clone()
        Divider.Parent = Dividers

        if i == math.floor(Unlocking[CurrentIsland].Unlockables / 2) then
            local RewardIcon = Dependency.Reward:Clone()
            RewardIcon.Parent = Divider
        end

    end

    -- Icons
    ProgressBar.CurrentIsland.Image = Modules.ProgressionDetails[CurrentIsland].Icon
    local NextIsland = GetNextIslandIndex()
    if NextIsland then
        ProgressBar.NextIsland.Visible = true
        ProgressBar.NextIsland.Image = Modules.ProgressionDetails[NextIsland].Icon
    else
		ProgressBar.NextIsland.Visible = false
    end

    -- Bar
    UpdateBar(false)

end

function Progress()
    local IslandInfo = Unlocking[CurrentIsland]
    IslandInfo.Unlocked += 1

    local Unlocked = IslandInfo.Unlocked
    local Unlockables = IslandInfo.Unlockables

    if Unlocked == Unlockables then
        if not GetIncompleteIslandIndex() then
		    TycoonCompleted()
        end
    end

   --  print("Progress:", Unlocked, Unlockables)
    UpdateBar(true)

    return Unlocked, Unlockables
end

function TycoonCompleted()
    ProgressBar.Visible = false
    ProgressBar:SetAttribute("Disabled", true)
end

-- Initialize
Unlocking = Remotes.GetTycoonInfo:InvokeServer()

-- Get current island, aka first non completed
CurrentIsland = GetIncompleteIslandIndex()
if CurrentIsland then
    LoadIsland(CurrentIsland)

    -- Load bar for future islands
    Remotes.ButtonPurchased.OnClientEvent:Connect(function(Index, Button)
        if Index ~= CurrentIsland then
            LoadIsland(Index)
        end

        if IsUnlockable(Index, Button) then
            local Unlocked, Unlockables = Progress()

            --Get half reward
            if Unlocked == math.floor(Unlockables/2) then
                local Id = os.time()
                PopupSession = Id

                Remotes.IslandProgressRewardCollected:FireServer(Index, Remotes.GetTemplateButtonAttribute:InvokeServer(Button, "Island"))
                Popup.Visible = true
                task.wait(4)
                if PopupSession == Id then
                    Popup.Visible = false
                end

            end

        end

    end)

else
    TycoonCompleted()
end

task.spawn(function()
    repeat task.wait() until Modules.Settings

    local AFKFishing = Paths.UI.Top.AFKFishing
    TycoonProgressBar.Toggle(not AFKFishing.Visible)
    AFKFishing:GetPropertyChangedSignal("Visible"):Connect(function()
        TycoonProgressBar.Toggle(not AFKFishing.Visible)
    end)

end)


return TycoonProgressBar