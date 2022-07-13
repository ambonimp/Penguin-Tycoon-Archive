local DataStoreService = game:GetService("DataStoreService")
local Pickaxe = {}

local MINE_COOLDOWN = 1
local MINE_COOLDOWNbase = 1

--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes
local UI = Paths.UI
local ParticleSystem = require(Services.RStorage.Modules.FreshParticles)



local Island = workspace.Islands["Mining Island"]
local Camera = workspace.CurrentCamera

local Char, MineTrack, Hrp

local Rand = Random.new()

local GoldPickaxePurchaseConn
local FirstTeleport = false

--- Functions ---
function GetCFramer(Model)
    local Primary = Model.PrimaryPart
    local PrimaryCF = Primary.CFrame
    local Cache = {}

    for _,Child in ipairs(Model:GetDescendants()) do
        if (Child:IsA("BasePart") and Child ~= Primary) then
            Cache[Child] = PrimaryCF:ToObjectSpace(Child.CFrame)
        end
    end

    return function(desiredCf)
        Primary.CFrame = desiredCf
        for Part, Offset in pairs(Cache) do
            Part.CFrame = desiredCf * Offset
        end
    end

end

function TweenCFrame(Model, Info, Goal) -- cframe
    local CFramer = GetCFramer(Model)

    local Value = Instance.new("CFrameValue")
    Value.Name = "Tween"
    Value.Value = Model.PrimaryPart.CFrame
    Value.Parent = Model

    Value.Changed:Connect(function(new)
        CFramer(new)
    end)

    local Tween = Services.TweenService:Create(Value, Info, {Value = Goal})
    Tween.Completed:Connect(function()
        Value:Destroy()
    end)
    Tween:Play()
end

function EarningParticle(Earned)
    task.spawn(function()
        local Particle = Paths.UI.Center.TreeReward:Clone()
        Particle.Parent = Paths.UI.Center

        local InitSize = Particle.Size
        Particle.Size = UDim2.fromScale(0,0)
        Particle.Text = "+ $ "..Paths.Modules.Format:FormatComma(Earned)

        local w, w2 = 0.1, 1

        Particle.Position = UDim2.fromScale(math.random(25,75)/100, math.random(25,75)/100)
        local Tween = Paths.Services.TweenService:Create(Particle,TweenInfo.new(w),{Size = InitSize})
        Particle.Visible = true
        Tween:Play()

        task.wait(w2)

        Tween = Paths.Services.TweenService:Create(Particle,TweenInfo.new(w),{Size = UDim2.fromScale(0,0)})
        Tween:Play()

        task.wait(w)
        Particle:Destroy()
    end)

end

local function DestroyDividers(Level)
    local Dividers = Island.Zones:WaitForChild(Level):WaitForChild("Dividers", math.huge)
    Dividers:Destroy()
end

local function UpdateDividerText(Level)
    local Dividers = Island.Zones[Level]:FindFirstChild("Dividers")
    if Dividers then
        for _, Divider in ipairs(Dividers:GetChildren()) do
            local PrevDetails = Modules.MiningDetails[Level-1]
            local Remainder = Modules.MiningDetails[Level].Requirement - Remotes.GetStat:InvokeServer("Mining").Mined[PrevDetails.Ore]

            Divider.SurfaceGui.BASE.Top.Text = string.format("%s %s Ore", Remainder, PrevDetails.Ore)
        end

    end

end

local function Teleport(To)
    Modules.UIAnimations.BlinkTransition(function()
        Remotes.TeleportInternal:InvokeServer(To)
    end, true)
end


local function LoadCharacter(C)
    if not C then return end
    Char = C
    Hrp = Char:WaitForChild("HumanoidRootPart")

    local Hum = Char:WaitForChild("Humanoid")
    Hum:WaitForChild("Animator") -- So animations replicate
    MineTrack = Hum:LoadAnimation(Services.RStorage.Animations.Woodcutting)

end

local function LoadMine(Mine)
    repeat task.wait() until Mine.PrimaryPart

    local prompt = Instance.new("ProximityPrompt")
	prompt.HoldDuration = 0.25
	prompt.MaxActivationDistance = 50
	prompt.RequiresLineOfSight = false
	prompt.ActionText = "Visit mine"
	prompt.Parent = Mine.PrimaryPart

    prompt.Triggered:Connect(function()
        prompt.Enabled = false
        Teleport("Mining Island")
        prompt.Enabled = true


        if not FirstTeleport then
            FirstTeleport = false
            -- Initialize dividers
            local Level = Remotes.GetStat:InvokeServer("Mining").Level

            for i = 2, Level do
                DestroyDividers(i)
            end

            for i = Level + 1, #Modules.MiningDetails do
                UpdateDividerText(i)
            end

        end

    end)

end


