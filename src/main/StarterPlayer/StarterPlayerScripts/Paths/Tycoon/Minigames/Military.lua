local Workspace = game:GetService("Workspace")
local ProximityPromptService = game:GetService("ProximityPromptService")
local Minigame = {}

local Paths = require(script.Parent.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes
local UI = Paths.UI



local UPGRADE_NAME = "Sergeant#1"
local DETAILS = {
    {Weapon = "Snowball Launcher",Instructions = "Shoot all of the penguins with the snowball launcher to get to the next stage!"},
    {Weapon = "Snow Grenade", Instructions = "Throw snownades at the polar bears to get to the next section!"},
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


local ReturnCFrame

-- Utility Functions --
local function HidePlayer(Player)
    local Char = Player.Character
    if Char then
        for _, BasePart in pairs(Char:GetDescendants()) do
            if BasePart:IsA("BasePart") then
                HiddenParts[BasePart] = BasePart.Transparency
                BasePart.Transparency = 1
            end
        end

        Char.DescendantAdded:Connect(function(Added)
            if Added:IsA("BasePart") then
                HiddenParts[Added] = Added.Transparency
                Added.Transparency = 1
            end
        end)

    end

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



-- Minigame Functions --
local function Level(Lvl)
    local Details = DETAILS[Lvl]
    local LevelCompleted


    InstructionFrame.Body.Text = Details.Instructions
    InstructionFrame.Visible = true
    Modules.Buttons:UIOn(CenterFrames, true)

    local StartTask
    StartTask = Round:GiveTask(InstructionFrame.Start.MouseButton1Down:Connect(function()
        Round[StartTask] = nil

        Modules.Buttons:UIOff(CenterFrames, true)
        InstructionFrame.Visible = false

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

                    local NewZoneTask
                    NewZoneTask= Round:GiveTask(Zone.Exit.PrimaryPart.Touched:Connect(function(Touched)
                        if Touched.Parent == Character then
                            Round[NewZoneTask] = nil
                            Level(Lvl + 1)
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

                    local Prompt = Instance.new("ProximityPrompt")
                    Prompt.HoldDuration = 0.25
                    Prompt.MaxActivationDistance = 15
                    Prompt.RequiresLineOfSight = false
                    Prompt.ActionText = "Rescue penguins"
                    Prompt.Parent = Cage.PrimaryPart
                    Round:GiveTask(Prompt)

                    Prompt.Triggered:Connect(function()
                        Cage:Destroy()

                        local RewardLbl = ResultFrame.Reward
                        RewardLbl.Value.Text = if ElepasedTime <= 35 then 3 else (if ElepasedTime <= 45 then 2 else (if ElepasedTime <= 60 then 1 else 0))

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

    end))

end

local function LoadUpgrade(Upgrade)
    local Prompt = Instance.new("ProximityPrompt")
	Prompt.HoldDuration = 0.25
	Prompt.MaxActivationDistance = 15
	Prompt.RequiresLineOfSight = false
	Prompt.ActionText = "Save the penguins"
	Prompt.Parent = Upgrade:WaitForChild("LapTop"):WaitForChild("Hitbox")

    Prompt.Triggered:Connect(function()
        Character = Paths.Player.Character
        if Character then
    		Prompt.Enabled = false

            -- Initialize round
            ElepasedTime = 0
            if not Remotes.MilitaryMinigame:InvokeServer("OnRoundBegan") then return end
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
    		Map.Parent = Workspace
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
                -- TODO: Minigame over screen
                if CenterFrames.Visible then
                    Modules.Buttons:UIOff(CenterFrames, true)
                end

                InstructionFrame.Visible = false
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

    		Prompt.Enabled = true

        end

    end)

end

if Remotes.GetStat:InvokeServer("Tycoon")[UPGRADE_NAME] then
    LoadUpgrade(Paths.Tycoon.Tycoon:WaitForChild(UPGRADE_NAME))
else
    local Conn
    Conn = Paths.Tycoon.Tycoon.ChildAdded:Connect(function(Added)
        if Added.Name == UPGRADE_NAME then
            Conn:Disconnect()
            LoadUpgrade(Added)
        end
    end)

end


return Minigame