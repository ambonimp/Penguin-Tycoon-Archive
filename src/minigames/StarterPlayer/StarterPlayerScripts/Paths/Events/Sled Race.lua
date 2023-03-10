local SledRace = {}

--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes
local UI = Paths.UI


-- Variables
local EVENT_NAME = script.Name


local Config = Modules.EventsConfig[EVENT_NAME]
local EventValues = Services.RStorage.Modules.EventsConfig.Values
local Participants = Services.RStorage.Modules.EventsConfig.Participants
local Assets = Services.RStorage.Assets[EVENT_NAME]
local LightingPreset = Services.RStorage.LightingPresets[EVENT_NAME]

local PositionMap = UI.Right.EventUIs.SledRace




local Player = game:GetService("Players").LocalPlayer
local Controls = require(Player.PlayerScripts:WaitForChild("PlayerModule")):GetControls()

local Character = Player.Character
local CollectSounds
local RParams

local Camera = workspace.CurrentCamera

local Map
local Velocity, TurnVelocity

local FOVTween
local BlizzardEnabled, BlizzardTween

local Driving
local SpeedLines

local PositionIndicators
local UserThumbnails = {}


local function GetNormalIncline(RaycastResults)
    local V1 = Vector3.new(0, 1, 0)
    local V2 = RaycastResults.Normal
    return -math.acos(math.clamp(V1:Dot(V2),-1,1)) / (V1.Magnitude*V2.Magnitude)
end

local function ToggleBlizzard(Toggle)
    if BlizzardEnabled == Toggle then return end
    BlizzardEnabled = Toggle

    if BlizzardTween then
        BlizzardTween:Cancel()
    end
    if Toggle then
        BlizzardTween = Services.TweenService:Create(Services.Lighting.Atmosphere, TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Density = 0.45})
    else
        BlizzardTween = Services.TweenService:Create(Services.Lighting.Atmosphere, TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {Density = LightingPreset.Atmosphere.Density})
    end

    BlizzardTween.Completed:Connect(function()
        BlizzardTween = nil
    end)

    BlizzardTween:Play()

end

local function ClosePositionMap()
    if PositionIndicators then
        PositionMap.Visible = false
        for _, Indicator in ipairs(PositionIndicators) do
            Indicator:Destroy()
        end
    end
end

local function IncrementVelocity(Addend)
   Velocity = math.clamp(Velocity + Addend, Config.MinVelocity, Config.MaxVelocity)
end


--- Event Functions ---
function SledRace:InitiateEvent(Collectables)
    Map = workspace.Event["Event Map"]
    RParams = RaycastParams.new()
    RParams.FilterDescendantsInstances = Map.Course:GetChildren()
    RParams.FilterType = Enum.RaycastFilterType.Whitelist

    BlizzardEnabled = false

    -- Configs
    Velocity = Config.DefaultVelocity
    TurnVelocity = Config.TurnVelocity


    -- Collectables
    for Id, Collectable in ipairs(Collectables) do
        local Type =  Collectable.Type
        local Model = Collectable.Model

        for _, BasePart in ipairs(Model:GetDescendants()) do
            if BasePart:IsA("BasePart") then
                BasePart.Touched:Connect(function(Hit)
                    if  Hit.Parent ~= Character then return end

                    CollectSounds[Type]:Play()

                    local VelocityAddend
                    if Type == "Boost" then
                        VelocityAddend = Config.BoostVelocityAddend

                        -- Zoom out fx
                        if FOVTween then FOVTween:Cancel() end
                        local CancelComeback = (100 - Camera.FieldOfView)/30 -- Tween length is proportional to how much FOV is actually changing

                        FOVTween = Services.TweenService:Create(Camera, TweenInfo.new(Config.CollectableEffectDuration*0.5*CancelComeback, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
                            FieldOfView = 100
                        })
                        FOVTween.Completed:Connect(function() -- Revert
                            FOVTween = Services.TweenService:Create(Camera, TweenInfo.new(Config.CollectableEffectDuration*0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
                                FieldOfView = 70
                            })
                            FOVTween.Completed:Connect(function()
                                FOVTween = nil
                            end)
                            FOVTween:Play()
                        end)
                        FOVTween:Play()

                    else
                        VelocityAddend = -Config.ObstacleVelocityMinuend
                        -- TODO: Smoke particle
                    end

                    IncrementVelocity(VelocityAddend)
                    task.delay(Config.CollectableEffectDuration, function()
                        IncrementVelocity(-VelocityAddend)
                    end)

                    -- Notifiy server that scoop has been collected
                    Remotes.SledRace:FireServer("OnCollectableCollected", Id)

                    Model:Destroy()

                end)

            end

        end

    end

end

