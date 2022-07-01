local VehicleSpawner = {}

local PLACE_RADIUS = 500
local TOOL = script.Name
local GAMEPASS = 54396254

--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes
local UI = Paths.UI
local Dependency = Services.RStorage.ClientDependency["VehicleSpawner"]

local Menu = UI.Center["VehicleSpawner"]
local PlacingScreen = UI.Center["VehiclePlacing"]


local Mouse = Paths.Player:GetMouse()
local Camera = workspace.CurrentCamera




local Equipped = false
local Placement = Modules.Maid.new()

local DisabledPrompts


local function BindControl(Handler, Button, Gamepad, Keyboard)
    Placement:GiveTask(Button.MouseButton1Down:Connect(Handler))

    local Keybind = Button.Keybind
    if Services.InputService.TouchEnabled and not Services.InputService.MouseEnabled then
        -- Mobile
        Keybind.Visible = false
    else
        Keybind.Visible = true

        if Services.InputService.GamepadEnabled then
            Keybind.Gamepad.Visible = true
            Keybind.Keyboard.Visible = false
        else
            Keybind.Gamepad.Visible = false
            Keybind.Keyboard.Visible = true
        end

        Placement:GiveTask(Services.InputService.GamepadConnected:Connect(function()
            Keybind.Gamepad.Visible = true
            Keybind.Keyboard.Visible = false
        end))
        Placement:GiveTask(Services.InputService.GamepadDisconnected:Connect(function()
            Keybind.Gamepad.Visible = false
            Keybind.Keyboard.Visible = true
        end))

        Services.ContextActionService:BindActionAtPriority(Button.Name, function(_, state)
			if state == Enum.UserInputState.Begin then
				Handler()
			end
		end, false, Enum.ContextActionPriority.High.Value, Gamepad, Keyboard)

        Placement:GiveTask(function()
            Services.ContextActionService:UnbindAction(Button.Name)
        end)

    end

end

local function ToggleProximityPrompts(Toggle)
    if Toggle then
        for Prompt, Parent in pairs(DisabledPrompts) do
            Prompt.Parent = Parent
        end
    else
        DisabledPrompts = {}
        for _, Prompt in ipairs(workspace:GetDescendants()) do
            if Prompt:IsA("ProximityPrompt") then
                DisabledPrompts[Prompt] = Prompt.Parent
                Prompt.Parent = Services.RStorage
            end
        end

        Placement:GiveTask(workspace.DescendantAdded:Connect(function(Prompt)
            if Prompt:IsA("ProximityPrompt") then
                DisabledPrompts[Prompt] = Prompt.Parent
                Prompt.Parent = Services.RStorage
            end
        end))

    end

end


local function UnlockVehicle(Spawner, DisplayName, Details)
    Spawner.Parent.LayoutOrder = Details.LayoutOrder

    Spawner.Thumbnail.ImageColor3 = Color3.new(255, 255, 255)

    Spawner.DisplayName.Text = DisplayName
    Spawner.DisplayName.Text = DisplayName
    Spawner.DisplayName.TextColor3 = Color3.fromRGB(255, 255, 255)
    Spawner.UIStroke.Color = Color3.fromRGB(125, 33, 226)

end


function VehicleSpawner.Equipped()
    if not Remotes.GetStat:InvokeServer("Gamepasses")[tostring(GAMEPASS)] then
        Services.MPService:PromptGamePassPurchase(Paths.Player, GAMEPASS)
        Remotes.Tools:FireServer("Equip Tool", TOOL)
    else
        Equipped = true
        Modules.Buttons:UIOn(Menu, true)
    end
end

function VehicleSpawner.Unequipped()
    Equipped = false
    if Paths.Player:GetAttribute("Tool") == TOOL then
        Remotes.Tools:FireServer("Equip Tool", TOOL)
    end

    Placement:Destroy()
    Modules.Buttons:UIOff(Menu, true)

end


