local Setup = {}
local Paths = require(script.Parent)
local PromptService = game:GetService("ProximityPromptService")
local SailboatBuild = Paths.Remotes:WaitForChild("SailboatBuild")
local PlaneBuild = Paths.Remotes:WaitForChild("PlaneBuild")
local currentlySelected = "Sail 1"
local currentlySelectedPlane = "Wing 1"
local metalUnlocked = false
local compassUnlocked = false

game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)

local NotifExample = Paths.UI.Main.Notifications.Example

function Setup:Notification(text,color,time)
    if Paths.Audio.Notif.IsPlaying == false then
        Paths.Audio.Notif:Play()
    end
    local notif = NotifExample:Clone()
    notif.Text = text
    notif.BackgroundColor3 = color or Color3.new(0.776470, 0.850980, 0.501960)
    notif.Parent = Paths.UI.Main.Notifications
    notif.Visible = true
    game:GetService("Debris"):AddItem(notif,time or 3)
end

Paths.Remotes.ClientNotif.OnClientEvent:Connect(function(text,color,time)
    Setup:Notification(text,color,time)
end)

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


local function onPromptTriggered(promptObject, player)
    if player == game.Players.LocalPlayer then
        if promptObject.ActionText == "Sailboat" then
            Paths.Modules.Buttons:UIOff(Paths.UI.Center.PlaneUnlock)
			Paths.Modules.Buttons:UIOn(Paths.UI.Center.BoatUnlock,true)
		elseif promptObject.ActionText == "Socials" then
			Paths.Modules.Buttons:UIOn(Paths.UI.Center.Codes,true)
        elseif promptObject.ActionText == "Spin" then
            Paths.Modules.Achievements.ButtonClicked(Paths.UI.Center.Achievements.Buttons.Spin,Paths.UI.Center.Achievements)
			Paths.Modules.Buttons:UIOn(Paths.UI.Center.Achievements,true)
		elseif promptObject.ActionText == "Money" then
			Paths.Modules.Store.ButtonClicked(Paths.UI.Center.Store.Buttons.Money,Paths.UI.Center.Store)
			Paths.Modules.Buttons:UIOn(Paths.UI.Center.Store,true)
		elseif promptObject.ActionText == "Gems" then
			Paths.Modules.Store.ButtonClicked(Paths.UI.Center.Store.Buttons.Gems,Paths.UI.Center.Store)
			Paths.Modules.Buttons:UIOn(Paths.UI.Center.Store,true)
        elseif promptObject.ActionText == "Plane" then
            Paths.Modules.Buttons:UIOff(Paths.UI.Center.BoatUnlock)
            Paths.Modules.Buttons:UIOn(Paths.UI.Center.PlaneUnlock,true)
		elseif promptObject.ActionText == "Buy Poofies!" then
			Paths.Modules.Pets.PetUI.LoadEgg(promptObject:GetAttribute("EggName"),Paths)
			Paths.Modules.Buttons:UIOff(Paths.UI.Center.Pets,true)
			Paths.Modules.Buttons:UIOn(Paths.UI.Center.BuyEgg,true)
        elseif promptObject.ObjectText == "Gamepass" then
            local id = promptObject:GetAttribute("Gamepass")
            Paths.Services.MPService:PromptGamePassPurchase(Paths.Player, id)
        elseif promptObject.ActionText == "Penguin City" then
            Paths.Modules.Teleporting:OpenConfirmation()
            Paths.Modules.Buttons:UIOn(Paths.UI.Center.TeleportConfirmation,true)
        end
    end
