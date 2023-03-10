local ProximityPromptService = game:GetService("ProximityPromptService")
local Minigame = {}

local Paths = require(script.Parent.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes
local UI = Paths.UI



local UPGRADE_NAME = "Sergeant#1"
local DETAILS = {
    {Weapon = "Snowball Launcher", Instructions = "Shoot all of the penguins with the snowball launcher to get to the next stage!"},
    {Weapon = "Snow Grenade", Instructions = "Throw snownades at the polar bears to get to the next stage!"},
    {Weapon = "Snowball Launcher", Instructions = "Kill the Boss Penguin to free the captured penguin!"}
}

local BOSS_HEALTH = 15

local Assets = Services.RStorage.Assets.MilitaryMinigame

local CenterFrames = UI.Center.MilitaryMinigame
local InstructionFrame = CenterFrames.Instructions
local ResultFrame = CenterFrames.Results
local StartFrame = CenterFrames.Start

local RoundFrame = UI.Full.MilitaryMinigame

local Character
local HiddenParts = {}

local Round = Modules.Maid.new()
local Map
local ElepasedTime

local Pointer

local ReturnCFrame

local function disableReset()
    Paths.Services.StarterGui:SetCore("ResetButtonCallback",false)
end

local function enableReset()
    Paths.Services.StarterGui:SetCore("ResetButtonCallback",true)
end

-- Utility Functions --
function HideCharacter(Char)
    if Char then
        for _, BasePart in pairs(Char:GetDescendants()) do
            if BasePart:IsA("BasePart") then
                HiddenParts[BasePart] = BasePart.Transparency
                BasePart.Transparency = 1
            end
        end

        Round:GiveTask(Char.DescendantAdded:Connect(function(Added)
            if Added:IsA("BasePart") then
                HiddenParts[Added] = Added.Transparency
                Added.Transparency = 1
            end
        end))

    end
end

local function HidePlayer(Player)
    HideCharacter(Player.Character)
    Round:GiveTask(Player.CharacterAdded:Connect(HideCharacter))
end

local function ToggleOtherUI(toggle)
    if not toggle then
        for _, Frame in ipairs(UI.Center:GetChildren()) do
            if Frame:IsA("Frame") or Frame:IsA("ImageLabel") then
                Frame.Visible = false
            end
        end

    end

	UI.Left.Visible = toggle
	UI.Right.Visible = toggle
	UI.Top.Visible = toggle
	-- UI.Bottom.Visible = toggle
end

local function PointTo(Destination)
    local Att0 = Instance.new("Attachment")
    Att0.Parent = Character.Main

    local Att1 = Instance.new("Attachment")
    Att1.Position -= Vector3.new(0, Destination.Size.Y * 0.4, 0)
    Att1.Parent = Destination

    local Beam = Services.RStorage.ClientDependency.Help.Pointer:Clone()
    Beam.Parent = Destination
    Beam.Attachment0 = Att0
    Beam.Attachment1 = Att1

    Pointer = Round:GiveTask(function()
        Att0:Destroy()
        Att1:Destroy()
        Beam:Destroy()
    end)

end

-- Minigame Functions --
local function Level(Lvl)
    local Details = DETAILS[Lvl]
    local LevelCompleted

    RoundFrame.Instructions.Text = Details.Instructions

    local Timer = RoundFrame.Timer.TextLabel
    Timer.Text = "0s"
    RoundFrame.Visible = true

    -- Countdown
    task.spawn(function()
        while not LevelCompleted and Map:IsDescendantOf(workspace) do
            ElepasedTime += task.wait()
            Timer.Text =  string.format("%.2fs", ElepasedTime)
        end
    end)


    local Zone = Map.Levels[Lvl]

    -- Attacking
    local Hit = 0
    local Enemies = Zone.Enemies:GetChildren()

    for _, Enemy in Enemies do
        local Highlight = Assets.Highlight:Clone()
        Highlight.Parent = Enemy
    end

    local Healthbar
    if Lvl == 3 then
        Healthbar = Assets.Healthbar:Clone()
        Healthbar.Parent = Enemies[1]

        Healthbar = Healthbar.BASE
    end


    local Tool = Details.Weapon
    Modules.Tools.UnhideTools({[Tool] = true})
    Remotes.Tools:FireServer("Equip Tool", Tool) -- Auto equips tool

    local ToolHandler = Modules.Tools.Handlers[Tool]
    ToolHandler.Damageables = Enemies

    local HitTask
    HitTask = Round:GiveTask(ToolHandler.Hit:Connect(function(Enemy)
        Hit += 1

        if Lvl < 3 then
            Enemy:Destroy()

            if Hit == #Enemies then
                -- Onto the next level
                LevelCompleted = true
                Zone.Exit.Model:Destroy() -- Tween it going down
                PointTo(Zone.Exit.PrimaryPart)

                local NewZoneTask
                NewZoneTask= Round:GiveTask(Zone.Exit.PrimaryPart.Touched:Connect(function(Touched)
                    if Touched.Parent == Character then
                        Round[NewZoneTask] = nil
                        Level(Lvl + 1)
                        Round[Pointer] = nil
                    end

                end))

            end

        else
            local Health = BOSS_HEALTH - Hit
            Healthbar.Bar:TweenSize(UDim2.fromScale(math.max(0, Health/BOSS_HEALTH), 1), Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.2, true)

            if Health == 0 then
                LevelCompleted = true
                Enemy:Destroy()

                local Cage = Zone.Cage
                PointTo(Cage.PrimaryPart)

                local Prompt = Instance.new("ProximityPrompt")
                Prompt.HoldDuration = 0.25
                Prompt.MaxActivationDistance = 15
                Prompt.RequiresLineOfSight = false
                Prompt.ActionText = "Rescue the penguin"
                Prompt.Parent = Cage.PrimaryPart
                Round:GiveTask(Prompt)

                Prompt.Triggered:Connect(function()
                    Round[Pointer] = nil
                    Cage:Destroy()

                    local RewardLbl = ResultFrame.Reward
                    RewardLbl.Value.Text = if ElepasedTime <= 45 then 3 else (if ElepasedTime <= 50 then 2 else (if ElepasedTime <= 60 then 1 else 0)) .. " Gems"

                    local ScoreLbl = ResultFrame.Time
                    ScoreLbl.Value.Text = Timer.Text
                    ScoreLbl.NewHighscore.Visible = ElepasedTime < Remotes.GetStat:InvokeServer("Military Minigame Score")


                    ResultFrame.Visible = true
                    Modules.Buttons:UIOn(CenterFrames, true)

                    Round:GiveTask(ResultFrame.Claim.MouseButton1Down:Connect(function()
                        Remotes.MilitaryMinigame:InvokeServer("OnRoundCompleted", ElepasedTime)

                        Modules.Buttons:UIOff(CenterFrames, true)

                        Modules.UIAnimations.BlinkTransition(function()
                            Character:SetPrimaryPartCFrame(ReturnCFrame)
                        end, true)

                        Round:Destroy()

                    end))

                end)

            end

        end

        if LevelCompleted then
            Round[HitTask] = nil

            Zone.Barriers:Destroy()

            Modules.Tools:HideTools()
            RoundFrame.Visible = false
        end

    end))


end

-- Open
Services.ProximityPrompt.PromptTriggered:Connect(function(Prompt, Player)
    if Prompt.ActionText == "Penguin Rescue" and Player == Paths.Player then
        Character = Paths.Player.Character
        if Character then
    		Prompt.Enabled = false

            -- Initialize round
            ElepasedTime = 0
            if not Remotes.MilitaryMinigame:InvokeServer("OnRoundBegan") then return end
            -- disableReset()
            Modules.Tools.HideTools()

            -- Hide all other players
            HiddenParts = {}
            for _, Player in pairs(game.Players:GetPlayers()) do
                if Player ~= Paths.Player then
                    HidePlayer(Player)
                end
            end

            Round:GiveTask(game.Players.PlayerAdded:Connect(HidePlayer))

            -- Create map, client side and teleport player there
    		Map = Assets.Map:Clone()
    		Map.Parent = workspace
            Round:GiveTask(Map)

            Modules.UIAnimations.BlinkTransition(function()
                ReturnCFrame = Character.PrimaryPart.CFrame
                Character:SetPrimaryPartCFrame(Map.Spawn.CFrame + Vector3.new(0, 3, 0))
            end, true)


            -- Open
            ToggleOtherUI(false)

            StartFrame.Visible = true
            Modules.Buttons:UIOn(CenterFrames, true)

            Round:GiveTask(StartFrame.Start.MouseButton1Down:Connect(function()
                StartFrame.Visible = false
                Modules.Buttons:UIOff(CenterFrames, true)

                Level(1)
            end))


            -- Offloading
            -- If character resets, round is over
            Round:GiveTask(Character.Humanoid.Died:Connect(function()
                Remotes.MilitaryMinigame:InvokeServer("OnRoundCancelled")
                Round:Destroy()
            end))

            -- Round over
            Round:GiveTask(function()
                if CenterFrames.Visible then
                    Modules.Buttons:UIOff(CenterFrames, true)
                end

                ResultFrame.Visible = false

                RoundFrame.Visible = false

                Modules.Tools.UnhideTools()
                ToggleOtherUI(true)

                for HiddenPart, Transparency in HiddenParts do
                    if HiddenPart:IsDescendantOf(workspace) then
                        HiddenPart.Transparency = Transparency
                    end
                end

                HiddenParts = nil

            end)
            -- enableReset()
    		Prompt.Enabled = true

        end

    end

end)

return Minigame