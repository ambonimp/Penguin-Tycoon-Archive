local Workspace = game:GetService("Workspace")
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
for Level, Enums in pairs(Modules.MiningDetails) do
    local Zone = Island.Zones[Level]
    for _, Mineable in ipairs(Zone.Mineables:GetChildren()) do
        Mineable:SetAttribute("CanMine", true) -- How i index them
        Mineable:SetAttribute("Health", MINE_MAX_HEALTH)
    end

    local Dividers = Zone:FindFirstChild("Dividers")
    if Dividers then
        local Enum = Modules.MiningDetails[Level-1]
        for _, Divider in ipairs(Dividers:GetChildren()) do
            if Divider:IsA("BasePart") then
                warn("GOOD")
                Divider.SurfaceGui.Top.Text = string.format("%s %s", Enums.Requirement, Enum.Plural or Enum.Ore .. "s")
            else
                warn("OH NO")
            end
        end
    end

end

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

        local Enums = Modules.MiningDetails[Level]
        local OresMinedThisLevel = Data.Mining.Mined[Enums.Ore] + 1

        Data.Mining.Mined[Enums.Ore] = OresMinedThisLevel

        local Earnings = Data.Income * Enums.EarningMultiplier * (Client:GetAttribute("Tool") == "Gold Pickaxe" and 2 or 1)
        Modules.Income:AddGems(Client, Earnings, "Mining")

        if Data.Mining.Level == Level then
            local NextLevel = Level + 1
            if Modules.MiningDetails[NextLevel] and OresMinedThisLevel >= Modules.MiningDetails[NextLevel].Requirement then
                -- warn("On level up")

                Data.Mining.Level = NextLevel
                -- Hat reward
                if NextLevel == 3 then
                    -- warn("Hard hat given outfit given")
                    Modules.Accessories:ItemAcquired(Client, "Hard Hat", "Accessory")
                end

                Remotes.MiningLevelUp:FireClient(Client, NextLevel)
            end

        end

        -- Exclusive outfit
        if Data.Mining.Mined["Diamond"] >= 2000 and not Data.Outfits["Miner"] then
            -- warn("Miner outfit given")
            Modules.Accessories:ItemAcquired(Client, "Miner", "Outfits")
        end

    end

end)

Remotes.MineTeleport.OnServerInvoke = function(Client, toIsland)
    local Character = Client.Character

    if Character then
        local SpawnPart = toIsland and Island.Spawn or Workspace.Tycoons[string.gsub(Client.Team.Name, " Island", "")].Spawn
        local CFrame = SpawnPart.CFrame + Vector3.new(0, 3, 0)
        Client:RequestStreamAroundAsync(CFrame.Position)
        Character:SetPrimaryPartCFrame(CFrame)
    end

end

task.spawn(function()
    require(game.ServerScriptService:WaitForChild("ChatServiceRunner").ChatService):RegisterProcessCommandsFunction("Commands", function(speaker, message)
        local player = game.Players[speaker]
        if player then
            local Data = Modules.PlayerData.sessionData[speaker]

            if string.find(message, "IronOre") then
                Data.Mining.Mined.Coal += 100
            elseif string.find(message, "GoldOre") then
                Data.Mining.Mined.Iron += 250
            elseif string.find(message, "RubyOre") then
                Data.Mining.Mined.Gold += 750
            elseif string.find(message, "EmeralOre") then
                Data.Mining.Mined.Ruby += 1250
            elseif string.find(message, "DiamondOre") then
                Data.Mining.Mined.Emerald += 1500
            elseif string.find(message, "OutfitOre") then
                Data.Mining.Mined.Diamond += 2000
            end

            return true

        else
            return false
        end
    end)

end)





return Pickaxe