end
do -- boat
    local function changeSelected(new)
        local last = currentlySelected
        local UI = Paths.UI.Center.BoatUnlock.Items.Unlocked:FindFirstChild(last)
        UI.BackgroundColor3 = Color3.fromRGB(47, 112, 172)
        UI.UIStroke.Color = Color3.fromRGB(29, 33, 68)

        local UI = Paths.UI.Center.BoatUnlock.Items.Unlocked:FindFirstChild(new)
        UI.BackgroundColor3 = Color3.new(0.231372, 0.6, 0.137254)
        UI.UIStroke.Color = Color3.new(0.101960, 0.254901, 0.062745)

        currentlySelected = new
    end


    local function unlockItem(itemName,doAnim)
        local model = game.ReplicatedStorage.BoatBuildParts:FindFirstChild(itemName)
        local UI = Paths.UI.Center.BoatUnlock.Items.Unlocked:FindFirstChild(itemName)
        local am = 1
        for i,v in pairs (Paths.UI.Center.BoatUnlock.Items.Unlocked:GetChildren()) do
            if v:IsA("Frame") and v.ViewportFrame.ImageColor3 == Color3.new(1,1,1) then
                am = am + 1
            end
        end
        if UI then
            UI.ViewportFrame.ImageColor3 = Color3.new(1,1,1)
            UI.ItemName.Text = itemName
            UI.ItemName.TextColor3 = Color3.new(1,1,1)
            UI.Location.Text = model:GetAttribute("Location")
            UI.Location.TextColor3 = Color3.new(1,1,1)
            if doAnim and am < 10 then
                Paths.UI.Right.Compass.Visible = false
                local n = UI.ViewportFrame:Clone()
                local foundBoatPart = Paths.UI.Top.Bottom.Popups.FoundBoatPart
                if foundBoatPart:FindFirstChild("ViewportFrame") then
                    foundBoatPart.ViewportFrame:Destroy()
                end
                n.Parent = foundBoatPart
                foundBoatPart.Size = UDim2.fromScale(0,0)
                foundBoatPart.Visible = true
                foundBoatPart.Text.Text = "You found a Sailboat part: "..itemName.."!"
                Paths.Audio.Celebration:Play()
                foundBoatPart:TweenSize(UDim2.fromScale(.309,.527),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,.25)
                task.defer(function()
                    foundBoatPart.BottomText.Text = am.."/10 items found"
                    if am == 1 then
                        Paths.Modules.Buttons:UIOn(Paths.UI.Center.FirstBoatPart,true)
                        task.wait(4)
                    else
                        task.wait(3)
                    end
                    foundBoatPart:TweenSize(UDim2.fromScale(0,0),Enum.EasingDirection.In,Enum.EasingStyle.Quad,.25)
                    task.wait(.25)
                    if Paths.UI.Center.PlaneUnlock.Metal.Owned.Visible == true or Paths.UI.Center.BoatUnlock.Compass.Owned.Visible == true then
                        Paths.UI.Right.Compass.Visible = true
                    end
                    foundBoatPart.Visible = false
                end)
            end
        end
        am = 0
        for i,v in pairs (Paths.UI.Center.BoatUnlock.Items.Unlocked:GetChildren()) do
            if v:IsA("Frame") and v.ViewportFrame.ImageColor3 == Color3.new(1,1,1) then
                am = am + 1
            end
        end
        Paths.UI.Center.BoatUnlock.Items.Text.Text =  am.."/10 ITEMS FOUND"
        if doAnim and am == 10 then
            Paths.UI.Right.Compass.Visible = false
            Paths.UI.Top.Bottom.Popups.FoundBoatPart.Visible = false
            local foundBoatPart = Paths.UI.Top.Bottom.Popups.SailboatCompleted
            foundBoatPart.Size = UDim2.fromScale(0,0)
            foundBoatPart.Visible = true
            Paths.Audio.Celebration:Play()
            foundBoatPart:TweenSize(UDim2.fromScale(.457,.778),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,.25)
            task.defer(function()
                task.wait(5)
                foundBoatPart:TweenSize(UDim2.fromScale(0,0),Enum.EasingDirection.In,Enum.EasingStyle.Quad,.25)
                task.wait(.25)
                foundBoatPart.Visible = false
            end)
            Paths.Services.RunService:UnbindFromRenderStep("Compass")
        end
    end


    local function startCompass(selected)
        local UI = Paths.UI.Right.Compass
        local Compass = UI.Compass
        local player = game.Players.LocalPlayer
        Paths.Services.RunService:BindToRenderStep("Compass",Enum.RenderPriority.Camera.Value+1,function()
            if player and player.Character and workspace:FindFirstChild(currentlySelected) then
                local pos = workspace:FindFirstChild(currentlySelected):GetPrimaryPartCFrame().Position
                Compass.Point.Rotation = math.deg(GetRotationInstructionsToPoint(pos).X)
            end
        end)
        Compass.Button.MouseButton1Down:Connect(function()
            Paths.Modules.Buttons:UIOff(Paths.UI.Center.PlaneUnlock)
            Paths.Modules.Buttons:UIOn(Paths.UI.Center.BoatUnlock,true)
        end)
        changeSelected(selected)
        UI.Visible = true
        Compass.Visible = true
    end

    local function activateCompass(selected)
        for i,frame in pairs (Paths.UI.Center.BoatUnlock.Items.Unlocked:GetChildren()) do
            if frame:IsA("Frame") then
                local model = game.ReplicatedStorage.BoatBuildParts:FindFirstChild(frame.Name)
                frame.Location.Text = model:GetAttribute("Location")

                frame.Button.MouseButton1Down:Connect(function()
                    if workspace:FindFirstChild(frame.Name) then
                        changeSelected(frame.Name)
                    end
                end)
            end
        end
        Paths.UI.Center.BoatUnlock.Compass.Owned.Visible = true
        Paths.UI.Center.BoatUnlock.Compass.NotOwned.Visible = false
        startCompass(selected)

        local isOn = true
        local function switch()
            print("switch")
            isOn = not isOn
            if isOn then
                Paths.UI.Center.BoatUnlock.Compass.Owned.ImageButton.On.Text.Text = "Disable"
                Paths.UI.Center.BoatUnlock.Compass.Owned.ImageButton.On.BackgroundColor3 = Color3.fromRGB(255,26,10)
            else
                Paths.UI.Center.BoatUnlock.Compass.Owned.ImageButton.On.Text.Text = "Enable"
                Paths.UI.Center.BoatUnlock.Compass.Owned.ImageButton.On.BackgroundColor3 = Color3.fromRGB(106, 255, 14)
            end
            Paths.UI.Right.Compass.Compass.Visible = isOn
        end

        Paths.UI.Center.BoatUnlock.Compass.Owned.ImageButton.MouseButton1Down:Connect(switch)
        Paths.UI.Center.BoatUnlock.Compass.Owned.ImageButton.On.MouseButton1Down:Connect(switch)
    end

    function SailboatBuild.OnClientInvoke(items)
        if items == "Compass" then
            compassUnlocked = true
            local unlocked = Paths.Remotes:WaitForChild("GetStat"):InvokeServer("BoatUnlocked")
            local selected = "Sail 1"
            for i,v in pairs (unlocked[2]) do
                if v == false then
                    selected = i
                    break
                end
            end
            activateCompass(selected)
        else
            for ModelName,CFra in pairs (items) do
                if CFra == true then
                    unlockItem(ModelName)
                elseif game.ReplicatedStorage.BoatBuildParts:FindFirstChild(ModelName) then
                    local c = game.ReplicatedStorage.BoatBuildParts:FindFirstChild(ModelName):Clone()
                    c:SetPrimaryPartCFrame(CFra)
                    c.Parent = workspace
                    local deb = false
                    c.PrimaryPart.Touched:Connect(function(hit)
                        if deb then return end
                        deb = true
                        if hit.Parent == game.Players.LocalPlayer.Character then
                            CFra = true
                            unlockItem(ModelName,true)
                            local unlocked =  SailboatBuild:InvokeServer(c.Name)
                            local selected = "Sail 1"
                            for i,v in pairs (unlocked[2]) do
                                if v == false then
                                    selected = i
                                    break
                                end
                            end
                            if compassUnlocked then
                                changeSelected(selected)
                            end
                            c:Destroy()
                        end
                        task.wait(.1)
                        deb = false
                    end)
                end
            end
        end
    end

    local unlocked = Paths.Remotes:WaitForChild("GetStat"):InvokeServer("BoatUnlocked")
    local ownsCompass = Paths.Remotes:WaitForChild("GetStat"):InvokeServer("Compass")

    if ownsCompass and unlocked[1] == false then
        compassUnlocked = true
        local selected = "Sail 1"
        for i,v in pairs (unlocked[2]) do
            if v == false then
                selected = i
                break
            end
        end
        activateCompass(selected)
    else
        Paths.UI.Center.BoatUnlock.Compass.NotOwned.ImageButton.MouseButton1Down:connect(function()
            Paths.Services.MPService:PromptProductPurchase(Paths.Player, 1260546076)
        end)
        Paths.UI.Center.BoatUnlock.Compass.NotOwned.ImageButton.Buy.MouseButton1Down:connect(function()
            Paths.Services.MPService:PromptProductPurchase(Paths.Player, 1260546076)
        end)
    end


