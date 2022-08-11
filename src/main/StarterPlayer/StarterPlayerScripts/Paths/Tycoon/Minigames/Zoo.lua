local CollectionService = game:GetService("CollectionService")
local NPCS = {}

local Paths = require(script.Parent.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes
local UI = Paths.UI

local COOLDOWN = 1
local TURN_SPEED = 3 / (2 * math.pi) -- 3s / 360 deg
local WALK_SPEED = 5

local NpcS = {
    "Zebra#1",
    "Turtle#1",
    "Parrot#1",
    "Gorilla#1",
    "Lion#1",
    "Panda#1",
    "Capybara#1",
}

local TAG = "NPC"

local function LoadWalking(Npc)
    local WalkingPoints = Npc.Parent:WaitForChild("WalkingPoints")
    local Animator = Npc:WaitForChild("AnimationController"):WaitForChild("Animator")
    local AnimationTrack = Animator:LoadAnimation(Npc.AnimationController.Walk)

    task.spawn(function()
        local RootPart
        repeat
            RootPart = Npc.PrimaryPart
            task.wait()
        until RootPart

        -- Loading Npc
        for _, BasePart in ipairs(Npc:GetChildren()) do
            if BasePart:IsA("BasePart") then
                BasePart.Anchored = BasePart == RootPart
                BasePart.CanCollide = false
            end
        end

        local CurrentPoint

        while Npc:IsDescendantOf(workspace) do
            local PotentialNextPoints = WalkingPoints:GetChildren()
            local RootPart = Npc.PrimaryPart
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

end

Paths.Services.CollectionService:GetInstanceAddedSignal(TAG):Connect(LoadWalking)
for _, Npc in ipairs(CollectionService:GetTagged(TAG)) do
    LoadWalking(Npc)
end


return NPCS