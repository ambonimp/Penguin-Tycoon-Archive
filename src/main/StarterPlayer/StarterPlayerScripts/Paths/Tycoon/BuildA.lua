local BuildA = {}

local Paths = require(script.Parent.Parent)
local Modules = Paths.Modules
local Services = Paths.Services
local Remotes = Paths.Remotes
local UI = Paths.UI

local Dependency = Services.RStorage.ClientDependency.BuildA

local TycoonSession = Modules.Maid.new()

local SailboatSearch
local PlaneSearch

local HELPING_BUTTON_COLOR = Color3.fromRGB(33, 118, 23)



local function LeadToUpgrade(Upgrade)
    local Character = Paths.Player.Character
    if not Character then return end

    task.spawn(function()
        local Model = Paths.Tycoon.Tycoon:WaitForChild(Upgrade)
        local InfoPart = Model:WaitForChild("InfoPart", math.huge)
        local Hitbox = Model:WaitForChild("Hitbox", math.huge)

        local Att0 = Instance.new("Attachment")
        Att0.Parent = Character.Main
        TycoonSession:GiveTask(Att0)

        local Att1 = Instance.new("Attachment")
        Att1.Parent = InfoPart
        TycoonSession:GiveTask(Att1)

        local Beam = Paths.Services.RStorage.ClientDependency.Help.Pointer:Clone()
        Beam.Color = ColorSequence.new(Color3.fromRGB(255, 0, 255))
        Beam.Parent = InfoPart
        Beam.Attachment0 = Att0
        Beam.Attachment1 = Att1
        TycoonSession:GiveTask(Beam)

        local SpawnTask
        SpawnTask = TycoonSession:GiveTask(Hitbox.Touched:Connect(function(Hit)
            if Hit.Parent == Character then
                Beam:Destroy()
                Att0:Destroy()

                TycoonSession[SpawnTask] = nil

            end
        end))

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

function GetAngle(vector1, vector2)
	return math.acos(math.clamp(vector1.Unit:Dot(vector2.Unit), -1, 1))
end

function GetRotationInstructionsToPoint(position)
    -- Get Camera Vectors
    local camera = workspace.CurrentCamera
    local cameraCframe = camera.CFrame
    local cameraDirection = cameraCframe.LookVector.Unit
    local cameraRightDirection = cameraCframe.RightVector.Unit
    local cameraLeftDirection = -cameraRightDirection

    -- Get to-point Vectors
    local cameraToPoint = position - cameraCframe.Position
    local cameraToPointDirection = cameraToPoint.Unit

    --------------------------
    -- X
    local rotationX = GetAngle(
        Vector3.new(cameraDirection.X, 0, cameraDirection.Z),
        Vector3.new(cameraToPointDirection.X, 0, cameraToPointDirection.Z)
    )

    -- Calculate if this vector leans more to the left or to the right of the camera
    local rotationXRight = GetAngle(
        Vector3.new(cameraRightDirection.X, 0, cameraRightDirection.Z),
        Vector3.new(cameraToPointDirection.X, 0, cameraToPointDirection.Z)
    )

    local rotationXLeft = GetAngle(
        Vector3.new(cameraLeftDirection.X, 0, cameraLeftDirection.Z),
        Vector3.new(cameraToPointDirection.X, 0, cameraToPointDirection.Z)
    )

    if rotationXLeft < rotationXRight then
        rotationX = -rotationX
    end

    --------------------------
    -- Y
    local rotationY = GetAngle(
        Vector3.new(
            1,
            cameraDirection.Y,
            0
        ),
        Vector3.new(
            1,
            cameraToPointDirection.Y,
            0
        )
    )

    if cameraDirection.Y < cameraToPointDirection.Y then
        rotationY = -rotationY
    end

    return Vector2.new(rotationX, rotationY)
end


local function CreateBuildA(self, Name, States, HelperProduct, FixedUpgrade)
    local Models = Services.RStorage.Assets.BuildA[Name]

    -- UI Instances
    local Frame = UI.Center[string.format("%sUnlock", Name)]
    local ItemButtons = Frame.Items.Unlocked
    local HelperContainer = Frame.Helper

    local FirstPartFrame = UI.Center[string.format("First%sPart", Name)]

    local ProgressPopup = UI.Top.Bottom.Popups[string.format("Found%sItem", Name)]
    local ProgressPopupSize = ProgressPopup.Size

    local CompletedPopup = UI.Top.Bottom.Popups[string.format("%sCompleted", Name)]
    local CompletedPopupSize = CompletedPopup.Size

    local Helper = Paths.UI.Right.Compass[Name]


    if not self then-- First time initializing
        self = {}

        local ITEM_BUTTON_TEMPLATE = Dependency.ItemTemplate
        local DEFAULT_ITEM_BUTTON_COLOR = ITEM_BUTTON_TEMPLATE.BackgroundColor3

        local HELPER_BINDING = "Helper" .. Name

        local HelpingFind

        self.HelperUnlocked = false
        self.ToComplete = 0

        function self:UnlockHelper(Enable)
            self.HelperUnlocked = true

            if Enable then
                self:OpenHelper()
            else
                self:CloseHelper()
            end

            HelperContainer.NotOwned.Visible = false
            HelperContainer.Owned.Visible = true

            HelperContainer.Owned.Toggle.MouseButton1Down:connect(function()
                if HelpingFind then
                    self:CloseHelper()
                else
                    self:OpenHelper()
                end
            end)

            Helper.Button.MouseButton1Down:Connect(function()
                if not Frame.Visible then
                    Modules.Buttons:UIOn(Frame, true)
                end
            end)

            for _, Button in ipairs(ItemButtons:GetChildren()) do
                if Button:IsA("ImageButton") then
                    Button.Selectable = true

                    Button.Location.Text = Models[Button.Name]:GetAttribute("Location")
                end
            end

        end

        function self:CloseHelper()
            if HelpingFind then
                ItemButtons[HelpingFind].BackgroundColor3 = DEFAULT_ITEM_BUTTON_COLOR
                Helper.Visible = false
                HelpingFind = nil

                Paths.Services.RunService:UnbindFromRenderStep(HELPER_BINDING)
            end

            HelperContainer.Owned.Toggle.On.Text.Text = "Enable"
            HelperContainer.Owned.Toggle.On.BackgroundColor3 = Color3.fromRGB(106, 255, 14)
        end

        function self:OpenHelper(Item)
            if not Item and not HelpingFind then
                for _, PotentialItem in ipairs(ItemButtons:GetChildren()) do
                    if PotentialItem:IsA("ImageButton") and not PotentialItem:GetAttribute("Unlocked") then
                        Item = PotentialItem.Name
                        break
                    end
                end

            end

            if HelpingFind then
                self:CloseHelper(true) -- Close previous
            end

            if Item then
                HelpingFind = Item

                ItemButtons[Item].BackgroundColor3 = HELPING_BUTTON_COLOR

                HelperContainer.Owned.Toggle.On.Text.Text = "Disable"
                HelperContainer.Owned.Toggle.On.BackgroundColor3 = Color3.fromRGB(255,26,10)

                -- Actual navigation
                Helper.Visible = true

                local Player = Paths.Player
                local Character = Player.Character
                Paths.Services.RunService:BindToRenderStep(HELPER_BINDING, Enum.RenderPriority.Camera.Value + 1,function()
                    local Model = workspace:FindFirstChild(Item)
                    if Player and Character and Model then
                        local Pos = Model:GetPrimaryPartCFrame().Position
                        Helper.Point.Rotation = math.deg(GetRotationInstructionsToPoint(Pos).X)
                    end

                end)

            end

        end

        function self:LockItem(Item)
            local Button = ItemButtons[Item]
            Button.LayoutOrder = 0
            Button.ViewportFrame.ImageColor3 = Color3.fromRGB(0, 0, 0)

            Button.ItemName.Text = "???"
            Button.ItemName.TextColor3 = Color3.fromRGB(0, 0, 0)

            Button.Location.Text = if self.HelperUnlocked then Models[Item]:GetAttribute("Location") else "???"
            Button.Location.TextColor3 = Color3.fromRGB(0, 0, 0)

            Button:SetAttribute("Unlocked", false)

        end

        function self:UnlockItem(Item, Setup)
            self.Completed += 1

            if not Setup then
                -- warn(self.Completed, self.ToComplete)

                if self.Completed == self.ToComplete then
                    Paths.Audio.FullyRepaired:Play()

                    self:CloseHelper()
                    LeadToUpgrade(FixedUpgrade)

                    OpenPopup(CompletedPopup, CompletedPopupSize)
                else
                    if self.Completed == 1 then
                        Modules.Buttons:UIOn(FirstPartFrame, false)
                    end


                    ProgressPopup.Text.Text = string.format("(%s/%s) You found a %s part: %s!", self.Completed, self.ToComplete, Name, Item)
                    OpenPopup(ProgressPopup, ProgressPopupSize)

                end

            end

            -- Update progress
            Frame.Items.Text.Text = string.format("%s/%s ITEMS FOUND", self.Completed, self.ToComplete)

            local Button = ItemButtons[Item]
            Button.LayoutOrder = 1
            Button.ViewportFrame.ImageColor3 = Color3.fromRGB(255, 255, 255)

            Button.ItemName.Text = Item
            Button.ItemName.TextColor3 = Color3.fromRGB(255, 255, 255)

            Button.Location.Text = Models[Item]:GetAttribute("Location")
            Button.Location.TextColor3 = Color3.fromRGB(255, 255, 255)

            Button:SetAttribute("Unlocked", true)
        end

        -- Load items
        for _, Model in ipairs(Models:GetChildren()) do
            self.ToComplete += 1

            local Item = Model.Name

            local Button = ITEM_BUTTON_TEMPLATE:Clone()
            Button.Name = Item
            Button.Selectable = false
            Button.Parent = ItemButtons

            -- Item Preview
            local Viewport = Button.ViewportFrame

            local ViewportCam = Instance.new("Camera", Viewport)
            ViewportCam.FieldOfView = 1

            Viewport.CurrentCamera = ViewportCam

            local ViewportModel = Models[Item]:Clone()
            ViewportModel.Parent = Viewport
            local o, ModelSize = ViewportModel:GetBoundingBox()
            local ModelCF = ViewportModel.PrimaryPart.CFrame


            local Offset = (ModelSize.Y / 2) / math.tan(math.rad(ViewportCam.FieldOfView / 2)) + (ModelSize.Z / 2)
            ViewportCam.CFrame = ModelCF * CFrame.new(0, math.pi, 0) * CFrame.new(0, 0, Offset)

--[[             if Item == "Deck" then
                warn(ModelSize)
                print(ViewportCam.FieldOfView)
                warn(Offset)
            end *]]


            Button.MouseButton1Down:Connect(function()
                if not Button:GetAttribute("Unlocked") and self.HelperUnlocked then
                    self:OpenHelper(Item)
                end
            end)

        end

        if Remotes.GetStat:InvokeServer(HelperProduct.Name) then
            self:UnlockHelper()
        else
            HelperContainer.NotOwned.Visible = true
            HelperContainer.Owned.Visible = false
            Helper.Visible = false

            HelperContainer.NotOwned.Buy.MouseButton1Down:connect(function()
                Paths.Services.MPService:PromptProductPurchase(Paths.Player, HelperProduct.Id)
            end)

        end

    end

    -- Reset progress
    self.Completed = 0

    -- Update items
    for Item, Info in pairs(States) do
        if Info == true then -- Unlocked
            self:UnlockItem(Item, true)

        else -- Info is part's cframe
            self:LockItem(Item)

            local Collectable = Models[Item]:Clone()
            Collectable:SetPrimaryPartCFrame(Info)
            Collectable.Parent = workspace
            TycoonSession:GiveTask(Collectable)

            local CollectTask
            CollectTask = TycoonSession:GiveTask(Collectable.PrimaryPart.Touched:Connect(function(Hit)
                if Hit.Parent == Paths.Player.Character then
                    TycoonSession[CollectTask]:Disconnect()
                    Collectable:Destroy()

                    if Remotes[Name .. "Build"]:InvokeServer(Item) then
                        self:UnlockItem(Item)

                        if self.HelperUnlocked then
                            self:CloseHelper()
                            task.wait(2)
                            self:OpenHelper()
                        end

                    end

                end

            end))


        end

    end

    TycoonSession:GiveTask(function()
        self:CloseHelper()
    end)

    return self
end



-- Setup
Remotes.SailboatBuild.OnClientInvoke = function(Items)
    if typeof(Items) == "string" then
        if SailboatSearch then
            SailboatSearch:UnlockHelper(true)
        end
    else
        SailboatSearch = CreateBuildA(
            SailboatSearch,
            "Sailboat",
            Items,
            {Name = "Compass", Id = 1260546076},
            "Sailboat#1"
        )
    end

end

Remotes.PlaneBuild.OnClientInvoke = function(Items)
    if typeof(Items) == "string" then
        if PlaneSearch then
            PlaneSearch:UnlockHelper(true)
        end
    else
        PlaneSearch = CreateBuildA(
            PlaneSearch,
            "Plane",
            Items,
            {Name = "MetalDetector", Id = 1265460820},
            "Plane#1"
        )
    end

end

Modules.Rebirths.Rebirthed:Connect(function()
    TycoonSession:Destroy()
end)

return BuildA