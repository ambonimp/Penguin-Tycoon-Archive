local TycoonProgressBar = {}

--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes
local UI = Paths.UI
local Dependency = Services.RStorage.ClientDependency.ProgressBarUI

local ProgressBar = UI.Top.ProgressBar
local Bar = ProgressBar.Bar

local Dividers = ProgressBar.Dividers
local DividerTemplate = Dependency.Divider
local DividerSize = DividerTemplate.Size.X.Scale

local Popup = UI.Top.Popups.ProgressBarReward
local PopupSession



local Buttons = Services.RStorage.Template:WaitForChild("Buttons")

local CurrentIsland
local Unlocking = {}




local function GetIslandIndex(Reference)
    local Island = Reference:GetAttribute("Island")
    if Island == "Island1" then
        return 1
    else
        for i = 2, #Modules.ProgressionDetails do
            local FirstButton = Buttons[Modules.ProgressionDetails[i].Object]
            if FirstButton:GetAttribute("Island") == Island then
                return i
            end
        end
    end
end

local function GetNextIslandIndex()
   return CurrentIsland ~= #Modules.ProgressionDetails and CurrentIsland + 1 or nil
end
local function GetIncompleteIslandIndex()
    for i,v in ipairs(Unlocking) do
        if v.Unlocked < v.Unlockables then
            return i
        end
    end
end

local function IsUnlockable(Index, Button)
    return Button:GetAttribute("CurrencyType") == "Money" and Button.Name ~= Modules.ProgressionDetails[Index].Object
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

        if i == math.floor(Unlockables/2) + 1 then
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
        ProgressBar.NextIsland.Visible = true
    end

    -- Bar
    UpdateBar(false)

end

function Progress()
    local IslandInfo = Unlocking[CurrentIsland]
    IslandInfo.Unlocked += 1

    local Unlocked = IslandInfo.Unlocked
    local Unlockables = IslandInfo.Unlockables

    -- warn(Unlocked, Unlockables)
    UpdateBar(true)

    return Unlocked, Unlockables
end

function TycoonCompleted()
    ProgressBar.Visible = false
end

-- Initialize
for i = 1, #Modules.ProgressionDetails do
    Unlocking[i] = {
        Unlocked = 0,
        Unlockables = {},
    }
end
-- Unlocked
for Object in pairs(Remotes.GetStat:InvokeServer("Tycoon")) do
    local Button = Buttons:FindFirstChild(Object)
    if Button then
        local Index = GetIslandIndex(Button)
        if IsUnlockable(Index, Button) then
            Unlocking[Index].Unlocked += 1
        end

    end

end

-- Unlockables
for _, Button in pairs(Buttons:GetChildren()) do
    local Index = GetIslandIndex(Button)
    if IsUnlockable(Index, Button) then
        table.insert(Unlocking[Index].Unlockables, Button)
    end
end

for _, v in ipairs(Unlocking) do
    v.Unlockables = #v.Unlockables
end


-- Get current island, aka first non completed
CurrentIsland = GetIncompleteIslandIndex()
if CurrentIsland then
    LoadIsland(CurrentIsland)

    -- Load bar for future islands
    Remotes.ButtonPurchased.OnClientEvent:Connect(function(Button)
        local TemplateButton = Buttons[Button]

        local Index = GetIslandIndex(TemplateButton)
        if Index ~= CurrentIsland then
            LoadIsland(Index)
        end

        if IsUnlockable(Index, TemplateButton) then
            local Unlocked, Unlockables = Progress()

            --Get half reward
            if Unlocked == math.floor(Unlockables / 2) then
                local Id = os.time()
                PopupSession = Id

                Remotes.IslandProgressRewardCollected:FireServer(Index, TemplateButton:GetAttribute("Island"))
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

return TycoonProgressBar