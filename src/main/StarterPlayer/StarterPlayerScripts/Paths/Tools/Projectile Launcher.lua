local Launcher = {}

local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes

local COOLDOWN = 0.5
local GRAVITY = -workspace.Gravity
local POWER = 350

local Assets = Services.RStorage.Assets.Tools

local Camera = workspace.CurrentCamera
local Mouse = Paths.Player:GetMouse()
local Character, Humanoid


-- Functions
local function LoadCharacter(Char)
    if not Char then return end
    Character = Char
    Humanoid = Character:WaitForChild("Humanoid")

end




function Launcher.new(Name, OnHit)
    local IdleTrack, ShootTrack
    Paths.Player.CharacterRemoving:Connect(function()
        ShootTrack = nil
        IdleTrack = nil
    end)

    return {
        Hit = Modules.Signal.new(),

        Damageables = nil,

        Equipped = function()
            if not Character or Paths.Player:GetAttribute("Tool") ~= Name then return end

            local Handle = Character:WaitForChild("Tool"):WaitForChild("Handle")
            local Nozzle = Handle:WaitForChild("Nozzle")

            -- Load animations
            local Animations = Assets[Name].Animations

            if not ShootTrack or not IdleTrack then
                ShootTrack = Humanoid:LoadAnimation(Assets[Name].Animations.Shoot)
                if Animations:FindFirstChild("Idle") then
                    IdleTrack = Humanoid:LoadAnimation(Assets[Name].Animations.Idle)
                end
            end

            if IdleTrack then
                IdleTrack:Play()
            end

            -- Shooting
            local Debounce
            Services.ContextActionService:BindActionAtPriority(Name, function(_, State)
                if State == Enum.UserInputState.Begin then
                    if not Debounce then
                        Debounce = true

                        -- Play animation
                        ShootTrack.TimePosition = 0
                        ShootTrack:Play()
                        ShootTrack.Stopped:Wait()

                        -- Create and launch projectile
                        local MouseLook = Camera:ScreenPointToRay(Mouse.X, Mouse.Y)
                        local C0 = CFrame.new(Nozzle.WorldPosition) * CFrame.new(MouseLook.Origin, MouseLook.Origin + MouseLook.Direction).Rotation

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

            end, Enum.ContextActionPriority.High.Value, true, Enum.UserInputType.MouseButton1, Enum.KeyCode.ButtonR2)

            local Button = Services.ContextActionService:GetButton(Name)
            if Button then
                local Icon = Button:WaitForChild("ActionIcon")
                Icon.Image = "rbxassetid://10001729216"
            end

        end,

        Unequipped = function()
            if IdleTrack then IdleTrack:Stop() end
            ShootTrack:Stop()

            Services.ContextActionService:UnbindAction(Name)
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