local Chainsaw = {}

--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes

local Trees = {}
local HittingGrand = {}

function changeTransparency(model,t)
    if model then
        for i,v in pairs (model:GetChildren()) do
            if v:IsA("BasePart") then
                v.Transparency = t
                if v:GetAttribute("NoCollide") then
                    v.CanCollide = false
                else
                    v.CanCollide = t == 0
                end
            end
        end
    end
end


function ConnectTree(Tree)
    if Tree.Name == "GrandTree" then return end
    Trees[Tree] = true
    local w = 10
    if Tree.Name == "GrandTree" then
        w = 60
    end
    local c
    local lastChange = nil
    local max = Tree:GetAttribute("Health")
    c = Tree:GetAttributeChangedSignal("Health"):Connect(function()
        local h = Tree:GetAttribute("Health")
        local Day = os.date("%A")
        local Mult = 1
        if Day == "Saturday" or Day == "Sunday" or Day == "Friday" then
            Mult = 2
        else
            Mult = 1
        end
        lastChange = os.time()
        if h <= 0 then
            Tree.PrimaryPart.Down:Play()
            changeTransparency(Tree:FindFirstChild(1),1)
            changeTransparency(Tree:FindFirstChild(2),1)
            changeTransparency(Tree:FindFirstChild(3),0)
        elseif h > 1 and h < 3 then
            changeTransparency(Tree:FindFirstChild(1),1)
            changeTransparency(Tree:FindFirstChild(2),0)
            changeTransparency(Tree:FindFirstChild(3),1)
        end
        task.wait(w)
        if os.time()-lastChange > w-1 then
            Tree.PrimaryPart.Pop:Play()
            Tree:SetAttribute("Health",max) 
            changeTransparency(Tree:FindFirstChild(1),0)
            changeTransparency(Tree:FindFirstChild(2),1)
            changeTransparency(Tree:FindFirstChild(3),1)
        end
    end)

    Tree.AncestryChanged:Connect(function()
        Trees[Tree] = nil
        c:Disconnect()
    end)
    
end

--- Functions ---
function Chainsaw.Equipped(player)
	Modules.Tools.ToolFunctions.Axe.LoadPlayer(player)
end

game.Players.PlayerRemoving:Connect(function(Player)
    if HittingGrand[Player.Name] then
        HittingGrand[Player.Name] = nil
    end
end)

Remotes.Chainsaw.OnServerEvent:Connect(function(Player,Tree)
    if not  Modules.Tools.ToolFunctions.Axe.canCut(Player,Tree) then return end
    if (Tree and Tree.Name == "GrandTree") or Tree == nil or Tree.PrimaryPart == nil then return end
    local dis = Player:DistanceFromCharacter(Tree.PrimaryPart.Position)
    if Tree and Player.Character and Player.Character.PrimaryPart and Tree:GetAttribute("Health") > 0 and dis < 14 then
        if Trees[Tree] == nil then
            ConnectTree(Tree)
        end
        Tree:SetAttribute("Health",0) 
        if Tree:GetAttribute("Health") >= 0 then
            local Data = Modules.PlayerData.sessionData[Player.Name]
            local Day = os.date("%A")
            local Mult = 1
            if Day == "Saturday" or Day == "Sunday" or Day == "Friday" then
                Mult = 2
            else
                Mult = 1
            end
            local Mult2 = 2
            if Tree:GetAttribute("Income") then
                Mult = Mult * Tree:GetAttribute("Income")
            end
            local Div = 1
            if Data then
				local PlayerIncome = math.floor(Data["Income"] * Data["Income Multiplier"])
                local added = math.floor((PlayerIncome*Mult*Mult2)/Div)
                if added < 10 then
                    added = 10
                end
                local mult = Paths.Modules.Pets.getBonus(Player,"Woodcutting","Income")
                added = math.floor(added*mult)
                Modules.Income:AddMoney(Player,added,true)
                Remotes.Axe:FireClient(Player,added)
            elseif Player:GetAttribute("Income") then
                local added = math.floor((Player:GetAttribute("Income")*Mult*Mult2)/Div)
                if added < 10 then
                    added = 10
                end
                local mult = Paths.Modules.Pets.getBonus(Player,"Woodcutting","Income")
                added = math.floor(added*mult)
                Modules.Income:AddMoney(Player,added,true)
                Remotes.Axe:FireClient(Player,added)
            end
            if Tree:GetAttribute("Health") == 0 then
                Modules.Tools.ToolFunctions.Axe.checkUnlocked(Player,Tree)
                Modules.Tools.ToolFunctions.Axe.GiveRandom(Player)
                Modules.Quests.GiveQuest(Player,"Collect","Woodcutting","Tree",1)
            end
        end
    end
end)


return Chainsaw