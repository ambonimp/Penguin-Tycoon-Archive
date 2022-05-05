local Axe = {}


--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes

local Trees = {}

function changeTransparency(model,t)
    if model then
        for i,v in pairs (model:GetChildren()) do
            if v:IsA("BasePart") then
                v.Transparency = t
                v.CanCollide = t == 0
            end
        end
    end
end


function ConnectTree(Tree)
    Trees[Tree] = true
    local c
    local lastChange = nil
    local max = Tree:GetAttribute("Health")
    c = Tree:GetAttributeChangedSignal("Health"):Connect(function()
        local h = Tree:GetAttribute("Health")
        lastChange = os.time()
        if h <= 0 then
            changeTransparency(Tree:FindFirstChild(1),1)
            changeTransparency(Tree:FindFirstChild(2),1)
            changeTransparency(Tree:FindFirstChild(3),0)
        elseif h > 1 and h < 3 then
            changeTransparency(Tree:FindFirstChild(1),1)
            changeTransparency(Tree:FindFirstChild(2),0)
            changeTransparency(Tree:FindFirstChild(3),1)
        end
        task.wait(10)
        if os.time()-lastChange > 9 then
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
function Axe.Equipped(player)
	
end

function CheckHealth(Tree)
    return Tree:GetAttribute("Health")
end

Remotes.Axe.OnServerEvent:Connect(function(Player,Tree)
    local dis = 30
    if Tree then
        dis = Tree.Name ~= "GrandTree" and 12 or 30
    end
    if Tree and Player.Character and Player.Character.PrimaryPart and Tree:GetAttribute("Health") > 0 and (Player.Character.PrimaryPart.Position-Tree.PrimaryPart.Position).magnitude < dis then
        if Trees[Tree] == nil then
            ConnectTree(Tree)
        end
        Tree:SetAttribute("Health",Tree:GetAttribute("Health") - 1) 
        if Tree:GetAttribute("Health") >= 0 then
            local Data = Modules.PlayerData.sessionData[Player.Name]
            local Day = os.date("%A")
            local Mult = 1
            if Day == "Saturday" or Day == "Sunday" then
                Mult = 2
            else
                Mult = 1
            end
            local Mult2 = 1
            if Player:GetAttribute("Tool") == "Gold Axe" then
                Mult2 = 2
            end
            if Data then
				local PlayerIncome = math.floor(Data["Income"] * Data["Income Multiplier"])
                Modules.Income:AddMoney(Player,math.floor((PlayerIncome*Mult*Mult2)/Tree:GetAttribute("MaxHealth")))
                Remotes.Axe:FireClient(Player,math.floor((PlayerIncome*Mult*Mult2)/Tree:GetAttribute("MaxHealth")))
            elseif Player:GetAttribute("Income") then
                Modules.Income:AddMoney(Player,math.floor((Player:GetAttribute("Income")*Mult*Mult2)/Tree:GetAttribute("MaxHealth")))
                Remotes.Axe:FireClient(Player,math.floor((Player:GetAttribute("Income")*Mult*Mult2)/Tree:GetAttribute("MaxHealth")))
            end
        end
    end
end)


return Axe