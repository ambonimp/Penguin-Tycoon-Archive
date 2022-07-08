local Rocket = {}




local Paths = require(script.Parent.Parent)
local Modules = Paths.Modules
local Services = Paths.Services
local Remotes = Paths.Remotes
local UI = Paths.UI

local Dependency = Services.RStorage.ClientDependency.BuildA

-- local TeleportFrame = UI.Center.RocketTeleportFrame

local ItemFrame = UI.Center.RocketItems
local ItemList = ItemFrame.Items.Unlocked
local ProgressLbl = ItemFrame.Items.Progress

local CollectFirstFrame = UI.Center.FirstRocketPart

local FoundPopup = UI.Top.Bottom.Popups.FoundRocketItem
local CompletedPopup = UI.Top.Bottom.Popups.RocketCompleted


local UPGRADE = "Rocketship#1"
local BROKEN_SHIP_UPGRADE = "New Island!#12"

local ITEM_TAG = "BuildAItem" -- Collection service tag, how items are found when added to tycoon



local UnlockingData = Remotes.GetStat:InvokeServer("RocketUnlocked")
local ItemModels =  Services.RStorage.RocketBuildItems


local function CreatePrompt(Parent, ActionText, ObjectText)
    local Prompt = Instance.new("ProximityPrompt")
    Prompt.HoldDuration = 0.25
    Prompt.MaxActivationDistance = 15
    Prompt.RequiresLineOfSight = false
    Prompt.ObjectText = ObjectText or ""
    Prompt.ActionText = ActionText
    Prompt.Parent = Parent

    return Prompt
end

-- Creates arrow to brocken rocket when rocket is unlocked
local function LeadToBuildA(Item)
    local Character = Paths.Player.Character
    if not Character then return end

    task.spawn(function()
        local Upgrade = Paths.Tycoon.Tycoon:WaitForChild(Item)
        local InfoPart = Upgrade:WaitForChild("InfoPart", math.huge)
        local Hitbox = Upgrade:WaitForChild("Hitbox", math.huge)

        local Att0 = Instance.new("Attachment")
        Att0.Parent = Character.Main

        local Att1 = Instance.new("Attachment")
        Att1.Parent = InfoPart

        local Beam = Paths.Services.RStorage.ClientDependency.Help.Pointer:Clone()
        Beam.Color = ColorSequence.new(Color3.fromRGB(255, 0, 255))
        Beam.Parent = InfoPart
        Beam.Attachment0 = Att0
        Beam.Attachment1 = Att1

        local Conn
        Conn = Hitbox.Touched:Connect(function(Hit)
            if Hit.Parent == Character then
                Beam:Destroy()
                Att0:Destroy()
                Conn:Disconnect()
            end

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
        LeadToBuildA(UPGRADE)
        OpenPopup(CompletedPopup, UDim2.fromScale(0.457, 1))
    elseif LastItem then
        FoundPopup.Text.Text = string.format("You found a sailboat  part: %s!", LastItem)
        Paths.Audio.Celebration:Play()

        OpenPopup(FoundPopup, UDim2.fromScale(.309, 1))
    end

end

local function UnlockLocation(Item)
    local Lbl = ItemList[Item]
    local Upgrade = Modules.BuildADetails.Rocket[Item]

    local LocationLbl = Lbl.Location
    LocationLbl.Text = Modules.ProgressionDetails[Remotes.GetIslandIndex:InvokeServer(Upgrade)].Alias
    LocationLbl.TextColor3 = Color3.new(255, 255, 255)

end

local function UnlockItem(Item)
    local Lbl = ItemList[Item]

    Lbl.ViewportFrame.ImageColor3 = Color3.new(255, 255, 255)

    local NameLbl = Lbl.ItemName
    NameLbl.Text = Item
    NameLbl.TextColor3 = Color3.new(255, 255, 255)

end

local function LoadCollectable(Item, Placeholder)
    if Placeholder:IsDescendantOf(Paths.Tycoon) and Placeholder.Name == Item then
        UnlockLocation(Item)

        local Collectable = ItemModels[Item]:Clone()
        Collectable:SetPrimaryPartCFrame(Placeholder.CFrame)
        Collectable.Parent = Placeholder.Parent

        Placeholder:Destroy()

        local Hitbox = Collectable.PrimaryPart
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
    local BrokenModel = Paths.Tycoon.Tycoon:WaitForChild(BROKEN_SHIP_UPGRADE):WaitForChild("BrokenRocketShip")

    local Prompt = CreatePrompt(BrokenModel:WaitForChild("Ship"), "Rocket", "Under Construction")
    Prompt.Triggered:Connect(function()
        if not ItemFrame.Visible then
            Modules.Buttons:UIOn(ItemFrame, true)
        end
    end)

    -- Frame
    for Item in pairs(Modules.BuildADetails.Rocket) do
        local UnlockLbl = Dependency.RocketItemTemplate:Clone()
        UnlockLbl.Name = Item
        UnlockLbl.Parent = ItemList

        -- Item Preview
        local Viewport = UnlockLbl.ViewportFrame

        local ViewportCam = Instance.new("Camera", Viewport)
        ViewportCam.FieldOfView = 1

        Viewport.CurrentCamera = ViewportCam

        local ViewportModel = ItemModels[Item]:Clone()
        ViewportModel.Parent = Viewport
        local ModelCF, ModelSize = ViewportModel:GetBoundingBox()

        local Offset = (ModelSize.Y / 2) / math.tan(math.rad(ViewportCam.FieldOfView / 2)) + (ModelSize.Z / 2)
        ViewportCam.CFrame = ModelCF * CFrame.new(0, math.pi, 0) * CFrame.new(0, 0, Offset)


        if UnlockingData[2][Item] then
            UnlockLocation(Item)
            UnlockItem(Item)

        else
            -- Black out lbl
            UnlockLbl.ViewportFrame.ImageColor3 = Color3.new(0, 0, 0)

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

local function LoadTeleporter()
--[[-- Load teleporter
    local Prompt = CreatePrompt(Paths.Tycoon.Tycoon:WaitForChild("RocketShip#1").PromptPart, "Blast Off")

    Prompt.Triggered:Connect(function()
        if not ItemFrame.Visible then
            Modules.Buttons:UIOn(TeleportFrame, true)
        end
    end)

    TeleportFrame.Exit.MouseButton1Down:Connect(function()
        Modules.Buttons:UIOff(TeleportFrame, true)
    end)
 *]]
end


if UnlockingData[1] then
    LoadTeleporter()
else
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

return Rocket