function SledRace:EventStarted()
    PositionMap.Visible = true

    local Sled = Character:WaitForChild("Sled")
    local SledSeatWeld = Sled.Seat.SeatWeld

    local PrimaryPart = Sled.PrimaryPart
    PrimaryPart.Dust.Enabled = true

    local LinearVelocity = PrimaryPart.LinearVelocity
    local AlignOrientation = PrimaryPart.AlignOrientation

    local Hrp = Character.HumanoidRootPart

    local SitCFrame = SledSeatWeld.C1
    local Steer = 0

    local Finished


    -- Sound
    CollectSounds = {}
    for _, Sound in ipairs(Assets.CollectSounds:GetChildren()) do
        Sound = Sound:Clone()
        Sound.Parent = Character

        CollectSounds[Sound.Name] = Sound
    end

    -- Moving
    SpeedLines = Paths.Modules.SpeedLines:Play()
    Driving = Services.RunService.Heartbeat:Connect(function(dt)
        local TurnSpeed = TurnVelocity * (dt * 2)

        local Results = assert(workspace:Raycast(Hrp.Position + Vector3.new(0, 50, 0), Vector3.new(0, -100, 0), RParams))
        local Incline = GetNormalIncline(Results)

        local SteerGoal = -Config.MaxSteerAngle * Controls:GetMoveVector().X
        Steer = Steer + (SteerGoal - Steer) * TurnSpeed

        local SteerThrottle = Steer/Config.MaxSteerAngle
        local Rotation = CFrame.fromEulerAnglesYXZ(Incline, 0, 0) * CFrame.fromEulerAnglesYXZ(0, Steer, 0)

        LinearVelocity.VectorVelocity = Rotation.LookVector.Unit * Velocity
        AlignOrientation.CFrame = Rotation

        SledSeatWeld.C1 = SitCFrame * CFrame.fromEulerAnglesYXZ(math.abs(SteerThrottle) * math.rad(10), SteerThrottle*math.rad(30), 0)-- Lean and roll

        if Results.Instance.Parent.Name == "Blizzard" then
            ToggleBlizzard(true)
        else
            ToggleBlizzard(false)
        end

    end)

    -- On Complete
    local Finishing
    local FinishLine = Map.FinishLine.PrimaryPart
    Finishing = FinishLine.Touched:Connect(function(hit)
        if not Finished and hit.Parent == Character then
            Finished = true

            Finishing:Disconnect()
            SpeedLines:Disconnect()

            LinearVelocity.MaxForce = 100
            Velocity = 0

            -- Effects
            PrimaryPart.Dust.Enabled = false

            for _, ParticleEmitter in ipairs(FinishLine:GetChildren()) do
                if ParticleEmitter:IsA("ParticleEmitter") then
                    ParticleEmitter:Emit(20)
                end
            end

            FinishLine.Cheering:Play()

            task.wait(2)
            Sled.PrimaryPart.Anchored = true
            Driving:Disconnect()

            Remotes.SledRace:FireServer("OnRaceFinished")

        end

    end)

    -- Progress bar on the left
    task.spawn(function()
        local Top = Map.StartingLine.PrimaryPart.CFrame
        local Distance = Top:PointToObjectSpace(FinishLine.Position).Z

        PositionIndicators = {}
        for _, Participant in ipairs(Participants:GetChildren()) do
            local RespectivePlayer = game.Players:FindFirstChild(Participant.Name)

            local Color = Color3.fromRGB(math.random(150, 255), math.random(150, 255), math.random(150, 255))

            local UserThumbnail = UserThumbnails[RespectivePlayer]
            if not UserThumbnail then
                UserThumbnail = Remotes.GetUserThumbnail:InvokeServer(RespectivePlayer)
                UserThumbnails[RespectivePlayer] = UserThumbnail
            end

            local Indicator = Assets.PositionIndicator:Clone()
            Indicator.Name = Participant.Name
            Indicator.BackgroundColor3 = Color

            local Thumbnail = Indicator.Thumbnail
            Thumbnail.Image = UserThumbnail
            Thumbnail.UIStroke.Color = Color
            Thumbnail.BackgroundColor3 = Color

            Indicator.Parent = PositionMap

            table.insert(PositionIndicators, Indicator)
        end

        while not Finished do
            for i = #PositionIndicators, 1, -1 do -- Used this type of loop cause we might remove, don't want to skip anything
                local Indicator = PositionIndicators[i]

                if Participants:FindFirstChild(Indicator.Name) then
                    local Char = game.Players:FindFirstChild(Indicator.Name).Character

                    local Position = Top:PointToObjectSpace(Char.PrimaryPart.Position).Z
                    Indicator.Position = UDim2.fromScale(1, math.clamp(1 - Position/Distance, 0, 1))
                else
                    Indicator:Destroy()
                    table.remove(PositionIndicators, i)
                end
            end
            task.wait()
        end

    end)

end

function SledRace:LeftEvent()
    if Driving then Driving:Disconnect() end
    if SpeedLines then SpeedLines:Disconnect() end

    ClosePositionMap()
end

function SledRace:EventEnded()
    ClosePositionMap()
end

Remotes.SledRace.OnClientEvent:Connect(function(Event, ...)
    local Params = table.pack(...)

    if Event == "Finished" then
        local Rankings = Params[1]
        Modules.EventsUI:UpdateRankings(Rankings)
    end

end)

Player.CharacterAdded:Connect(function(Char)
    Character = Char
end)

game.Players.PlayerRemoving:Connect(function(OtherPlayer)
    UserThumbnails[Player] = nil
end)

return SledRace