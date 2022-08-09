local Rocket = {}

local Paths = require(script.Parent.Parent)
local Modules = Paths.Modules
local Services = Paths.Services
local Remotes = Paths.Remotes
local UI = Paths.UI

local Dependency = Services.RStorage.ClientDependency.BuildA

local TeleportFrame = UI.Center.WorldTeleport
local WorldList = TeleportFrame.List

local ItemFrame = UI.Center.RocketUnlock
local ItemList = ItemFrame.Items.Unlocked
local ProgressLbl = ItemFrame.Items.Progress

local CollectFirstFrame = UI.Center.FirstRocketPart

local FoundPopup = UI.Top.Bottom.Popups.FoundRocketItem
local CompletedPopup = UI.Top.Bottom.Popups.RocketCompleted


local UPGRADE = "Rocketship#1"
local BROKEN_SHIP_UPGRADE = "Icy Access#1"

local ITEM_TAG = "BuildAItem" -- Collection service tag, how items are found when added to tycoon


local TycoonSession = Modules.Maid.new()

local UnlockingData = Remotes.GetStat:InvokeServer("RocketUnlocked")
local ItemModels =  Services.RStorage.Assets.BuildA.Rocket

local LeadCons = {}

function Rocket.CloseToBuildA(Name)
    LeadCons[2]:Destroy()
    LeadCons[3]:Destroy()
    LeadCons[1]:Disconnect()
end

-- Creates arrow to brocken rocket when rocket is unlocked
function Rocket.LeadToBuildA(Name)
    local Character = Paths.Player.Character
    if not Character then return end

    task.spawn(function()
        local Upgrade = nil
        local PromptPart = nil
        if Name then 
            Upgrade = Paths.Tycoon.Tycoon:WaitForChild("Icy Access#1"):WaitForChild("BrokenRocketShip")
            PromptPart = Upgrade:WaitForChild("Ship")
        else
            Upgrade = Paths.Tycoon.Tycoon:WaitForChild(UPGRADE)
            PromptPart = Upgrade:WaitForChild("PromptPart")
        end

        LeadCons[3] = Instance.new("Attachment")
        LeadCons[3].Parent = Character.Main

        local Att1 = Instance.new("Attachment")
        Att1.Parent = PromptPart

        LeadCons[2] = Paths.Services.RStorage.ClientDependency.Help.Pointer:Clone()
        LeadCons[2] .Color = ColorSequence.new(Color3.fromRGB(255, 0, 255))
        LeadCons[2] .Parent = PromptPart
        LeadCons[2] .Attachment0 = LeadCons[3]
        LeadCons[2] .Attachment1 = Att1

        
        LeadCons[1] = PromptPart.ProximityPrompt.Triggered:Connect(function()
            LeadCons[2]:Destroy()
            LeadCons[3]:Destroy()
            LeadCons[1]:Disconnect()
        end)

     end)

end

local function OpenPopup(Popup, FinalSize)
    Popup.Size = UDim2.fromScale(0,0)
    Popup.Visible = true
    Popup:TweenSize(FinalSize, Enum.EasingDirection.Out,Enum.EasingStyle.Quad, 0.25, true, function()
        task.wait(5)
        Popup.Visible = false
    end)
end

local function UnlockLocation(Item)
    local Lbl = ItemList[Item]
    local Upgrade = Modules.BuildADetails.Rocket[Item]

    local LocationLbl = Lbl.Location
    LocationLbl.Text = Modules.ProgressionDetails[Remotes.GetIslandIndexFromUpgrade:InvokeServer(Upgrade)].Alias
    LocationLbl.TextColor3 = Color3.new(255, 255, 255)

end

local function UnlockItem(Item)
    local Lbl = ItemList[Item]

    Lbl.Thumbnail.ImageColor3 = Color3.new(255, 255, 255)

    local NameLbl = Lbl.ItemName
    NameLbl.Text = Item
    NameLbl.TextColor3 = Color3.new(255, 255, 255)

end


local function UpdateProgress(LastItem)
    local Completed = 0
    local Total = 0

    for _, Unlocked in pairs(UnlockingData[2]) do
        Total += 1
        if Unlocked then Completed += 1 end
    end

    ProgressLbl.Text = string.format("%s/%s Parts Colleted", Completed, Total)

    if Total == 1 then
        Modules.Buttons:UIOn(CollectFirstFrame, true)

        local Conn
        Conn = CollectFirstFrame.Exit.MouseButton1Down:Connect(function()
            Conn:Disconnect()
            Modules.Buttons:UIOff(CollectFirstFrame, true)
        end)

    elseif Completed == Total then
        Paths.Audio.FullyRepaired:Play()

        Rocket.LeadToBuildA()
        OpenPopup(CompletedPopup, UDim2.fromScale(0.457, 1))

    elseif LastItem then
        -- Item shows up in popup
        FoundPopup.Thumbnail.Image = ItemModels[LastItem]:GetAttribute("Thumbnail")

        FoundPopup.Text.Text = string.format("(%s/%s) You found a Rocket part: %s!", Completed, Total, LastItem)
        Paths.Audio.Celebration:Play()

        OpenPopup(FoundPopup, UDim2.fromScale(.309, 1))
    end

end


