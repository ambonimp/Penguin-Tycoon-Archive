local Pickaxe = {}

local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes


local IS_QA = game.GameId == 3425594443

local MINE_RESPAWN_RATE = 10
local MINE_MAX_HEALTH = 6

local RANDOM_REWARD_LIKELYHOOD = if IS_QA then 0.25 else 0.01

-- Spawning
local Island = workspace.Islands["Mining Island"]

-- Functions
function Pickaxe.Equipped(player)
end


-- Initializing
for Level in pairs(Modules.MiningDetails) do
    local Zone = Island.Zones[Level]
    for _, Mineable in ipairs(Zone.Mineables:GetChildren()) do
        Mineable:SetAttribute("CanMine", true) -- How i index them
        Mineable:SetAttribute("Health", MINE_MAX_HEALTH)
    end

    local Dividers = Zone:FindFirstChild("Dividers")
    if Dividers then
        Dividers:SetAttribute("Children", #Dividers:GetChildren())
    end

    task.spawn(function()
        local Dividers = Zone:FindFirstChild("Dividers")
        local Id = 1274261950
        if Dividers then
            for _, Divider in ipairs(Dividers:GetChildren()) do
                Divider.SurfaceGui.BASE.RobuxNotice.Text = "(Unlock now for R$249)"

                local Prompt = Instance.new("ProximityPrompt")
                Prompt.HoldDuration = 0.25
                Prompt.MaxActivationDistance = 30
                Prompt.RequiresLineOfSight = false
                Prompt.ActionText = "Unlock"
                Prompt.Parent = Divider

                Prompt.Triggered:Connect(function(Player)
                    local Data = Modules.PlayerData.sessionData[Player.Name]

                    if Data and Data.Mining.Level + 1 == Level then
                        Services.MPService:PromptProductPurchase(Player, Id)

                        local Conn
                        Conn = Services.MPService.PromptProductPurchaseFinished:Connect(function(UserId, _Id, Purchased)
                            if UserId == Player.UserId then
                                if Id == Id and Purchased then
                                    Data.Mining.Level = Level
                                    Remotes.MiningLevelUp:FireClient(Player, Level)
                                end
                                Conn:Disconnect()
                            end
                        end)

                    end

                end)

            end

        end

    end)

end

Island.GoldPickaxe.Model.Hitbox.ProximityPrompt.Triggered:Connect(function(Player)
    Modules.Purchasing:PurchaseItem(Player, "Gold Pickaxe#1", false)
end)

Remotes.Pickaxe.OnServerInvoke = function(Client, Mineable)
    local AwardedHat

    local Data = Modules.PlayerData.sessionData[Client.Name]
    if not Data then return end

    local Health = Mineable:GetAttribute("Health")
    local Level = tonumber(Mineable.Parent.Parent.Name)

    if Health > 0 and Level <= Data.Mining.Level then
        Health -= 1
        Mineable:SetAttribute("Health", Health)

        for _, Ore in ipairs(Mineable.Ores:GetChildren()) do
            if Ore.Transparency ~= 1 then
                Ore.Transparency = 1
                break
            end
        end

        if Health == 0 then
            task.delay(MINE_RESPAWN_RATE, function()
                for _, Ore in ipairs(Mineable.Ores:GetChildren()) do
                    Ore.Transparency = 0
                end
                Mineable:SetAttribute("Health", MINE_MAX_HEALTH)
            end)

            local RNG = math.random(1, math.max(2, math.random(100 * RANDOM_REWARD_LIKELYHOOD)))

            if RNG == 1 then
                if Modules.Accessories:ItemAcquired(Client, "Popcorn Hat", "Accessory") then
                    AwardedHat = "Popcorn Hat"
                end
            elseif RNG == 2 then
                if Modules.Accessories:ItemAcquired(Client, "Chicken Hat", "Accessory") then
                    AwardedHat = "Chicken Hat"
                end
            end

        end

        local Details = Modules.MiningDetails[Level]
        local OreMined = Details.Ore
        local OresMinedThisLevel = Data.Mining.Mined[OreMined] + 1

        Data.Mining.Mined[OreMined] = OresMinedThisLevel
        Data.Stats["Total Mined"] += 1

        if OreMined == "Diamond" then
            Modules.Achievements.Progress(Client, 32)
        end

        local Earnings = Data.Income * Data["Income Multiplier"] * Details.EarningMultiplier * (Client:GetAttribute("Tool") == "Gold Pickaxe" and 2 or 1)
        local mult = Modules.Pets.getBonus(Client,"Mining","Income")

		Earnings = math.floor(Earnings * mult)
        Modules.Income:AddMoney(Client, Earnings)

        if Data.Mining.Level == Level then
            local NextLevel = Level + 1
            if Modules.MiningDetails[NextLevel] and OresMinedThisLevel >= Modules.MiningDetails[NextLevel].Requirement then
                Data.Mining.Level = NextLevel

                Modules.Achievements.Progress(Client, 31)
                Remotes.MiningLevelUp:FireClient(Client, NextLevel)
            end

        end

        return AwardedHat

    end

end

Modules.Achievements.Reconciled:Connect(function(Data)
	Modules.Achievements.ReconcileSet(Data, 32, Data.Mining.Mined["Diamond"])
	Modules.Achievements.ReconcileSet(Data, 31, Data.Mining.Level)
end)

return Pickaxe