-- Load menu
for Id, Details in pairs(Modules.VehicleDetails) do
    local Type = Details.Type
    local Source = Details.Source

    local Island = if Source == "Button" then Remotes.GetTemplateButtonAttribute:InvokeServer(Id, "Island") else Details.Island
    local DisplayName = Remotes.GetTemplateUpgradeAttribute:InvokeServer(Island, Id, "Vehicle")
    local Model = Services.RStorage.Assets.Vehicles[DisplayName]
    local Unlocked = Paths.Tycoon.Tycoon:FindFirstChild(Id)

    local Spawner = Dependency.VehicleTemplate:Clone()
    Spawner.Parent = Menu.Vehicles.List
    Spawner.Name = Id

    -- Appearance
    Spawner = Spawner.Button

    -- Viewport stuff
    local Thumb = Spawner.Thumbnail
    Thumb.Image = Details.Thumbnail

    if Unlocked then
        UnlockVehicle(Spawner, DisplayName, Details)
    else
        Spawner.Parent.LayoutOrder = Modules.FuncLib.DictLength(Modules.VehicleDetails) + Details.LayoutOrder
        Spawner.DisplayName.Text = "???"

        Thumb.ImageColor3 = Color3.new(0, 0, 0)
        Spawner.DisplayName.TextColor3 = Color3.new()
        Spawner.UIStroke.Color = Color3.new()


        local Conn
        Conn = Paths.Tycoon.Tycoon.ChildAdded:Connect(function(Purchased)
            if Purchased.Name == Id then
                Conn:Disconnect()
                Unlocked = true

                UnlockVehicle(Spawner, DisplayName, Details)
            end
        end)

    end


    Spawner.MouseButton1Down:Connect(function()
        if Unlocked then
            local Character = Paths.Player.Character
            if Character then
                -- Hide interface
                ToggleProximityPrompts(false)

                Modules.Buttons:UIOff(Menu, true)
                Modules.Buttons:UIOn(PlacingScreen, false)

                Paths.UI.Left.Visible = false
                Paths.UI.Right.Visible = false
                Paths.UI.Bottom.Visible = false
                Paths.UI.BLCorner.Visible = false
                Paths.UI.Top.Visible = false

                -- Placement
                local Preview = Model:Clone()
                for _, Descendant in ipairs(Preview:GetDescendants()) do
                    if Descendant:IsA('BasePart') or Descendant:IsA("Model") and not Descendant:IsA("VehicleSeat") then
                        if Descendant:IsA("BasePart") then
                            Descendant.Anchored = true
                            Descendant.CanCollide = false
                        end
                    else
                        Descendant:Destroy()
                    end

                end

                local Highlight = Instance.new("Highlight")
                Highlight.Adornee = Preview
                Highlight.FillTransparency = 0.6
                Highlight.OutlineTransparency = 0
                Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                Highlight.Parent = Preview

                Preview.Parent = workspace
                Placement:GiveTask(Preview)


                local RParams = RaycastParams.new()
                RParams.FilterDescendantsInstances = {Preview, Character}
                RParams.FilterType = Enum.RaycastFilterType.Blacklist
                RParams.IgnoreWater = false

                local OParams = OverlapParams.new()
                OParams.FilterDescendantsInstances = {Preview}
                OParams.FilterType = Enum.RaycastFilterType.Blacklist


                local CF, Size = Model:GetBoundingBox()
                local PrimaryPartOffset = CF:ToObjectSpace(Model.PrimaryPart.CFrame)

                local Rotation = CFrame.new()

                local CanPlace
                Placement:GiveTask(Services.RunService.RenderStepped:Connect(function()
                    local X = Mouse.X
                    local Y = Mouse.Y

                    local OccludingGui = Paths.Player.PlayerGui:GetGuiObjectsAtPosition(X, Y)
                    for _, Object in ipairs(OccludingGui) do
                        if Object.Visible and (Object.BackgroundTransparency ~= 1 or (if Object:IsA("ImageLabel") then Object.ImageTransparency ~= 1 else false)) then
                            -- warn(Object, Object.Visible, Object.BackgroundTransparency, (if Object:IsA("ImageLabel") then Object.ImageTransparency else false))
                            return
                        end
                    end

                    -- Get mouse position while. Doesn't use mouse.Hit because we want to ignore more than one thing
                    local Resuls = workspace:Raycast(Camera.CFrame.Position, Camera:ScreenPointToRay(X, Y, 0).Direction  * PLACE_RADIUS, RParams)
                    if Resuls then
                        CF = CFrame.new(Resuls.Position+Vector3.new(0, Size.Y/2, 0)) * Rotation
                        Preview:SetPrimaryPartCFrame(CF*PrimaryPartOffset)

                        -- Can only place if not colliding with anything
                        CanPlace = true
                        local Colliding = workspace:GetPartBoundsInBox(CF + Vector3.new(0, 1, 0), Size,  OParams) -- Elevate a little
                        for _, Part in ipairs(Colliding) do
                            if Part.CanCollide and Part.Transparency ~= 1 then
                                CanPlace = false
                                break
                            end
                        end

                        -- Boats must spawn on water
                        if CanPlace and Type == "Boat" then
                            local Results = workspace:Raycast(CF.Position, Vector3.new(0, -Size.Y*0.6, 0), RParams)
                            if Results then
                                CanPlace = Results.Instance == workspace.Terrain
                            end
                        end

                        local HColor = CanPlace and Color3.fromRGB(100, 215, 24) or Color3.fromRGB(255, 0, 0)
                        Highlight.FillColor = HColor
                        Highlight.OutlineColor = HColor
                    end

                end))

                -- Controlls
                game:GetService("GuiService").AutoSelectGuiEnabled = false

                -- Place
                BindControl(function()
                    if CanPlace then
                        Remotes.VehicleSpawned:FireServer(Id, CF)
                        VehicleSpawner.Unequipped()
                    end
                end, PlacingScreen.Place, Enum.KeyCode.ButtonL2, Enum.UserInputType.MouseButton1)

                -- Rotating
                BindControl(function()
                    Rotation *= CFrame.fromEulerAnglesYXZ(0, math.pi/4, 0)
                end, PlacingScreen.Rotate, Enum.KeyCode.ButtonR2, Enum.KeyCode.R)

                -- Canceling
                BindControl(function()
                    Modules.Buttons:UIOn(Menu, true)
                    Placement:Destroy()
                end, PlacingScreen.Cancel, Enum.KeyCode.ButtonB, Enum.KeyCode.Backspace)



                Placement:GiveTask(Character.Humanoid.Died:Connect(function()
                    Placement:Destroy()
                end))

                Placement:GiveTask(function()
                    game:GetService("GuiService").AutoSelectGuiEnabled = true

                    -- Interface
                    Modules.Buttons:UIOff(PlacingScreen, false)
                    ToggleProximityPrompts(true)

                	Paths.UI.Left.Visible = true
                    Paths.UI.Right.Visible = true
                	Paths.UI.Bottom.Visible = true
                    Paths.UI.Top.Visible = true
                    Paths.UI.BLCorner.Visible = true


                end)

            end

        end

    end)

end

-- Events
Menu.Exit.MouseButton1Down:Connect(function()
    VehicleSpawner.Unequipped()
end)

return VehicleSpawner