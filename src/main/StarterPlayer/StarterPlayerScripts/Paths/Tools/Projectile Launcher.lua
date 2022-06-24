local Launcher = {}

local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes

local COOLDOWN = 0.5
local GRAVITY = -workspace.Gravity
local POWER = 200

local CAMERA_OFFSET = CFrame.new(4, 4, 10)


local Assets = Services.RStorage.Assets.Tools

local Camera = workspace.CurrentCamera
local Mouse = Paths.Player:GetMouse()
local Character, Humanoid


-- Functions
local function GetYAngleBetweenPoints(P1, P2)
    local Offset = P1:PointToObjectSpace(P2)
    return math.atan2(-Offset.Z, Offset.X)
end

local function GetYAngle(CF)
    local _, X, _ = CF:ToEulerAnglesYXZ()
    return X
end


local function LoadCharacter(Char)
    if not Char then return end
    Character = Char
    Humanoid = Character:WaitForChild("Humanoid")

end




function Launcher.new(Name, OnHit)
    local IdleTrack, ShootTrack, Pointing

    return {
        Hit = Modules.Signal.new(),

        Damageables = nil,

        Equipped = function()
            if not Character then return end

            local Handle = Character:WaitForChild("Tool"):WaitForChild("Handle")
            local Nozzle = Handle:WaitForChild("Nozzle")

            -- Load animations
            local Animations = Assets[Name].Animations

            if not ShootTrack then
                ShootTrack = Humanoid:LoadAnimation(Assets[Name].Animations.Shoot)
                if Animations:FindFirstChild("Idle") then
                    IdleTrack = Humanoid:LoadAnimation(Assets[Name].Animations.Idle)

                end
            end

            if IdleTrack then
                IdleTrack:Play()
            end


            -- Camera/Mouse  lock
            local Main = Character.Main
            Humanoid.AutoRotate = true
            local MainNozzleOffset = math.abs(GetYAngleBetweenPoints(Main.CFrame, Nozzle.WorldPosition))
            warn(math.deg(MainNozzleOffset))

            local LookY = GetYAngle(Main.CFrame) -- Horizontal angle. Starts off how character is rotated.
            local LookX = 0 -- Vertical angle

            local ArmR = Main["Arm R"]
            local ArmL = Main["Arm L"]
            local RArmCFrame = CFrame.new(ArmR.C0.Position) * CFrame.fromEulerAnglesYXZ(0, table.unpack(table.pack(ArmR.C0:ToEulerAnglesYXZ()), 2))
            local LArmCFrame = CFrame.new(ArmL.C0.Position) * CFrame.fromEulerAnglesYXZ(ArmR.C0:ToEulerAnglesYXZ() - ArmL.C0:ToEulerAnglesYXZ(), table.unpack(table.pack(ArmL.C0:ToEulerAnglesYXZ()), 2))

            -- Get input
            Services.ContextActionService:BindAction("Camera" .. Name, function(_, _, Input)
                if Input.UserInputState == Enum.UserInputState.Change then
                    local Delta =  Input.Delta
                    LookX = math.clamp(LookX - Delta.Y * 0.01, -math.rad(45), math.rad(45))
                    LookY -= Delta.X * 0.005
                end
            end, false, Enum.UserInputType.MouseMovement, Enum.UserInputType.Touch, Enum.UserInputType.Gamepad1)

            -- Update
            Pointing = Services.RunService.RenderStepped:Connect(function(dt)
                local Alpha = dt * 8

                Services.InputService.MouseBehavior = Enum.MouseBehavior.LockCenter
                Camera.CameraType = Enum.CameraType.Scriptable

                ArmR.C0 = ArmR.C0:Lerp(RArmCFrame * CFrame.fromEulerAnglesYXZ(LookX, 0, 0), Alpha)
                ArmL.C0 = ArmL.C0:Lerp(LArmCFrame * CFrame.fromEulerAnglesYXZ(LookX, 0, 0), Alpha)
                Main.CFrame = CFrame.new(Main.Position) * CFrame.fromEulerAnglesYXZ(0, LookY, 0)

                Camera.CFrame = Main.CFrame * CFrame.fromEulerAnglesYXZ(0, MainNozzleOffset, 0) * CFrame.fromEulerAnglesYXZ(LookX, 0, 0) * CAMERA_OFFSET
            end)

            -- Shooting
            local Debounce
            Services.ContextActionService:BindActionAtPriority(Name, function(_, State)
                if State == Enum.UserInputState.Begin then
                    if not Debounce then
                        Debounce = true

                        -- Play animation
                        ShootTrack:Play()
                        ShootTrack.Stopped:Wait()

                        -- Create and launch projectile
                        local C0 = CFrame.new(Nozzle.WorldPosition) * CFrame.fromEulerAnglesYXZ(LookX, GetYAngle(Main.CFrame) + MainNozzleOffset, 0)

                        local Projectile = Assets[Name].Projectile:Clone()
                        Projectile.Anchored = true
                        Projectile.CFrame = C0
                        Projectile.Parent = workspace

                        local V0 = Vector2.new(POWER, 0)

                        -- Path
                        local et = 0
                        local Shot
                        Shot = Services.RunService.RenderStepped:Connect(function(dt)
                            et += dt / 1.5

                            local Pos = Vector2.new(V0.X * et, (V0.Y * et) + (0.5 * GRAVITY * (et ^ 2)))

                            local CF = C0 * CFrame.new(0, Pos.Y, -Pos.X)
                            Projectile.CFrame = CF * CFrame.fromEulerAnglesYXZ(math.atan2((V0.Y/V0.X) + ((GRAVITY * Pos.X) / V0.X ^ 2), 1), 0, 0)

                            local CollisionPoint = Projectile.Touched:Connect(function() end)
                            for _, Hit in Projectile:GetTouchingParts() do
                                if Hit.Parent ~= Character and Hit.CanCollide and Hit.CanTouch and Hit.Transparency ~= 1 then
                                    local Position = Projectile.Position

                                    Projectile:Destroy()
                                    Shot:Disconnect()

                                    if OnHit(Hit, Position) then
                                        break
                                    end

                                end

                            end

                            CollisionPoint:Disconnect()


                            if Pos.Magnitude > 500 then
                                Projectile:Destroy()
                                Shot:Disconnect()
                            end

                        end)

                        task.wait(COOLDOWN)
                        Debounce = false
                    end

                end

            end, Enum.ContextActionPriority.High.Value, true, Enum.UserInputType.MouseButton1, Enum.UserInputType.Touch, Enum.KeyCode.ButtonR2)

            local Button = Services.ContextActionService:GetButton(script.Name)
            if Button then
                warn("COOL")
            end

        end,

        Unequipped = function()
            if IdleTrack then IdleTrack:Stop() end
            Pointing:Disconnect()

            Humanoid.AutoRotate = true

            Services.InputService.MouseBehavior = Enum.MouseBehavior.Default

            Services.ContextActionService:UnbindAction(Name)
            Services.ContextActionService:UnbindAction("Camera" .. Name)



            Modules.Camera:ResetToCharacter()

        end,

    }

end

-- Events --
LoadCharacter(Paths.Player.Character)
Paths.Player.CharacterAdded:Connect(LoadCharacter)
Paths.Player.CharacterRemoving:Connect(function()
    Character = nil
    Humanoid = nil
end)

return Launcher