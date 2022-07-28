local PhysicsService = game:GetService("PhysicsService")
local TweenService = game:GetService("TweenService")
local Zoo = {}


local Paths = require(script.Parent.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes
local UI = Paths.UI

local COOLDOWN = 1
local TURN_SPEED = 3 / (2 * math.pi) -- 3s / 360 deg
local WALK_SPEED = 5

local ANIMALS = {
    "Zebra#1",
    "Turtle#1",
    "Parrot#1",
    "Gorilla#1",
    "Lion#1",
    "Panda#1",
    "Capybara#1",
}

local Playing

local ActiveAnimals
local UnlockConn

local function LoadWalking(Upgrade)
    Playing = true
    ActiveAnimals += 1

    local Enclosure = Paths.Tycoon.Tycoon:WaitForChild(Upgrade)
    local WalkingPoints = Enclosure.WalkingPoints

    local Animal = Enclosure.Animal
    local Animator = Animal.AnimationController.Animator
    local AnimationTrack = Animator:LoadAnimation(Animal.AnimationController.Walk)

    task.spawn(function()
        local RootPart
        repeat
            RootPart = Animal.PrimaryPart
            task.wait()
        until RootPart

        -- Loading animal
        for _, BasePart in ipairs(Animal:GetChildren()) do
            if BasePart:IsA("BasePart") then
                BasePart.Anchored = BasePart == RootPart
                BasePart.CanCollide = false
            end
        end

        local CurrentPoint

        while Playing  do
            local PotentialNextPoints = WalkingPoints:GetChildren()
            local RootPart = Animal.PrimaryPart
            if #PotentialNextPoints == 4 and RootPart then
                -- Can't stay in the same place
                if CurrentPoint then
                    table.remove(PotentialNextPoints, table.find(PotentialNextPoints, CurrentPoint))
                end

                local NextPoint = PotentialNextPoints[math.random(1, #PotentialNextPoints)]

                local NextPos = NextPoint.Position
                local PosOffset = RootPart.CFrame:PointToObjectSpace(NextPos) * Vector3.new(1, 1, -1)
                local TurnAngle = math.atan2(PosOffset.Z, PosOffset.X) - (math.pi / 2)

                local LookTweenInfo = TweenInfo.new(TURN_SPEED * TurnAngle, Enum.EasingStyle.Linear)
                local LookTween = Paths.Services.TweenService:Create(RootPart, LookTweenInfo, {CFrame = RootPart.CFrame * CFrame.fromEulerAnglesYXZ(0, TurnAngle, 0)})
                LookTween:Play()

                LookTween.Completed:Wait()

                local Distance = math.abs( RootPart.CFrame:PointToObjectSpace(NextPos).Z)
                -- warn(Distance, Distance / WALK_SPEED)
                local WalkTweenInfo = TweenInfo.new(Distance / WALK_SPEED, Enum.EasingStyle.Linear)
                local WalkTween = Paths.Services.TweenService:Create(RootPart, WalkTweenInfo, {CFrame = RootPart.CFrame * CFrame.new(0, 0, -Distance)})

                AnimationTrack:Play()

                WalkTween:Play()
                WalkTween.Completed:Wait()

                AnimationTrack:Stop()

                CurrentPoint = NextPoint

            else
                CurrentPoint = nil
            end

            task.wait(COOLDOWN)
        end


    end)

    task.spawn(function()


    end)

end

local function Init()
    ActiveAnimals = 0

    local Data = Remotes.GetStat:InvokeServer("Tycoon")
    for _, Enclosure in ipairs(ANIMALS) do
        if Data[Enclosure] then
            LoadWalking(Enclosure)
        end
    end

    if ActiveAnimals ~= #ANIMALS then -- Potential for more to be unlocked in the future
        UnlockConn = Remotes.ButtonPurchased.OnClientEvent:Connect(function(_, Name)
            if table.find(ANIMALS, Name) then
                LoadWalking(Name)

                if ActiveAnimals == #ANIMALS then
                    UnlockConn:Disconnect()
                end
            end

        end)

    end

end

Init()

task.spawn(function()
    repeat task.wait() until Modules.Rebirths
    Modules.Rebirths.Rebirthed:Connect(function()
        Playing = false

        if UnlockConn then
            UnlockConn:Disconnect()
        end

    end)

end)

return Zoo