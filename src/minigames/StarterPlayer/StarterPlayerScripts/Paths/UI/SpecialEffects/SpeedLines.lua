local SpeedLines = {}

--- Main Variables ---
local Paths = require(script.Parent.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes
local UIFx = Paths.UIFx




local MIN_RADIUS = 0.1
local MAX_RADIUS = 0.3
local MAX_DISTANCE = 0.4

local MAX_PARTICLE_LENGTH = 0.7
local MAX_PARTICLE_WIDTH = 0.015

local SPEED = 0.25
local MAX_RATE = 3


local Rate = 0
local Rand = Random.new()

local function Lerp(a, b, t)
    return a + (b - a) * t
end

local Camera = workspace.CurrentCamera

function SpeedLines:Play()
    local Character = game:GetService("Players").LocalPlayer.Character
    if Character then
        local Hrp = Character.HumanoidRootPart

        return Services.RunService.RenderStepped:Connect(function(dt)
            local Speed = Hrp.AssemblyLinearVelocity.Magnitude
            Rate = Lerp(Rate, math.clamp(Speed, 0, MAX_RATE), dt / 2)

            -- When camera is facing the direction you are moving in, everything is more visible
            local V1 = Camera.CFrame.LookVector
            local V2 = Hrp.CFrame.LookVector
            local Alpha = 1- math.min(1, math.acos(math.clamp(V1:Dot(V2),-1,1)) / (V1.Magnitude*V2.Magnitude)/(math.pi/2))

            if Rate ~= 0 then
                for i = 1, math.floor(Rate) do
                    local Thetha = Rand:NextNumber(0, math.pi * 2)

                    local Rng = Rand:NextNumber(MIN_RADIUS, MAX_RADIUS)
                    local Scale = Rng / MAX_RADIUS
                    local Ease = Rate / MAX_RATE

                    local x = math.cos(Thetha)
                    local y = -math.sin(Thetha)

                    local length = Scale * MAX_PARTICLE_LENGTH
                    local width = Scale * MAX_PARTICLE_WIDTH

                    local radius = Rng + length / 2


                    local Particle = Instance.new("ImageLabel")
                    Particle.BackgroundTransparency = 1
                    Particle.AnchorPoint = Vector2.new(0.5, 0.5)
                    Particle.Position = UDim2.fromScale(0.5, 0.5) + UDim2.fromScale(x * radius, y * radius)
                    Particle.Size = UDim2.fromScale(width, length)
                    Particle.Image = "rbxassetid://9119749106"
                    Particle.ImageTransparency = 1
                    Particle.Rotation = 270 - math.deg(Thetha)
                    Particle.Parent = UIFx

                    local Tween = Services.TweenService:Create(Particle,
                        TweenInfo.new(SPEED * Scale * Ease, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
                        {
                            Position = Particle.Position + UDim2.fromScale(x * MAX_DISTANCE * Scale, y * MAX_DISTANCE * Scale),
                            ImageTransparency = 1 - (math.pow(2.3, Scale * Ease) - 1) * Alpha
                        }
                    )

                    Tween.Completed:Connect(function()
                        Particle:Destroy()
                    end)

                    Tween:Play()
                end
            end
        end)
    end

end


return SpeedLines