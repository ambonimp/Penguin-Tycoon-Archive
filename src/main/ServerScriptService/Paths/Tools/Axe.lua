local Axe = {}


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
        if Tree.Name == "GrandTree" then
            local max = Tree:GetAttribute("MaxHealth")
            local per = math.floor(h/max*100)/100
            Tree.PrimaryPart.BillboardGui.Frame.Frame:TweenSize(UDim2.fromScale(per,1),Enum.EasingDirection.In,Enum.EasingStyle.Linear,.1,true)
            Tree.PrimaryPart.BillboardGui.Frame.Text.Text = h.." / "..max
        end
        local Day = os.date("%A")
        local Mult = 1
        if Day == "Saturday" or Day == "Sunday" or Day == "Friday" then
            Mult = 2
        else
            Mult = 1
        end
        if h == 0 and Tree.Name == "GrandTree" then
            for v,amountofhits in pairs (HittingGrand) do
                pcall(function()
                    if game.Players:FindFirstChild(v) then
                        local Player = game.Players:FindFirstChild(v)
                        local Data = Modules.PlayerData.sessionData[Player.Name]
                        local Mult2 = 1
                        if Player:GetAttribute("Tool") == "Gold Axe" then
                            Mult2 = 2
                        end
                        if Tree.Name == "GrandTree" and Tree:GetAttribute("Health") == 0 then
                            if Data then
                                local PlayerIncome = math.floor(Data["Income"] * Data["Income Multiplier"])
                                local am = math.floor((PlayerIncome*(Mult*Mult2/10)))*amountofhits
                                
                                Modules.Income:AddMoney(Player,am)
                                Remotes.Axe:FireClient(Player,am,true)
                            elseif Player:GetAttribute("Income") then
                                local PlayerIncome = Player:GetAttribute("Income")
                                local am = math.floor((PlayerIncome*(Mult*Mult2/10)))*amountofhits
                                Modules.Income:AddMoney(Player,am)
                                Remotes.Axe:FireClient(Player,am,true)
                            end
                        end
                    end
                end)
            end
            HittingGrand = {}
            task.defer(function()
                for i = 59,0,-1 do
					if i < 10 then
						Tree.PrimaryPart.BillboardGui.Frame.Text.Text = "Respawning in: 0:0"..i
					else
						Tree.PrimaryPart.BillboardGui.Frame.Text.Text = "Respawning in: 0:"..i
					end
                    task.wait(1)
				end
				Tree.PrimaryPart.BillboardGui.Frame.Text.Text = "1000 / 1000"
            end)
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
function Axe.Equipped(player)
	
end

game.Players.PlayerRemoving:Connect(function(Player)
    if HittingGrand[Player.Name] then
        HittingGrand[Player.Name] = nil
    end
end)

Remotes.Axe.OnServerEvent:Connect(function(Player,Tree)
    local dis = 14
    if Tree then
        dis = Tree.Name ~= "GrandTree" and 12 or 14
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
            if Day == "Saturday" or Day == "Sunday" or Day == "Friday" then
                Mult = 2
            else
                Mult = 1
            end
            local Mult2 = 1
            if Player:GetAttribute("Tool") == "Gold Axe" then
                Mult2 = 2
            end
            local Div = Tree:GetAttribute("MaxHealth")
            if Tree.Name == "GrandTree" then
                Div = 50
                if HittingGrand[Player.Name] then
                    HittingGrand[Player.Name]+=1 
                else
                    HittingGrand[Player.Name] = 1
                end
            end
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
                Modules.Quests.GiveQuest(Player,"Collect","Woodcutting","Tree",1)
            end
        end
    end
end)


return Axe