--- Events ---
local LastMined = 0
task.spawn(function()
	while true do
		if string.match(Paths.Player:GetAttribute("Tool"), "Pickaxe") then
		    local Now = os.clock()
			if Now - LastMined >= MINE_COOLDOWN and Char and MineTrack then
			    LastMined = Now
                MINE_COOLDOWN = MINE_COOLDOWNbase / Remotes.GetBonus:InvokeServer("Mining","Speed")
 				local InBounds = workspace:GetPartBoundsInRadius((Char:GetPrimaryPartCFrame()*CFrame.new(0,0,-5)).Position,3)

				local Mining, Level
				for _, Part in ipairs(InBounds) do
                    local Mineable = Part.Parent.Parent
					if Mineable:GetAttribute("CanMine") and Mineable:GetAttribute("Health") > 0  then
                        Mining = Mineable
                        Level = tonumber(Mining.Parent.Parent.Name)
                        break
                    end
				end

                if Mining then
                    -- Special effects
                    local Earnings = game.Players.LocalPlayer:GetAttribute("Income") * Remotes.GetStat:InvokeServer("Income Multiplier") * Modules.MiningDetails[Level].EarningMultiplier * (Paths.Player:GetAttribute("Tool") == "Gold Pickaxe" and 2 or 1) * Remotes.GetBonus:InvokeServer("Mining","Income")
                    EarningParticle(math.floor(Earnings))

					Remotes.Pickaxe:FireServer(Mining)
                    local Particles = Mining.PrimaryPart:FindFirstChild("OnMine")
                    if not Particles then
                        Particles = Services.RStorage.Assets.MiningParticles.Attachment:Clone()
                        Particles.Parent = Mining.PrimaryPart
                        Particles.Name = "OnMine"
                    end

                    Particles.Flare:Emit(1)
                    Particles.Rays:Emit(3)


                    local Offset = Mining.PrimaryPart.CFrame + ((Hrp.CFrame.LookVector.Unit*Vector3.new(1, 0, 1)+Vector3.new(0, -1, 0))*Rand:NextNumber(1, 1.5))
                    TweenCFrame(Mining, TweenInfo.new(0.05, Enum.EasingStyle.Back, Enum.EasingDirection.InOut, 0, true), Offset)

                    MineTrack:Play(nil, nil, 1.25)
					MineTrack.Looped = false

                    Paths.Modules.Index.OreCollected(Level)
                    -- TODO: Sound

                    local NextLevel = Level + 1
                    if Modules.MiningDetails[NextLevel] then
                        UpdateDividerText(NextLevel)
                    end

				else
					MineTrack:Stop()
				end

			end

		elseif MineTrack then
			MineTrack:Stop()
		end

		task.wait()

	end

end)

LoadCharacter(Paths.Player.Character)
Paths.Player.CharacterAdded:Connect(LoadCharacter)
Paths.Player.CharacterRemoving:Connect(function()
    MineTrack = nil
    Char = nil
end)

function Init()
    if Remotes.GetStat:InvokeServer("Tycoon")["Mine#1"]then
        LoadMine(Paths.Tycoon.Tycoon:WaitForChild("Mine#1"))
    else
        local Conn
        Conn = Paths.Tycoon.Tycoon.ChildAdded:Connect(function(Child)
            if Child.Name == "Mine#1" then
                Conn:Disconnect()
                LoadMine(Child)
            end
        end)

    end

    -- Island
    task.spawn(function()
        -- Teleport back
        local prompt = Instance.new("ProximityPrompt")
    	prompt.HoldDuration = 0.25
    	prompt.MaxActivationDistance = 50
    	prompt.RequiresLineOfSight = false
    	prompt.ActionText = "Return home"
    	prompt.Parent = Island.Teleport:WaitForChild("Hitbox", math.huge)

    	prompt.Triggered:Connect(function()
            prompt.Enabled = false
            Teleport(Paths.Player.Name)
            prompt.Enabled = true
        end)

        local GoldPickaxe = Island.GoldPickaxe
        GoldPickaxe:WaitForChild("Loader", math.huge)
        if Remotes.GetStat:InvokeServer("Tycoon")["Gold Pickaxe#1"] then
            if GoldPickaxe:FindFirstChild("Model") then
                GoldPickaxe.Model:Destroy()
            end
        else
            GoldPickaxePurchaseConn = Remotes.ButtonPurchased.OnClientEvent:Connect(function(_, Button)
                if Button == "Gold Pickaxe#1" then
                    GoldPickaxePurchaseConn:Disconnect()
                    GoldPickaxePurchaseConn = nil

                    GoldPickaxe.Model:Destroy()
                end
            end)
        end

    end)

end

Init()
task.spawn(function()
    repeat task.wait() until Modules.Rebirths
    Modules.Rebirths.Rebirthed:Connect(function()
        Init()
    end)
end)
Remotes.MiningLevelUp.OnClientEvent:Connect(DestroyDividers)

return Pickaxe