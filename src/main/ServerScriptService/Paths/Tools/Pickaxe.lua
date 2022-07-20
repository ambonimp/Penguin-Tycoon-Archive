local Pickaxe = {}

local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes


local MINE_RESPAWN_RATE = 10
local MINE_MAX_HEALTH = 6

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
                            if UserId == Player.UserId and _Id == Id then
                                if Purchased then
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

Remotes.Pickaxe.OnServerEvent:Connect(function(Client, Mineable)
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
        end

        local Details = Modules.MiningDetails[Level]
        local OresMinedThisLevel = Data.Mining.Mined[Details.Ore] + 1

        Data.Mining.Mined[Details.Ore] = OresMinedThisLevel
        Data.Stats["Total Mined"] += 1

        local Earnings = Data.Income * Data["Income Multiplier"] * Details.EarningMultiplier * (Client:GetAttribute("Tool") == "Gold Pickaxe" and 2 or 1)
        local mult = Modules.Pets.getBonus(Client,"Mining","Income")

		Earnings = math.floor(Earnings * mult)
        Modules.Income:AddMoney(Client, Earnings)

        if Data.Mining.Level == Level then
            local NextLevel = Level + 1
            if Modules.MiningDetails[NextLevel] and OresMinedThisLevel >= Modules.MiningDetails[NextLevel].Requirement then
                Data.Mining.Level = NextLevel
                -- Hat reward
                if NextLevel == 3 then
                    Modules.Accessories:ItemAcquired(Client, "Hard Hat", "Accessory")
                end

                Remotes.MiningLevelUp:FireClient(Client, NextLevel)
            end

        end

        -- Exclusive outfit
        if Data.Mining.Mined["Diamond"] >= 2000 and not Data.Outfits["Miner"] then
            Modules.Accessories:ItemAcquired(Client, "Miner", "Outfits")
        end

    end

end)


--[[ if game.PlaceId == 9118461324 then
    task.spawn(function()
        require(game.ServerScriptService:WaitForChild("ChatServiceRunner").ChatService):RegisterProcessCommandsFunction("Commands", function(speaker, message)
            local player = game.Players[speaker]
            if player then
                local Data = Modules.PlayerData.sessionData[speaker]

                if string.find(message, "IronOre") then
                    Data.Mining.Mined.Coal += 100
                elseif string.find(message, "GoldOre") then
                    Data.Mining.Mined.Iron += 350
                elseif string.find(message, "RubyOre") then
                    Data.Mining.Mined.Gold += 950
                elseif string.find(message, "EmeraldOre") then
                    Data.Mining.Mined.Ruby += 1250
                elseif string.find(message, "DiamondOre") then
                    Data.Mining.Mined.Emerald += 1750
                elseif string.find(message, "OutfitOre") then
                    Data.Mining.Mined.Diamond += 2000
                end

                return false
            else
                return false
            end

        end)

    end)

end *]]

return Pickaxe