end

do -- plane
    local function changeSelected(new)
        local last = currentlySelectedPlane
        local UI = Paths.UI.Center.PlaneUnlock.Items.Unlocked:FindFirstChild(last)
        UI.BackgroundColor3 = Color3.fromRGB(47, 112, 172)
        UI.UIStroke.Color = Color3.fromRGB(29, 33, 68)

        local UI = Paths.UI.Center.PlaneUnlock.Items.Unlocked:FindFirstChild(new)
        UI.BackgroundColor3 = Color3.new(0.231372, 0.6, 0.137254)
        UI.UIStroke.Color = Color3.new(0.101960, 0.254901, 0.062745)

        currentlySelectedPlane = new
    end


    local function unlockItem(itemName,doAnim)
        local model = game.ReplicatedStorage.PlaneBuildParts:FindFirstChild(itemName)
        local UI = Paths.UI.Center.PlaneUnlock.Items.Unlocked:FindFirstChild(itemName)
        local am = 1
        for i,v in pairs (Paths.UI.Center.PlaneUnlock.Items.Unlocked:GetChildren()) do
            if v:IsA("Frame") and v.ViewportFrame.ImageColor3 == Color3.new(1,1,1) then
                am = am + 1
            end
        end
        if UI then
            UI.ViewportFrame.ImageColor3 = Color3.new(1,1,1)
            UI.ItemName.Text = itemName
            UI.ItemName.TextColor3 = Color3.new(1,1,1)
            UI.Location.Text = model:GetAttribute("Location")
            UI.Location.TextColor3 = Color3.new(1,1,1)
            if doAnim and am < 10 then
                Paths.UI.Right.Compass.Visible = false
                local n = UI.ViewportFrame:Clone()
                local foundBoatPart = Paths.UI.Top.Bottom.Popups.FoundPlanePart
                if foundBoatPart:FindFirstChild("ViewportFrame") then
                    foundBoatPart.ViewportFrame:Destroy()
                end
                n.Parent = foundBoatPart
                foundBoatPart.Size = UDim2.fromScale(0,0)
                foundBoatPart.Visible = true
                foundBoatPart.Text.Text = "You found a plane part: "..itemName.."!"
                Paths.Audio.Celebration:Play()
                foundBoatPart:TweenSize(UDim2.fromScale(.309,.527),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,.25)
                task.defer(function()
                    foundBoatPart.BottomText.Text = am.."/10 items found"
                    if am == 1 then
                        Paths.Modules.Buttons:UIOn(Paths.UI.Center.FirstPlanePart,true)
                        task.wait(4)
                    else
                        task.wait(3)
                    end
                    foundBoatPart:TweenSize(UDim2.fromScale(0,0),Enum.EasingDirection.In,Enum.EasingStyle.Quad,.25)
                    task.wait(.25)
                    if Paths.UI.Center.PlaneUnlock.Metal.Owned.Visible == true or Paths.UI.Center.BoatUnlock.Compass.Owned.Visible == true then
                        Paths.UI.Right.Compass.Visible = true
                    end
                    foundBoatPart.Visible = false
                end)
            end
        end
        am = 0
        for i,v in pairs (Paths.UI.Center.PlaneUnlock.Items.Unlocked:GetChildren()) do
            if v:IsA("Frame") and v.ViewportFrame.ImageColor3 == Color3.new(1,1,1) then
                am = am + 1
            end
        end
        Paths.UI.Center.PlaneUnlock.Items.Text.Text =  am.."/10 ITEMS FOUND"
        if doAnim and am == 10 then
            Paths.UI.Right.Compass.Visible = false
			Paths.UI.Top.Bottom.Popups.FoundPlanePart.Visible = false
			local foundBoatPart = Paths.UI.Top.Bottom.Popups.PlaneCompleted
            foundBoatPart.Size = UDim2.fromScale(0,0)
            foundBoatPart.Visible = true
            Paths.Audio.Celebration:Play()
            foundBoatPart:TweenSize(UDim2.fromScale(.457,.778),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,.25)
            task.defer(function()
                task.wait(5)
                foundBoatPart:TweenSize(UDim2.fromScale(0,0),Enum.EasingDirection.In,Enum.EasingStyle.Quad,.25)
                task.wait(.25)
                foundBoatPart.Visible = false
            end)
            Paths.Services.RunService:UnbindFromRenderStep("Metal")
        end
    end

    local function startCompass(selected)
        local UI = Paths.UI.Right.Compass
        local Compass = UI.Metal
        local player = game.Players.LocalPlayer
        Paths.Services.RunService:BindToRenderStep("Metal",Enum.RenderPriority.Camera.Value+1,function()
            if player and player.Character and workspace:FindFirstChild(currentlySelectedPlane) then
                local pos = workspace:FindFirstChild(currentlySelectedPlane):GetPrimaryPartCFrame().Position
                Compass.Point.Rotation = math.deg(GetRotationInstructionsToPoint(pos).X)
            end
        end)
        Compass.Button.MouseButton1Down:Connect(function()
            Paths.Modules.Buttons:UIOff(Paths.UI.Center.BoatUnlock)
            Paths.Modules.Buttons:UIOn(Paths.UI.Center.PlaneUnlock,true)
        end)
        changeSelected(selected)
        UI.Visible = true
        Compass.Visible = true
    end

    local function activateCompass(selected)
        for i,frame in pairs (Paths.UI.Center.PlaneUnlock.Items.Unlocked:GetChildren()) do
            if frame:IsA("Frame") then
                local model = game.ReplicatedStorage.PlaneBuildParts:FindFirstChild(frame.Name)
                frame.Location.Text = model:GetAttribute("Location")

                frame.Button.MouseButton1Down:Connect(function()
                    if workspace:FindFirstChild(frame.Name) then
                        changeSelected(frame.Name)
                    end
                end)
            end
        end
        Paths.UI.Center.PlaneUnlock.Metal.Owned.Visible = true
        Paths.UI.Center.PlaneUnlock.Metal.NotOwned.Visible = false
        startCompass(selected)

        local isOn = true
        local function switch()
            print("switch")
            isOn = not isOn
            if isOn then
                Paths.UI.Center.PlaneUnlock.Metal.Owned.ImageButton.On.Text.Text = "Disable"
                Paths.UI.Center.PlaneUnlock.Metal.Owned.ImageButton.On.BackgroundColor3 = Color3.fromRGB(255,26,10)
            else
                Paths.UI.Center.PlaneUnlock.Metal.Owned.ImageButton.On.Text.Text = "Enable"
                Paths.UI.Center.PlaneUnlock.Metal.Owned.ImageButton.On.BackgroundColor3 = Color3.fromRGB(106, 255, 14)
            end
            Paths.UI.Right.Compass.Metal.Visible = isOn
        end
        Paths.UI.Center.PlaneUnlock.Metal.Owned.ImageButton.MouseButton1Down:Connect(switch)
        Paths.UI.Center.PlaneUnlock.Metal.Owned.ImageButton.On.MouseButton1Down:Connect(switch)
    end

    function PlaneBuild.OnClientInvoke(items)
        if items == "Compass" then
            metalUnlocked = true
            local unlocked = Paths.Remotes:WaitForChild("GetStat"):InvokeServer("PlaneUnlocked")
            local selected = "Wing 1"
            for i,v in pairs (unlocked[2]) do
                if v == false then
                    selected = i
                    break
                end
            end
            activateCompass(selected)
        else
            print("SET UP CLIENT:",items)
            for ModelName,CFra in pairs (items) do
                if CFra == true then
                    unlockItem(ModelName)
                elseif game.ReplicatedStorage.PlaneBuildParts:FindFirstChild(ModelName) then
                    local c = game.ReplicatedStorage.PlaneBuildParts:FindFirstChild(ModelName):Clone()
                    c:SetPrimaryPartCFrame(CFra)
                    c.Parent = workspace
                    local deb = false
                    c.PrimaryPart.Touched:Connect(function(hit)
                        if deb then return end
                        deb = true
                        if hit.Parent == game.Players.LocalPlayer.Character then
                            print("UNLOCK ITEM",c.Name)
                            CFra = true
                            unlockItem(ModelName,true)
                            local unlocked = PlaneBuild:InvokeServer(c.Name)
                            if unlocked then
                                print("ATTEMPT UNLOCK 2")
                                local selected = "Wing 1"
                                for i,v in pairs (unlocked[2]) do
                                    if v == false then
                                        selected = i
                                        break
                                    end
                                end
                                if metalUnlocked then
                                    print("HAS DETECTOR")
                                    changeSelected(selected)
                                end
                                print(c,"DESTROY")
                                c:Destroy()
                            end
                        end
                        task.wait(.1)
                        deb = false
                    end)
                end
            end
        end
    end

    local unlocked = Paths.Remotes:WaitForChild("GetStat"):InvokeServer("PlaneUnlocked")
    local ownsCompass = Paths.Remotes:WaitForChild("GetStat"):InvokeServer("MetalDetector")

    if ownsCompass and unlocked[1] == false then
        metalUnlocked = true
        local selected = "Wing 1"
        for i,v in pairs (unlocked[2]) do
            if v == false then
                selected = i
                break
            end
        end
        activateCompass(selected)
    else
        Paths.UI.Center.PlaneUnlock.Metal.NotOwned.ImageButton.MouseButton1Down:connect(function()
            Paths.Services.MPService:PromptProductPurchase(Paths.Player, 1265460820)
        end)
        Paths.UI.Center.PlaneUnlock.Metal.NotOwned.ImageButton.Buy.MouseButton1Down:connect(function()
            Paths.Services.MPService:PromptProductPurchase(Paths.Player, 1265460820)
        end)
    end


end

PromptService.PromptTriggered:Connect(onPromptTriggered)

return Setup