local function LoadCollectable(Item, Placeholder)
    if Placeholder:IsDescendantOf(Paths.Tycoon) and Placeholder.Name == Item then
        UnlockLocation(Item)

        local Collectable = ItemModels[Item]:Clone()
        Collectable:SetPrimaryPartCFrame(Placeholder.CFrame)
        Collectable.Parent = Placeholder.Parent
        TycoonSession:GiveTask(Collectable)

        Placeholder:Destroy()

        local Hitbox = Collectable.PrimaryPart
        Hitbox.CanCollide = false

        local Conn
        Conn = Hitbox.Touched:Connect(function(Hit)
            if Hit.Parent == Paths.Player.Character then
                Conn:Disconnect()

                local Data = Remotes.RocketBuild:InvokeServer(Item)
                if Data then -- Flag for success
                    UnlockingData = Data

                    UnlockItem(Item)
                    UpdateProgress(Item)
                    Collectable:Destroy()
                end

            end

        end)

        return true

    end

end


local function LoadBuildA()
    -- Frame
    for Item in pairs(Modules.BuildADetails.Rocket) do
        local UnlockLbl = ItemList:FindFirstChild(Item)
        if not UnlockLbl then
            UnlockLbl = Dependency.RocketItemTemplate:Clone()
            UnlockLbl.Name = Item
            UnlockLbl.Parent = ItemList

            -- Item Preview
            local Thumbnail = UnlockLbl.Thumbnail
            Thumbnail.Image = ItemModels[Item]:GetAttribute("Thumbnail")

        end

        if UnlockingData[2][Item] then
            UnlockLocation(Item)
            UnlockItem(Item)
        else
            -- Black out lbl
            UnlockLbl.Thumbnail.ImageColor3 = Color3.new(0, 0, 0)

            local NameLbl = UnlockLbl.ItemName
            NameLbl.Text = "???"
            NameLbl.TextColor3 = Color3.new(0, 0, 0)

            local LocationLbl = UnlockLbl.Location
            LocationLbl.Text = "???"
            LocationLbl.TextColor3 = Color3.new(0, 0, 0)


            local Loaded
            for _, Placeholder in ipairs(Services.CollectionService:GetTagged(ITEM_TAG)) do
                if not Loaded and LoadCollectable(Item, Placeholder) then
                    Loaded = true
                end

            end
            if not Loaded then
                local Conn
                Conn = Services.CollectionService:GetInstanceAddedSignal(ITEM_TAG):Connect(function(Placeholder)
                    if LoadCollectable(Item, Placeholder) then
                        Conn:Disconnect()
                    end

                end)

            end

        end

    end

    UpdateProgress()
end

local function Init()
    if not UnlockingData[1] then
        if Remotes.GetStat:InvokeServer("Tycoon")[BROKEN_SHIP_UPGRADE] then
            LoadBuildA()
        else
            local Conn
            Conn = Remotes.ButtonPurchased.OnClientEvent:Connect(function(_, Button)
                if Button == BROKEN_SHIP_UPGRADE then
                    LoadBuildA()
                    Conn:Disconnect()
                end

            end)

        end

    end

end




-- Teleport interface
local LastLocation
local Locations = {}

for _, Location in ipairs(WorldList:GetChildren()) do
    if Location:IsA("ImageButton") then
        Locations[Location.LayoutOrder] = Location

        if Location.LayoutOrder == Paths.Player:GetAttribute("World") then
            LastLocation = Location
            Location.YouAreHere.Visible = true
        end
    end
end

Paths.Player:GetAttributeChangedSignal("World"):Connect(function()
    LastLocation.YouAreHere.Visible = false

    LastLocation = Locations[Paths.Player:GetAttribute("World")]
    LastLocation.YouAreHere.Visible = true

end)

local function SwitchWorld(Location, Destination)
    Location.MouseButton1Down:Connect(function()
        if not Location.YouAreHere.Visible then
            Paths.Audio.BlastOff:Play()

            Modules.Buttons:UIOff(TeleportFrame, true)
            Modules.UIAnimations.BlinkTransition(function()
                Remotes.TeleportInternal:InvokeServer(Destination)
            end, true)

        end

    end)

end

SwitchWorld(WorldList.Main, Paths.Player.Name)
SwitchWorld(WorldList.Woodcutting, "Woodcutting World")

--[[     WorldList.City.MouseButton1Down:Connect(function()
    Modules.Buttons:UIOff(TeleportFrame, true)
    Remotes.TeleportExternal:InvokeServer(Modules.PlaceIds["Penguin City"], game.GameId)
end) *]]


Services.ProximityPrompt.PromptTriggered:Connect(function(Prompt, Player)
    if Player == Paths.Player then
        if Prompt.ActionText == "Fix Rocket" then
            Modules.Buttons:UIOn(ItemFrame , true)
        elseif Prompt.ActionText == "Blast Off" then
            Modules.Buttons:UIOn(UI.Center.WorldTeleport, true)
        end
    end

end)

TeleportFrame.Exit.MouseButton1Down:Connect(function()
    Modules.Buttons:UIOff(TeleportFrame, true)
end)


-- Initialize
Init()
task.spawn(function()
    repeat task.wait() until Modules.Rebirths
    Modules.Rebirths.Rebirthed:Connect(function()
        TycoonSession:Destroy()
        Init()
    end)
end)



return Rocket